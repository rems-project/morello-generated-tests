.section data0, #alloc, #write
	.zero 2016
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00
	.zero 2064
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xe1, 0xbf, 0x94, 0xeb, 0xdf, 0x29, 0xc1, 0xc2, 0x1c, 0x30, 0xc0, 0xc2, 0x11, 0x2c, 0xde, 0xc2
	.byte 0xc6, 0x4f, 0x76, 0x82, 0x3a, 0xa7, 0x49, 0xf8, 0x42, 0xb3, 0xc5, 0xc2, 0x40, 0x7c, 0x72, 0xd2
	.byte 0xbf, 0x01, 0x12, 0x78, 0x22, 0x21, 0x50, 0xa2, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x120050000000000000000
	/* C9 */
	.octa 0x801000005a040204000000000000141e
	/* C13 */
	.octa 0x400000000003000500000000000020c0
	/* C14 */
	.octa 0x3fff800000000000000000000000
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x800000000001000700000000000017e8
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x803fffffbfc01c
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x801000005a040204000000000000141e
	/* C13 */
	.octa 0x400000000003000500000000000020c0
	/* C14 */
	.octa 0x3fff800000000000000000000000
	/* C17 */
	.octa 0x120050000000000000000
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x80000000000100070000000000001882
	/* C26 */
	.octa 0x8000000000001c
	/* C28 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005c02000000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xeb94bfe1 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:31 imm6:101111 Rm:20 0:0 shift:10 01011:01011 S:1 op:1 sf:1
	.inst 0xc2c129df // BICFLGS-C.CR-C Cd:31 Cn:14 1010:1010 opc:00 Rm:1 11000010110:11000010110
	.inst 0xc2c0301c // GCLEN-R.C-C Rd:28 Cn:0 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc2de2c11 // CSEL-C.CI-C Cd:17 Cn:0 11:11 cond:0010 Cm:30 11000010110:11000010110
	.inst 0x82764fc6 // ALDR-R.RI-64 Rt:6 Rn:30 op:11 imm9:101100100 L:1 1000001001:1000001001
	.inst 0xf849a73a // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:26 Rn:25 01:01 imm9:010011010 0:0 opc:01 111000:111000 size:11
	.inst 0xc2c5b342 // CVTP-C.R-C Cd:2 Rn:26 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xd2727c40 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:2 imms:011111 immr:110010 N:1 100100:100100 opc:10 sf:1
	.inst 0x781201bf // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:13 00:00 imm9:100100000 0:0 opc:00 111000:111000 size:01
	.inst 0xa2502122 // LDUR-C.RI-C Ct:2 Rn:9 00:00 imm9:100000010 0:0 opc:01 10100010:10100010
	.inst 0xc2c211e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400469 // ldr c9, [x3, #1]
	.inst 0xc240086d // ldr c13, [x3, #2]
	.inst 0xc2400c6e // ldr c14, [x3, #3]
	.inst 0xc2401074 // ldr c20, [x3, #4]
	.inst 0xc2401479 // ldr c25, [x3, #5]
	.inst 0xc240187e // ldr c30, [x3, #6]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0xc
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031e3 // ldr c3, [c15, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x826011e3 // ldr c3, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x15, #0xf
	and x3, x3, x15
	cmp x3, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006f // ldr c15, [x3, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240046f // ldr c15, [x3, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240086f // ldr c15, [x3, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400c6f // ldr c15, [x3, #3]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc240106f // ldr c15, [x3, #4]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc240146f // ldr c15, [x3, #5]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc240186f // ldr c15, [x3, #6]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc2401c6f // ldr c15, [x3, #7]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc240206f // ldr c15, [x3, #8]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc240246f // ldr c15, [x3, #9]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc240286f // ldr c15, [x3, #10]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc2402c6f // ldr c15, [x3, #11]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc240306f // ldr c15, [x3, #12]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001320
	ldr x1, =check_data0
	ldr x2, =0x00001330
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017e8
	ldr x1, =check_data1
	ldr x2, =0x000017f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b20
	ldr x1, =check_data2
	ldr x2, =0x00001b28
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001fe2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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
