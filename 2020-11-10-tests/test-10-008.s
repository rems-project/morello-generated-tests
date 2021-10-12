.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xe8, 0x33, 0x61, 0xb8, 0x88, 0xfc, 0x1f, 0x22, 0x5f, 0x07, 0xc0, 0xda, 0x60, 0xa8, 0x70, 0x71
	.byte 0xdf, 0x2b, 0x7f, 0x22, 0xc9, 0x13, 0xc5, 0xc2, 0xdf, 0x0f, 0x44, 0xf8, 0x71, 0x7d, 0x5f, 0x42
	.byte 0x1f, 0x1c, 0x9f, 0x2b, 0xde, 0x5b, 0xd9, 0xc2, 0x80, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x1800
	/* C11 */
	.octa 0x801000004002c004000000000040c100
	/* C30 */
	.octa 0x1020
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x1800
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x1020
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x801000004002c004000000000040c100
	/* C17 */
	.octa 0x0
	/* C30 */
	.octa 0x4000000000000
initial_SP_EL3_value:
	.octa 0x1800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200020000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000000600050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb86133e8 // ldset:aarch64/instrs/memory/atomicops/ld Rt:8 Rn:31 00:00 opc:011 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x221ffc88 // STLXR-R.CR-C Ct:8 Rn:4 (1)(1)(1)(1)(1):11111 1:1 Rs:31 0:0 L:0 001000100:001000100
	.inst 0xdac0075f // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:26 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0x7170a860 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:3 imm12:110000101010 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0x227f2bdf // LDXP-C.R-C Ct:31 Rn:30 Ct2:01010 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xc2c513c9 // CVTD-R.C-C Rd:9 Cn:30 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xf8440fdf // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:30 11:11 imm9:001000000 0:0 opc:01 111000:111000 size:11
	.inst 0x425f7d71 // ALDAR-C.R-C Ct:17 Rn:11 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x2b9f1c1f // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:31 Rn:0 imm6:000111 Rm:31 0:0 shift:10 01011:01011 S:1 op:0 sf:0
	.inst 0xc2d95bde // ALIGNU-C.CI-C Cd:30 Cn:30 0110:0110 U:1 imm6:110010 11000010110:11000010110
	.inst 0xc2c21280
	.zero 1048532
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
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e4 // ldr c4, [x15, #1]
	.inst 0xc24009eb // ldr c11, [x15, #2]
	.inst 0xc2400dfe // ldr c30, [x15, #3]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x3085103f
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260328f // ldr c15, [c20, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260128f // ldr c15, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
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
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24005f4 // ldr c20, [x15, #1]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc24009f4 // ldr c20, [x15, #2]
	.inst 0xc2d4a501 // chkeq c8, c20
	b.ne comparison_fail
	.inst 0xc2400df4 // ldr c20, [x15, #3]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc24011f4 // ldr c20, [x15, #4]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc24015f4 // ldr c20, [x15, #5]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc24019f4 // ldr c20, [x15, #6]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2401df4 // ldr c20, [x15, #7]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001068
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001810
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040c100
	ldr x1, =check_data4
	ldr x2, =0x0040c110
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
