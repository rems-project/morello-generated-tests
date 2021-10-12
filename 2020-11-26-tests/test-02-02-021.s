.section data0, #alloc, #write
	.zero 96
	.byte 0x10, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 3984
.data
check_data0:
	.byte 0x10, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xfd, 0x01, 0xc0, 0xda, 0xa1, 0xbb, 0x8c, 0xb8, 0xfa, 0x7f, 0x5f, 0x42, 0x01, 0xd0, 0xd9, 0xc2
	.byte 0xdb, 0x7e, 0xb8, 0xb9, 0x1d, 0xc4, 0xd2, 0x38, 0xde, 0x1b, 0xf7, 0xc2, 0xe0, 0x13, 0xc0, 0xc2
	.byte 0xb4, 0x33, 0xc5, 0xc2, 0x3f, 0xac, 0x49, 0x38, 0x00, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x64, 0x00, 0x40, 0x00
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90000000000100050000000000001380
	/* C15 */
	.octa 0xbd3f920000000000
	/* C22 */
	.octa 0x4fc77c
	/* C23 */
	.octa 0x40000020
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4000fe
	/* C15 */
	.octa 0xbd3f920000000000
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x4fc77c
	/* C23 */
	.octa 0x40000020
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000800100060000000040000020
initial_SP_EL3_value:
	.octa 0x801000000001000500000000004fffe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001060
	.dword initial_cap_values + 0
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac001fd // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:29 Rn:15 101101011000000000000:101101011000000000000 sf:1
	.inst 0xb88cbba1 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:29 10:10 imm9:011001011 0:0 opc:10 111000:111000 size:10
	.inst 0x425f7ffa // ALDAR-C.R-C Ct:26 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2d9d001 // BLR-CI-C 1:1 0000:0000 Cn:0 100:100 imm7:1001110 110000101101:110000101101
	.inst 0xb9b87edb // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:27 Rn:22 imm12:111000011111 opc:10 111001:111001 size:10
	.inst 0x38d2c41d // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:0 01:01 imm9:100101100 0:0 opc:11 111000:111000 size:00
	.inst 0xc2f71bde // CVT-C.CR-C Cd:30 Cn:30 0110:0110 0:0 0:0 Rm:23 11000010111:11000010111
	.inst 0xc2c013e0 // GCBASE-R.C-C Rd:0 Cn:31 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2c533b4 // CVTP-R.C-C Rd:20 Cn:29 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x3849ac3f // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:1 11:11 imm9:010011010 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c21100
	.zero 654684
	.inst 0x00400064
	.zero 393844
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc240078f // ldr c15, [x28, #1]
	.inst 0xc2400b96 // ldr c22, [x28, #2]
	.inst 0xc2400f97 // ldr c23, [x28, #3]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	ldr x28, =0x84
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260311c // ldr c28, [c8, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260111c // ldr c28, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x8, #0xf
	and x28, x28, x8
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400388 // ldr c8, [x28, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400788 // ldr c8, [x28, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400b88 // ldr c8, [x28, #2]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc2400f88 // ldr c8, [x28, #3]
	.inst 0xc2c8a681 // chkeq c20, c8
	b.ne comparison_fail
	.inst 0xc2401388 // ldr c8, [x28, #4]
	.inst 0xc2c8a6c1 // chkeq c22, c8
	b.ne comparison_fail
	.inst 0xc2401788 // ldr c8, [x28, #5]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2401b88 // ldr c8, [x28, #6]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2401f88 // ldr c8, [x28, #7]
	.inst 0xc2c8a761 // chkeq c27, c8
	b.ne comparison_fail
	.inst 0xc2402388 // ldr c8, [x28, #8]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2402788 // ldr c8, [x28, #9]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001060
	ldr x1, =check_data0
	ldr x2, =0x00001070
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001380
	ldr x1, =check_data1
	ldr x2, =0x00001381
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
	ldr x0, =0x004000fe
	ldr x1, =check_data3
	ldr x2, =0x004000ff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0049fd88
	ldr x1, =check_data4
	ldr x2, =0x0049fd8c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004fffe0
	ldr x1, =check_data5
	ldr x2, =0x004ffff0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff8
	ldr x1, =check_data6
	ldr x2, =0x004ffffc
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
