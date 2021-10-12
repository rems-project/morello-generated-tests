.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x20, 0x44, 0x85, 0xf9, 0x21, 0x7c, 0x28, 0xe2, 0x20, 0xcb, 0x19, 0xe2, 0xc1, 0x13, 0xc2, 0xc2
	.byte 0x5e, 0x76, 0x97, 0x38, 0xd5, 0x93, 0xc1, 0xc2, 0x3f, 0x92, 0xc0, 0xc2, 0xe1, 0x88, 0xc5, 0xc2
	.byte 0x58, 0x81, 0x16, 0x82, 0xcc, 0xd4, 0xe1, 0xc2, 0x40, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000005000000100000000004002f9
	/* C5 */
	.octa 0x24039007000080000000a001
	/* C6 */
	.octa 0x400000002006000ffffffffffff23000
	/* C7 */
	.octa 0xf802f0000c0840000de00
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x4fc000
	/* C25 */
	.octa 0x80000000000500070000000000001861
	/* C30 */
	.octa 0x3fff800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xf802f0000c0840000de00
	/* C5 */
	.octa 0x24039007000080000000a001
	/* C6 */
	.octa 0x400000002006000ffffffffffff23000
	/* C7 */
	.octa 0xf802f0000c0840000de00
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x4fbf77
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x80000000000500070000000000001861
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb0108000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf9854420 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:1 imm12:000101010001 opc:10 111001:111001 size:11
	.inst 0xe2287c21 // ALDUR-V.RI-Q Rt:1 Rn:1 op2:11 imm9:010000111 V:1 op1:00 11100010:11100010
	.inst 0xe219cb20 // ALDURSB-R.RI-64 Rt:0 Rn:25 op2:10 imm9:110011100 V:0 op1:00 11100010:11100010
	.inst 0xc2c213c1 // CHKSLD-C-C 00001:00001 Cn:30 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x3897765e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:18 01:01 imm9:101110111 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c193d5 // CLRTAG-C.C-C Cd:21 Cn:30 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c0923f // GCTAG-R.C-C Rd:31 Cn:17 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc2c588e1 // CHKSSU-C.CC-C Cd:1 Cn:7 0010:0010 opc:10 Cm:5 11000010110:11000010110
	.inst 0x82168158 // LDR-C.I-C Ct:24 imm17:01011010000001010 1000001000:1000001000
	.inst 0xc2e1d4cc // ASTR-C.RRB-C Ct:12 Rn:6 1:1 L:0 S:1 option:110 Rm:1 11000010111:11000010111
	.inst 0xc2c21340
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400361 // ldr c1, [x27, #0]
	.inst 0xc2400765 // ldr c5, [x27, #1]
	.inst 0xc2400b66 // ldr c6, [x27, #2]
	.inst 0xc2400f67 // ldr c7, [x27, #3]
	.inst 0xc240136c // ldr c12, [x27, #4]
	.inst 0xc2401771 // ldr c17, [x27, #5]
	.inst 0xc2401b72 // ldr c18, [x27, #6]
	.inst 0xc2401f79 // ldr c25, [x27, #7]
	.inst 0xc240237e // ldr c30, [x27, #8]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850032
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260335b // ldr c27, [c26, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260135b // ldr c27, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x26, #0xf
	and x27, x27, x26
	cmp x27, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240037a // ldr c26, [x27, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240077a // ldr c26, [x27, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400b7a // ldr c26, [x27, #2]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc2400f7a // ldr c26, [x27, #3]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc240137a // ldr c26, [x27, #4]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc240177a // ldr c26, [x27, #5]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc2401b7a // ldr c26, [x27, #6]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc2401f7a // ldr c26, [x27, #7]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc240237a // ldr c26, [x27, #8]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc240277a // ldr c26, [x27, #9]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc2402b7a // ldr c26, [x27, #10]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc2402f7a // ldr c26, [x27, #11]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x26, v1.d[0]
	cmp x27, x26
	b.ne comparison_fail
	ldr x27, =0x0
	mov x26, v1.d[1]
	cmp x27, x26
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
	ldr x0, =0x000017fd
	ldr x1, =check_data1
	ldr x2, =0x000017fe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400380
	ldr x1, =check_data3
	ldr x2, =0x00400390
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004b40c0
	ldr x1, =check_data4
	ldr x2, =0x004b40d0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004fc000
	ldr x1, =check_data5
	ldr x2, =0x004fc001
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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
