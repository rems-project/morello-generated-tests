.section data0, #alloc, #write
	.zero 128
	.byte 0x02, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0xd8, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xe1, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x5e, 0x43, 0x3f, 0xf8, 0xae, 0xab, 0xdd, 0xc2, 0x7d, 0x11, 0xc0, 0xda, 0xe0, 0x73, 0xc2, 0xc2
	.byte 0xae, 0xcf, 0xa8, 0x82, 0x5f, 0x00, 0xf4, 0xf8, 0x80, 0x3e, 0x93, 0x78, 0x61, 0x98, 0xe1, 0xc2
	.byte 0xbd, 0x83, 0xca, 0xc2, 0xe2, 0x24, 0x8d, 0xe2, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xc0000000000200000000000000001080
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x172a
	/* C8 */
	.octa 0xffe
	/* C10 */
	.octa 0x1
	/* C11 */
	.octa 0x2a138b8b0000002e
	/* C20 */
	.octa 0x800000000007000f00000000004000df
	/* C26 */
	.octa 0x1000
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xffffffffffff82a8
	/* C1 */
	.octa 0x3
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x172a
	/* C8 */
	.octa 0xffe
	/* C10 */
	.octa 0x1
	/* C11 */
	.octa 0x2a138b8b0000002e
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0x800000000007000f0000000000400012
	/* C26 */
	.octa 0x1000
	/* C29 */
	.octa 0x2
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000500000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000201c0050080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf83f435e // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:26 00:00 opc:100 0:0 Rs:31 1:1 R:0 A:0 111000:111000 size:11
	.inst 0xc2ddabae // EORFLGS-C.CR-C Cd:14 Cn:29 1010:1010 opc:10 Rm:29 11000010110:11000010110
	.inst 0xdac0117d // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:29 Rn:11 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x82a8cfae // ASTR-V.RRB-S Rt:14 Rn:29 opc:11 S:0 option:110 Rm:8 1:1 L:0 100000101:100000101
	.inst 0xf8f4005f // ldadd:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:2 00:00 opc:000 0:0 Rs:20 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x78933e80 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:20 11:11 imm9:100110011 0:0 opc:10 111000:111000 size:01
	.inst 0xc2e19861 // SUBS-R.CC-C Rd:1 Cn:3 100110:100110 Cm:1 11000010111:11000010111
	.inst 0xc2ca83bd // SCTAG-C.CR-C Cd:29 Cn:29 000:000 0:0 10:10 Rm:10 11000010110:11000010110
	.inst 0xe28d24e2 // ALDUR-R.RI-32 Rt:2 Rn:7 op2:01 imm9:011010010 V:0 op1:10 11100010:11100010
	.inst 0xc2c211a0
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a63 // ldr c3, [x19, #2]
	.inst 0xc2400e67 // ldr c7, [x19, #3]
	.inst 0xc2401268 // ldr c8, [x19, #4]
	.inst 0xc240166a // ldr c10, [x19, #5]
	.inst 0xc2401a6b // ldr c11, [x19, #6]
	.inst 0xc2401e74 // ldr c20, [x19, #7]
	.inst 0xc240227a // ldr c26, [x19, #8]
	.inst 0xc240267d // ldr c29, [x19, #9]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q14, =0xd8000000
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b3 // ldr c19, [c13, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826011b3 // ldr c19, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x13, #0xf
	and x19, x19, x13
	cmp x19, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026d // ldr c13, [x19, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240066d // ldr c13, [x19, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400a6d // ldr c13, [x19, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400e6d // ldr c13, [x19, #3]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc240126d // ldr c13, [x19, #4]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc240166d // ldr c13, [x19, #5]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc2401a6d // ldr c13, [x19, #6]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc2401e6d // ldr c13, [x19, #7]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240226d // ldr c13, [x19, #8]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc240266d // ldr c13, [x19, #9]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc2402a6d // ldr c13, [x19, #10]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc2402e6d // ldr c13, [x19, #11]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240326d // ldr c13, [x19, #12]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0xd8000000
	mov x13, v14.d[0]
	cmp x19, x13
	b.ne comparison_fail
	ldr x19, =0x0
	mov x13, v14.d[1]
	cmp x19, x13
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001088
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017fc
	ldr x1, =check_data2
	ldr x2, =0x00001800
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
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
