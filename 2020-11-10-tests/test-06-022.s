.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x02, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0xc2
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x5e, 0xc0, 0x21, 0xf2, 0xc0, 0xff, 0x3f, 0x42, 0x27, 0x88, 0xc6, 0xc2, 0xec, 0x9b, 0x0f, 0xe2
	.byte 0x01, 0x4b, 0x5a, 0xf8, 0x61, 0x3f, 0x52, 0x58, 0x01, 0x84, 0xd0, 0xc2, 0xc1, 0x33, 0xc2, 0xc2
	.byte 0x41, 0x51, 0xc0, 0xc2, 0xc9, 0xfd, 0x3f, 0x42, 0x80, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x26260000022000000200
	/* C1 */
	.octa 0x28284010080000000000000
	/* C2 */
	.octa 0x80
	/* C6 */
	.octa 0xaf8100250000000000008001
	/* C9 */
	.octa 0xc2000000
	/* C14 */
	.octa 0x840
	/* C16 */
	.octa 0x400101000000000000000003
	/* C24 */
	.octa 0x800000005fb81d3a000000000000200c
final_cap_values:
	/* C0 */
	.octa 0x26260000022000000200
	/* C2 */
	.octa 0x80
	/* C6 */
	.octa 0xaf8100250000000000008001
	/* C7 */
	.octa 0x28284010080000000000000
	/* C9 */
	.octa 0xc2000000
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x840
	/* C16 */
	.octa 0x400101000000000000000003
	/* C24 */
	.octa 0x800000005fb81d3a000000000000200c
	/* C30 */
	.octa 0x80
initial_SP_EL3_value:
	.octa 0x80
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000058010f8400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf221c05e // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:2 imms:110000 immr:100001 N:0 100100:100100 opc:11 sf:1
	.inst 0x423fffc0 // ASTLR-R.R-32 Rt:0 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c68827 // CHKSSU-C.CC-C Cd:7 Cn:1 0010:0010 opc:10 Cm:6 11000010110:11000010110
	.inst 0xe20f9bec // ALDURSB-R.RI-64 Rt:12 Rn:31 op2:10 imm9:011111001 V:0 op1:00 11100010:11100010
	.inst 0xf85a4b01 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:24 10:10 imm9:110100100 0:0 opc:01 111000:111000 size:11
	.inst 0x58523f61 // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:1 imm19:0101001000111111011 011000:011000 opc:01
	.inst 0xc2d08401 // CHKSS-_.CC-C 00001:00001 Cn:0 001:001 opc:00 1:1 Cm:16 11000010110:11000010110
	.inst 0xc2c233c1 // CHKTGD-C-C 00001:00001 Cn:30 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c05141 // GCVALUE-R.C-C Rd:1 Cn:10 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x423ffdc9 // ASTLR-R.R-32 Rt:9 Rn:14 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c21280
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa2 // ldr c2, [x21, #2]
	.inst 0xc2400ea6 // ldr c6, [x21, #3]
	.inst 0xc24012a9 // ldr c9, [x21, #4]
	.inst 0xc24016ae // ldr c14, [x21, #5]
	.inst 0xc2401ab0 // ldr c16, [x21, #6]
	.inst 0xc2401eb8 // ldr c24, [x21, #7]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x3085103d
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603295 // ldr c21, [c20, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601295 // ldr c21, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x20, #0xf
	and x21, x21, x20
	cmp x21, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b4 // ldr c20, [x21, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24006b4 // ldr c20, [x21, #1]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400ab4 // ldr c20, [x21, #2]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2400eb4 // ldr c20, [x21, #3]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc24012b4 // ldr c20, [x21, #4]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc24016b4 // ldr c20, [x21, #5]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2401ab4 // ldr c20, [x21, #6]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401eb4 // ldr c20, [x21, #7]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc24022b4 // ldr c20, [x21, #8]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc24026b4 // ldr c20, [x21, #9]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010fd
	ldr x1, =check_data1
	ldr x2, =0x000010fe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017c4
	ldr x1, =check_data2
	ldr x2, =0x000017c8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fb0
	ldr x1, =check_data3
	ldr x2, =0x00001fb8
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
	ldr x0, =0x004a4800
	ldr x1, =check_data5
	ldr x2, =0x004a4808
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
