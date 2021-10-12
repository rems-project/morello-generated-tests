.section text0, #alloc, #execinstr
test_start:
	.inst 0x489ffe21 // stlrh:aarch64/instrs/memory/ordered Rt:1 Rn:17 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x4817fc13 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:19 Rn:0 Rt2:11111 o0:1 Rs:23 0:0 L:0 0010000:0010000 size:01
	.inst 0x38015021 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:1 00:00 imm9:000010101 0:0 opc:00 111000:111000 size:00
	.inst 0xbc123fd6 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:22 Rn:30 11:11 imm9:100100011 0:0 opc:00 111100:111100 size:10
	.inst 0x397345b6 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:22 Rn:13 imm12:110011010001 opc:01 111001:111001 size:00
	.inst 0xb83f23ff // 0xb83f23ff
	.inst 0x889f7ed9 // 0x889f7ed9
	.inst 0xa22383e0 // 0xa22383e0
	.inst 0xdac0013e // 0xdac0013e
	.inst 0xd4000001
	.zero 65496
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400903 // ldr c3, [x8, #2]
	.inst 0xc2400d0d // ldr c13, [x8, #3]
	.inst 0xc2401111 // ldr c17, [x8, #4]
	.inst 0xc2401519 // ldr c25, [x8, #5]
	.inst 0xc240191e // ldr c30, [x8, #6]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q22, =0x0
	/* Set up flags and system registers */
	ldr x8, =0x0
	msr SPSR_EL3, x8
	ldr x8, =initial_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884108 // msr CSP_EL0, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0x3c0000
	msr CPACR_EL1, x8
	ldr x8, =0x0
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x4
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601168 // ldr c8, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010b // ldr c11, [x8, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240050b // ldr c11, [x8, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240090b // ldr c11, [x8, #2]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc2400d0b // ldr c11, [x8, #3]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240110b // ldr c11, [x8, #4]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc240150b // ldr c11, [x8, #5]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc240190b // ldr c11, [x8, #6]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc2401d0b // ldr c11, [x8, #7]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x11, v22.d[0]
	cmp x8, x11
	b.ne comparison_fail
	ldr x8, =0x0
	mov x11, v22.d[1]
	cmp x8, x11
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298410b // mrs c11, CSP_EL0
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba501 // chkeq c8, c11
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
	ldr x0, =0x00001006
	ldr x1, =check_data1
	ldr x2, =0x00001008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001025
	ldr x1, =check_data2
	ldr x2, =0x00001026
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001710
	ldr x1, =check_data3
	ldr x2, =0x00001712
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001810
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001cd1
	ldr x1, =check_data5
	ldr x2, =0x00001cd2
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001ec0
	ldr x1, =check_data6
	ldr x2, =0x00001ec4
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400000
	ldr x1, =check_data7
	ldr x2, =0x40400028
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.zero 3280
	.byte 0x00, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 800
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x20
.data
check_data1:
	.byte 0x00, 0x01
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x80
.data
check_data5:
	.byte 0xf0
.data
check_data6:
	.zero 4
.data
check_data7:
	.byte 0x21, 0xfe, 0x9f, 0x48, 0x13, 0xfc, 0x17, 0x48, 0x21, 0x50, 0x01, 0x38, 0xd6, 0x3f, 0x12, 0xbc
	.byte 0xb6, 0x45, 0x73, 0x39, 0xff, 0x23, 0x3f, 0xb8, 0xd9, 0x7e, 0x9f, 0x88, 0xe0, 0x83, 0x23, 0xa2
	.byte 0x3e, 0x01, 0xc0, 0xda, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800
	/* C1 */
	.octa 0x100
	/* C3 */
	.octa 0x80020000000000000040800000000000
	/* C13 */
	.octa 0xf0
	/* C17 */
	.octa 0xf6
	/* C25 */
	.octa 0x20000000
	/* C30 */
	.octa 0x108d
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x100
	/* C3 */
	.octa 0x80020000000000000040800000000000
	/* C13 */
	.octa 0xf0
	/* C17 */
	.octa 0xf6
	/* C22 */
	.octa 0xf0
	/* C23 */
	.octa 0x1
	/* C25 */
	.octa 0x20000000
initial_SP_EL0_value:
	.octa 0x8f0
initial_DDC_EL0_value:
	.octa 0xd010000010070f170000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x8f0
final_PCC_value:
	.octa 0x20008000480000000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
