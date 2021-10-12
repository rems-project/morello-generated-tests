.section data0, #alloc, #write
	.zero 2640
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 1424
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xde, 0xd3, 0xc1, 0xc2, 0x22, 0x2c, 0xcd, 0x78, 0xf5, 0xc3, 0xc2, 0xc2, 0x03, 0x78, 0xca, 0xc2
	.byte 0xeb, 0x4b, 0xd9, 0xc2, 0xc1, 0x88, 0x44, 0xac, 0x59, 0x60, 0xf5, 0xc2, 0xe0, 0xd9, 0xc2, 0xea
	.byte 0xe1, 0xf9, 0xc7, 0xc2, 0x1c, 0x88, 0xde, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xff, 0xff
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x700060000000000000000
	/* C1 */
	.octa 0x8000000000008008000000000040205a
	/* C6 */
	.octa 0x800000000001000500000000000019c0
	/* C15 */
	.octa 0x80000002000003fffffffc00
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x1
final_cap_values:
	/* C0 */
	.octa 0x3fffffffc00
	/* C1 */
	.octa 0xfcf0fc00000003fffffffc00
	/* C2 */
	.octa 0xffffffff
	/* C3 */
	.octa 0x414000000000000000000000
	/* C6 */
	.octa 0x800000000001000500000000000019c0
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x80000002000003fffffffc00
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0xffffffff
	/* C28 */
	.octa 0x3fffffffc00
	/* C30 */
	.octa 0x1
initial_csp_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_csp_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1d3de // CPY-C.C-C Cd:30 Cn:30 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x78cd2c22 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:1 11:11 imm9:011010010 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c2c3f5 // CVT-R.CC-C Rd:21 Cn:31 110000:110000 Cm:2 11000010110:11000010110
	.inst 0xc2ca7803 // SCBNDS-C.CI-S Cd:3 Cn:0 1110:1110 S:1 imm6:010100 11000010110:11000010110
	.inst 0xc2d94beb // UNSEAL-C.CC-C Cd:11 Cn:31 0010:0010 opc:01 Cm:25 11000010110:11000010110
	.inst 0xac4488c1 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:1 Rn:6 Rt2:00010 imm7:0001001 L:1 1011000:1011000 opc:10
	.inst 0xc2f56059 // BICFLGS-C.CI-C Cd:25 Cn:2 0:0 00:00 imm8:10101011 11000010111:11000010111
	.inst 0xeac2d9e0 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:15 imm6:110110 Rm:2 N:0 shift:11 01010:01010 opc:11 sf:1
	.inst 0xc2c7f9e1 // SCBNDS-C.CI-S Cd:1 Cn:15 1110:1110 S:1 imm6:001111 11000010110:11000010110
	.inst 0xc2de881c // CHKSSU-C.CC-C Cd:28 Cn:0 0010:0010 opc:10 Cm:30 11000010110:11000010110
	.inst 0xc2c210e0
	.zero 8448
	.inst 0x0000ffff
	.zero 1040080
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b06 // ldr c6, [x24, #2]
	.inst 0xc2400f0f // ldr c15, [x24, #3]
	.inst 0xc2401319 // ldr c25, [x24, #4]
	.inst 0xc240171e // ldr c30, [x24, #5]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_csp_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010f8 // ldr c24, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x7, #0xf
	and x24, x24, x7
	cmp x24, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400307 // ldr c7, [x24, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400707 // ldr c7, [x24, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400b07 // ldr c7, [x24, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400f07 // ldr c7, [x24, #3]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2401307 // ldr c7, [x24, #4]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc2401707 // ldr c7, [x24, #5]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401b07 // ldr c7, [x24, #6]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401f07 // ldr c7, [x24, #7]
	.inst 0xc2c7a6a1 // chkeq c21, c7
	b.ne comparison_fail
	.inst 0xc2402307 // ldr c7, [x24, #8]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2402707 // ldr c7, [x24, #9]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402b07 // ldr c7, [x24, #10]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0xc2c2c2c2c2c2c2c2
	mov x7, v1.d[0]
	cmp x24, x7
	b.ne comparison_fail
	ldr x24, =0xc2c2c2c2c2c2c2c2
	mov x7, v1.d[1]
	cmp x24, x7
	b.ne comparison_fail
	ldr x24, =0xc2c2c2c2c2c2c2c2
	mov x7, v2.d[0]
	cmp x24, x7
	b.ne comparison_fail
	ldr x24, =0xc2c2c2c2c2c2c2c2
	mov x7, v2.d[1]
	cmp x24, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001a50
	ldr x1, =check_data0
	ldr x2, =0x00001a70
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0040212c
	ldr x1, =check_data2
	ldr x2, =0x0040212e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
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
