.section data0, #alloc, #write
	.zero 3072
	.byte 0x00, 0x00, 0x00, 0x01, 0x47, 0x7f, 0xa1, 0xa2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1008
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x01, 0x47, 0x7f, 0xa1, 0xa2
.data
check_data5:
	.byte 0xfd, 0xee, 0xe7, 0x28, 0xfe, 0x7f, 0x5f, 0x9b, 0x47, 0x7f, 0xa1, 0xa2, 0xbd, 0x34, 0xad, 0x28
	.byte 0x01, 0x30, 0xc0, 0xc2, 0x5f, 0x02, 0x7e, 0x78, 0xc1, 0x5d, 0x23, 0xe2, 0x16, 0x40, 0xb5, 0x82
	.byte 0x01, 0xa4, 0xdb, 0xc2, 0xdf, 0x43, 0x87, 0xf8, 0x60, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400100010000000000001000
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000000300070000000000001000
	/* C7 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x40002b
	/* C18 */
	.octa 0xc00000000001000500000000000013f8
	/* C21 */
	.octa 0x40
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x80000000780108010000000000001c00
	/* C26 */
	.octa 0xdc100000040700030000000000001100
final_cap_values:
	/* C0 */
	.octa 0x400100010000000000001000
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000000300070000000000000f68
	/* C7 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x40002b
	/* C18 */
	.octa 0xc00000000001000500000000000013f8
	/* C21 */
	.octa 0x40
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x80000000780108010000000000001b3c
	/* C26 */
	.octa 0xdc100000040700030000000000001100
	/* C27 */
	.octa 0xa2a17f47
	/* C29 */
	.octa 0x1000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000482c00000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 144
	.dword initial_cap_values + 160
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x28e7eefd // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:29 Rn:23 Rt2:11011 imm7:1001111 L:1 1010001:1010001 opc:00
	.inst 0x9b5f7ffe // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:31 Ra:11111 0:0 Rm:31 10:10 U:0 10011011:10011011
	.inst 0xa2a17f47 // CAS-C.R-C Ct:7 Rn:26 11111:11111 R:0 Cs:1 1:1 L:0 1:1 10100010:10100010
	.inst 0x28ad34bd // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:29 Rn:5 Rt2:01101 imm7:1011010 L:0 1010001:1010001 opc:00
	.inst 0xc2c03001 // GCLEN-R.C-C Rd:1 Cn:0 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x787e025f // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:18 00:00 opc:000 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xe2235dc1 // ALDUR-V.RI-Q Rt:1 Rn:14 op2:11 imm9:000110101 V:1 op1:00 11100010:11100010
	.inst 0x82b54016 // ASTR-R.RRB-32 Rt:22 Rn:0 opc:00 S:0 option:010 Rm:21 1:1 L:0 100000101:100000101
	.inst 0xc2dba401 // CHKEQ-_.CC-C 00001:00001 Cn:0 001:001 opc:01 1:1 Cm:27 11000010110:11000010110
	.inst 0xf88743df // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:30 00:00 imm9:001110100 0:0 opc:10 111000:111000 size:11
	.inst 0xc2c21160
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
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a65 // ldr c5, [x19, #2]
	.inst 0xc2400e67 // ldr c7, [x19, #3]
	.inst 0xc240126d // ldr c13, [x19, #4]
	.inst 0xc240166e // ldr c14, [x19, #5]
	.inst 0xc2401a72 // ldr c18, [x19, #6]
	.inst 0xc2401e75 // ldr c21, [x19, #7]
	.inst 0xc2402276 // ldr c22, [x19, #8]
	.inst 0xc2402677 // ldr c23, [x19, #9]
	.inst 0xc2402a7a // ldr c26, [x19, #10]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851037
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603173 // ldr c19, [c11, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601173 // ldr c19, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	mov x11, #0xf
	and x19, x19, x11
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026b // ldr c11, [x19, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240066b // ldr c11, [x19, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400a6b // ldr c11, [x19, #2]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc2400e6b // ldr c11, [x19, #3]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc240126b // ldr c11, [x19, #4]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240166b // ldr c11, [x19, #5]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc2401a6b // ldr c11, [x19, #6]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc2401e6b // ldr c11, [x19, #7]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc240226b // ldr c11, [x19, #8]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc240266b // ldr c11, [x19, #9]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc2402a6b // ldr c11, [x19, #10]
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	.inst 0xc2402e6b // ldr c11, [x19, #11]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc240326b // ldr c11, [x19, #12]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc240366b // ldr c11, [x19, #13]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x11, v1.d[0]
	cmp x19, x11
	b.ne comparison_fail
	ldr x19, =0x0
	mov x11, v1.d[1]
	cmp x19, x11
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001110
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013f8
	ldr x1, =check_data3
	ldr x2, =0x000013fa
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001c00
	ldr x1, =check_data4
	ldr x2, =0x00001c08
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400060
	ldr x1, =check_data6
	ldr x2, =0x00400070
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
