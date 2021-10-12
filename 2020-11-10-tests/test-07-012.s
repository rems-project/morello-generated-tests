.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 5
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0xde, 0xc7, 0x61, 0x2d, 0x1c, 0x56, 0x82, 0x9a, 0xee, 0xc6, 0x7c, 0x82, 0xe0, 0x87, 0x60, 0x28
	.byte 0xfe, 0xe7, 0x82, 0x82, 0xdf, 0x20, 0x7a, 0x38, 0x41, 0x08, 0xc2, 0xc2, 0xaf, 0x7e, 0xdf, 0x88
	.byte 0xc0, 0x7b, 0x70, 0x02, 0x45, 0x64, 0x57, 0x7c, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x2000000478100c00000000000000f80
	/* C6 */
	.octa 0x1000
	/* C21 */
	.octa 0x800
	/* C23 */
	.octa 0x800000000006000f0000000000000e38
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x1814
final_cap_values:
	/* C0 */
	.octa 0xc1e000
	/* C1 */
	.octa 0x20007c0478100c00000000000000f80
	/* C2 */
	.octa 0xef6
	/* C6 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0x800
	/* C23 */
	.octa 0x800000000006000f0000000000000e38
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0xf81
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800000004004000a0000000000000c00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004004080000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2d61c7de // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:30 Rn:30 Rt2:10001 imm7:1000011 L:1 1011010:1011010 opc:00
	.inst 0x9a82561c // csinc:aarch64/instrs/integer/conditional/select Rd:28 Rn:16 o2:1 0:0 cond:0101 Rm:2 011010100:011010100 op:0 sf:1
	.inst 0x827cc6ee // ALDRB-R.RI-B Rt:14 Rn:23 op:01 imm9:111001100 L:1 1000001001:1000001001
	.inst 0x286087e0 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:0 Rn:31 Rt2:00001 imm7:1000001 L:1 1010000:1010000 opc:00
	.inst 0x8282e7fe // ALDRSB-R.RRB-64 Rt:30 Rn:31 opc:01 S:0 option:111 Rm:2 0:0 L:0 100000101:100000101
	.inst 0x387a20df // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:010 o3:0 Rs:26 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c20841 // SEAL-C.CC-C Cd:1 Cn:2 0010:0010 opc:00 Cm:2 11000010110:11000010110
	.inst 0x88df7eaf // ldlar:aarch64/instrs/memory/ordered Rt:15 Rn:21 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x02707bc0 // ADD-C.CIS-C Cd:0 Cn:30 imm12:110000011110 sh:1 A:0 00000010:00000010
	.inst 0x7c576445 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:5 Rn:2 01:01 imm9:101110110 0:0 opc:01 111100:111100 size:01
	.inst 0xc2c21120
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
	.inst 0xc2400102 // ldr c2, [x8, #0]
	.inst 0xc2400506 // ldr c6, [x8, #1]
	.inst 0xc2400915 // ldr c21, [x8, #2]
	.inst 0xc2400d17 // ldr c23, [x8, #3]
	.inst 0xc240111a // ldr c26, [x8, #4]
	.inst 0xc240151e // ldr c30, [x8, #5]
	/* Set up flags and system registers */
	mov x8, #0x80000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x3085103f
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603128 // ldr c8, [c9, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601128 // ldr c8, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
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
	mov x9, #0x8
	and x8, x8, x9
	cmp x8, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400109 // ldr c9, [x8, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400509 // ldr c9, [x8, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400909 // ldr c9, [x8, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400d09 // ldr c9, [x8, #3]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401109 // ldr c9, [x8, #4]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401509 // ldr c9, [x8, #5]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401909 // ldr c9, [x8, #6]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2401d09 // ldr c9, [x8, #7]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2402109 // ldr c9, [x8, #8]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc2402509 // ldr c9, [x8, #9]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402909 // ldr c9, [x8, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x9, v5.d[0]
	cmp x8, x9
	b.ne comparison_fail
	ldr x8, =0x0
	mov x9, v5.d[1]
	cmp x8, x9
	b.ne comparison_fail
	ldr x8, =0x0
	mov x9, v17.d[0]
	cmp x8, x9
	b.ne comparison_fail
	ldr x8, =0x0
	mov x9, v17.d[1]
	cmp x8, x9
	b.ne comparison_fail
	ldr x8, =0x0
	mov x9, v30.d[0]
	cmp x8, x9
	b.ne comparison_fail
	ldr x8, =0x0
	mov x9, v30.d[1]
	cmp x8, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001005
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001304
	ldr x1, =check_data1
	ldr x2, =0x0000130c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001780
	ldr x1, =check_data2
	ldr x2, =0x00001782
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001801
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001b80
	ldr x1, =check_data4
	ldr x2, =0x00001b81
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f20
	ldr x1, =check_data5
	ldr x2, =0x00001f28
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
