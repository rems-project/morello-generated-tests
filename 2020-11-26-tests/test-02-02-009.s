.section data0, #alloc, #write
	.byte 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x18, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0xb0, 0x0f, 0x00, 0x00
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 1
.data
check_data7:
	.byte 0x0b, 0x2a, 0x0b, 0xe2, 0x3d, 0xb4, 0x8f, 0xb8, 0x02, 0x44, 0x0d, 0xe2, 0x24, 0xcb, 0x9c, 0xd2
	.byte 0xff, 0xc5, 0xe2, 0xe2, 0x26, 0x48, 0x3d, 0x38, 0x5e, 0x3e, 0x03, 0x78, 0xff, 0x43, 0x12, 0x29
	.byte 0xdf, 0x7f, 0xdf, 0x88, 0x17, 0x6a, 0x45, 0x78, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1008
	/* C1 */
	.octa 0xc0000000000300070000000000001000
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x1004
	/* C16 */
	.octa 0x80000000000300070000000000000fb0
	/* C18 */
	.octa 0x400000001007000d0000000000000fcd
	/* C30 */
	.octa 0x80000000008788860000000000400018
final_cap_values:
	/* C0 */
	.octa 0x1008
	/* C1 */
	.octa 0xc00000000003000700000000000010fb
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0xe659
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x1004
	/* C16 */
	.octa 0x80000000000300070000000000000fb0
	/* C18 */
	.octa 0x400000001007000d0000000000001000
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x5
	/* C30 */
	.octa 0x80000000008788860000000000400018
initial_SP_EL3_value:
	.octa 0x400000001207082f0000000000001010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080003ff900050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000180050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe20b2a0b // ALDURSB-R.RI-64 Rt:11 Rn:16 op2:10 imm9:010110010 V:0 op1:00 11100010:11100010
	.inst 0xb88fb43d // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:1 01:01 imm9:011111011 0:0 opc:10 111000:111000 size:10
	.inst 0xe20d4402 // ALDURB-R.RI-32 Rt:2 Rn:0 op2:01 imm9:011010100 V:0 op1:00 11100010:11100010
	.inst 0xd29ccb24 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:4 imm16:1110011001011001 hw:00 100101:100101 opc:10 sf:1
	.inst 0xe2e2c5ff // ALDUR-V.RI-D Rt:31 Rn:15 op2:01 imm9:000101100 V:1 op1:11 11100010:11100010
	.inst 0x383d4826 // strb_reg:aarch64/instrs/memory/single/general/register Rt:6 Rn:1 10:10 S:0 option:010 Rm:29 1:1 opc:00 111000:111000 size:00
	.inst 0x78033e5e // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:18 11:11 imm9:000110011 0:0 opc:00 111000:111000 size:01
	.inst 0x291243ff // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:31 Rt2:10000 imm7:0100100 L:0 1010010:1010010 opc:00
	.inst 0x88df7fdf // ldlar:aarch64/instrs/memory/ordered Rt:31 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x78456a17 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:23 Rn:16 10:10 imm9:001010110 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c211a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac6 // ldr c6, [x22, #2]
	.inst 0xc2400ecf // ldr c15, [x22, #3]
	.inst 0xc24012d0 // ldr c16, [x22, #4]
	.inst 0xc24016d2 // ldr c18, [x22, #5]
	.inst 0xc2401ade // ldr c30, [x22, #6]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_SP_EL3_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x3085103d
	msr SCTLR_EL3, x22
	ldr x22, =0x0
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b6 // ldr c22, [c13, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x826011b6 // ldr c22, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002cd // ldr c13, [x22, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc24006cd // ldr c13, [x22, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400acd // ldr c13, [x22, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400ecd // ldr c13, [x22, #3]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc24012cd // ldr c13, [x22, #4]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc24016cd // ldr c13, [x22, #5]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc2401acd // ldr c13, [x22, #6]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc2401ecd // ldr c13, [x22, #7]
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	.inst 0xc24022cd // ldr c13, [x22, #8]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc24026cd // ldr c13, [x22, #9]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc2402acd // ldr c13, [x22, #10]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc2402ecd // ldr c13, [x22, #11]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x13, v31.d[0]
	cmp x22, x13
	b.ne comparison_fail
	ldr x22, =0x0
	mov x13, v31.d[1]
	cmp x22, x13
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
	ldr x0, =0x00001006
	ldr x1, =check_data1
	ldr x2, =0x00001008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001030
	ldr x1, =check_data2
	ldr x2, =0x00001038
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001062
	ldr x1, =check_data3
	ldr x2, =0x00001063
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000010a0
	ldr x1, =check_data4
	ldr x2, =0x000010a8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000010dc
	ldr x1, =check_data5
	ldr x2, =0x000010dd
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001100
	ldr x1, =check_data6
	ldr x2, =0x00001101
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
