.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xfd, 0xcf
.data
check_data1:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xe3, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0xcc, 0x73, 0xc0, 0xc2, 0x14, 0x25, 0xdc, 0x9a, 0xcf, 0x7f, 0x0d, 0x78, 0x9a, 0x62, 0x30, 0x82
	.byte 0x4e, 0x93, 0xc5, 0xc2, 0xbf, 0x19, 0x12, 0x62, 0x30, 0x74, 0x54, 0xa9, 0xe1, 0x87, 0xcb, 0xc2
	.byte 0x0a, 0xa0, 0x1e, 0xe2, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1800
	/* C1 */
	.octa 0x800000000001000500000000003fff28
	/* C6 */
	.octa 0x4000000000000000000000000000
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x400100010033c51ffdfec001
	/* C13 */
	.octa 0x48000000000100050000000000001130
	/* C15 */
	.octa 0xa010000000010007000000000047cffd
	/* C30 */
	.octa 0x400000000046000f0000000000001229
final_cap_values:
	/* C0 */
	.octa 0x1800
	/* C1 */
	.octa 0x800000000001000500000000003fff28
	/* C6 */
	.octa 0x4000000000000000000000000000
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x400100010033c51ffdfec001
	/* C12 */
	.octa 0xa29
	/* C13 */
	.octa 0x48000000000100050000000000001130
	/* C14 */
	.octa 0x40000000580108010000000000000001
	/* C15 */
	.octa 0xa010000000010007000000000047cffd
	/* C16 */
	.octa 0x0
	/* C26 */
	.octa 0x1
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000046000f0000000000001300
initial_RDDC_EL0_value:
	.octa 0x400000005801080100ffffffffffe001
initial_RSP_EL0_value:
	.octa 0x4500200040800000c5
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 192
	.dword initial_RDDC_EL0_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c211e3 // BRR-C-C 00011:00011 Cn:15 100:100 opc:00 11000010110000100:11000010110000100
	.zero 316
	.inst 0x00000001
	.zero 511672
	.inst 0xc2c073cc // GCOFF-R.C-C Rd:12 Cn:30 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x9adc2514 // lsrv:aarch64/instrs/integer/shift/variable Rd:20 Rn:8 op2:01 0010:0010 Rm:28 0011010110:0011010110 sf:1
	.inst 0x780d7fcf // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:15 Rn:30 11:11 imm9:011010111 0:0 opc:00 111000:111000 size:01
	.inst 0x8230629a // LDR-C.I-C Ct:26 imm17:11000001100010100 1000001000:1000001000
	.inst 0xc2c5934e // CVTD-C.R-C Cd:14 Rn:26 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x621219bf // STNP-C.RIB-C Ct:31 Rn:13 Ct2:00110 imm7:0100100 L:0 011000100:011000100
	.inst 0xa9547430 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:16 Rn:1 Rt2:11101 imm7:0101000 L:1 1010010:1010010 opc:10
	.inst 0xc2cb87e1 // CHKSS-_.CC-C 00001:00001 Cn:31 001:001 opc:00 1:1 Cm:11 11000010110:11000010110
	.inst 0xe21ea00a // ASTURB-R.RI-32 Rt:10 Rn:0 op2:00 imm9:111101010 V:0 op1:00 11100010:11100010
	.inst 0xc2c212a0
	.zero 536540
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x2, cptr_el3
	orr x2, x2, #0x200
	msr cptr_el3, x2
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc2400846 // ldr c6, [x2, #2]
	.inst 0xc2400c4a // ldr c10, [x2, #3]
	.inst 0xc240104b // ldr c11, [x2, #4]
	.inst 0xc240144d // ldr c13, [x2, #5]
	.inst 0xc240184f // ldr c15, [x2, #6]
	.inst 0xc2401c5e // ldr c30, [x2, #7]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	ldr x2, =0x0
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	ldr x2, =initial_RDDC_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc28b4322 // msr RDDC_EL0, c2
	ldr x2, =initial_RSP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc28f4162 // msr RSP_EL0, c2
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012a2 // ldr c2, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x21, #0xf
	and x2, x2, x21
	cmp x2, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400055 // ldr c21, [x2, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400455 // ldr c21, [x2, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400855 // ldr c21, [x2, #2]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc2400c55 // ldr c21, [x2, #3]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401055 // ldr c21, [x2, #4]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401455 // ldr c21, [x2, #5]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2401855 // ldr c21, [x2, #6]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2401c55 // ldr c21, [x2, #7]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc2402055 // ldr c21, [x2, #8]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2402455 // ldr c21, [x2, #9]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2402855 // ldr c21, [x2, #10]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2402c55 // ldr c21, [x2, #11]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2403055 // ldr c21, [x2, #12]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001300
	ldr x1, =check_data0
	ldr x2, =0x00001302
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001370
	ldr x1, =check_data1
	ldr x2, =0x00001390
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017ea
	ldr x1, =check_data2
	ldr x2, =0x000017eb
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400068
	ldr x1, =check_data4
	ldr x2, =0x00400078
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400140
	ldr x1, =check_data5
	ldr x2, =0x00400150
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0047cffc
	ldr x1, =check_data6
	ldr x2, =0x0047d024
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
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
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
