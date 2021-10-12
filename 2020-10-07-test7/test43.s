.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x02, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x40
.data
check_data5:
	.byte 0x02, 0x10, 0x00, 0x00, 0x00, 0x00, 0x8d, 0x00
.data
check_data6:
	.byte 0x02, 0xbb, 0x39, 0x28, 0x0d, 0x00, 0x5c, 0x78, 0x0f, 0xe0, 0x8d, 0xe2, 0xdf, 0x33, 0xc1, 0xc2
	.byte 0x5e, 0xe0, 0x5f, 0xb8, 0xe4, 0xef, 0x2d, 0xe2, 0x60, 0x0d, 0x9a, 0xe2, 0x9f, 0x94, 0x4f, 0x31
	.byte 0x80, 0x64, 0xdf, 0x82, 0x22, 0xc4, 0x8c, 0xda, 0x20, 0x12, 0xc2, 0xc2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40004000000000000000000000001402
	/* C2 */
	.octa 0x1002
	/* C4 */
	.octa 0x80000000040780170000000000408400
	/* C11 */
	.octa 0x48000000100700830000000000002000
	/* C14 */
	.octa 0x8d0000
	/* C15 */
	.octa 0x0
	/* C24 */
	.octa 0x2000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000040780170000000000408400
	/* C11 */
	.octa 0x48000000100700830000000000002000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x8d0000
	/* C15 */
	.octa 0x0
	/* C24 */
	.octa 0x2000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000300020000000000001002
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005ff4002000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2839bb02 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:2 Rn:24 Rt2:01110 imm7:1110011 L:0 1010000:1010000 opc:00
	.inst 0x785c000d // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:13 Rn:0 00:00 imm9:111000000 0:0 opc:01 111000:111000 size:01
	.inst 0xe28de00f // ASTUR-R.RI-32 Rt:15 Rn:0 op2:00 imm9:011011110 V:0 op1:10 11100010:11100010
	.inst 0xc2c133df // GCFLGS-R.C-C Rd:31 Cn:30 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xb85fe05e // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:2 00:00 imm9:111111110 0:0 opc:01 111000:111000 size:10
	.inst 0xe22defe4 // ALDUR-V.RI-Q Rt:4 Rn:31 op2:11 imm9:011011110 V:1 op1:00 11100010:11100010
	.inst 0xe29a0d60 // ASTUR-C.RI-C Ct:0 Rn:11 op2:11 imm9:110100000 V:0 op1:10 11100010:11100010
	.inst 0x314f949f // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:4 imm12:001111100101 sh:1 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0x82df6480 // ALDRSB-R.RRB-32 Rt:0 Rn:4 opc:01 S:0 option:011 Rm:31 0:0 L:1 100000101:100000101
	.inst 0xda8cc422 // csneg:aarch64/instrs/integer/conditional/select Rd:2 Rn:1 o2:1 0:0 cond:1100 Rm:12 011010100:011010100 op:1 sf:1
	.inst 0xc2c21220
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c4 // ldr c4, [x6, #2]
	.inst 0xc2400ccb // ldr c11, [x6, #3]
	.inst 0xc24010ce // ldr c14, [x6, #4]
	.inst 0xc24014cf // ldr c15, [x6, #5]
	.inst 0xc24018d8 // ldr c24, [x6, #6]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603226 // ldr c6, [c17, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601226 // ldr c6, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x17, #0xf
	and x6, x6, x17
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d1 // ldr c17, [x6, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24004d1 // ldr c17, [x6, #1]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc24008d1 // ldr c17, [x6, #2]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc2400cd1 // ldr c17, [x6, #3]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc2d1a5c1 // chkeq c14, c17
	b.ne comparison_fail
	.inst 0xc24014d1 // ldr c17, [x6, #5]
	.inst 0xc2d1a5e1 // chkeq c15, c17
	b.ne comparison_fail
	.inst 0xc24018d1 // ldr c17, [x6, #6]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc2401cd1 // ldr c17, [x6, #7]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x17, v4.d[0]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v4.d[1]
	cmp x6, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001024
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x000010f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013e2
	ldr x1, =check_data2
	ldr x2, =0x000013e4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000014e0
	ldr x1, =check_data3
	ldr x2, =0x000014e4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fa0
	ldr x1, =check_data4
	ldr x2, =0x00001fb0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fec
	ldr x1, =check_data5
	ldr x2, =0x00001ff4
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
	ldr x0, =0x00408400
	ldr x1, =check_data7
	ldr x2, =0x00408401
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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

	.balign 128
vector_table:
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
