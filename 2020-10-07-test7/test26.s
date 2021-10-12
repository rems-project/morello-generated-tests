.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x40, 0xbc, 0x18, 0xe2, 0x20, 0xfc, 0x06, 0xb8, 0xdf, 0x1a, 0x82, 0xe2, 0xb0, 0x65, 0x5f, 0x6a
	.byte 0x87, 0x01, 0x16, 0xfa, 0x6e, 0x6a, 0xd1, 0xc2, 0x20, 0xfc, 0x9f, 0x08, 0x9a, 0x34, 0x07, 0x78
	.byte 0x21, 0x43, 0xb4, 0x35, 0x5e, 0x00, 0x01, 0xfa, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xffffffffffffff91
	/* C2 */
	.octa 0x80000000000300050000000000001400
	/* C4 */
	.octa 0xfe4
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x800000000001000700000000003fffdf
	/* C26 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000000300050000000000001400
	/* C4 */
	.octa 0x1057
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x800000000001000700000000003fffdf
	/* C26 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000400010000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe218bc40 // ALDURSB-R.RI-32 Rt:0 Rn:2 op2:11 imm9:110001011 V:0 op1:00 11100010:11100010
	.inst 0xb806fc20 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:1 11:11 imm9:001101111 0:0 opc:00 111000:111000 size:10
	.inst 0xe2821adf // ALDURSW-R.RI-64 Rt:31 Rn:22 op2:10 imm9:000100001 V:0 op1:10 11100010:11100010
	.inst 0x6a5f65b0 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:16 Rn:13 imm6:011001 Rm:31 N:0 shift:01 01010:01010 opc:11 sf:0
	.inst 0xfa160187 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:7 Rn:12 000000:000000 Rm:22 11010000:11010000 S:1 op:1 sf:1
	.inst 0xc2d16a6e // ORRFLGS-C.CR-C Cd:14 Cn:19 1010:1010 opc:01 Rm:17 11000010110:11000010110
	.inst 0x089ffc20 // stlrb:aarch64/instrs/memory/ordered Rt:0 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x7807349a // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:26 Rn:4 01:01 imm9:001110011 0:0 opc:00 111000:111000 size:01
	.inst 0x35b44321 // cbnz:aarch64/instrs/branch/conditional/compare Rt:1 imm19:1011010001000011001 op:1 011010:011010 sf:0
	.inst 0xfa01005e // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:2 000000:000000 Rm:1 11010000:11010000 S:1 op:1 sf:1
	.inst 0xc2c21320
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e4 // ldr c4, [x15, #2]
	.inst 0xc2400df3 // ldr c19, [x15, #3]
	.inst 0xc24011f6 // ldr c22, [x15, #4]
	.inst 0xc24015fa // ldr c26, [x15, #5]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260332f // ldr c15, [c25, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260132f // ldr c15, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x25, #0x4
	and x15, x15, x25
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f9 // ldr c25, [x15, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24005f9 // ldr c25, [x15, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24009f9 // ldr c25, [x15, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400df9 // ldr c25, [x15, #3]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc24011f9 // ldr c25, [x15, #4]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc24015f9 // ldr c25, [x15, #5]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc24019f9 // ldr c25, [x15, #6]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc2401df9 // ldr c25, [x15, #7]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000138b
	ldr x1, =check_data1
	ldr x2, =0x0000138c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe4
	ldr x1, =check_data2
	ldr x2, =0x00001fe6
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
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
