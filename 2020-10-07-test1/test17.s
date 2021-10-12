.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x42, 0x40, 0x52, 0x78, 0x1e, 0x7f, 0x9f, 0x48, 0x5e, 0x31, 0x51, 0x98, 0x22, 0x50, 0xc2, 0xc2
	.byte 0x3b, 0x00, 0x0c, 0x7a, 0x59, 0xfb, 0x9f, 0x82, 0xff, 0x6f, 0xe0, 0xc2, 0x02, 0x30, 0xc2, 0xc2
	.byte 0x01, 0x87, 0xde, 0xc2, 0x05, 0xc1, 0xdb, 0xe2, 0x80, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000200140050000000000400020
	/* C1 */
	.octa 0x20008000000100050000000000400010
	/* C2 */
	.octa 0x2000
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x40000000000100050000000000001044
	/* C24 */
	.octa 0x420010020000000000001000
	/* C26 */
	.octa 0x80000000000100050000000000001fdc
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x20008000200140050000000000400020
	/* C1 */
	.octa 0x20008000000100050000000000400010
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x40000000000100050000000000001044
	/* C24 */
	.octa 0x420010020000000000001000
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x80000000000100050000000000001fdc
	/* C30 */
	.octa 0x20008000000100050000000000400020
initial_SP_EL3_value:
	.octa 0x9010000007730007ffffffffffc010e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa000800006c600e10000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000700060000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001100
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78524042 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:2 00:00 imm9:100100100 0:0 opc:01 111000:111000 size:01
	.inst 0x489f7f1e // stllrh:aarch64/instrs/memory/ordered Rt:30 Rn:24 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x9851315e // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:30 imm19:0101000100110001010 011000:011000 opc:10
	.inst 0xc2c25022 // RETS-C-C 00010:00010 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x7a0c003b // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:27 Rn:1 000000:000000 Rm:12 11010000:11010000 S:1 op:1 sf:0
	.inst 0x829ffb59 // ALDRSH-R.RRB-64 Rt:25 Rn:26 opc:10 S:1 option:111 Rm:31 0:0 L:0 100000101:100000101
	.inst 0xc2e06fff // ALDR-C.RRB-C Ct:31 Rn:31 1:1 L:1 S:0 option:011 Rm:0 11000010111:11000010111
	.inst 0xc2c23002 // BLRS-C-C 00010:00010 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2de8701 // CHKSS-_.CC-C 00001:00001 Cn:24 001:001 opc:00 1:1 Cm:30 11000010110:11000010110
	.inst 0xe2dbc105 // ASTUR-R.RI-64 Rt:5 Rn:8 op2:00 imm9:110111100 V:0 op1:11 11100010:11100010
	.inst 0xc2c21280
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
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2400de5 // ldr c5, [x15, #3]
	.inst 0xc24011e8 // ldr c8, [x15, #4]
	.inst 0xc24015f8 // ldr c24, [x15, #5]
	.inst 0xc24019fa // ldr c26, [x15, #6]
	.inst 0xc2401dfe // ldr c30, [x15, #7]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x3085003a
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260328f // ldr c15, [c20, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260128f // ldr c15, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
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
	mov x20, #0xf
	and x15, x15, x20
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f4 // ldr c20, [x15, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24005f4 // ldr c20, [x15, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24009f4 // ldr c20, [x15, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400df4 // ldr c20, [x15, #3]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc24011f4 // ldr c20, [x15, #4]
	.inst 0xc2d4a501 // chkeq c8, c20
	b.ne comparison_fail
	.inst 0xc24015f4 // ldr c20, [x15, #5]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc24019f4 // ldr c20, [x15, #6]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc2401df4 // ldr c20, [x15, #7]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc24021f4 // ldr c20, [x15, #8]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f24
	ldr x1, =check_data2
	ldr x2, =0x00001f26
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fdc
	ldr x1, =check_data3
	ldr x2, =0x00001fde
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
	ldr x0, =0x004a2630
	ldr x1, =check_data5
	ldr x2, =0x004a2634
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
