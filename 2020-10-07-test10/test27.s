.section data0, #alloc, #write
	.byte 0x5e, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 112
.data
check_data0:
	.byte 0x5e, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xb0, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x81, 0x5c, 0x60, 0xa8, 0x53, 0x4b, 0x61, 0xa2, 0x6f, 0xa4, 0x6f, 0x82, 0x03, 0x10, 0xc2, 0xc2
	.byte 0x33, 0xe0, 0x19, 0x78, 0x26, 0x10, 0xc7, 0xc2, 0x01, 0x08, 0xd4, 0x1a, 0xfe, 0x53, 0xc0, 0xc2
	.byte 0xfe, 0xa3, 0x15, 0x38, 0xfe, 0x8b, 0xa2, 0x22, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000000100060000000000400010
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x80000000000100050000000000001f04
	/* C4 */
	.octa 0x1200
	/* C20 */
	.octa 0x0
	/* C26 */
	.octa 0xe22
final_cap_values:
	/* C0 */
	.octa 0x20008000000100060000000000400010
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x80000000000100050000000000001f04
	/* C4 */
	.octa 0x1200
	/* C6 */
	.octa 0x115e
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x101800000000000000000000000
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0xe22
	/* C30 */
	.octa 0x10b0
initial_SP_EL3_value:
	.octa 0x10b0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000218100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000080100000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001f80
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa8605c81 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:1 Rn:4 Rt2:10111 imm7:1000000 L:1 1010000:1010000 opc:10
	.inst 0xa2614b53 // LDR-C.RRB-C Ct:19 Rn:26 10:10 S:0 option:010 Rm:1 1:1 opc:01 10100010:10100010
	.inst 0x826fa46f // ALDRB-R.RI-B Rt:15 Rn:3 op:01 imm9:011111010 L:1 1000001001:1000001001
	.inst 0xc2c21003 // BRR-C-C 00011:00011 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x7819e033 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:19 Rn:1 00:00 imm9:110011110 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c71026 // RRLEN-R.R-C Rd:6 Rn:1 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x1ad40801 // udiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:0 o1:0 00001:00001 Rm:20 0011010110:0011010110 sf:0
	.inst 0xc2c053fe // GCVALUE-R.C-C Rd:30 Cn:31 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x3815a3fe // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:31 00:00 imm9:101011010 0:0 opc:00 111000:111000 size:00
	.inst 0x22a28bfe // STP-CC.RIAW-C Ct:30 Rn:31 Ct2:00010 imm7:1000101 L:0 001000101:001000101
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400963 // ldr c3, [x11, #2]
	.inst 0xc2400d64 // ldr c4, [x11, #3]
	.inst 0xc2401174 // ldr c20, [x11, #4]
	.inst 0xc240157a // ldr c26, [x11, #5]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850038
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032ab // ldr c11, [c21, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x826012ab // ldr c11, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400175 // ldr c21, [x11, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400575 // ldr c21, [x11, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400975 // ldr c21, [x11, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400d75 // ldr c21, [x11, #3]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2401175 // ldr c21, [x11, #4]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc2401575 // ldr c21, [x11, #5]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc2401975 // ldr c21, [x11, #6]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2401d75 // ldr c21, [x11, #7]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc2402175 // ldr c21, [x11, #8]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc2402575 // ldr c21, [x11, #9]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc2402975 // ldr c21, [x11, #10]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2402d75 // ldr c21, [x11, #11]
	.inst 0xc2d5a7c1 // chkeq c30, c21
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
	ldr x0, =0x000010b0
	ldr x1, =check_data1
	ldr x2, =0x000010d0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010fc
	ldr x1, =check_data2
	ldr x2, =0x000010fe
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
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
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
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
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
