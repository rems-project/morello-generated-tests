.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xc4, 0x0b, 0xcb, 0xc2, 0x1f, 0xbd, 0x58, 0xfc, 0xe1, 0x23, 0xc5, 0x38, 0x48, 0xfe, 0x7f, 0x42
	.byte 0xfe, 0x57, 0x69, 0x0a, 0x01, 0x48, 0xc0, 0xc2, 0xd7, 0xe3, 0x50, 0x82, 0x5f, 0x70, 0x08, 0x39
	.byte 0xff, 0xf7, 0x05, 0x3c, 0x03, 0x91, 0xc1, 0xc2, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000000000000000000
	/* C2 */
	.octa 0x40000000000700330000000000001000
	/* C8 */
	.octa 0x800000004006c200000000000040c805
	/* C11 */
	.octa 0x2000000004490030040000000000400
	/* C18 */
	.octa 0x1000
	/* C23 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x40000000000000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000000700330000000000001000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x200000000000000000000000000
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x2000000004490030040000000000400
	/* C18 */
	.octa 0x1000
	/* C23 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc0000000580200040000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000082900070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000207006600ffffffffffc000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2cb0bc4 // SEAL-C.CC-C Cd:4 Cn:30 0010:0010 opc:00 Cm:11 11000010110:11000010110
	.inst 0xfc58bd1f // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:31 Rn:8 11:11 imm9:110001011 0:0 opc:01 111100:111100 size:11
	.inst 0x38c523e1 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:31 00:00 imm9:001010010 0:0 opc:11 111000:111000 size:00
	.inst 0x427ffe48 // ALDAR-R.R-32 Rt:8 Rn:18 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x0a6957fe // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:31 imm6:010101 Rm:9 N:1 shift:01 01010:01010 opc:00 sf:0
	.inst 0xc2c04801 // UNSEAL-C.CC-C Cd:1 Cn:0 0010:0010 opc:01 Cm:0 11000010110:11000010110
	.inst 0x8250e3d7 // ASTR-C.RI-C Ct:23 Rn:30 op:00 imm9:100001110 L:0 1000001001:1000001001
	.inst 0x3908705f // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:2 imm12:001000011100 opc:00 111001:111001 size:00
	.inst 0x3c05f7ff // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:31 Rn:31 01:01 imm9:001011111 0:0 opc:00 111100:111100 size:00
	.inst 0xc2c19103 // CLRTAG-C.C-C Cd:3 Cn:8 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c211c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400682 // ldr c2, [x20, #1]
	.inst 0xc2400a88 // ldr c8, [x20, #2]
	.inst 0xc2400e8b // ldr c11, [x20, #3]
	.inst 0xc2401292 // ldr c18, [x20, #4]
	.inst 0xc2401697 // ldr c23, [x20, #5]
	.inst 0xc2401a9e // ldr c30, [x20, #6]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850038
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031d4 // ldr c20, [c14, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826011d4 // ldr c20, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240028e // ldr c14, [x20, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240068e // ldr c14, [x20, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400a8e // ldr c14, [x20, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400e8e // ldr c14, [x20, #3]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc240128e // ldr c14, [x20, #4]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc240168e // ldr c14, [x20, #5]
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	.inst 0xc2401a8e // ldr c14, [x20, #6]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc2401e8e // ldr c14, [x20, #7]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc240228e // ldr c14, [x20, #8]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc240268e // ldr c14, [x20, #9]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x14, v31.d[0]
	cmp x20, x14
	b.ne comparison_fail
	ldr x20, =0x0
	mov x14, v31.d[1]
	cmp x20, x14
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
	ldr x0, =0x00001052
	ldr x1, =check_data1
	ldr x2, =0x00001053
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010c4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011a0
	ldr x1, =check_data3
	ldr x2, =0x000011b0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0000121c
	ldr x1, =check_data4
	ldr x2, =0x0000121d
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
	ldr x0, =0x0040c790
	ldr x1, =check_data6
	ldr x2, =0x0040c798
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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
