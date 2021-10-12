.section text0, #alloc, #execinstr
test_start:
	.inst 0x489ffe21 // stlrh:aarch64/instrs/memory/ordered Rt:1 Rn:17 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x4817fc13 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:19 Rn:0 Rt2:11111 o0:1 Rs:23 0:0 L:0 0010000:0010000 size:01
	.inst 0x38015021 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:1 00:00 imm9:000010101 0:0 opc:00 111000:111000 size:00
	.inst 0xbc123fd6 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:22 Rn:30 11:11 imm9:100100011 0:0 opc:00 111100:111100 size:10
	.inst 0x397345b6 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:22 Rn:13 imm12:110011010001 opc:01 111001:111001 size:00
	.zero 1004
	.inst 0xb83f23ff // 0xb83f23ff
	.inst 0x889f7ed9 // 0x889f7ed9
	.inst 0xa22383e0 // 0xa22383e0
	.inst 0xdac0013e // 0xdac0013e
	.inst 0xd4000001
	.zero 64492
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	ldr x0, =vector_table_el1
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc288c001 // msr CVBAR_EL1, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	msr ttbr0_el1, x0
	mov x0, #0xff
	msr mair_el3, x0
	msr mair_el1, x0
	ldr x0, =0x0d003519
	msr tcr_el3, x0
	ldr x0, =0x0000320000803519 // No cap effects, inner shareable, normal, outer write-back read-allocate write-allocate cacheable
	msr tcr_el1, x0
	isb
	tlbi alle3
	tlbi alle1
	dsb sy
	ldr x0, =0x30851035
	msr sctlr_el3, x0
	isb
	/* Write tags to memory */
	ldr x0, =initial_tag_locations
	mov x1, #1
tag_init_loop:
	ldr x2, [x0], #8
	cbz x2, tag_init_end
	.inst 0xc2400043 // ldr c3, [x2, #0]
	.inst 0xc2c18063 // sctag c3, c3, c1
	.inst 0xc2000043 // str c3, [x2, #0]
	b tag_init_loop
tag_init_end:
	/* Write general purpose registers */
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa3 // ldr c3, [x21, #2]
	.inst 0xc2400ead // ldr c13, [x21, #3]
	.inst 0xc24012b1 // ldr c17, [x21, #4]
	.inst 0xc24016b6 // ldr c22, [x21, #5]
	.inst 0xc2401ab9 // ldr c25, [x21, #6]
	.inst 0xc2401ebe // ldr c30, [x21, #7]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q22, =0x0
	/* Set up flags and system registers */
	ldr x21, =0x0
	msr SPSR_EL3, x21
	ldr x21, =initial_SP_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc28c4115 // msr CSP_EL1, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30d5d99f
	msr SCTLR_EL1, x21
	ldr x21, =0x3c0000
	msr CPACR_EL1, x21
	ldr x21, =0x0
	msr S3_0_C1_C2_2, x21 // CCTLR_EL1
	ldr x21, =0x4
	msr S3_3_C1_C2_2, x21 // CCTLR_EL0
	ldr x21, =initial_DDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884135 // msr DDC_EL0, c21
	ldr x21, =0x80000000
	msr HCR_EL2, x21
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601155 // ldr c21, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e4035 // msr CELR_EL3, c21
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002aa // ldr c10, [x21, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24006aa // ldr c10, [x21, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400aaa // ldr c10, [x21, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400eaa // ldr c10, [x21, #3]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc24012aa // ldr c10, [x21, #4]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc24016aa // ldr c10, [x21, #5]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc2401aaa // ldr c10, [x21, #6]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc2401eaa // ldr c10, [x21, #7]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x10, v22.d[0]
	cmp x21, x10
	b.ne comparison_fail
	ldr x21, =0x0
	mov x10, v22.d[1]
	cmp x21, x10
	b.ne comparison_fail
	/* Check system registers */
	ldr x21, =final_SP_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc29c410a // mrs c10, CSP_EL1
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	ldr x21, =final_PCC_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x21, 0x83
	orr x10, x10, x21
	ldr x21, =0x920000ab
	cmp x21, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001016
	ldr x1, =check_data1
	ldr x2, =0x00001017
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001110
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =fail_message
write_tube:
	ldr x1, =trickbox
write_tube_loop:
	ldrb w2, [x0], #1
	strb w2, [x1]
	b write_tube_loop
ok_message:
	.ascii "OK\n\004"
fail_message:
	.ascii "FAILED\n\004"

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x02, 0x00, 0x00, 0x00, 0x01, 0x00, 0x80, 0x40, 0x00, 0x10
.data
check_data3:
	.byte 0x21, 0xfe, 0x9f, 0x48, 0x13, 0xfc, 0x17, 0x48, 0x21, 0x50, 0x01, 0x38, 0xd6, 0x3f, 0x12, 0xbc
	.byte 0xb6, 0x45, 0x73, 0x39
.data
check_data4:
	.byte 0xff, 0x23, 0x3f, 0xb8, 0xd9, 0x7e, 0x9f, 0x88, 0xe0, 0x83, 0x23, 0xa2, 0x3e, 0x01, 0xc0, 0xda
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfff
	/* C1 */
	.octa 0x1000
	/* C3 */
	.octa 0x10004080000100000002100000000000
	/* C13 */
	.octa 0x801eb5b
	/* C17 */
	.octa 0xfff
	/* C22 */
	.octa 0x40000000000600000000000000001000
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x10dc
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C3 */
	.octa 0x10004080000100000002100000000000
	/* C13 */
	.octa 0x801eb5b
	/* C17 */
	.octa 0xfff
	/* C22 */
	.octa 0x40000000000600000000000000001000
	/* C23 */
	.octa 0x1
	/* C25 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0xc8100000000100050000000000001100
initial_DDC_EL0_value:
	.octa 0xc0000000580200010000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400001
final_SP_EL1_value:
	.octa 0xc8100000000100050000000000001100
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000061500050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
	esr_el1_dump_address:
	.dword 0

.section vector_table, #alloc, #execinstr
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b finish
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail

.section vector_table_el1, #alloc, #execinstr
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x020002b5 // add c21, c21, #0
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x020202b5 // add c21, c21, #128
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x020402b5 // add c21, c21, #256
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x020602b5 // add c21, c21, #384
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x020802b5 // add c21, c21, #512
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x020a02b5 // add c21, c21, #640
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x020c02b5 // add c21, c21, #768
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x020e02b5 // add c21, c21, #896
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x021002b5 // add c21, c21, #1024
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x021202b5 // add c21, c21, #1152
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x021402b5 // add c21, c21, #1280
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x021602b5 // add c21, c21, #1408
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x021802b5 // add c21, c21, #1536
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x021a02b5 // add c21, c21, #1664
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x021c02b5 // add c21, c21, #1792
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600d55 // ldr x21, [c10, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d55 // str x21, [c10, #0]
	ldr x21, =0x40400414
	mrs x10, ELR_EL1
	sub x21, x21, x10
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2aa // cvtp c10, x21
	.inst 0xc2d5414a // scvalue c10, c10, x21
	.inst 0x82600155 // ldr c21, [c10, #0]
	.inst 0x021e02b5 // add c21, c21, #1920
	.inst 0xc2c212a0 // br c21

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
