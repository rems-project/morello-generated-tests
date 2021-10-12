.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x28, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xc1, 0x87, 0xc0, 0xc2, 0x43, 0x50, 0xc2, 0xc2
.data
check_data4:
	.byte 0x19, 0x10, 0xc5, 0xc2, 0x00, 0x80, 0x15, 0xa2, 0x38, 0x11, 0xc7, 0xc2, 0xfe, 0x23, 0x67, 0xc2
	.byte 0x60, 0x13, 0xc2, 0xc2
.data
check_data5:
	.byte 0x5a, 0x0c, 0x51, 0x79, 0x06, 0x18, 0x2a, 0xe2, 0x80, 0x03, 0xc0, 0xda, 0x20, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000000000000000000000115f
	/* C1 */
	.octa 0x20008000c40044110000000000408000
	/* C2 */
	.octa 0x2000800088078bce0000000000480000
	/* C9 */
	.octa 0x0
	/* C28 */
	.octa 0x1404000000000000
	/* C30 */
	.octa 0x40000000000000000
final_cap_values:
	/* C0 */
	.octa 0x2028
	/* C1 */
	.octa 0x20008000c40044110000000000408000
	/* C2 */
	.octa 0x2000800088078bce0000000000480000
	/* C9 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x1404000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xffffffffffff7800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000006000500ffffffff800001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001480
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c087c1 // CHKSS-_.CC-C 00001:00001 Cn:30 001:001 opc:00 1:1 Cm:0 11000010110:11000010110
	.inst 0xc2c25043 // RETR-C-C 00011:00011 Cn:2 100:100 opc:10 11000010110000100:11000010110000100
	.zero 32760
	.inst 0xc2c51019 // CVTD-R.C-C Rd:25 Cn:0 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xa2158000 // STUR-C.RI-C Ct:0 Rn:0 00:00 imm9:101011000 0:0 opc:00 10100010:10100010
	.inst 0xc2c71138 // RRLEN-R.R-C Rd:24 Rn:9 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xc26723fe // LDR-C.RIB-C Ct:30 Rn:31 imm12:100111001000 L:1 110000100:110000100
	.inst 0xc2c21360
	.zero 491500
	.inst 0x79510c5a // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:26 Rn:2 imm12:010001000011 opc:01 111001:111001 size:01
	.inst 0xe22a1806 // ASTUR-V.RI-Q Rt:6 Rn:0 op2:10 imm9:010100001 V:1 op1:00 11100010:11100010
	.inst 0xdac00380 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:0 Rn:28 101101011000000000000:101101011000000000000 sf:1
	.inst 0xc2c21020 // BR-C-C 00000:00000 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.zero 524272
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400882 // ldr c2, [x4, #2]
	.inst 0xc2400c89 // ldr c9, [x4, #3]
	.inst 0xc240109c // ldr c28, [x4, #4]
	.inst 0xc240149e // ldr c30, [x4, #5]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q6, =0x20000000000000000000000
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850032
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603364 // ldr c4, [c27, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601364 // ldr c4, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x27, #0xf
	and x4, x4, x27
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240009b // ldr c27, [x4, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240049b // ldr c27, [x4, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240089b // ldr c27, [x4, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400c9b // ldr c27, [x4, #3]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc240109b // ldr c27, [x4, #4]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc240149b // ldr c27, [x4, #5]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc240189b // ldr c27, [x4, #6]
	.inst 0xc2dba741 // chkeq c26, c27
	b.ne comparison_fail
	.inst 0xc2401c9b // ldr c27, [x4, #7]
	.inst 0xc2dba781 // chkeq c28, c27
	b.ne comparison_fail
	.inst 0xc240209b // ldr c27, [x4, #8]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x27, v6.d[0]
	cmp x4, x27
	b.ne comparison_fail
	ldr x4, =0x2000000
	mov x27, v6.d[1]
	cmp x4, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001200
	ldr x1, =check_data0
	ldr x2, =0x00001210
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001480
	ldr x1, =check_data1
	ldr x2, =0x00001490
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f80
	ldr x1, =check_data2
	ldr x2, =0x00001f90
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00408000
	ldr x1, =check_data4
	ldr x2, =0x00408014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00480000
	ldr x1, =check_data5
	ldr x2, =0x00480010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00480886
	ldr x1, =check_data6
	ldr x2, =0x00480888
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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

	.balign 128
vector_table:
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
