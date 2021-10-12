.section data0, #alloc, #write
	.zero 192
	.byte 0x26, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 3872
.data
check_data0:
	.zero 40
.data
check_data1:
	.byte 0x26, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xdf, 0x57, 0x79, 0xe2, 0x52, 0x7c, 0x3f, 0x42, 0x42, 0x24, 0xc2, 0xc2, 0xbf, 0xdd, 0xe2, 0xc2
	.byte 0xfe, 0x2f, 0x46, 0x62, 0x60, 0x65, 0x1b, 0xb2, 0x65, 0x43, 0x9a, 0x6c, 0xc1, 0x6f, 0x5e, 0x39
	.byte 0xfe, 0x53, 0xc4, 0xac, 0x9d, 0xc4, 0xdf, 0x82, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x40000000000080080000000000001000
	/* C4 */
	.octa 0x800000000001000500000000004ffffe
	/* C13 */
	.octa 0x80100000400000040000000000001020
	/* C18 */
	.octa 0x0
	/* C27 */
	.octa 0x1018
	/* C30 */
	.octa 0x80000000240400030000000000001401
final_cap_values:
	/* C0 */
	.octa 0x7fffffe07fffffe0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4000000000008008ffffffffffffffff
	/* C4 */
	.octa 0x800000000001000500000000004ffffe
	/* C11 */
	.octa 0x101800000000000000000000000
	/* C13 */
	.octa 0x80100000400000040000000000001020
	/* C18 */
	.octa 0x0
	/* C27 */
	.octa 0x11b8
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1426
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x00000000000010d0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe27957df // ALDUR-V.RI-H Rt:31 Rn:30 op2:01 imm9:110010101 V:1 op1:01 11100010:11100010
	.inst 0x423f7c52 // ASTLRB-R.R-B Rt:18 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c22442 // CPYTYPE-C.C-C Cd:2 Cn:2 001:001 opc:01 0:0 Cm:2 11000010110:11000010110
	.inst 0xc2e2ddbf // ALDR-C.RRB-C Ct:31 Rn:13 1:1 L:1 S:1 option:110 Rm:2 11000010111:11000010111
	.inst 0x62462ffe // LDNP-C.RIB-C Ct:30 Rn:31 Ct2:01011 imm7:0001100 L:1 011000100:011000100
	.inst 0xb21b6560 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:11 imms:011001 immr:011011 N:0 100100:100100 opc:01 sf:1
	.inst 0x6c9a4365 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:5 Rn:27 Rt2:10000 imm7:0110100 L:0 1011001:1011001 opc:01
	.inst 0x395e6fc1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:30 imm12:011110011011 opc:01 111001:111001 size:00
	.inst 0xacc453fe // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:30 Rn:31 Rt2:10100 imm7:0001000 L:1 1011001:1011001 opc:10
	.inst 0x82dfc49d // ALDRSB-R.RRB-32 Rt:29 Rn:4 opc:01 S:0 option:110 Rm:31 0:0 L:1 100000101:100000101
	.inst 0xc2c210c0
	.zero 1048532
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
	.inst 0xc2400182 // ldr c2, [x12, #0]
	.inst 0xc2400584 // ldr c4, [x12, #1]
	.inst 0xc240098d // ldr c13, [x12, #2]
	.inst 0xc2400d92 // ldr c18, [x12, #3]
	.inst 0xc240119b // ldr c27, [x12, #4]
	.inst 0xc240159e // ldr c30, [x12, #5]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q5, =0x0
	ldr q16, =0x0
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850038
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030cc // ldr c12, [c6, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826010cc // ldr c12, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
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
	.inst 0xc2400186 // ldr c6, [x12, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400586 // ldr c6, [x12, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400986 // ldr c6, [x12, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400d86 // ldr c6, [x12, #3]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2401186 // ldr c6, [x12, #4]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2401586 // ldr c6, [x12, #5]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2401986 // ldr c6, [x12, #6]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2401d86 // ldr c6, [x12, #7]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2402186 // ldr c6, [x12, #8]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402586 // ldr c6, [x12, #9]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x6, v5.d[0]
	cmp x12, x6
	b.ne comparison_fail
	ldr x12, =0x0
	mov x6, v5.d[1]
	cmp x12, x6
	b.ne comparison_fail
	ldr x12, =0x0
	mov x6, v16.d[0]
	cmp x12, x6
	b.ne comparison_fail
	ldr x12, =0x0
	mov x6, v16.d[1]
	cmp x12, x6
	b.ne comparison_fail
	ldr x12, =0x0
	mov x6, v20.d[0]
	cmp x12, x6
	b.ne comparison_fail
	ldr x12, =0x0
	mov x6, v20.d[1]
	cmp x12, x6
	b.ne comparison_fail
	ldr x12, =0x0
	mov x6, v30.d[0]
	cmp x12, x6
	b.ne comparison_fail
	ldr x12, =0x0
	mov x6, v30.d[1]
	cmp x12, x6
	b.ne comparison_fail
	ldr x12, =0x0
	mov x6, v31.d[0]
	cmp x12, x6
	b.ne comparison_fail
	ldr x12, =0x0
	mov x6, v31.d[1]
	cmp x12, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001028
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c0
	ldr x1, =check_data1
	ldr x2, =0x000010e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001396
	ldr x1, =check_data2
	ldr x2, =0x00001398
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001bc1
	ldr x1, =check_data3
	ldr x2, =0x00001bc2
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
