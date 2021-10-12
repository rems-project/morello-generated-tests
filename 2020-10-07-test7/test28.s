.section data0, #alloc, #write
	.zero 240
	.byte 0x10, 0x1d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x4c
	.zero 3840
.data
check_data0:
	.byte 0x10, 0x1d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x4c
	.byte 0x28, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x10, 0x1d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x10, 0x1d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x4c
.data
check_data4:
	.byte 0x3e, 0xb0, 0xc7, 0x42, 0x8f, 0xe2, 0xa8, 0xb9, 0x5e, 0xbc, 0x5b, 0x82, 0x03, 0x10, 0xc2, 0xc2
.data
check_data5:
	.byte 0xfa, 0xe3, 0x27, 0x4b, 0xde, 0x73, 0x42, 0x82, 0x02, 0xe1, 0x85, 0xe2, 0x22, 0x98, 0xf3, 0xc2
	.byte 0x56, 0x83, 0xf4, 0xc2, 0xe2, 0xac, 0x91, 0xe2, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x200000000201c0050000000000400014
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x40000000600007f10000000000000828
	/* C7 */
	.octa 0x40000000600000040000000000001c06
	/* C8 */
	.octa 0x400000005204101800000000000010a2
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x400024
final_cap_values:
	/* C0 */
	.octa 0x200000000201c0050000000000400014
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x1
	/* C7 */
	.octa 0x40000000600000040000000000001c06
	/* C8 */
	.octa 0x400000005204101800000000000010a2
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x400024
	/* C30 */
	.octa 0x4c000000000700060000000000001d10
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000401100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x901000000003000700fffe0000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010f0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x42c7b03e // LDP-C.RIB-C Ct:30 Rn:1 Ct2:01100 imm7:0001111 L:1 010000101:010000101
	.inst 0xb9a8e28f // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:15 Rn:20 imm12:101000111000 opc:10 111001:111001 size:10
	.inst 0x825bbc5e // ASTR-R.RI-64 Rt:30 Rn:2 op:11 imm9:110111011 L:0 1000001001:1000001001
	.inst 0xc2c21003 // BRR-C-C 00011:00011 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.zero 4
	.inst 0x4b27e3fa // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:26 Rn:31 imm3:000 option:111 Rm:7 01011001:01011001 S:0 op:1 sf:0
	.inst 0x824273de // ASTR-C.RI-C Ct:30 Rn:30 op:00 imm9:000100111 L:0 1000001001:1000001001
	.inst 0xe285e102 // ASTUR-R.RI-32 Rt:2 Rn:8 op2:00 imm9:001011110 V:0 op1:10 11100010:11100010
	.inst 0xc2f39822 // SUBS-R.CC-C Rd:2 Cn:1 100110:100110 Cm:19 11000010111:11000010111
	.inst 0xc2f48356 // BICFLGS-C.CI-C Cd:22 Cn:26 0:0 00:00 imm8:10100100 11000010111:11000010111
	.inst 0xe291ace2 // ASTUR-C.RI-C Ct:2 Rn:7 op2:11 imm9:100011010 V:0 op1:10 11100010:11100010
	.inst 0xc2c211a0
	.zero 1048528
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c2 // ldr c2, [x14, #2]
	.inst 0xc2400dc7 // ldr c7, [x14, #3]
	.inst 0xc24011c8 // ldr c8, [x14, #4]
	.inst 0xc24015d3 // ldr c19, [x14, #5]
	.inst 0xc24019d4 // ldr c20, [x14, #6]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031ae // ldr c14, [c13, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x826011ae // ldr c14, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x13, #0xf
	and x14, x14, x13
	cmp x14, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001cd // ldr c13, [x14, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc24005cd // ldr c13, [x14, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc24009cd // ldr c13, [x14, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400dcd // ldr c13, [x14, #3]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc24011cd // ldr c13, [x14, #4]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc24015cd // ldr c13, [x14, #5]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc24019cd // ldr c13, [x14, #6]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc2401dcd // ldr c13, [x14, #7]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc24021cd // ldr c13, [x14, #8]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc24025cd // ldr c13, [x14, #9]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010f0
	ldr x1, =check_data0
	ldr x2, =0x00001110
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001600
	ldr x1, =check_data1
	ldr x2, =0x00001608
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b20
	ldr x1, =check_data2
	ldr x2, =0x00001b30
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f80
	ldr x1, =check_data3
	ldr x2, =0x00001f90
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400014
	ldr x1, =check_data5
	ldr x2, =0x00400030
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00402904
	ldr x1, =check_data6
	ldr x2, =0x00402908
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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
