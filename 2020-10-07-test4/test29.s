.section data0, #alloc, #write
	.zero 32
	.byte 0x40, 0x44, 0x4c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 4048
.data
check_data0:
	.byte 0x01, 0x08, 0xfd, 0xf7, 0xf7, 0xfd, 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x40, 0x44, 0x4c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x01
.data
check_data3:
	.byte 0xff, 0x12, 0xc4, 0xc2
.data
check_data4:
	.zero 32
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x30, 0x30, 0xc0, 0xc2, 0x03, 0x00, 0xc3, 0xac, 0xc2, 0x7f, 0x06, 0xf8, 0xc2, 0xdf, 0x1c, 0x39
	.byte 0xda, 0x7b, 0x03, 0xa9, 0x41, 0x64, 0xde, 0xc2, 0xfe, 0x13, 0xc1, 0xc2, 0xe0, 0x97, 0x89, 0xe2
	.byte 0x20, 0x04, 0xc0, 0xda, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4024d0
	/* C1 */
	.octa 0x180860000000000000000
	/* C2 */
	.octa 0xb003a00300fefdf7f7fd0801
	/* C23 */
	.octa 0x90100000000500030000000000001010
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0xfa9
final_cap_values:
	/* C0 */
	.octa 0x1010
	/* C1 */
	.octa 0xb003a0030000000000001010
	/* C2 */
	.octa 0xb003a00300fefdf7f7fd0801
	/* C16 */
	.octa 0xffffffffffffffff
	/* C23 */
	.octa 0x90100000000500030000000000001010
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0xffffffffffffffff
initial_SP_EL3_value:
	.octa 0x80000000000000000000000000403f43
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c412ff // LDPBR-C.C-C Ct:31 Cn:23 100:100 opc:00 11000010110001000:11000010110001000
	.zero 803900
	.inst 0xc2c03030 // GCLEN-R.C-C Rd:16 Cn:1 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xacc30003 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:3 Rn:0 Rt2:00000 imm7:0000110 L:1 1011001:1011001 opc:10
	.inst 0xf8067fc2 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:30 11:11 imm9:001100111 0:0 opc:00 111000:111000 size:11
	.inst 0x391cdfc2 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:30 imm12:011100110111 opc:00 111001:111001 size:00
	.inst 0xa9037bda // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:26 Rn:30 Rt2:11110 imm7:0000110 L:0 1010010:1010010 opc:10
	.inst 0xc2de6441 // CPYVALUE-C.C-C Cd:1 Cn:2 001:001 opc:11 0:0 Cm:30 11000010110:11000010110
	.inst 0xc2c113fe // GCLIM-R.C-C Rd:30 Cn:31 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xe28997e0 // ALDUR-R.RI-32 Rt:0 Rn:31 op2:01 imm9:010011001 V:0 op1:10 11100010:11100010
	.inst 0xdac00420 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:1 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c21360
	.zero 244632
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a42 // ldr c2, [x18, #2]
	.inst 0xc2400e57 // ldr c23, [x18, #3]
	.inst 0xc240125a // ldr c26, [x18, #4]
	.inst 0xc240165e // ldr c30, [x18, #5]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850032
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603372 // ldr c18, [c27, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601372 // ldr c18, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240025b // ldr c27, [x18, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240065b // ldr c27, [x18, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400a5b // ldr c27, [x18, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400e5b // ldr c27, [x18, #3]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc240125b // ldr c27, [x18, #4]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc240165b // ldr c27, [x18, #5]
	.inst 0xc2dba741 // chkeq c26, c27
	b.ne comparison_fail
	.inst 0xc2401a5b // ldr c27, [x18, #6]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x27, v0.d[0]
	cmp x18, x27
	b.ne comparison_fail
	ldr x18, =0x0
	mov x27, v0.d[1]
	cmp x18, x27
	b.ne comparison_fail
	ldr x18, =0x0
	mov x27, v3.d[0]
	cmp x18, x27
	b.ne comparison_fail
	ldr x18, =0x0
	mov x27, v3.d[1]
	cmp x18, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001747
	ldr x1, =check_data2
	ldr x2, =0x00001748
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004024d0
	ldr x1, =check_data4
	ldr x2, =0x004024f0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00403fdc
	ldr x1, =check_data5
	ldr x2, =0x00403fe0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004c4440
	ldr x1, =check_data6
	ldr x2, =0x004c4468
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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
