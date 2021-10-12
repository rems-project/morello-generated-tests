.section data0, #alloc, #write
	.zero 112
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3120
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 688
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 112
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0x20, 0x7c, 0x50, 0xa2, 0xdf, 0x3b, 0x50, 0x2d, 0x90, 0xfe, 0x02, 0x1b, 0xd7, 0x93, 0xc0, 0xc2
	.byte 0x7e, 0x93, 0xc1, 0xc2, 0xc2, 0x53, 0xc0, 0xc2, 0xd2, 0x4b, 0x7e, 0xf8, 0x5f, 0x7b, 0x00, 0x1b
	.byte 0xc0, 0xe4, 0xc7, 0x62, 0x5c, 0x80, 0x83, 0x5a, 0x20, 0x12, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x2000
	/* C6 */
	.octa 0x1bc0
	/* C27 */
	.octa 0x27fff8
	/* C30 */
	.octa 0x1f00
final_cap_values:
	/* C0 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C1 */
	.octa 0x1070
	/* C2 */
	.octa 0x27fff8
	/* C6 */
	.octa 0x1cb0
	/* C18 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C27 */
	.octa 0x27fff8
	/* C30 */
	.octa 0x27fff8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001070
	.dword 0x0000000000001cb0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2507c20 // LDR-C.RIBW-C Ct:0 Rn:1 11:11 imm9:100000111 0:0 opc:01 10100010:10100010
	.inst 0x2d503bdf // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:31 Rn:30 Rt2:01110 imm7:0100000 L:1 1011010:1011010 opc:00
	.inst 0x1b02fe90 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:16 Rn:20 Ra:31 o0:1 Rm:2 0011011000:0011011000 sf:0
	.inst 0xc2c093d7 // GCTAG-R.C-C Rd:23 Cn:30 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc2c1937e // CLRTAG-C.C-C Cd:30 Cn:27 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c053c2 // GCVALUE-R.C-C Rd:2 Cn:30 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xf87e4bd2 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:18 Rn:30 10:10 S:0 option:010 Rm:30 1:1 opc:01 111000:111000 size:11
	.inst 0x1b007b5f // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:26 Ra:30 o0:0 Rm:0 0011011000:0011011000 sf:0
	.inst 0x62c7e4c0 // LDP-C.RIBW-C Ct:0 Rn:6 Ct2:11001 imm7:0001111 L:1 011000101:011000101
	.inst 0x5a83805c // csinv:aarch64/instrs/integer/conditional/select Rd:28 Rn:2 o2:0 0:0 cond:1000 Rm:3 011010100:011010100 op:1 sf:0
	.inst 0xc2c21220
	.zero 1048516
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 8
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c1 // ldr c1, [x22, #0]
	.inst 0xc24006c6 // ldr c6, [x22, #1]
	.inst 0xc2400adb // ldr c27, [x22, #2]
	.inst 0xc2400ede // ldr c30, [x22, #3]
	/* Set up flags and system registers */
	mov x22, #0x60000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	ldr x22, =0x0
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603236 // ldr c22, [c17, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601236 // ldr c22, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x17, #0x6
	and x22, x22, x17
	cmp x22, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d1 // ldr c17, [x22, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24006d1 // ldr c17, [x22, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400ad1 // ldr c17, [x22, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400ed1 // ldr c17, [x22, #3]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc24012d1 // ldr c17, [x22, #4]
	.inst 0xc2d1a641 // chkeq c18, c17
	b.ne comparison_fail
	.inst 0xc24016d1 // ldr c17, [x22, #5]
	.inst 0xc2d1a6e1 // chkeq c23, c17
	b.ne comparison_fail
	.inst 0xc2401ad1 // ldr c17, [x22, #6]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc2401ed1 // ldr c17, [x22, #7]
	.inst 0xc2d1a761 // chkeq c27, c17
	b.ne comparison_fail
	.inst 0xc24022d1 // ldr c17, [x22, #8]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0xc2c2c2c2
	mov x17, v14.d[0]
	cmp x22, x17
	b.ne comparison_fail
	ldr x22, =0x0
	mov x17, v14.d[1]
	cmp x22, x17
	b.ne comparison_fail
	ldr x22, =0xc2c2c2c2
	mov x17, v31.d[0]
	cmp x22, x17
	b.ne comparison_fail
	ldr x22, =0x0
	mov x17, v31.d[1]
	cmp x22, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001070
	ldr x1, =check_data0
	ldr x2, =0x00001080
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001cb0
	ldr x1, =check_data1
	ldr x2, =0x00001cd0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f80
	ldr x1, =check_data2
	ldr x2, =0x00001f88
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
	ldr x0, =0x004ffff0
	ldr x1, =check_data4
	ldr x2, =0x004ffff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
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
