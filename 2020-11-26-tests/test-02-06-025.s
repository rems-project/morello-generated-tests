.section data0, #alloc, #write
	.zero 3984
	.byte 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 96
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x11
.data
check_data3:
	.byte 0x78, 0xfd, 0x1f, 0x88, 0x00, 0xb4, 0xae, 0xe2, 0x1f, 0x00, 0x20, 0x38, 0x18, 0x10, 0xc1, 0xc2
	.byte 0x3e, 0x84, 0x11, 0x9b, 0x69, 0xd2, 0xc0, 0xc2, 0xde, 0x97, 0x3d, 0x22, 0x2d, 0x60, 0x3e, 0x35
	.byte 0xbf, 0x83, 0xf3, 0xc2, 0x00, 0xf9, 0x7f, 0x88, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000002b0980050000000000000f91
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x4000000000000000000000000000
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x8c000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x4000000000000000000000000000
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x8c000000000
	/* C24 */
	.octa 0xffffffffffffffff
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000007020400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x881ffd78 // stlxr:aarch64/instrs/memory/exclusive/single Rt:24 Rn:11 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:10
	.inst 0xe2aeb400 // ALDUR-V.RI-S Rt:0 Rn:0 op2:01 imm9:011101011 V:1 op1:10 11100010:11100010
	.inst 0x3820001f // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:000 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c11018 // GCLIM-R.C-C Rd:24 Cn:0 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x9b11843e // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:30 Rn:1 Ra:1 o0:1 Rm:17 0011011000:0011011000 sf:1
	.inst 0xc2c0d269 // GCPERM-R.C-C Rd:9 Cn:19 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x223d97de // STLXP-R.CR-C Ct:30 Rn:30 Ct2:00101 1:1 Rs:29 1:1 L:0 001000100:001000100
	.inst 0x353e602d // cbnz:aarch64/instrs/branch/conditional/compare Rt:13 imm19:0011111001100000001 op:1 011010:011010 sf:0
	.inst 0xc2f383bf // BICFLGS-C.CI-C Cd:31 Cn:29 0:0 00:00 imm8:10011100 11000010111:11000010111
	.inst 0x887ff900 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:0 Rn:8 Rt2:11110 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0xc2c211c0
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
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e5 // ldr c5, [x15, #2]
	.inst 0xc2400de8 // ldr c8, [x15, #3]
	.inst 0xc24011eb // ldr c11, [x15, #4]
	.inst 0xc24015ed // ldr c13, [x15, #5]
	.inst 0xc24019f1 // ldr c17, [x15, #6]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851037
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031cf // ldr c15, [c14, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x826011cf // ldr c15, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
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
	.inst 0xc24001ee // ldr c14, [x15, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24005ee // ldr c14, [x15, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24009ee // ldr c14, [x15, #2]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc2400dee // ldr c14, [x15, #3]
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	.inst 0xc24011ee // ldr c14, [x15, #4]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc24015ee // ldr c14, [x15, #5]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc24019ee // ldr c14, [x15, #6]
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	.inst 0xc2401dee // ldr c14, [x15, #7]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc24021ee // ldr c14, [x15, #8]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc24025ee // ldr c14, [x15, #9]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x14, v0.d[0]
	cmp x15, x14
	b.ne comparison_fail
	ldr x15, =0x0
	mov x14, v0.d[1]
	cmp x15, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000107c
	ldr x1, =check_data1
	ldr x2, =0x00001080
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f91
	ldr x1, =check_data2
	ldr x2, =0x00001f92
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
