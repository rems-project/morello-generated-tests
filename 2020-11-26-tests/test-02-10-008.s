.section data0, #alloc, #write
	.zero 32
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2960
	.byte 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 928
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x10
	.zero 128
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0x20, 0x10
.data
check_data3:
	.byte 0xbe, 0x63, 0x3e, 0x78, 0x1d, 0xb4, 0x81, 0x5a, 0x65, 0x74, 0x3c, 0x54
.data
check_data4:
	.byte 0xc2
.data
check_data5:
	.byte 0xc2
.data
check_data6:
	.byte 0xc2, 0xc2
.data
check_data7:
	.byte 0x80, 0xb3, 0xc5, 0xc2, 0x35, 0xd8, 0xfd, 0x38, 0x02, 0xfa, 0x7d, 0x3c, 0x60, 0xfc, 0x5f, 0x48
	.byte 0xce, 0xeb, 0xf4, 0x28, 0xce, 0x6a, 0x7e, 0xbc, 0xc5, 0x29, 0x40, 0xfa, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000
	/* C1 */
	.octa 0x401000
	/* C3 */
	.octa 0x408b7c
	/* C16 */
	.octa 0x400000
	/* C22 */
	.octa 0xc00
	/* C28 */
	.octa 0xe00000008001
	/* C29 */
	.octa 0x1f7e
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc2c2
	/* C1 */
	.octa 0x401000
	/* C3 */
	.octa 0x408b7c
	/* C14 */
	.octa 0xc2c2c2c2
	/* C16 */
	.octa 0x400000
	/* C21 */
	.octa 0xffffffc2
	/* C22 */
	.octa 0xc00
	/* C26 */
	.octa 0xc2c2c2c2
	/* C28 */
	.octa 0xe00000008001
	/* C29 */
	.octa 0x2000
	/* C30 */
	.octa 0xfc4
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000003ffb00070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x783e63be // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:29 00:00 opc:110 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x5a81b41d // csneg:aarch64/instrs/integer/conditional/select Rd:29 Rn:0 o2:1 0:0 cond:1011 Rm:1 011010100:011010100 op:1 sf:0
	.inst 0x543c7465 // b_cond:aarch64/instrs/branch/conditional/cond cond:0101 0:0 imm19:0011110001110100011 01010100:01010100
	.zero 8180
	.inst 0x000000c2
	.zero 4092
	.inst 0x000000c2
	.zero 23416
	.inst 0x0000c2c2
	.zero 459540
	.inst 0xc2c5b380 // CVTP-C.R-C Cd:0 Rn:28 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x38fdd835 // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:21 Rn:1 10:10 S:1 option:110 Rm:29 1:1 opc:11 111000:111000 size:00
	.inst 0x3c7dfa02 // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:2 Rn:16 10:10 S:1 option:111 Rm:29 1:1 opc:01 111100:111100 size:00
	.inst 0x485ffc60 // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:0 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x28f4ebce // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:14 Rn:30 Rt2:11010 imm7:1101001 L:1 1010001:1010001 opc:00
	.inst 0xbc7e6ace // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:14 Rn:22 10:10 S:0 option:011 Rm:30 1:1 opc:01 111100:111100 size:10
	.inst 0xfa4029c5 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0101 0:0 Rn:14 10:10 cond:0010 imm5:00000 111010010:111010010 op:1 sf:1
	.inst 0xc2c21220
	.zero 553292
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b23 // ldr c3, [x25, #2]
	.inst 0xc2400f30 // ldr c16, [x25, #3]
	.inst 0xc2401336 // ldr c22, [x25, #4]
	.inst 0xc240173c // ldr c28, [x25, #5]
	.inst 0xc2401b3d // ldr c29, [x25, #6]
	.inst 0xc2401f3e // ldr c30, [x25, #7]
	/* Set up flags and system registers */
	mov x25, #0x30000000
	msr nzcv, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	ldr x25, =0x4
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603239 // ldr c25, [c17, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x82601239 // ldr c25, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x17, #0xf
	and x25, x25, x17
	cmp x25, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400331 // ldr c17, [x25, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400731 // ldr c17, [x25, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400b31 // ldr c17, [x25, #2]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2400f31 // ldr c17, [x25, #3]
	.inst 0xc2d1a5c1 // chkeq c14, c17
	b.ne comparison_fail
	.inst 0xc2401331 // ldr c17, [x25, #4]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc2401731 // ldr c17, [x25, #5]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2401b31 // ldr c17, [x25, #6]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc2401f31 // ldr c17, [x25, #7]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc2402331 // ldr c17, [x25, #8]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	.inst 0xc2402731 // ldr c17, [x25, #9]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402b31 // ldr c17, [x25, #10]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0xc2
	mov x17, v2.d[0]
	cmp x25, x17
	b.ne comparison_fail
	ldr x25, =0x0
	mov x17, v2.d[1]
	cmp x25, x17
	b.ne comparison_fail
	ldr x25, =0xc2c2c2c2
	mov x17, v14.d[0]
	cmp x25, x17
	b.ne comparison_fail
	ldr x25, =0x0
	mov x17, v14.d[1]
	cmp x25, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001028
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001bc4
	ldr x1, =check_data1
	ldr x2, =0x00001bc8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f7e
	ldr x1, =check_data2
	ldr x2, =0x00001f80
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040000c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00402000
	ldr x1, =check_data4
	ldr x2, =0x00402001
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00403000
	ldr x1, =check_data5
	ldr x2, =0x00403001
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00408b7c
	ldr x1, =check_data6
	ldr x2, =0x00408b7e
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00478e94
	ldr x1, =check_data7
	ldr x2, =0x00478eb4
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
