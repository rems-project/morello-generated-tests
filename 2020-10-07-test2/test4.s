.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x62, 0xd1, 0x9f, 0x1a
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xdf, 0xf5, 0x53, 0xf8, 0xfc, 0xa7, 0x96, 0xb9, 0xc8, 0xb7, 0xbf, 0xe2, 0xe0, 0x13, 0xc5, 0xc2
	.byte 0x3e, 0xb4, 0x80, 0x38, 0xb2, 0xf2, 0x82, 0x82, 0x42, 0x46, 0x94, 0xf2, 0x62, 0xd1, 0x9f, 0x1a
	.byte 0x36, 0xa0, 0xa1, 0x2c, 0xdf, 0x7d, 0xdf, 0x08, 0x00, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000000100070000000000001001
	/* C2 */
	.octa 0x618
	/* C14 */
	.octa 0x800000000001000500000000004800b8
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x14d0
	/* C30 */
	.octa 0x400021
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc0000000000100070000000000000f18
	/* C14 */
	.octa 0x8000000000010005000000000047fff7
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x14d0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000001600060000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000003ffb00070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf853f5df // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:14 01:01 imm9:100111111 0:0 opc:01 111000:111000 size:11
	.inst 0xb996a7fc // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:31 imm12:010110101001 opc:10 111001:111001 size:10
	.inst 0xe2bfb7c8 // ALDUR-V.RI-S Rt:8 Rn:30 op2:01 imm9:111111011 V:1 op1:10 11100010:11100010
	.inst 0xc2c513e0 // CVTD-R.C-C Rd:0 Cn:31 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x3880b43e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:1 01:01 imm9:000001011 0:0 opc:10 111000:111000 size:00
	.inst 0x8282f2b2 // ASTRB-R.RRB-B Rt:18 Rn:21 opc:00 S:1 option:111 Rm:2 0:0 L:0 100000101:100000101
	.inst 0xf2944642 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:2 imm16:1010001000110010 hw:00 100101:100101 opc:11 sf:1
	.inst 0x1a9fd162 // csel:aarch64/instrs/integer/conditional/select Rd:2 Rn:11 o2:0 0:0 cond:1101 Rm:31 011010100:011010100 op:0 sf:0
	.inst 0x2ca1a036 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:22 Rn:1 Rt2:01000 imm7:1000011 L:0 1011001:1011001 opc:00
	.inst 0x08df7ddf // ldlarb:aarch64/instrs/memory/ordered Rt:31 Rn:14 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c21200
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc240086e // ldr c14, [x3, #2]
	.inst 0xc2400c72 // ldr c18, [x3, #3]
	.inst 0xc2401075 // ldr c21, [x3, #4]
	.inst 0xc240147e // ldr c30, [x3, #5]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q22, =0x0
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603203 // ldr c3, [c16, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601203 // ldr c3, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x16, #0xf
	and x3, x3, x16
	cmp x3, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400070 // ldr c16, [x3, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400470 // ldr c16, [x3, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400870 // ldr c16, [x3, #2]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2400c70 // ldr c16, [x3, #3]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc2401070 // ldr c16, [x3, #4]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc2401470 // ldr c16, [x3, #5]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	.inst 0xc2401870 // ldr c16, [x3, #6]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x1a9fd162
	mov x16, v8.d[0]
	cmp x3, x16
	b.ne comparison_fail
	ldr x3, =0x0
	mov x16, v8.d[1]
	cmp x3, x16
	b.ne comparison_fail
	ldr x3, =0x0
	mov x16, v22.d[0]
	cmp x3, x16
	b.ne comparison_fail
	ldr x3, =0x0
	mov x16, v22.d[1]
	cmp x3, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001001
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000100c
	ldr x1, =check_data1
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000016a4
	ldr x1, =check_data2
	ldr x2, =0x000016a8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ae8
	ldr x1, =check_data3
	ldr x2, =0x00001ae9
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
	ldr x0, =0x0047fff7
	ldr x1, =check_data5
	ldr x2, =0x0047fff8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004800b8
	ldr x1, =check_data6
	ldr x2, =0x004800c0
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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
