.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x14, 0x00, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x04, 0x00, 0x04, 0x80
.data
check_data2:
	.byte 0x44, 0x58, 0x50, 0xba, 0x00, 0xfa, 0xd8, 0xc2, 0xc2, 0xff, 0x5f, 0x48, 0x9f, 0x23, 0xec, 0xb8
	.byte 0xb4, 0xaa, 0x26, 0x22, 0x47, 0x82, 0x65, 0xa2, 0x2e, 0x20, 0x35, 0x78, 0x1b, 0x08, 0xd6, 0x9a
	.byte 0xe1, 0xb1, 0x8a, 0x5a, 0xed, 0x93, 0x3b, 0x4b, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1010
	/* C2 */
	.octa 0x8000000000000000
	/* C5 */
	.octa 0x80040004008000000000000038000000
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x80000700030000000000000000
	/* C18 */
	.octa 0x1010
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C21 */
	.octa 0x1400
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x1000
	/* C30 */
	.octa 0x1002
final_cap_values:
	/* C0 */
	.octa 0x80431000000000000000000000
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x80040004008000000000000038000000
	/* C6 */
	.octa 0x1
	/* C7 */
	.octa 0x800
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x80000700030000000000000000
	/* C18 */
	.octa 0x1010
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C21 */
	.octa 0x1400
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x1000
	/* C30 */
	.octa 0x1002
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc1000000c01c0050000000000005001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 80
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xba505844 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0100 0:0 Rn:2 10:10 cond:0101 imm5:10000 111010010:111010010 op:0 sf:1
	.inst 0xc2d8fa00 // SCBNDS-C.CI-S Cd:0 Cn:16 1110:1110 S:1 imm6:110001 11000010110:11000010110
	.inst 0x485fffc2 // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:2 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xb8ec239f // ldeor:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:28 00:00 opc:010 0:0 Rs:12 1:1 R:1 A:1 111000:111000 size:10
	.inst 0x2226aab4 // STLXP-R.CR-C Ct:20 Rn:21 Ct2:01010 1:1 Rs:6 1:1 L:0 001000100:001000100
	.inst 0xa2658247 // SWPL-CC.R-C Ct:7 Rn:18 100000:100000 Cs:5 1:1 R:1 A:0 10100010:10100010
	.inst 0x7835202e // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:14 Rn:1 00:00 opc:010 0:0 Rs:21 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x9ad6081b // udiv:aarch64/instrs/integer/arithmetic/div Rd:27 Rn:0 o1:0 00001:00001 Rm:22 0011010110:0011010110 sf:1
	.inst 0x5a8ab1e1 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:15 o2:0 0:0 cond:1011 Rm:10 011010100:011010100 op:1 sf:0
	.inst 0x4b3b93ed // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:13 Rn:31 imm3:100 option:100 Rm:27 01011001:01011001 S:0 op:1 sf:0
	.inst 0xc2c212e0
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
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400905 // ldr c5, [x8, #2]
	.inst 0xc2400d0a // ldr c10, [x8, #3]
	.inst 0xc240110c // ldr c12, [x8, #4]
	.inst 0xc2401510 // ldr c16, [x8, #5]
	.inst 0xc2401912 // ldr c18, [x8, #6]
	.inst 0xc2401d14 // ldr c20, [x8, #7]
	.inst 0xc2402115 // ldr c21, [x8, #8]
	.inst 0xc2402516 // ldr c22, [x8, #9]
	.inst 0xc240291c // ldr c28, [x8, #10]
	.inst 0xc2402d1e // ldr c30, [x8, #11]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032e8 // ldr c8, [c23, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826012e8 // ldr c8, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x23, #0xf
	and x8, x8, x23
	cmp x8, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400117 // ldr c23, [x8, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400517 // ldr c23, [x8, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400917 // ldr c23, [x8, #2]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc2400d17 // ldr c23, [x8, #3]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc2401117 // ldr c23, [x8, #4]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2401517 // ldr c23, [x8, #5]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2401917 // ldr c23, [x8, #6]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401d17 // ldr c23, [x8, #7]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2402117 // ldr c23, [x8, #8]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2402517 // ldr c23, [x8, #9]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2402917 // ldr c23, [x8, #10]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2402d17 // ldr c23, [x8, #11]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc2403117 // ldr c23, [x8, #12]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2403517 // ldr c23, [x8, #13]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2403917 // ldr c23, [x8, #14]
	.inst 0xc2d7a781 // chkeq c28, c23
	b.ne comparison_fail
	.inst 0xc2403d17 // ldr c23, [x8, #15]
	.inst 0xc2d7a7c1 // chkeq c30, c23
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
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
