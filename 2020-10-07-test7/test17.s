.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x18, 0x1e, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xff, 0x27, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xde, 0x70, 0x87, 0xe2, 0x20, 0xcc, 0xc1, 0x82, 0x01, 0x10, 0xc2, 0xc2, 0xc2, 0x93, 0x94, 0xf8
	.byte 0x3a, 0xb0, 0x13, 0xd8, 0xdf, 0x51, 0xc1, 0xc2, 0x0e, 0x60, 0x42, 0x3a, 0xd6, 0x67, 0x4e, 0x82
	.byte 0x82, 0x86, 0x02, 0x1b, 0x80, 0x86, 0x3d, 0xa9, 0x80, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x27fffc
	/* C6 */
	.octa 0x1109
	/* C20 */
	.octa 0x40000000000100050000000000002000
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x1e18
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x27fffc
	/* C6 */
	.octa 0x1109
	/* C20 */
	.octa 0x40000000000100050000000000002000
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x1e18
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe28770de // ASTUR-R.RI-32 Rt:30 Rn:6 op2:00 imm9:001110111 V:0 op1:10 11100010:11100010
	.inst 0x82c1cc20 // ALDRH-R.RRB-32 Rt:0 Rn:1 opc:11 S:0 option:110 Rm:1 0:0 L:1 100000101:100000101
	.inst 0xc2c21001 // CHKSLD-C-C 00001:00001 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xf89493c2 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:30 00:00 imm9:101001001 0:0 opc:10 111000:111000 size:11
	.inst 0xd813b03a // prfm_lit:aarch64/instrs/memory/literal/general Rt:26 imm19:0001001110110000001 011000:011000 opc:11
	.inst 0xc2c151df // CFHI-R.C-C Rd:31 Cn:14 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x3a42600e // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1110 0:0 Rn:0 00:00 cond:0110 Rm:2 111010010:111010010 op:0 sf:0
	.inst 0x824e67d6 // ASTRB-R.RI-B Rt:22 Rn:30 op:01 imm9:011100110 L:0 1000001001:1000001001
	.inst 0x1b028682 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:2 Rn:20 Ra:1 o0:1 Rm:2 0011011000:0011011000 sf:0
	.inst 0xa93d8680 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:20 Rt2:00001 imm7:1111011 L:0 1010010:1010010 opc:10
	.inst 0xc2c21180
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400786 // ldr c6, [x28, #1]
	.inst 0xc2400b94 // ldr c20, [x28, #2]
	.inst 0xc2400f96 // ldr c22, [x28, #3]
	.inst 0xc240139e // ldr c30, [x28, #4]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260319c // ldr c28, [c12, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260119c // ldr c28, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x12, #0xf
	and x28, x28, x12
	cmp x28, #0xe
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038c // ldr c12, [x28, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240078c // ldr c12, [x28, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400b8c // ldr c12, [x28, #2]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc2400f8c // ldr c12, [x28, #3]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc240138c // ldr c12, [x28, #4]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc240178c // ldr c12, [x28, #5]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001180
	ldr x1, =check_data0
	ldr x2, =0x00001184
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001efe
	ldr x1, =check_data1
	ldr x2, =0x00001eff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fd8
	ldr x1, =check_data2
	ldr x2, =0x00001fe8
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
	ldr x0, =0x004ffff8
	ldr x1, =check_data4
	ldr x2, =0x004ffffa
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
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
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
