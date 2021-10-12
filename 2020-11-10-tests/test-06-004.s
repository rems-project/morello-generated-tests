.section data0, #alloc, #write
	.byte 0x85, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x04, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xed, 0x6b, 0x7b, 0x82, 0x02, 0xfe, 0xdf, 0x08, 0x43, 0xe8, 0xc1, 0xc2, 0x63, 0x32, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x5f, 0x42, 0x71, 0x38, 0xfe, 0xfd, 0xbe, 0xa2, 0xa1, 0x58, 0x89, 0xaa, 0x01, 0x98, 0x93, 0x78
	.byte 0xd1, 0x8b, 0x4d, 0x69, 0x8a, 0xd0, 0x79, 0xe2, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x5000c3
	/* C4 */
	.octa 0x40000000000400000000000000001661
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0x800000000003000700000000004fdf9e
	/* C17 */
	.octa 0x4
	/* C18 */
	.octa 0x1000
	/* C19 */
	.octa 0x20008000000100070000000000410000
final_cap_values:
	/* C0 */
	.octa 0x5000c3
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x40000000000400000000000000001661
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0x800000000003000700000000004fdf9e
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x1000
	/* C19 */
	.octa 0x20008000000100070000000000410000
	/* C30 */
	.octa 0x1004
initial_SP_EL3_value:
	.octa 0x400000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004010c0180000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc100000000200020000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x827b6bed // ALDR-R.RI-32 Rt:13 Rn:31 op:10 imm9:110110110 L:1 1000001001:1000001001
	.inst 0x08dffe02 // ldarb:aarch64/instrs/memory/ordered Rt:2 Rn:16 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c1e843 // CTHI-C.CR-C Cd:3 Cn:2 1010:1010 opc:11 Rm:1 11000010110:11000010110
	.inst 0xc2c23263 // BLRR-C-C 00011:00011 Cn:19 100:100 opc:01 11000010110000100:11000010110000100
	.zero 65520
	.inst 0x3871425f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:18 00:00 opc:100 o3:0 Rs:17 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xa2befdfe // CASL-C.R-C Ct:30 Rn:15 11111:11111 R:1 Cs:30 1:1 L:0 1:1 10100010:10100010
	.inst 0xaa8958a1 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:5 imm6:010110 Rm:9 N:0 shift:10 01010:01010 opc:01 sf:1
	.inst 0x78939801 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:0 10:10 imm9:100111001 0:0 opc:10 111000:111000 size:01
	.inst 0x694d8bd1 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:17 Rn:30 Rt2:00010 imm7:0011011 L:1 1010010:1010010 opc:01
	.inst 0xe279d08a // ASTUR-V.RI-H Rt:10 Rn:4 op2:00 imm9:110011101 V:1 op1:01 11100010:11100010
	.inst 0xc2c212a0
	.zero 983012
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
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c4 // ldr c4, [x6, #1]
	.inst 0xc24008cf // ldr c15, [x6, #2]
	.inst 0xc2400cd0 // ldr c16, [x6, #3]
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc24014d2 // ldr c18, [x6, #5]
	.inst 0xc24018d3 // ldr c19, [x6, #6]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q10, =0x0
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032a6 // ldr c6, [c21, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826012a6 // ldr c6, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d5 // ldr c21, [x6, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24004d5 // ldr c21, [x6, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24008d5 // ldr c21, [x6, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400cd5 // ldr c21, [x6, #3]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc24010d5 // ldr c21, [x6, #4]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc24014d5 // ldr c21, [x6, #5]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc24018d5 // ldr c21, [x6, #6]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2401cd5 // ldr c21, [x6, #7]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc24020d5 // ldr c21, [x6, #8]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc24024d5 // ldr c21, [x6, #9]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc24028d5 // ldr c21, [x6, #10]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x21, v10.d[0]
	cmp x6, x21
	b.ne comparison_fail
	ldr x6, =0x0
	mov x21, v10.d[1]
	cmp x6, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001078
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000015fe
	ldr x1, =check_data2
	ldr x2, =0x00001600
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004006d8
	ldr x1, =check_data4
	ldr x2, =0x004006dc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00410000
	ldr x1, =check_data5
	ldr x2, =0x0041001c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004fdf9e
	ldr x1, =check_data6
	ldr x2, =0x004fdf9f
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffffc
	ldr x1, =check_data7
	ldr x2, =0x004ffffe
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
