.section data0, #alloc, #write
	.byte 0xf0, 0x0f, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 4080
.data
check_data0:
	.byte 0xf0, 0x0f, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0x01, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x02, 0xaf, 0xb0, 0xb9, 0x58, 0x00, 0x02, 0xfa, 0x5f, 0x3e, 0x03, 0xd5, 0x80, 0x52, 0xda, 0xc2
.data
check_data4:
	.byte 0xf7, 0x9d, 0xe6, 0x39, 0x1e, 0x64, 0xc0, 0x82, 0xe0, 0x1f, 0xa1, 0xa8, 0x21, 0x98, 0xe2, 0xc2
	.byte 0x41, 0x29, 0x03, 0xb8, 0x2f, 0x70, 0x41, 0x7a, 0x20, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000000801
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x1fc6
	/* C15 */
	.octa 0x407657
	/* C20 */
	.octa 0x900000000003000700000000000012e0
	/* C24 */
	.octa 0x400014
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000000801
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x1fc6
	/* C15 */
	.octa 0x407657
	/* C20 */
	.octa 0x900000000003000700000000000012e0
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x40
initial_csp_value:
	.octa 0x1fa0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010140050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb9b0af02 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:24 imm12:110000101011 opc:10 111001:111001 size:10
	.inst 0xfa020058 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:24 Rn:2 000000:000000 Rm:2 11010000:11010000 S:1 op:1 sf:1
	.inst 0xd5033e5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1110 11010101000000110011:11010101000000110011
	.inst 0xc2da5280 // BR-CI-C 0:0 0000:0000 Cn:20 100:100 imm7:1010010 110000101101:110000101101
	.zero 4064
	.inst 0x39e69df7 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:23 Rn:15 imm12:100110100111 opc:11 111001:111001 size:00
	.inst 0x82c0641e // ALDRSB-R.RRB-32 Rt:30 Rn:0 opc:01 S:0 option:011 Rm:0 0:0 L:1 100000101:100000101
	.inst 0xa8a11fe0 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:0 Rn:31 Rt2:00111 imm7:1000010 L:0 1010001:1010001 opc:10
	.inst 0xc2e29821 // SUBS-R.CC-C Rd:1 Cn:1 100110:100110 Cm:2 11000010111:11000010111
	.inst 0xb8032941 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:10 10:10 imm9:000110010 0:0 opc:00 111000:111000 size:10
	.inst 0x7a41702f // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1111 0:0 Rn:1 00:00 cond:0111 Rm:1 111010010:111010010 op:1 sf:0
	.inst 0xc2c21320
	.zero 1044468
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b67 // ldr c7, [x27, #2]
	.inst 0xc2400f6a // ldr c10, [x27, #3]
	.inst 0xc240136f // ldr c15, [x27, #4]
	.inst 0xc2401774 // ldr c20, [x27, #5]
	.inst 0xc2401b78 // ldr c24, [x27, #6]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_csp_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x3085003a
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260333b // ldr c27, [c25, #3]
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	.inst 0x8260133b // ldr c27, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x25, #0xf
	and x27, x27, x25
	cmp x27, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400379 // ldr c25, [x27, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400779 // ldr c25, [x27, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400b79 // ldr c25, [x27, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400f79 // ldr c25, [x27, #3]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc2401379 // ldr c25, [x27, #4]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc2401779 // ldr c25, [x27, #5]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2401b79 // ldr c25, [x27, #6]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2401f79 // ldr c25, [x27, #7]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2402379 // ldr c25, [x27, #8]
	.inst 0xc2d9a7c1 // chkeq c30, c25
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
	ldr x0, =0x00001fa0
	ldr x1, =check_data1
	ldr x2, =0x00001fb0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff8
	ldr x1, =check_data2
	ldr x2, =0x00001ffc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400ff0
	ldr x1, =check_data4
	ldr x2, =0x0040100c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004030c0
	ldr x1, =check_data5
	ldr x2, =0x004030c4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00407ffe
	ldr x1, =check_data6
	ldr x2, =0x00407fff
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
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
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
