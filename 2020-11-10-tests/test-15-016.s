.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xfe, 0x7f, 0x5f, 0x9b, 0xfe, 0x93, 0xc1, 0xc2, 0xbf, 0xc0, 0x1f, 0x1b, 0x5f, 0xfc, 0x6d, 0x79
	.byte 0xd6, 0x0d, 0xdf, 0x1a, 0xbd, 0x05, 0x53, 0x78, 0x1f, 0x6c, 0x7e, 0xf9, 0xaa, 0x5e, 0x04, 0xb8
	.byte 0x02, 0xd8, 0xdf, 0xc2, 0x80, 0xe1, 0x1f, 0x9b, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000ffffffffffffa008
	/* C2 */
	.octa 0x104
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x17fc
	/* C21 */
	.octa 0x1003
final_cap_values:
	/* C2 */
	.octa 0x800000000000000000000000
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x172c
	/* C21 */
	.octa 0x1048
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000300fffffffffe0001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b5f7ffe // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:31 Ra:11111 0:0 Rm:31 10:10 U:0 10011011:10011011
	.inst 0xc2c193fe // CLRTAG-C.C-C Cd:30 Cn:31 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x1b1fc0bf // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:5 Ra:16 o0:1 Rm:31 0011011000:0011011000 sf:0
	.inst 0x796dfc5f // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:2 imm12:101101111111 opc:01 111001:111001 size:01
	.inst 0x1adf0dd6 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:22 Rn:14 o1:1 00001:00001 Rm:31 0011010110:0011010110 sf:0
	.inst 0x785305bd // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:13 01:01 imm9:100110000 0:0 opc:01 111000:111000 size:01
	.inst 0xf97e6c1f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:0 imm12:111110011011 opc:01 111001:111001 size:11
	.inst 0xb8045eaa // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:10 Rn:21 11:11 imm9:001000101 0:0 opc:00 111000:111000 size:10
	.inst 0xc2dfd802 // ALIGNU-C.CI-C Cd:2 Cn:0 0110:0110 U:1 imm6:111111 11000010110:11000010110
	.inst 0x9b1fe180 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:0 Rn:12 Ra:24 o0:1 Rm:31 0011011000:0011011000 sf:1
	.inst 0xc2c21260
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400aea // ldr c10, [x23, #2]
	.inst 0xc2400eed // ldr c13, [x23, #3]
	.inst 0xc24012f5 // ldr c21, [x23, #4]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851037
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603277 // ldr c23, [c19, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601277 // ldr c23, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f3 // ldr c19, [x23, #0]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc24006f3 // ldr c19, [x23, #1]
	.inst 0xc2d3a541 // chkeq c10, c19
	b.ne comparison_fail
	.inst 0xc2400af3 // ldr c19, [x23, #2]
	.inst 0xc2d3a5a1 // chkeq c13, c19
	b.ne comparison_fail
	.inst 0xc2400ef3 // ldr c19, [x23, #3]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc24012f3 // ldr c19, [x23, #4]
	.inst 0xc2d3a6c1 // chkeq c22, c19
	b.ne comparison_fail
	.inst 0xc24016f3 // ldr c19, [x23, #5]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001048
	ldr x1, =check_data0
	ldr x2, =0x0000104c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017fc
	ldr x1, =check_data1
	ldr x2, =0x000017fe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001802
	ldr x1, =check_data2
	ldr x2, =0x00001804
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ce0
	ldr x1, =check_data3
	ldr x2, =0x00001ce8
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
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
