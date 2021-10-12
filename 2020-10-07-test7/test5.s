.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x29, 0x54, 0x81, 0x5a, 0x18, 0x55, 0x0d, 0x38, 0x77, 0xa4, 0x0a, 0xe2, 0x13, 0x03, 0x1b, 0x7a
	.byte 0x00, 0x50, 0xc2, 0xc2
.data
check_data5:
	.byte 0xa1, 0x7a, 0xe0, 0x82, 0x5b, 0xfc, 0xdf, 0x88, 0xbf, 0x4c, 0x1d, 0x38, 0x1b, 0x28, 0xd1, 0x1a
	.byte 0x1a, 0x00, 0x02, 0xba, 0x20, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x200080009007001f0000000000400101
	/* C2 */
	.octa 0x800000000006000f0000000000401000
	/* C3 */
	.octa 0x1000
	/* C5 */
	.octa 0x40000000000400070000000000001200
	/* C8 */
	.octa 0x40000000000100070000000000001000
	/* C21 */
	.octa 0xfffffffffe000800
	/* C24 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x200080009007001f0000000000400101
	/* C2 */
	.octa 0x800000000006000f0000000000401000
	/* C3 */
	.octa 0x1000
	/* C5 */
	.octa 0x400000000004000700000000000011d4
	/* C8 */
	.octa 0x400000000001000700000000000010d5
	/* C21 */
	.octa 0xfffffffffe000800
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000180060080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5a815429 // csneg:aarch64/instrs/integer/conditional/select Rd:9 Rn:1 o2:1 0:0 cond:0101 Rm:1 011010100:011010100 op:1 sf:0
	.inst 0x380d5518 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:24 Rn:8 01:01 imm9:011010101 0:0 opc:00 111000:111000 size:00
	.inst 0xe20aa477 // ALDURB-R.RI-32 Rt:23 Rn:3 op2:01 imm9:010101010 V:0 op1:00 11100010:11100010
	.inst 0x7a1b0313 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:19 Rn:24 000000:000000 Rm:27 11010000:11010000 S:1 op:1 sf:0
	.inst 0xc2c25000 // RET-C-C 00000:00000 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 236
	.inst 0x82e07aa1 // ALDR-V.RRB-D Rt:1 Rn:21 opc:10 S:1 option:011 Rm:0 1:1 L:1 100000101:100000101
	.inst 0x88dffc5b // ldar:aarch64/instrs/memory/ordered Rt:27 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x381d4cbf // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:5 11:11 imm9:111010100 0:0 opc:00 111000:111000 size:00
	.inst 0x1ad1281b // asrv:aarch64/instrs/integer/shift/variable Rd:27 Rn:0 op2:10 0010:0010 Rm:17 0011010110:0011010110 sf:0
	.inst 0xba02001a // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:26 Rn:0 000000:000000 Rm:2 11010000:11010000 S:1 op:0 sf:1
	.inst 0xc2c21320
	.zero 1048296
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2400e05 // ldr c5, [x16, #3]
	.inst 0xc2401208 // ldr c8, [x16, #4]
	.inst 0xc2401615 // ldr c21, [x16, #5]
	.inst 0xc2401a18 // ldr c24, [x16, #6]
	/* Set up flags and system registers */
	mov x16, #0x80000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850032
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603330 // ldr c16, [c25, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601330 // ldr c16, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x25, #0x4
	and x16, x16, x25
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400219 // ldr c25, [x16, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400619 // ldr c25, [x16, #1]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400a19 // ldr c25, [x16, #2]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2400e19 // ldr c25, [x16, #3]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2401219 // ldr c25, [x16, #4]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2401619 // ldr c25, [x16, #5]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc2401a19 // ldr c25, [x16, #6]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2401e19 // ldr c25, [x16, #7]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x25, v1.d[0]
	cmp x16, x25
	b.ne comparison_fail
	ldr x16, =0x0
	mov x25, v1.d[1]
	cmp x16, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010aa
	ldr x1, =check_data2
	ldr x2, =0x000010ab
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011d4
	ldr x1, =check_data3
	ldr x2, =0x000011d5
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400100
	ldr x1, =check_data5
	ldr x2, =0x00400118
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00401000
	ldr x1, =check_data6
	ldr x2, =0x00401004
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
