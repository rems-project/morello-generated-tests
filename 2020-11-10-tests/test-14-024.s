.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x90, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xfe, 0x4b, 0xdf, 0xc2, 0x00, 0x08, 0xc0, 0xda, 0x1e, 0x74, 0x85, 0xb8, 0xf3, 0xf3, 0xc0, 0xc2
	.byte 0x31, 0xb0, 0x37, 0xf9, 0xc2, 0x8b, 0x52, 0x78, 0x5e, 0x05, 0xc4, 0xc2, 0xfd, 0xcf, 0x13, 0x78
	.byte 0x01, 0xd0, 0xc1, 0xc2, 0xea, 0x13, 0x6d, 0x38, 0xc0, 0x10, 0xc2, 0xc2, 0x00, 0x00
.data
check_data2:
	.byte 0x04, 0x01, 0x40, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xf8004e00
	/* C1 */
	.octa 0xffffffffffffa2c0
	/* C4 */
	.octa 0x3a0010020e00000000001
	/* C10 */
	.octa 0x800300070008000000000001
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C29 */
	.octa 0x90
final_cap_values:
	/* C0 */
	.octa 0x4e014f
	/* C1 */
	.octa 0x4e014f
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x3a0010020e00000000001
	/* C10 */
	.octa 0x90
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C29 */
	.octa 0x90
	/* C30 */
	.octa 0x300070008000000000001
initial_SP_EL3_value:
	.octa 0x12e6
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df4bfe // UNSEAL-C.CC-C Cd:30 Cn:31 0010:0010 opc:01 Cm:31 11000010110:11000010110
	.inst 0xdac00800 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:0 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xb885741e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:0 01:01 imm9:001010111 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c0f3f3 // GCTYPE-R.C-C Rd:19 Cn:31 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xf937b031 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:17 Rn:1 imm12:110111101100 opc:00 111001:111001 size:11
	.inst 0x78528bc2 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:30 10:10 imm9:100101000 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c4055e // BUILD-C.C-C Cd:30 Cn:10 001:001 opc:00 0:0 Cm:4 11000010110:11000010110
	.inst 0x7813cffd // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:29 Rn:31 11:11 imm9:100111100 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c1d001 // CPY-C.C-C Cd:1 Cn:0 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x386d13ea // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:10 Rn:31 00:00 opc:001 0:0 Rs:13 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xc2c210c0
	.zero 917708
	.inst 0x00400104
	.zero 130820
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400904 // ldr c4, [x8, #2]
	.inst 0xc2400d0a // ldr c10, [x8, #3]
	.inst 0xc240110d // ldr c13, [x8, #4]
	.inst 0xc2401511 // ldr c17, [x8, #5]
	.inst 0xc240191d // ldr c29, [x8, #6]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851037
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030c8 // ldr c8, [c6, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826010c8 // ldr c8, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400106 // ldr c6, [x8, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400506 // ldr c6, [x8, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400906 // ldr c6, [x8, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400d06 // ldr c6, [x8, #3]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2401106 // ldr c6, [x8, #4]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401506 // ldr c6, [x8, #5]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2401906 // ldr c6, [x8, #6]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2401d06 // ldr c6, [x8, #7]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2402106 // ldr c6, [x8, #8]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402506 // ldr c6, [x8, #9]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001220
	ldr x1, =check_data0
	ldr x2, =0x00001228
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004e00f8
	ldr x1, =check_data2
	ldr x2, =0x004e00fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
