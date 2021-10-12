.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8204b9e // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:30 Rn:28 10:10 S:0 option:010 Rm:0 1:1 opc:00 111000:111000 size:11
	.inst 0x3c18b3bd // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:29 Rn:29 00:00 imm9:110001011 0:0 opc:00 111100:111100 size:00
	.inst 0xb10804df // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:6 imm12:001000000001 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2d143bd // SCVALUE-C.CR-C Cd:29 Cn:29 000:000 opc:10 0:0 Rm:17 11000010110:11000010110
	.inst 0x39da2adc // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:22 imm12:011010001010 opc:11 111001:111001 size:00
	.zero 1004
	.inst 0x381ba740 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:26 01:01 imm9:110111010 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c04751 // CSEAL-C.C-C Cd:17 Cn:26 001:001 opc:10 0:0 Cm:0 11000010110:11000010110
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xa2618029 // SWPL-CC.R-C Ct:9 Rn:1 100000:100000 Cs:1 1:1 R:1 A:0 10100010:10100010
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a11 // ldr c17, [x16, #2]
	.inst 0xc2400e16 // ldr c22, [x16, #3]
	.inst 0xc240121a // ldr c26, [x16, #4]
	.inst 0xc240161c // ldr c28, [x16, #5]
	.inst 0xc2401a1d // ldr c29, [x16, #6]
	.inst 0xc2401e1e // ldr c30, [x16, #7]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x3c0000
	msr CPACR_EL1, x16
	ldr x16, =0x4
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =initial_DDC_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4130 // msr DDC_EL1, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601310 // ldr c16, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x24, #0xf
	and x16, x16, x24
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400218 // ldr c24, [x16, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400618 // ldr c24, [x16, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400a18 // ldr c24, [x16, #2]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2400e18 // ldr c24, [x16, #3]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2401218 // ldr c24, [x16, #4]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc2401618 // ldr c24, [x16, #5]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc2401a18 // ldr c24, [x16, #6]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2401e18 // ldr c24, [x16, #7]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2402218 // ldr c24, [x16, #8]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x24, v29.d[0]
	cmp x16, x24
	b.ne comparison_fail
	ldr x16, =0x0
	mov x24, v29.d[1]
	cmp x16, x24
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x24, 0x80
	orr x16, x16, x24
	ldr x24, =0x920000ab
	cmp x24, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001088
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001210
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f8b
	ldr x1, =check_data3
	ldr x2, =0x00001f8c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40
.data
check_data2:
	.byte 0x00, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0x00, 0x00, 0x40, 0x00, 0xd8
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x9e, 0x4b, 0x20, 0xf8, 0xbd, 0xb3, 0x18, 0x3c, 0xdf, 0x04, 0x08, 0xb1, 0xbd, 0x43, 0xd1, 0xc2
	.byte 0xdc, 0x2a, 0xda, 0x39
.data
check_data5:
	.byte 0x40, 0xa7, 0x1b, 0x38, 0x51, 0x47, 0xc0, 0xc2, 0xe0, 0x73, 0xc2, 0xc2, 0x29, 0x80, 0x61, 0xa2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xd8004000000080080000000000001200
	/* C17 */
	.octa 0x80ffffffffe001
	/* C22 */
	.octa 0xfffffffffffff976
	/* C26 */
	.octa 0x1000
	/* C28 */
	.octa 0x1080
	/* C29 */
	.octa 0x771a70000000000002000
	/* C30 */
	.octa 0x4000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xd8004000000080080000000000001200
	/* C9 */
	.octa 0x0
	/* C17 */
	.octa 0xfba
	/* C22 */
	.octa 0xfffffffffffff976
	/* C26 */
	.octa 0xfba
	/* C28 */
	.octa 0x1080
	/* C29 */
	.octa 0x771a70080ffffffffe001
	/* C30 */
	.octa 0x4000000000000000
initial_DDC_EL0_value:
	.octa 0x400000006001000200ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x40000000603200000000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000082000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001200
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001200
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001080
	.dword 0x0000000000001f80
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400414
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
