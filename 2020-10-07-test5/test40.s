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
	.byte 0x8b, 0xc8, 0xa8, 0x39, 0xc3, 0xff, 0x3f, 0x42, 0x5f, 0x43, 0xcd, 0xc2, 0x41, 0xd8, 0x88, 0x82
	.byte 0x42, 0x67, 0xbf, 0xc2, 0xa5, 0x00, 0x82, 0x1a, 0xe2, 0x07, 0x48, 0x78, 0xfc, 0x8b, 0xd8, 0xc2
	.byte 0x79, 0xb3, 0xc0, 0xc2, 0xde, 0x03, 0x9c, 0xf8, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000000100050000000000000000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x15cc
	/* C8 */
	.octa 0x27fffe
	/* C13 */
	.octa 0x4ffffc
	/* C24 */
	.octa 0x100040000000000000000
	/* C26 */
	.octa 0x8018122e50000000000000000
	/* C27 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x40000000000100050000000000001ef8
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x15cc
	/* C8 */
	.octa 0x27fffe
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x4ffffc
	/* C24 */
	.octa 0x100040000000000000000
	/* C25 */
	.octa 0x1
	/* C26 */
	.octa 0x8018122e50000000000000000
	/* C27 */
	.octa 0x3fff800000000000000000000000
	/* C28 */
	.octa 0x50007c
	/* C30 */
	.octa 0x40000000000100050000000000001ef8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000020c0200000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 128
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x39a8c88b // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:11 Rn:4 imm12:101000110010 opc:10 111001:111001 size:00
	.inst 0x423fffc3 // ASTLR-R.R-32 Rt:3 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2cd435f // SCVALUE-C.CR-C Cd:31 Cn:26 000:000 opc:10 0:0 Rm:13 11000010110:11000010110
	.inst 0x8288d841 // ALDRSH-R.RRB-64 Rt:1 Rn:2 opc:10 S:1 option:110 Rm:8 0:0 L:0 100000101:100000101
	.inst 0xc2bf6742 // ADD-C.CRI-C Cd:2 Cn:26 imm3:001 option:011 Rm:31 11000010101:11000010101
	.inst 0x1a8200a5 // csel:aarch64/instrs/integer/conditional/select Rd:5 Rn:5 o2:0 0:0 cond:0000 Rm:2 011010100:011010100 op:0 sf:0
	.inst 0x784807e2 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:31 01:01 imm9:010000000 0:0 opc:01 111000:111000 size:01
	.inst 0xc2d88bfc // CHKSSU-C.CC-C Cd:28 Cn:31 0010:0010 opc:10 Cm:24 11000010110:11000010110
	.inst 0xc2c0b379 // GCSEAL-R.C-C Rd:25 Cn:27 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xf89c03de // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:30 00:00 imm9:111000000 0:0 opc:10 111000:111000 size:11
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400182 // ldr c2, [x12, #0]
	.inst 0xc2400583 // ldr c3, [x12, #1]
	.inst 0xc2400984 // ldr c4, [x12, #2]
	.inst 0xc2400d88 // ldr c8, [x12, #3]
	.inst 0xc240118d // ldr c13, [x12, #4]
	.inst 0xc2401598 // ldr c24, [x12, #5]
	.inst 0xc240199a // ldr c26, [x12, #6]
	.inst 0xc2401d9b // ldr c27, [x12, #7]
	.inst 0xc240219e // ldr c30, [x12, #8]
	/* Set up flags and system registers */
	mov x12, #0x40000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850032
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030ec // ldr c12, [c7, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826010ec // ldr c12, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x7, #0xf
	and x12, x12, x7
	cmp x12, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400187 // ldr c7, [x12, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400587 // ldr c7, [x12, #1]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400987 // ldr c7, [x12, #2]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400d87 // ldr c7, [x12, #3]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2401187 // ldr c7, [x12, #4]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc2401587 // ldr c7, [x12, #5]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401987 // ldr c7, [x12, #6]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401d87 // ldr c7, [x12, #7]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2402187 // ldr c7, [x12, #8]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2402587 // ldr c7, [x12, #9]
	.inst 0xc2c7a741 // chkeq c26, c7
	b.ne comparison_fail
	.inst 0xc2402987 // ldr c7, [x12, #10]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402d87 // ldr c7, [x12, #11]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2403187 // ldr c7, [x12, #12]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ef8
	ldr x1, =check_data0
	ldr x2, =0x00001efc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
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
	ldr x0, =0x004ffffc
	ldr x1, =check_data3
	ldr x2, =0x004ffffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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
