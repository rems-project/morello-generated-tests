.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x25, 0xc9, 0x3e, 0x78, 0xdf, 0x3f, 0xc6, 0xc2, 0xe6, 0x34, 0x5e, 0x78, 0x2f, 0x58, 0xe2, 0xc2
	.byte 0x43, 0x30, 0xc2, 0xc2
.data
check_data5:
	.byte 0x3d, 0x0c, 0xfb, 0x39, 0x6d, 0xa4, 0x8b, 0x38, 0x5e, 0x75, 0x41, 0x38, 0xc0, 0xc3, 0x5b, 0xd3
	.byte 0xe1, 0x13, 0xc0, 0x5a, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0071ffa0000000000000000
	/* C2 */
	.octa 0x200080008000c000000000000043f040
	/* C3 */
	.octa 0xe00
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0xe20
	/* C9 */
	.octa 0xffffffffc0000e00
	/* C10 */
	.octa 0x1200
	/* C30 */
	.octa 0x40000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x20
	/* C2 */
	.octa 0x200080008000c000000000000043f040
	/* C3 */
	.octa 0xeba
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0xe03
	/* C9 */
	.octa 0xffffffffc0000e00
	/* C10 */
	.octa 0x1217
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0xc0071ffa000000000044103a
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000087020700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x783ec925 // strh_reg:aarch64/instrs/memory/single/general/register Rt:5 Rn:9 10:10 S:0 option:110 Rm:30 1:1 opc:00 111000:111000 size:01
	.inst 0xc2c63fdf // CSEL-C.CI-C Cd:31 Cn:30 11:11 cond:0011 Cm:6 11000010110:11000010110
	.inst 0x785e34e6 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:6 Rn:7 01:01 imm9:111100011 0:0 opc:01 111000:111000 size:01
	.inst 0xc2e2582f // CVTZ-C.CR-C Cd:15 Cn:1 0110:0110 1:1 0:0 Rm:2 11000010111:11000010111
	.inst 0xc2c23043 // BLRR-C-C 00011:00011 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.zero 258092
	.inst 0x39fb0c3d // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:1 imm12:111011000011 opc:11 111001:111001 size:00
	.inst 0x388ba46d // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:13 Rn:3 01:01 imm9:010111010 0:0 opc:10 111000:111000 size:00
	.inst 0x3841755e // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:10 01:01 imm9:000010111 0:0 opc:01 111000:111000 size:00
	.inst 0xd35bc3c0 // ubfm:aarch64/instrs/integer/bitfield Rd:0 Rn:30 imms:110000 immr:011011 N:1 100110:100110 opc:10 sf:1
	.inst 0x5ac013e1 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:1 Rn:31 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2c21080
	.zero 790440
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
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc2400983 // ldr c3, [x12, #2]
	.inst 0xc2400d85 // ldr c5, [x12, #3]
	.inst 0xc2401187 // ldr c7, [x12, #4]
	.inst 0xc2401589 // ldr c9, [x12, #5]
	.inst 0xc240198a // ldr c10, [x12, #6]
	.inst 0xc2401d9e // ldr c30, [x12, #7]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	ldr x12, =0x84
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260308c // ldr c12, [c4, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260108c // ldr c12, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x4, #0x2
	and x12, x12, x4
	cmp x12, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400184 // ldr c4, [x12, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400584 // ldr c4, [x12, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400984 // ldr c4, [x12, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400d84 // ldr c4, [x12, #3]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc2401184 // ldr c4, [x12, #4]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2401584 // ldr c4, [x12, #5]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2401984 // ldr c4, [x12, #6]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc2401d84 // ldr c4, [x12, #7]
	.inst 0xc2c4a521 // chkeq c9, c4
	b.ne comparison_fail
	.inst 0xc2402184 // ldr c4, [x12, #8]
	.inst 0xc2c4a541 // chkeq c10, c4
	b.ne comparison_fail
	.inst 0xc2402584 // ldr c4, [x12, #9]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc2402984 // ldr c4, [x12, #10]
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	.inst 0xc2402d84 // ldr c4, [x12, #11]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2403184 // ldr c4, [x12, #12]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001022
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c3
	ldr x1, =check_data2
	ldr x2, =0x000010c4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001400
	ldr x1, =check_data3
	ldr x2, =0x00001401
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0043f040
	ldr x1, =check_data5
	ldr x2, =0x0043f058
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
