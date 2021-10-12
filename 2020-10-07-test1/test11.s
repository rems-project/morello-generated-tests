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
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x41, 0x30, 0xc2, 0xc2, 0x20, 0x32, 0xc2, 0xc2
.data
check_data6:
	.byte 0xb1, 0xdd, 0xc2, 0xf2, 0xf1, 0x16, 0xc0, 0x5a, 0x3f, 0x58, 0x87, 0x38, 0x7f, 0xff, 0x74, 0x39
	.byte 0x67, 0xf0, 0x87, 0xa9, 0x50, 0x84, 0x4e, 0x38, 0x02, 0x14, 0x44, 0xbc, 0xdc, 0x11, 0xc1, 0xc2
	.byte 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x1028
	/* C3 */
	.octa 0x1000
	/* C7 */
	.octa 0x0
	/* C14 */
	.octa 0x4006c00900ffffffffffa001
	/* C17 */
	.octa 0x20008000143100060000000000403000
	/* C27 */
	.octa 0x1000
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1041
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x1110
	/* C3 */
	.octa 0x1078
	/* C7 */
	.octa 0x0
	/* C14 */
	.octa 0x4006c00900ffffffffffa001
	/* C16 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
	/* C28 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x20008000000100070000000000400009
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000600400000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23041 // CHKTGD-C-C 00001:00001 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c23220 // BLR-C-C 00000:00000 Cn:17 100:100 opc:01 11000010110000100:11000010110000100
	.zero 12280
	.inst 0xf2c2ddb1 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:17 imm16:0001011011101101 hw:10 100101:100101 opc:11 sf:1
	.inst 0x5ac016f1 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:17 Rn:23 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0x3887583f // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:1 10:10 imm9:001110101 0:0 opc:10 111000:111000 size:00
	.inst 0x3974ff7f // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:27 imm12:110100111111 opc:01 111001:111001 size:00
	.inst 0xa987f067 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:7 Rn:3 Rt2:11100 imm7:0001111 L:0 1010011:1010011 opc:10
	.inst 0x384e8450 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:16 Rn:2 01:01 imm9:011101000 0:0 opc:01 111000:111000 size:00
	.inst 0xbc441402 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:2 Rn:0 01:01 imm9:001000001 0:0 opc:01 111100:111100 size:10
	.inst 0xc2c111dc // GCLIM-R.C-C Rd:28 Cn:14 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xc2c21080
	.zero 1036252
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a2 // ldr c2, [x13, #2]
	.inst 0xc2400da3 // ldr c3, [x13, #3]
	.inst 0xc24011a7 // ldr c7, [x13, #4]
	.inst 0xc24015ae // ldr c14, [x13, #5]
	.inst 0xc24019b1 // ldr c17, [x13, #6]
	.inst 0xc2401dbb // ldr c27, [x13, #7]
	.inst 0xc24021bc // ldr c28, [x13, #8]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260308d // ldr c13, [c4, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260108d // ldr c13, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x4, #0xf
	and x13, x13, x4
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a4 // ldr c4, [x13, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24005a4 // ldr c4, [x13, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc24009a4 // ldr c4, [x13, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400da4 // ldr c4, [x13, #3]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc24011a4 // ldr c4, [x13, #4]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc24015a4 // ldr c4, [x13, #5]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc24019a4 // ldr c4, [x13, #6]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2401da4 // ldr c4, [x13, #7]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc24021a4 // ldr c4, [x13, #8]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc24025a4 // ldr c4, [x13, #9]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x4, v2.d[0]
	cmp x13, x4
	b.ne comparison_fail
	ldr x13, =0x0
	mov x4, v2.d[1]
	cmp x13, x4
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
	ldr x0, =0x00001028
	ldr x1, =check_data1
	ldr x2, =0x00001029
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001075
	ldr x1, =check_data2
	ldr x2, =0x00001076
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001078
	ldr x1, =check_data3
	ldr x2, =0x00001088
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001d3f
	ldr x1, =check_data4
	ldr x2, =0x00001d40
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400008
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00403000
	ldr x1, =check_data6
	ldr x2, =0x00403024
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
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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
