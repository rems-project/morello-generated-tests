.section data0, #alloc, #write
	.zero 1184
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x40, 0x00, 0x08
	.zero 2896
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x40, 0x00, 0x08
	.byte 0xc0, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x40, 0x00, 0x80
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x40, 0x00, 0x08
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xff, 0xb3, 0x3f, 0xeb, 0x5e, 0xa0, 0x63, 0x82, 0xe1, 0x6a, 0x06, 0xe2, 0x41, 0xfe, 0x9f, 0x88
	.byte 0xfe, 0x5d, 0x88, 0x62, 0x4a, 0x74, 0x2a, 0xe2, 0xc1, 0xe3, 0xcd, 0xc2, 0xe3, 0xca, 0x60, 0x82
	.byte 0x2f, 0x81, 0xdd, 0xd8, 0x33, 0xd0, 0xc1, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x90100000000700070000000000001100
	/* C15 */
	.octa 0xf00
	/* C18 */
	.octa 0x1720
	/* C23 */
	.octa 0x800040000000040000000000004000c0
final_cap_values:
	/* C2 */
	.octa 0x90100000000700070000000000001100
	/* C3 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C18 */
	.octa 0x1720
	/* C23 */
	.octa 0x800040000000040000000000004000c0
	/* C30 */
	.octa 0x8004001000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002f0620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x48000000000000000000000000008050
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000014a0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xeb3fb3ff // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:31 imm3:100 option:101 Rm:31 01011001:01011001 S:1 op:1 sf:1
	.inst 0x8263a05e // ALDR-C.RI-C Ct:30 Rn:2 op:00 imm9:000111010 L:1 1000001001:1000001001
	.inst 0xe2066ae1 // ALDURSB-R.RI-64 Rt:1 Rn:23 op2:10 imm9:001100110 V:0 op1:00 11100010:11100010
	.inst 0x889ffe41 // stlr:aarch64/instrs/memory/ordered Rt:1 Rn:18 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x62885dfe // STP-C.RIBW-C Ct:30 Rn:15 Ct2:10111 imm7:0010000 L:0 011000101:011000101
	.inst 0xe22a744a // ALDUR-V.RI-B Rt:10 Rn:2 op2:01 imm9:010100111 V:1 op1:00 11100010:11100010
	.inst 0xc2cde3c1 // SCFLGS-C.CR-C Cd:1 Cn:30 111000:111000 Rm:13 11000010110:11000010110
	.inst 0x8260cae3 // ALDR-R.RI-32 Rt:3 Rn:23 op:10 imm9:000001100 L:1 1000001001:1000001001
	.inst 0xd8dd812f // prfm_lit:aarch64/instrs/memory/literal/general Rt:15 imm19:1101110110000001001 011000:011000 opc:11
	.inst 0xc2c1d033 // CPY-C.C-C Cd:19 Cn:1 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xc2c21180
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x0, cptr_el3
	orr x0, x0, #0x200
	msr cptr_el3, x0
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
	ldr x0, =initial_cap_values
	.inst 0xc2400002 // ldr c2, [x0, #0]
	.inst 0xc240040f // ldr c15, [x0, #1]
	.inst 0xc2400812 // ldr c18, [x0, #2]
	.inst 0xc2400c17 // ldr c23, [x0, #3]
	/* Set up flags and system registers */
	mov x0, #0x00000000
	msr nzcv, x0
	ldr x0, =0x200
	msr CPTR_EL3, x0
	ldr x0, =0x30850030
	msr SCTLR_EL3, x0
	ldr x0, =0x4
	msr S3_6_C1_C2_2, x0 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603180 // ldr c0, [c12, #3]
	.inst 0xc28b4120 // msr ddc_el3, c0
	isb
	.inst 0x82601180 // ldr c0, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21000 // br c0
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b000 // cvtp c0, x0
	.inst 0xc2df4000 // scvalue c0, c0, x31
	.inst 0xc28b4120 // msr ddc_el3, c0
	isb
	/* Check processor flags */
	mrs x0, nzcv
	ubfx x0, x0, #28, #4
	mov x12, #0x3
	and x0, x0, x12
	cmp x0, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x0, =final_cap_values
	.inst 0xc240000c // ldr c12, [x0, #0]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc240040c // ldr c12, [x0, #1]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc240080c // ldr c12, [x0, #2]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc2400c0c // ldr c12, [x0, #3]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc240100c // ldr c12, [x0, #4]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc240140c // ldr c12, [x0, #5]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x0, =0x0
	mov x12, v10.d[0]
	cmp x0, x12
	b.ne comparison_fail
	ldr x0, =0x0
	mov x12, v10.d[1]
	cmp x0, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011a7
	ldr x1, =check_data1
	ldr x2, =0x000011a8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014a0
	ldr x1, =check_data2
	ldr x2, =0x000014b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001720
	ldr x1, =check_data3
	ldr x2, =0x00001724
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
	ldr x0, =0x004000f0
	ldr x1, =check_data5
	ldr x2, =0x004000f4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400126
	ldr x1, =check_data6
	ldr x2, =0x00400127
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
	.inst 0xc2c5b000 // cvtp c0, x0
	.inst 0xc2df4000 // scvalue c0, c0, x31
	.inst 0xc28b4120 // msr ddc_el3, c0
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
