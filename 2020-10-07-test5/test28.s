.section data0, #alloc, #write
	.zero 336
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3680
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0x9e, 0x51, 0xc0, 0xc2, 0x1e, 0x38, 0x91, 0xb9, 0xeb, 0xd4, 0x9b, 0x9a, 0xe1, 0xc7, 0x5a, 0xad
	.byte 0xe2, 0x93, 0xc0, 0xc2, 0x23, 0xf8, 0x4b, 0x29, 0xc1, 0x82, 0x58, 0x7c, 0x50, 0x04, 0xc0, 0xc2
	.byte 0x00, 0x08, 0xdf, 0xc2, 0x01, 0x52, 0xd2, 0xd8, 0x40, 0x13, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000000000004a3bdc
	/* C1 */
	.octa 0x400000
	/* C22 */
	.octa 0x1210
final_cap_values:
	/* C0 */
	.octa 0x4a3bdc
	/* C1 */
	.octa 0x400000
	/* C2 */
	.octa 0x1
	/* C3 */
	.octa 0xc2c2c2c2
	/* C16 */
	.octa 0x1
	/* C22 */
	.octa 0x1210
	/* C30 */
	.octa 0xc2c2c2c2
initial_SP_EL3_value:
	.octa 0xe00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008784660000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000005000700ffffffe0000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0519e // GCVALUE-R.C-C Rd:30 Cn:12 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xb991381e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:010001001110 opc:10 111001:111001 size:10
	.inst 0x9a9bd4eb // csinc:aarch64/instrs/integer/conditional/select Rd:11 Rn:7 o2:1 0:0 cond:1101 Rm:27 011010100:011010100 op:0 sf:1
	.inst 0xad5ac7e1 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:1 Rn:31 Rt2:10001 imm7:0110101 L:1 1011010:1011010 opc:10
	.inst 0xc2c093e2 // GCTAG-R.C-C Rd:2 Cn:31 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x294bf823 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:3 Rn:1 Rt2:11110 imm7:0010111 L:1 1010010:1010010 opc:00
	.inst 0x7c5882c1 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:1 Rn:22 00:00 imm9:110001000 0:0 opc:01 111100:111100 size:01
	.inst 0xc2c00450 // BUILD-C.C-C Cd:16 Cn:2 001:001 opc:00 0:0 Cm:0 11000010110:11000010110
	.inst 0xc2df0800 // SEAL-C.CC-C Cd:0 Cn:0 0010:0010 opc:00 Cm:31 11000010110:11000010110
	.inst 0xd8d25201 // prfm_lit:aarch64/instrs/memory/literal/general Rt:1 imm19:1101001001010010000 011000:011000 opc:11
	.inst 0xc2c21340
	.zero 48
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 674992
	.inst 0xc2c2c2c2
	.zero 373480
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400936 // ldr c22, [x9, #2]
	/* Set up flags and system registers */
	mov x9, #0x80000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603349 // ldr c9, [c26, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601349 // ldr c9, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x26, #0x9
	and x9, x9, x26
	cmp x9, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240013a // ldr c26, [x9, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240053a // ldr c26, [x9, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240093a // ldr c26, [x9, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400d3a // ldr c26, [x9, #3]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc240113a // ldr c26, [x9, #4]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc240153a // ldr c26, [x9, #5]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc240193a // ldr c26, [x9, #6]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0xc2c2
	mov x26, v1.d[0]
	cmp x9, x26
	b.ne comparison_fail
	ldr x9, =0x0
	mov x26, v1.d[1]
	cmp x9, x26
	b.ne comparison_fail
	ldr x9, =0xc2c2c2c2c2c2c2c2
	mov x26, v17.d[0]
	cmp x9, x26
	b.ne comparison_fail
	ldr x9, =0xc2c2c2c2c2c2c2c2
	mov x26, v17.d[1]
	cmp x9, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001150
	ldr x1, =check_data0
	ldr x2, =0x00001170
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001198
	ldr x1, =check_data1
	ldr x2, =0x0000119a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040005c
	ldr x1, =check_data3
	ldr x2, =0x00400064
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004a4d14
	ldr x1, =check_data4
	ldr x2, =0x004a4d18
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
