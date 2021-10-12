.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x5b
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xce, 0x7e, 0x1f, 0x42, 0x59, 0x32, 0xc5, 0xc2, 0xa0, 0xe1, 0x7f, 0xea, 0x5c, 0x84, 0xd8, 0xe2
	.byte 0x50, 0x1b, 0xc7, 0xc2, 0xe1, 0x33, 0xc5, 0xc2, 0xa7, 0xf8, 0x61, 0xb9, 0x22, 0x12, 0xc2, 0xc2
.data
check_data3:
	.byte 0x5d, 0xfd, 0x07, 0xa2, 0xe1, 0x87, 0xdf, 0xc2, 0xc0, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x500000
	/* C5 */
	.octa 0x80000000120700030000000000440000
	/* C10 */
	.octa 0x4c000000000100050000000000000bc0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x5b004000000000000000000000000000
	/* C17 */
	.octa 0x20008000800080000000000000400031
	/* C18 */
	.octa 0x1
	/* C22 */
	.octa 0x1000
	/* C26 */
	.octa 0x140b0504000408000004c404
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x500000
	/* C5 */
	.octa 0x80000000120700030000000000440000
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x4c0000000001000500000000000013b0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x5b004000000000000000000000000000
	/* C16 */
	.octa 0x140b0504000408000004c000
	/* C17 */
	.octa 0x20008000800080000000000000400031
	/* C18 */
	.octa 0x1
	/* C22 */
	.octa 0x1000
	/* C25 */
	.octa 0x1
	/* C26 */
	.octa 0x140b0504000408000004c404
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x50000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000b00070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000000600170000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 144
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 240
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x421f7ece // ASTLR-C.R-C Ct:14 Rn:22 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2c53259 // CVTP-R.C-C Rd:25 Cn:18 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xea7fe1a0 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:13 imm6:111000 Rm:31 N:1 shift:01 01010:01010 opc:11 sf:1
	.inst 0xe2d8845c // ALDUR-R.RI-64 Rt:28 Rn:2 op2:01 imm9:110001000 V:0 op1:11 11100010:11100010
	.inst 0xc2c71b50 // ALIGND-C.CI-C Cd:16 Cn:26 0110:0110 U:0 imm6:001110 11000010110:11000010110
	.inst 0xc2c533e1 // CVTP-R.C-C Rd:1 Cn:31 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xb961f8a7 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:7 Rn:5 imm12:100001111110 opc:01 111001:111001 size:10
	.inst 0xc2c21222 // BRS-C-C 00010:00010 Cn:17 100:100 opc:00 11000010110000100:11000010110000100
	.zero 16
	.inst 0xa207fd5d // STR-C.RIBW-C Ct:29 Rn:10 11:11 imm9:001111111 0:0 opc:00 10100010:10100010
	.inst 0xc2df87e1 // CHKSS-_.CC-C 00001:00001 Cn:31 001:001 opc:00 1:1 Cm:31 11000010110:11000010110
	.inst 0xc2c213c0
	.zero 1048516
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
	ldr x24, =initial_cap_values
	.inst 0xc2400302 // ldr c2, [x24, #0]
	.inst 0xc2400705 // ldr c5, [x24, #1]
	.inst 0xc2400b0a // ldr c10, [x24, #2]
	.inst 0xc2400f0d // ldr c13, [x24, #3]
	.inst 0xc240130e // ldr c14, [x24, #4]
	.inst 0xc2401711 // ldr c17, [x24, #5]
	.inst 0xc2401b12 // ldr c18, [x24, #6]
	.inst 0xc2401f16 // ldr c22, [x24, #7]
	.inst 0xc240231a // ldr c26, [x24, #8]
	.inst 0xc240271d // ldr c29, [x24, #9]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	ldr x24, =0x8
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x30, =pcc_return_ddc_capabilities
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0x826033d8 // ldr c24, [c30, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x826013d8 // ldr c24, [c30, #1]
	.inst 0x826023de // ldr c30, [c30, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x30, #0xf
	and x24, x24, x30
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240031e // ldr c30, [x24, #0]
	.inst 0xc2dea401 // chkeq c0, c30
	b.ne comparison_fail
	.inst 0xc240071e // ldr c30, [x24, #1]
	.inst 0xc2dea421 // chkeq c1, c30
	b.ne comparison_fail
	.inst 0xc2400b1e // ldr c30, [x24, #2]
	.inst 0xc2dea441 // chkeq c2, c30
	b.ne comparison_fail
	.inst 0xc2400f1e // ldr c30, [x24, #3]
	.inst 0xc2dea4a1 // chkeq c5, c30
	b.ne comparison_fail
	.inst 0xc240131e // ldr c30, [x24, #4]
	.inst 0xc2dea4e1 // chkeq c7, c30
	b.ne comparison_fail
	.inst 0xc240171e // ldr c30, [x24, #5]
	.inst 0xc2dea541 // chkeq c10, c30
	b.ne comparison_fail
	.inst 0xc2401b1e // ldr c30, [x24, #6]
	.inst 0xc2dea5a1 // chkeq c13, c30
	b.ne comparison_fail
	.inst 0xc2401f1e // ldr c30, [x24, #7]
	.inst 0xc2dea5c1 // chkeq c14, c30
	b.ne comparison_fail
	.inst 0xc240231e // ldr c30, [x24, #8]
	.inst 0xc2dea601 // chkeq c16, c30
	b.ne comparison_fail
	.inst 0xc240271e // ldr c30, [x24, #9]
	.inst 0xc2dea621 // chkeq c17, c30
	b.ne comparison_fail
	.inst 0xc2402b1e // ldr c30, [x24, #10]
	.inst 0xc2dea641 // chkeq c18, c30
	b.ne comparison_fail
	.inst 0xc2402f1e // ldr c30, [x24, #11]
	.inst 0xc2dea6c1 // chkeq c22, c30
	b.ne comparison_fail
	.inst 0xc240331e // ldr c30, [x24, #12]
	.inst 0xc2dea721 // chkeq c25, c30
	b.ne comparison_fail
	.inst 0xc240371e // ldr c30, [x24, #13]
	.inst 0xc2dea741 // chkeq c26, c30
	b.ne comparison_fail
	.inst 0xc2403b1e // ldr c30, [x24, #14]
	.inst 0xc2dea781 // chkeq c28, c30
	b.ne comparison_fail
	.inst 0xc2403f1e // ldr c30, [x24, #15]
	.inst 0xc2dea7a1 // chkeq c29, c30
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
	ldr x0, =0x000013b0
	ldr x1, =check_data1
	ldr x2, =0x000013c0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400020
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400030
	ldr x1, =check_data3
	ldr x2, =0x0040003c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004421f8
	ldr x1, =check_data4
	ldr x2, =0x004421fc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004fff88
	ldr x1, =check_data5
	ldr x2, =0x004fff90
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
