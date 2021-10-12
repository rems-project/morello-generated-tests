.section data0, #alloc, #write
	.zero 144
	.byte 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3936
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x19, 0x00
.data
check_data3:
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x97, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0xe2, 0x6b, 0xc0, 0x82, 0xde, 0x75, 0x16, 0x3c, 0x00, 0x60, 0x7f, 0xf8, 0xd5, 0x04, 0xc2, 0xc2
	.byte 0x46, 0x78, 0x2e, 0xe2, 0xf7, 0x77, 0x9e, 0x5a, 0x96, 0xdf, 0xe0, 0x28, 0x2d, 0x30, 0x2d, 0x78
	.byte 0x80, 0x10, 0xc2, 0xc2
.data
check_data7:
	.byte 0x41, 0x3b, 0x4c, 0xfa, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000400020000000000001880
	/* C1 */
	.octa 0xc0000000600404020000000000001000
	/* C4 */
	.octa 0x20008000bd06271f0000000000400080
	/* C6 */
	.octa 0x3fff800000000000000000000000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x400000000000c0000000000000001400
	/* C28 */
	.octa 0x80000000600000040000000000001024
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc0000000600404020000000000001000
	/* C2 */
	.octa 0x19
	/* C4 */
	.octa 0x20008000bd06271f0000000000400080
	/* C6 */
	.octa 0x3fff800000000000000000000000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x400000000000c0000000000000001367
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000600000040000000000000f28
initial_SP_EL3_value:
	.octa 0xffffffffffffe810
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004d00070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000070082000000000003fe88
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82c06be2 // ALDRSH-R.RRB-32 Rt:2 Rn:31 opc:10 S:0 option:011 Rm:0 0:0 L:1 100000101:100000101
	.inst 0x3c1675de // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:30 Rn:14 01:01 imm9:101100111 0:0 opc:00 111100:111100 size:00
	.inst 0xf87f6000 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:0 00:00 opc:110 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:11
	.inst 0xc2c204d5 // BUILD-C.C-C Cd:21 Cn:6 001:001 opc:00 0:0 Cm:2 11000010110:11000010110
	.inst 0xe22e7846 // ASTUR-V.RI-Q Rt:6 Rn:2 op2:10 imm9:011100111 V:1 op1:00 11100010:11100010
	.inst 0x5a9e77f7 // csneg:aarch64/instrs/integer/conditional/select Rd:23 Rn:31 o2:1 0:0 cond:0111 Rm:30 011010100:011010100 op:1 sf:0
	.inst 0x28e0df96 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:22 Rn:28 Rt2:10111 imm7:1000001 L:1 1010001:1010001 opc:00
	.inst 0x782d302d // ldseth:aarch64/instrs/memory/atomicops/ld Rt:13 Rn:1 00:00 opc:011 0:0 Rs:13 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xc2c21080 // BR-C-C 00000:00000 Cn:4 100:100 opc:00 11000010110000100:11000010110000100
	.zero 92
	.inst 0xfa4c3b41 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0001 0:0 Rn:26 10:10 cond:0011 imm5:01100 111010010:111010010 op:1 sf:1
	.inst 0xc2c21120
	.zero 1048440
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2400c66 // ldr c6, [x3, #3]
	.inst 0xc240106d // ldr c13, [x3, #4]
	.inst 0xc240146e // ldr c14, [x3, #5]
	.inst 0xc240187c // ldr c28, [x3, #6]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q6, =0x970000000080000000000000000002
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x3, #0x10000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x3085103f
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603123 // ldr c3, [c9, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601123 // ldr c3, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400069 // ldr c9, [x3, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400469 // ldr c9, [x3, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400869 // ldr c9, [x3, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400c69 // ldr c9, [x3, #3]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2401069 // ldr c9, [x3, #4]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401469 // ldr c9, [x3, #5]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc2401869 // ldr c9, [x3, #6]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401c69 // ldr c9, [x3, #7]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2402069 // ldr c9, [x3, #8]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2402469 // ldr c9, [x3, #9]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2402869 // ldr c9, [x3, #10]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x2
	mov x9, v6.d[0]
	cmp x3, x9
	b.ne comparison_fail
	ldr x3, =0x97000000008000
	mov x9, v6.d[1]
	cmp x3, x9
	b.ne comparison_fail
	ldr x3, =0x0
	mov x9, v30.d[0]
	cmp x3, x9
	b.ne comparison_fail
	ldr x3, =0x0
	mov x9, v30.d[1]
	cmp x3, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001024
	ldr x1, =check_data1
	ldr x2, =0x0000102c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001090
	ldr x1, =check_data2
	ldr x2, =0x00001092
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001100
	ldr x1, =check_data3
	ldr x2, =0x00001110
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001400
	ldr x1, =check_data4
	ldr x2, =0x00001401
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001880
	ldr x1, =check_data5
	ldr x2, =0x00001888
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400024
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400080
	ldr x1, =check_data7
	ldr x2, =0x00400088
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
