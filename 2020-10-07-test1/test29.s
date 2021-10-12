.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xde, 0xc2, 0x95, 0xb8, 0x2d, 0x00, 0x1e, 0x3a, 0xc5, 0xf0, 0xc0, 0xc2, 0xfd, 0x1c, 0x5b, 0x6c
	.byte 0xf0, 0x03, 0x1f, 0x1a, 0x41, 0xb8, 0x91, 0x38, 0xe1, 0x7f, 0x5f, 0x42, 0x83, 0xac, 0x11, 0x79
	.byte 0x41, 0xd0, 0xc1, 0xc2, 0x00, 0x50, 0xdc, 0xc2
.data
check_data6:
	.byte 0x60, 0x13, 0xc2, 0xc2
.data
check_data7:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x901000000001000500000000000011e0
	/* C2 */
	.octa 0x800000000001000500000000000020e3
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x40000000000100050000000000001140
	/* C7 */
	.octa 0x80000000000080080000000000001a38
	/* C22 */
	.octa 0x800000000001000500000000000010c0
final_cap_values:
	/* C0 */
	.octa 0x901000000001000500000000000011e0
	/* C1 */
	.octa 0x800000000001000500000000000020e3
	/* C2 */
	.octa 0x800000000001000500000000000020e3
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x40000000000100050000000000001140
	/* C7 */
	.octa 0x80000000000080080000000000001a38
	/* C22 */
	.octa 0x800000000001000500000000000010c0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x4fffe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000001700020000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb895c2de // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:22 00:00 imm9:101011100 0:0 opc:10 111000:111000 size:10
	.inst 0x3a1e002d // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:13 Rn:1 000000:000000 Rm:30 11010000:11010000 S:1 op:0 sf:0
	.inst 0xc2c0f0c5 // GCTYPE-R.C-C Rd:5 Cn:6 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x6c5b1cfd // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:29 Rn:7 Rt2:00111 imm7:0110110 L:1 1011000:1011000 opc:01
	.inst 0x1a1f03f0 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:16 Rn:31 000000:000000 Rm:31 11010000:11010000 S:0 op:0 sf:0
	.inst 0x3891b841 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:2 10:10 imm9:100011011 0:0 opc:10 111000:111000 size:00
	.inst 0x425f7fe1 // ALDAR-C.R-C Ct:1 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x7911ac83 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:3 Rn:4 imm12:010001101011 opc:00 111001:111001 size:01
	.inst 0xc2c1d041 // CPY-C.C-C Cd:1 Cn:2 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xc2dc5000 // BR-CI-C 0:0 0000:0000 Cn:0 100:100 imm7:1100010 110000101101:110000101101
	.zero 524248
	.inst 0xc2c21360
	.zero 524284
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc2400983 // ldr c3, [x12, #2]
	.inst 0xc2400d84 // ldr c4, [x12, #3]
	.inst 0xc2401187 // ldr c7, [x12, #4]
	.inst 0xc2401596 // ldr c22, [x12, #5]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850032
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260336c // ldr c12, [c27, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260136c // ldr c12, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240019b // ldr c27, [x12, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240059b // ldr c27, [x12, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240099b // ldr c27, [x12, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400d9b // ldr c27, [x12, #3]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc240119b // ldr c27, [x12, #4]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc240159b // ldr c27, [x12, #5]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc240199b // ldr c27, [x12, #6]
	.inst 0xc2dba6c1 // chkeq c22, c27
	b.ne comparison_fail
	.inst 0xc2401d9b // ldr c27, [x12, #7]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x27, v7.d[0]
	cmp x12, x27
	b.ne comparison_fail
	ldr x12, =0x0
	mov x27, v7.d[1]
	cmp x12, x27
	b.ne comparison_fail
	ldr x12, =0x0
	mov x27, v29.d[0]
	cmp x12, x27
	b.ne comparison_fail
	ldr x12, =0x0
	mov x27, v29.d[1]
	cmp x12, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000101c
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a16
	ldr x1, =check_data2
	ldr x2, =0x00001a18
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001be8
	ldr x1, =check_data3
	ldr x2, =0x00001bf8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00480000
	ldr x1, =check_data6
	ldr x2, =0x00480004
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004fffe0
	ldr x1, =check_data7
	ldr x2, =0x004ffff0
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
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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
