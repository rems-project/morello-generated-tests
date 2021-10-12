.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 20
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x01, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x83, 0x00, 0x00, 0x40, 0x00, 0x40
.data
check_data5:
	.byte 0x01, 0x84, 0xd0, 0xc2, 0x20, 0xb0, 0x52, 0x82, 0x3f, 0x8e, 0x05, 0xb8, 0x9f, 0x86, 0xc8, 0x28
	.byte 0xfd, 0xd3, 0xe1, 0xc2, 0xee, 0x2f, 0xbd, 0xa8, 0x5e, 0xa8, 0x90, 0xb8, 0xc2, 0x20, 0xc0, 0x1a
	.byte 0x05, 0x90, 0x57, 0xe2, 0xd3, 0x13, 0x91, 0xf8, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40004000008300070000000000001101
	/* C1 */
	.octa 0x48000000600100020000000000000d20
	/* C2 */
	.octa 0x2002
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x60010000000000000000a001
	/* C17 */
	.octa 0x1008
	/* C20 */
	.octa 0x100c
final_cap_values:
	/* C0 */
	.octa 0x40004000008300070000000000001101
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x60010000000000000000a001
	/* C17 */
	.octa 0x1060
	/* C20 */
	.octa 0x1050
	/* C29 */
	.octa 0x800000000e00000000001000
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x800000000000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000300070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d08401 // CHKSS-_.CC-C 00001:00001 Cn:0 001:001 opc:00 1:1 Cm:16 11000010110:11000010110
	.inst 0x8252b020 // ASTR-C.RI-C Ct:0 Rn:1 op:00 imm9:100101011 L:0 1000001001:1000001001
	.inst 0xb8058e3f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:17 11:11 imm9:001011000 0:0 opc:00 111000:111000 size:10
	.inst 0x28c8869f // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:31 Rn:20 Rt2:00001 imm7:0010001 L:1 1010001:1010001 opc:00
	.inst 0xc2e1d3fd // EORFLGS-C.CI-C Cd:29 Cn:31 0:0 10:10 imm8:00001110 11000010111:11000010111
	.inst 0xa8bd2fee // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:14 Rn:31 Rt2:01011 imm7:1111010 L:0 1010001:1010001 opc:10
	.inst 0xb890a85e // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:2 10:10 imm9:100001010 0:0 opc:10 111000:111000 size:10
	.inst 0x1ac020c2 // lslv:aarch64/instrs/integer/shift/variable Rd:2 Rn:6 op2:00 0010:0010 Rm:0 0011010110:0011010110 sf:0
	.inst 0xe2579005 // ASTURH-R.RI-32 Rt:5 Rn:0 op2:00 imm9:101111001 V:0 op1:01 11100010:11100010
	.inst 0xf89113d3 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:19 Rn:30 00:00 imm9:100010001 0:0 opc:10 111000:111000 size:11
	.inst 0xc2c21180
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2400d45 // ldr c5, [x10, #3]
	.inst 0xc240114b // ldr c11, [x10, #4]
	.inst 0xc240154e // ldr c14, [x10, #5]
	.inst 0xc2401950 // ldr c16, [x10, #6]
	.inst 0xc2401d51 // ldr c17, [x10, #7]
	.inst 0xc2402154 // ldr c20, [x10, #8]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_csp_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850038
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260318a // ldr c10, [c12, #3]
	.inst 0xc28b412a // msr ddc_el3, c10
	isb
	.inst 0x8260118a // ldr c10, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr ddc_el3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x12, #0xf
	and x10, x10, x12
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240014c // ldr c12, [x10, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240054c // ldr c12, [x10, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240094c // ldr c12, [x10, #2]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc2400d4c // ldr c12, [x10, #3]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc240114c // ldr c12, [x10, #4]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc240154c // ldr c12, [x10, #5]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240194c // ldr c12, [x10, #6]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc2401d4c // ldr c12, [x10, #7]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc240214c // ldr c12, [x10, #8]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc240254c // ldr c12, [x10, #9]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001064
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000107a
	ldr x1, =check_data2
	ldr x2, =0x0000107c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f0c
	ldr x1, =check_data3
	ldr x2, =0x00001f10
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fd0
	ldr x1, =check_data4
	ldr x2, =0x00001fe0
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
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr ddc_el3, c10
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
