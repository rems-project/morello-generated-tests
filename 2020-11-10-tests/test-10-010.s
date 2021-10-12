.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xc0, 0x03, 0x1f, 0xd6, 0x58, 0xcc, 0x43, 0xf8, 0xd3, 0x4f, 0x7a, 0x79, 0xe2, 0x7f, 0x5f, 0xc8
	.byte 0xb4, 0x70, 0xc0, 0xc2, 0x3f, 0x00, 0x00, 0x1a, 0xd4, 0x1a, 0xc4, 0xc2, 0x00, 0xc4, 0xd2, 0xc2
	.byte 0xd3, 0x49, 0x4c, 0xf1, 0x74, 0x63, 0xbf, 0xc2, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20408002500100090000000000400020
	/* C2 */
	.octa 0x800000001007100f00000000004e8004
	/* C5 */
	.octa 0x700060000000000000000
	/* C18 */
	.octa 0x400002000000000000000000000000
	/* C22 */
	.octa 0x400100000000000000000101
	/* C27 */
	.octa 0x120040000000000000000
	/* C30 */
	.octa 0x80000000000080080000000000400004
final_cap_values:
	/* C0 */
	.octa 0x20408002500100090000000000400020
	/* C2 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C5 */
	.octa 0x700060000000000000000
	/* C18 */
	.octa 0x400002000000000000000000000000
	/* C20 */
	.octa 0x120040000000000000000
	/* C22 */
	.octa 0x400100000000000000000101
	/* C24 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C27 */
	.octa 0x120040000000000000000
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x80000000000080080000000000400004
initial_SP_EL3_value:
	.octa 0x800000000000800800000000004ffff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004805d0050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd61f03c0 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:30 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.inst 0xf843cc58 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:24 Rn:2 11:11 imm9:000111100 0:0 opc:01 111000:111000 size:11
	.inst 0x797a4fd3 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:19 Rn:30 imm12:111010010011 opc:01 111001:111001 size:01
	.inst 0xc85f7fe2 // ldxr:aarch64/instrs/memory/exclusive/single Rt:2 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xc2c070b4 // GCOFF-R.C-C Rd:20 Cn:5 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x1a00003f // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:1 000000:000000 Rm:0 11010000:11010000 S:0 op:0 sf:0
	.inst 0xc2c41ad4 // ALIGND-C.CI-C Cd:20 Cn:22 0110:0110 U:0 imm6:001000 11000010110:11000010110
	.inst 0xc2d2c400 // RETS-C.C-C 00000:00000 Cn:0 001:001 opc:10 1:1 Cm:18 11000010110:11000010110
	.inst 0xf14c49d3 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:19 Rn:14 imm12:001100010010 sh:1 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0xc2bf6374 // ADD-C.CRI-C Cd:20 Cn:27 imm3:000 option:011 Rm:31 11000010101:11000010101
	.inst 0xc2c212a0
	.zero 7420
	.inst 0xc2c20000
	.zero 942868
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 98216
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 8
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc2400985 // ldr c5, [x12, #2]
	.inst 0xc2400d92 // ldr c18, [x12, #3]
	.inst 0xc2401196 // ldr c22, [x12, #4]
	.inst 0xc240159b // ldr c27, [x12, #5]
	.inst 0xc240199e // ldr c30, [x12, #6]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851037
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012ac // ldr c12, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400195 // ldr c21, [x12, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400595 // ldr c21, [x12, #1]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400995 // ldr c21, [x12, #2]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2400d95 // ldr c21, [x12, #3]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc2401195 // ldr c21, [x12, #4]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc2401595 // ldr c21, [x12, #5]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2401995 // ldr c21, [x12, #6]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc2401d95 // ldr c21, [x12, #7]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2402195 // ldr c21, [x12, #8]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2402595 // ldr c21, [x12, #9]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040002c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00401d2a
	ldr x1, =check_data1
	ldr x2, =0x00401d2c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004e8040
	ldr x1, =check_data2
	ldr x2, =0x004e8048
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffff0
	ldr x1, =check_data3
	ldr x2, =0x004ffff8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
