.section data0, #alloc, #write
	.zero 2416
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 1664
.data
check_data0:
	.byte 0x02, 0x10, 0x40, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 16
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x7f, 0x28, 0xdb, 0x9a, 0x55, 0xcc, 0xdb, 0x42, 0x19, 0xe4, 0xce, 0x38, 0x4e, 0xff, 0x3f, 0x42
	.byte 0x60, 0x01, 0x1f, 0xd6
.data
check_data7:
	.zero 1
.data
check_data8:
	.byte 0x42, 0x9c, 0x44, 0x82, 0x25, 0xa8, 0x76, 0x82, 0xef, 0x93, 0x56, 0x3a, 0xc0, 0xff, 0x9f, 0x88
	.byte 0x10, 0x33, 0x19, 0x78, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400f14
	/* C1 */
	.octa 0x80000000002140050000000000001240
	/* C2 */
	.octa 0x40000000000500030000000000001600
	/* C11 */
	.octa 0x480000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C24 */
	.octa 0x2011
	/* C26 */
	.octa 0x40000000580100010000000000001470
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x401002
	/* C1 */
	.octa 0x80000000002140050000000000001240
	/* C2 */
	.octa 0x40000000000500030000000000001600
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x480000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x101800000000000000000000000
	/* C24 */
	.octa 0x2011
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x40000000580100010000000000001470
	/* C30 */
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000200000080000000000000800
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001970
	.dword 0x0000000000001980
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9adb287f // asrv:aarch64/instrs/integer/shift/variable Rd:31 Rn:3 op2:10 0010:0010 Rm:27 0011010110:0011010110 sf:1
	.inst 0x42dbcc55 // LDP-C.RIB-C Ct:21 Rn:2 Ct2:10011 imm7:0110111 L:1 010000101:010000101
	.inst 0x38cee419 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:25 Rn:0 01:01 imm9:011101110 0:0 opc:11 111000:111000 size:00
	.inst 0x423fff4e // ASTLR-R.R-32 Rt:14 Rn:26 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xd61f0160 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:11 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 524268
	.inst 0x82449c42 // ASTR-R.RI-64 Rt:2 Rn:2 op:11 imm9:001001001 L:0 1000001001:1000001001
	.inst 0x8276a825 // ALDR-R.RI-32 Rt:5 Rn:1 op:10 imm9:101101010 L:1 1000001001:1000001001
	.inst 0x3a5693ef // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1111 0:0 Rn:31 00:00 cond:1001 Rm:22 111010010:111010010 op:0 sf:0
	.inst 0x889fffc0 // stlr:aarch64/instrs/memory/ordered Rt:0 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x78193310 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:24 00:00 imm9:110010011 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21280
	.zero 524264
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2400deb // ldr c11, [x15, #3]
	.inst 0xc24011ee // ldr c14, [x15, #4]
	.inst 0xc24015f0 // ldr c16, [x15, #5]
	.inst 0xc24019f8 // ldr c24, [x15, #6]
	.inst 0xc2401dfa // ldr c26, [x15, #7]
	.inst 0xc24021fe // ldr c30, [x15, #8]
	/* Set up flags and system registers */
	mov x15, #0x60000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260328f // ldr c15, [c20, #3]
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	.inst 0x8260128f // ldr c15, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x20, #0x3
	and x15, x15, x20
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f4 // ldr c20, [x15, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24005f4 // ldr c20, [x15, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24009f4 // ldr c20, [x15, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400df4 // ldr c20, [x15, #3]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc24011f4 // ldr c20, [x15, #4]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc24015f4 // ldr c20, [x15, #5]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc24019f4 // ldr c20, [x15, #6]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2401df4 // ldr c20, [x15, #7]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc24021f4 // ldr c20, [x15, #8]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc24025f4 // ldr c20, [x15, #9]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc24029f4 // ldr c20, [x15, #10]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc2402df4 // ldr c20, [x15, #11]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc24031f4 // ldr c20, [x15, #12]
	.inst 0xc2d4a7c1 // chkeq c30, c20
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
	ldr x0, =0x00001470
	ldr x1, =check_data1
	ldr x2, =0x00001474
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017e8
	ldr x1, =check_data2
	ldr x2, =0x000017ec
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001848
	ldr x1, =check_data3
	ldr x2, =0x00001850
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001970
	ldr x1, =check_data4
	ldr x2, =0x00001990
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fa4
	ldr x1, =check_data5
	ldr x2, =0x00001fa6
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400f14
	ldr x1, =check_data7
	ldr x2, =0x00400f15
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00480000
	ldr x1, =check_data8
	ldr x2, =0x00480018
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
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
