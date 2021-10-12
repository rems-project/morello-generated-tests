.section data0, #alloc, #write
	.zero 64
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00
	.zero 4016
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x40
.data
check_data6:
	.zero 16
.data
check_data7:
	.byte 0xc1, 0xdb, 0x7f, 0xc8, 0xfe, 0x9d, 0x22, 0xe2, 0xc1, 0x07, 0x68, 0x39, 0xde, 0x7c, 0x3f, 0x42
	.byte 0xdf, 0xdb, 0x3e, 0xa8, 0xe1, 0xa7, 0xd3, 0xc2, 0x40, 0x68, 0xc1, 0xc2, 0xbf, 0x23, 0x3b, 0x78
	.byte 0x5f, 0x40, 0xd1, 0xe2, 0xe7, 0x50, 0xc0, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x4000000000060003000000000000122c
	/* C6 */
	.octa 0x40000000000100050000000000001fd0
	/* C15 */
	.octa 0x80000000000700050000000000001fb7
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1040
final_cap_values:
	/* C0 */
	.octa 0x4000000000060003000000000000122c
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4000000000060003000000000000122c
	/* C6 */
	.octa 0x40000000000100050000000000001fd0
	/* C15 */
	.octa 0x80000000000700050000000000001fb7
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x2000000
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1040
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000001f81000700000000000e0001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc87fdbc1 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:30 Rt2:10110 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xe2229dfe // ALDUR-V.RI-Q Rt:30 Rn:15 op2:11 imm9:000101001 V:1 op1:00 11100010:11100010
	.inst 0x396807c1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:30 imm12:101000000001 opc:01 111001:111001 size:00
	.inst 0x423f7cde // ASTLRB-R.R-B Rt:30 Rn:6 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xa83edbdf // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:31 Rn:30 Rt2:10110 imm7:1111101 L:0 1010000:1010000 opc:10
	.inst 0xc2d3a7e1 // CHKEQ-_.CC-C 00001:00001 Cn:31 001:001 opc:01 1:1 Cm:19 11000010110:11000010110
	.inst 0xc2c16840 // ORRFLGS-C.CR-C Cd:0 Cn:2 1010:1010 opc:01 Rm:1 11000010110:11000010110
	.inst 0x783b23bf // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:010 o3:0 Rs:27 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xe2d1405f // ASTUR-R.RI-64 Rt:31 Rn:2 op2:00 imm9:100010100 V:0 op1:11 11100010:11100010
	.inst 0xc2c050e7 // GCVALUE-R.C-C Rd:7 Cn:7 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c21220
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
	ldr x28, =initial_cap_values
	.inst 0xc2400382 // ldr c2, [x28, #0]
	.inst 0xc2400786 // ldr c6, [x28, #1]
	.inst 0xc2400b8f // ldr c15, [x28, #2]
	.inst 0xc2400f93 // ldr c19, [x28, #3]
	.inst 0xc240139b // ldr c27, [x28, #4]
	.inst 0xc240179d // ldr c29, [x28, #5]
	.inst 0xc2401b9e // ldr c30, [x28, #6]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30851037
	msr SCTLR_EL3, x28
	ldr x28, =0x4
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260323c // ldr c28, [c17, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260123c // ldr c28, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x17, #0xf
	and x28, x28, x17
	cmp x28, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400391 // ldr c17, [x28, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400791 // ldr c17, [x28, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400b91 // ldr c17, [x28, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400f91 // ldr c17, [x28, #3]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc2401391 // ldr c17, [x28, #4]
	.inst 0xc2d1a5e1 // chkeq c15, c17
	b.ne comparison_fail
	.inst 0xc2401791 // ldr c17, [x28, #5]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc2401b91 // ldr c17, [x28, #6]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc2401f91 // ldr c17, [x28, #7]
	.inst 0xc2d1a761 // chkeq c27, c17
	b.ne comparison_fail
	.inst 0xc2402391 // ldr c17, [x28, #8]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402791 // ldr c17, [x28, #9]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x17, v30.d[0]
	cmp x28, x17
	b.ne comparison_fail
	ldr x28, =0x0
	mov x17, v30.d[1]
	cmp x28, x17
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
	ldr x0, =0x00001028
	ldr x1, =check_data1
	ldr x2, =0x00001038
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001050
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001140
	ldr x1, =check_data3
	ldr x2, =0x00001148
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001a41
	ldr x1, =check_data4
	ldr x2, =0x00001a42
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fd0
	ldr x1, =check_data5
	ldr x2, =0x00001fd1
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001fe0
	ldr x1, =check_data6
	ldr x2, =0x00001ff0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
