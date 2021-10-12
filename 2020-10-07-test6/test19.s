.section data0, #alloc, #write
	.zero 2048
	.byte 0x10, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x10, 0x11
.data
check_data5:
	.byte 0x56, 0xd0, 0xc1, 0xc2, 0xc2, 0xff, 0xdf, 0x48, 0x3f, 0x89, 0xc1, 0xc2, 0xde, 0xe3, 0x9b, 0x1a
	.byte 0xe1, 0x9f, 0x13, 0xa2, 0x4f, 0x36, 0x42, 0x3c, 0x2c, 0xf3, 0x10, 0xe2, 0x20, 0x10, 0xc0, 0xc2
	.byte 0x4a, 0x48, 0x76, 0xf8, 0x99, 0x5a, 0x20, 0xaa, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x400000080000000000000000
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x7000700ffffffffffe000
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0x1000
	/* C25 */
	.octa 0x400000006001001e0000000000001100
	/* C30 */
	.octa 0x1800
final_cap_values:
	/* C0 */
	.octa 0x8
	/* C1 */
	.octa 0x400000080000000000000000
	/* C2 */
	.octa 0x1110
	/* C9 */
	.octa 0x7000700ffffffffffe000
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0x1023
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x1800
initial_SP_EL3_value:
	.octa 0x1d10
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000000007000400ffffffffff0000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1d056 // CPY-C.C-C Cd:22 Cn:2 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x48dfffc2 // ldarh:aarch64/instrs/memory/ordered Rt:2 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c1893f // CHKSSU-C.CC-C Cd:31 Cn:9 0010:0010 opc:10 Cm:1 11000010110:11000010110
	.inst 0x1a9be3de // csel:aarch64/instrs/integer/conditional/select Rd:30 Rn:30 o2:0 0:0 cond:1110 Rm:27 011010100:011010100 op:0 sf:0
	.inst 0xa2139fe1 // STR-C.RIBW-C Ct:1 Rn:31 11:11 imm9:100111001 0:0 opc:00 10100010:10100010
	.inst 0x3c42364f // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:15 Rn:18 01:01 imm9:000100011 0:0 opc:01 111100:111100 size:00
	.inst 0xe210f32c // ASTURB-R.RI-32 Rt:12 Rn:25 op2:00 imm9:100001111 V:0 op1:00 11100010:11100010
	.inst 0xc2c01020 // GCBASE-R.C-C Rd:0 Cn:1 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xf876484a // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:10 Rn:2 10:10 S:0 option:010 Rm:22 1:1 opc:01 111000:111000 size:11
	.inst 0xaa205a99 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:25 Rn:20 imm6:010110 Rm:0 N:1 shift:00 01010:01010 opc:01 sf:1
	.inst 0xc2c21380
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a1 // ldr c1, [x29, #0]
	.inst 0xc24007a2 // ldr c2, [x29, #1]
	.inst 0xc2400ba9 // ldr c9, [x29, #2]
	.inst 0xc2400fac // ldr c12, [x29, #3]
	.inst 0xc24013b2 // ldr c18, [x29, #4]
	.inst 0xc24017b9 // ldr c25, [x29, #5]
	.inst 0xc2401bbe // ldr c30, [x29, #6]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850032
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260339d // ldr c29, [c28, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260139d // ldr c29, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x28, #0xf
	and x29, x29, x28
	cmp x29, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003bc // ldr c28, [x29, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24007bc // ldr c28, [x29, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400bbc // ldr c28, [x29, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400fbc // ldr c28, [x29, #3]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc24013bc // ldr c28, [x29, #4]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc24017bc // ldr c28, [x29, #5]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc2401bbc // ldr c28, [x29, #6]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc2401fbc // ldr c28, [x29, #7]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc24023bc // ldr c28, [x29, #8]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x28, v15.d[0]
	cmp x29, x28
	b.ne comparison_fail
	ldr x29, =0x0
	mov x28, v15.d[1]
	cmp x29, x28
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
	ldr x0, =0x0000100f
	ldr x1, =check_data1
	ldr x2, =0x00001010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a0
	ldr x1, =check_data2
	ldr x2, =0x000010b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001110
	ldr x1, =check_data3
	ldr x2, =0x00001118
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001802
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
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
