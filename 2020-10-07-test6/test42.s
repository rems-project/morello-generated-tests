.section data0, #alloc, #write
	.zero 2752
	.byte 0xfd, 0xff, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1328
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xfd, 0xff, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xfa, 0x53, 0xc3, 0x78, 0x40, 0xd0, 0x6a, 0x82, 0x2c, 0x7d, 0xdf, 0x88, 0x2e, 0x30, 0x09, 0x78
	.byte 0xc4, 0xc7, 0xc0, 0x82, 0xde, 0x01, 0x01, 0x7a, 0x5f, 0x65, 0xb3, 0x9b, 0xdf, 0x0b, 0xc0, 0xda
	.byte 0xc5, 0x93, 0xbf, 0xc2, 0x22, 0x71, 0xc0, 0xc2, 0x00, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1129
	/* C2 */
	.octa 0x90100000000600070000000000000ff0
	/* C9 */
	.octa 0x500070000000000001ff4
	/* C14 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000100050000000000000001
final_cap_values:
	/* C0 */
	.octa 0x4ffffd
	/* C1 */
	.octa 0x1129
	/* C2 */
	.octa 0x1ff4
	/* C4 */
	.octa 0x0
	/* C9 */
	.octa 0x500070000000000001ff4
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C26 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000400410040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001ac0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78c353fa // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:26 Rn:31 00:00 imm9:000110101 0:0 opc:11 111000:111000 size:01
	.inst 0x826ad040 // ALDR-C.RI-C Ct:0 Rn:2 op:00 imm9:010101101 L:1 1000001001:1000001001
	.inst 0x88df7d2c // ldlar:aarch64/instrs/memory/ordered Rt:12 Rn:9 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x7809302e // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:14 Rn:1 00:00 imm9:010010011 0:0 opc:00 111000:111000 size:01
	.inst 0x82c0c7c4 // ALDRSB-R.RRB-32 Rt:4 Rn:30 opc:01 S:0 option:110 Rm:0 0:0 L:1 100000101:100000101
	.inst 0x7a0101de // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:14 000000:000000 Rm:1 11010000:11010000 S:1 op:1 sf:0
	.inst 0x9bb3655f // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:10 Ra:25 o0:0 Rm:19 01:01 U:1 10011011:10011011
	.inst 0xdac00bdf // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2bf93c5 // ADD-C.CRI-C Cd:5 Cn:30 imm3:100 option:100 Rm:31 11000010101:11000010101
	.inst 0xc2c07122 // GCOFF-R.C-C Rd:2 Cn:9 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c21300
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400909 // ldr c9, [x8, #2]
	.inst 0xc2400d0e // ldr c14, [x8, #3]
	.inst 0xc240111e // ldr c30, [x8, #4]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603308 // ldr c8, [c24, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601308 // ldr c8, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x24, #0xf
	and x8, x8, x24
	cmp x8, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400118 // ldr c24, [x8, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400518 // ldr c24, [x8, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400918 // ldr c24, [x8, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400d18 // ldr c24, [x8, #3]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2401118 // ldr c24, [x8, #4]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2401518 // ldr c24, [x8, #5]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc2401918 // ldr c24, [x8, #6]
	.inst 0xc2d8a5c1 // chkeq c14, c24
	b.ne comparison_fail
	.inst 0xc2401d18 // ldr c24, [x8, #7]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001036
	ldr x1, =check_data0
	ldr x2, =0x00001038
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011bc
	ldr x1, =check_data1
	ldr x2, =0x000011be
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ac0
	ldr x1, =check_data2
	ldr x2, =0x00001ad0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff4
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffe
	ldr x1, =check_data5
	ldr x2, =0x004fffff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
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
