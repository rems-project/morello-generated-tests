.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0x20, 0xa6, 0xc9, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0xe6, 0xdf, 0x5b, 0x82, 0xbf, 0x90, 0x71, 0xb5, 0xff, 0x33, 0x69, 0x78, 0xa9, 0x17, 0x2e, 0xc8
	.byte 0xf0, 0x23, 0x01, 0x02, 0x19, 0x0c, 0xfb, 0x22, 0xe1, 0x50, 0x91, 0x82, 0x08, 0x76, 0xd2, 0x39
	.byte 0x22, 0xd0, 0xc0, 0xc2, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x900000001007000b0000000000001090
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x200000000
	/* C7 */
	.octa 0xffffffffffb7d01d
	/* C9 */
	.octa 0x40400008420100000000000000400000
	/* C17 */
	.octa 0x204080084806100d0000000000484001
final_cap_values:
	/* C0 */
	.octa 0x900000001007000b0000000000000ff0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x200000000
	/* C7 */
	.octa 0xffffffffffb7d01d
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x40400008420100000000000000400000
	/* C14 */
	.octa 0x1
	/* C16 */
	.octa 0xc0000000102f10070000000000001068
	/* C17 */
	.octa 0x204080084806100d0000000000484001
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x40400000420100000000000000400000
	/* C30 */
	.octa 0x20008000800f00040000000000400005
initial_SP_EL3_value:
	.octa 0xc0000000102f10070000000000001020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000f00040000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000002001400500fffffffef9a0a1
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001090
	.dword 0x00000000000010a0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c9a620 // BLRS-C.C-C 00000:00000 Cn:17 001:001 opc:01 1:1 Cm:9 11000010110:11000010110
	.zero 540668
	.inst 0x825bdfe6 // ASTR-R.RI-64 Rt:6 Rn:31 op:11 imm9:110111101 L:0 1000001001:1000001001
	.inst 0xb57190bf // cbnz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:0111000110010000101 op:1 011010:011010 sf:1
	.inst 0x786933ff // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:011 o3:0 Rs:9 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc82e17a9 // stxp:aarch64/instrs/memory/exclusive/pair Rt:9 Rn:29 Rt2:00101 o0:0 Rs:14 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0x020123f0 // 0x020123f0
	.inst 0x22fb0c19 // LDP-CC.RIAW-C Ct:25 Rn:0 Ct2:00011 imm7:1110110 L:1 001000101:001000101
	.inst 0x829150e1 // ASTRB-R.RRB-B Rt:1 Rn:7 opc:00 S:1 option:010 Rm:17 0:0 L:0 100000101:100000101
	.inst 0x39d27608 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:8 Rn:16 imm12:010010011101 opc:11 111001:111001 size:00
	.inst 0xc2c0d022 // GCPERM-R.C-C Rd:2 Cn:1 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2c212a0
	.zero 507864
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e6 // ldr c6, [x15, #2]
	.inst 0xc2400de7 // ldr c7, [x15, #3]
	.inst 0xc24011e9 // ldr c9, [x15, #4]
	.inst 0xc24015f1 // ldr c17, [x15, #5]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851037
	msr SCTLR_EL3, x15
	ldr x15, =0x84
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032af // ldr c15, [c21, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x826012af // ldr c15, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f5 // ldr c21, [x15, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24005f5 // ldr c21, [x15, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24009f5 // ldr c21, [x15, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400df5 // ldr c21, [x15, #3]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc24011f5 // ldr c21, [x15, #4]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc24015f5 // ldr c21, [x15, #5]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc24019f5 // ldr c21, [x15, #6]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc2401df5 // ldr c21, [x15, #7]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc24021f5 // ldr c21, [x15, #8]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc24025f5 // ldr c21, [x15, #9]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc24029f5 // ldr c21, [x15, #10]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2402df5 // ldr c21, [x15, #11]
	.inst 0xc2d5a721 // chkeq c25, c21
	b.ne comparison_fail
	.inst 0xc24031f5 // ldr c21, [x15, #12]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc24035f5 // ldr c21, [x15, #13]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101e
	ldr x1, =check_data0
	ldr x2, =0x0000101f
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001022
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001090
	ldr x1, =check_data2
	ldr x2, =0x000010b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001505
	ldr x1, =check_data3
	ldr x2, =0x00001506
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e08
	ldr x1, =check_data4
	ldr x2, =0x00001e10
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00484000
	ldr x1, =check_data6
	ldr x2, =0x00484028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
