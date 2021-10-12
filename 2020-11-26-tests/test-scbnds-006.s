.section data0, #alloc, #write
	.zero 208
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3872
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0x20, 0x0f, 0x98, 0x72, 0x1e, 0x24, 0xdf, 0xc2, 0x31, 0x54, 0x6d, 0xe2, 0x00, 0x78, 0x8b, 0xf9
	.byte 0x04, 0x78, 0x5f, 0x3a, 0x20, 0x00, 0xc2, 0xc2, 0xac, 0x33, 0xc7, 0xc2, 0x21, 0x08, 0xc0, 0x5a
	.byte 0x40, 0x28, 0xd3, 0x9a, 0xfd, 0x07, 0xc0, 0xda, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x400000000000000000001003
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x3100000
	/* C12 */
	.octa 0xffffffffffffffff
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000022100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000500040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x72980f20 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1100000001111001 hw:00 100101:100101 opc:11 sf:0
	.inst 0xc2df241e // CPYTYPE-C.C-C Cd:30 Cn:0 001:001 opc:01 0:0 Cm:31 11000010110:11000010110
	.inst 0xe26d5431 // ALDUR-V.RI-H Rt:17 Rn:1 op2:01 imm9:011010101 V:1 op1:01 11100010:11100010
	.inst 0xf98b7800 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:0 imm12:001011011110 opc:10 111001:111001 size:11
	.inst 0x3a5f7804 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0100 0:0 Rn:0 10:10 cond:0111 imm5:11111 111010010:111010010 op:0 sf:0
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0xc2c733ac // RRMASK-R.R-C Rd:12 Rn:29 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x5ac00821 // rev:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:1 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0x9ad32840 // asrv:aarch64/instrs/integer/shift/variable Rd:0 Rn:2 op2:10 0010:0010 Rm:19 0011010110:0011010110 sf:1
	.inst 0xdac007fd // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:29 Rn:31 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c212c0
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc240053d // ldr c29, [x9, #1]
	/* Set up flags and system registers */
	mov x9, #0x10000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30851037
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032c9 // ldr c9, [c22, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x826012c9 // ldr c9, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x22, #0xf
	and x9, x9, x22
	cmp x9, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400136 // ldr c22, [x9, #0]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400536 // ldr c22, [x9, #1]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2400936 // ldr c22, [x9, #2]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2400d36 // ldr c22, [x9, #3]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0xc2c2
	mov x22, v17.d[0]
	cmp x9, x22
	b.ne comparison_fail
	ldr x9, =0x0
	mov x22, v17.d[1]
	cmp x9, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010d8
	ldr x1, =check_data0
	ldr x2, =0x000010da
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	/* Done print message */
	/* turn off MMU */
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
