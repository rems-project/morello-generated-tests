.section data0, #alloc, #write
	.zero 144
	.byte 0x9c, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3936
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x40
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xa1, 0x6e, 0xc0, 0x79, 0x80, 0x30, 0xc7, 0xc2, 0x40, 0x39, 0x5d, 0xf8, 0x27, 0x10, 0x17, 0xb8
	.byte 0xa2, 0xc4, 0xfe, 0x82, 0xe1, 0x43, 0xf8, 0x78, 0xb2, 0x40, 0x16, 0x35
.data
check_data5:
	.byte 0x27, 0x20
.data
check_data6:
	.byte 0x42, 0x78, 0xcf, 0xc2, 0x3e, 0x48, 0x75, 0x39, 0x21, 0x80, 0x2b, 0x8a, 0x20, 0x12, 0xc2, 0xc2
.data
check_data7:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x800000003fda00070000000000000000
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x4beebd
	/* C18 */
	.octa 0xffffffff
	/* C21 */
	.octa 0x400c7c
	/* C24 */
	.octa 0x4000
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x109c
	/* C2 */
	.octa 0x41e000000000000000000000
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x800000003fda00070000000000000000
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x4beebd
	/* C18 */
	.octa 0xffffffff
	/* C21 */
	.octa 0x400c7c
	/* C24 */
	.octa 0x4000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1090
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200602d70000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000003f80000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x79c06ea1 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:21 imm12:000000011011 opc:11 111001:111001 size:01
	.inst 0xc2c73080 // RRMASK-R.R-C Rd:0 Rn:4 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xf85d3940 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:10 10:10 imm9:111010011 0:0 opc:01 111000:111000 size:11
	.inst 0xb8171027 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:7 Rn:1 00:00 imm9:101110001 0:0 opc:00 111000:111000 size:10
	.inst 0x82fec4a2 // ALDR-R.RRB-64 Rt:2 Rn:5 opc:01 S:0 option:110 Rm:30 1:1 L:1 100000101:100000101
	.inst 0x78f843e1 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:31 00:00 opc:100 0:0 Rs:24 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x351640b2 // cbnz:aarch64/instrs/branch/conditional/compare Rt:18 imm19:0001011001000000101 op:1 011010:011010 sf:0
	.zero 3220
	.inst 0x20270000
	.zero 179064
	.inst 0xc2cf7842 // SCBNDS-C.CI-S Cd:2 Cn:2 1110:1110 S:1 imm6:011110 11000010110:11000010110
	.inst 0x3975483e // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:1 imm12:110101010010 opc:01 111001:111001 size:00
	.inst 0x8a2b8021 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:1 imm6:100000 Rm:11 N:1 shift:00 01010:01010 opc:00 sf:1
	.inst 0xc2c21220
	.zero 866244
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c4 // ldr c4, [x14, #0]
	.inst 0xc24005c5 // ldr c5, [x14, #1]
	.inst 0xc24009c7 // ldr c7, [x14, #2]
	.inst 0xc2400dca // ldr c10, [x14, #3]
	.inst 0xc24011d2 // ldr c18, [x14, #4]
	.inst 0xc24015d5 // ldr c21, [x14, #5]
	.inst 0xc24019d8 // ldr c24, [x14, #6]
	.inst 0xc2401dde // ldr c30, [x14, #7]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260322e // ldr c14, [c17, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260122e // ldr c14, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d1 // ldr c17, [x14, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24005d1 // ldr c17, [x14, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24009d1 // ldr c17, [x14, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400dd1 // ldr c17, [x14, #3]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc24011d1 // ldr c17, [x14, #4]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc24015d1 // ldr c17, [x14, #5]
	.inst 0xc2d1a4e1 // chkeq c7, c17
	b.ne comparison_fail
	.inst 0xc24019d1 // ldr c17, [x14, #6]
	.inst 0xc2d1a541 // chkeq c10, c17
	b.ne comparison_fail
	.inst 0xc2401dd1 // ldr c17, [x14, #7]
	.inst 0xc2d1a641 // chkeq c18, c17
	b.ne comparison_fail
	.inst 0xc24021d1 // ldr c17, [x14, #8]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc24025d1 // ldr c17, [x14, #9]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc24029d1 // ldr c17, [x14, #10]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001090
	ldr x1, =check_data1
	ldr x2, =0x00001092
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001dee
	ldr x1, =check_data2
	ldr x2, =0x00001def
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f98
	ldr x1, =check_data3
	ldr x2, =0x00001f9c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400cb2
	ldr x1, =check_data5
	ldr x2, =0x00400cb4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0042c82c
	ldr x1, =check_data6
	ldr x2, =0x0042c83c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004bee90
	ldr x1, =check_data7
	ldr x2, =0x004bee98
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
