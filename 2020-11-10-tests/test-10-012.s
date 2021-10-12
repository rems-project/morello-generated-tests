.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x40, 0x00, 0x3f, 0xd6, 0xe0, 0xd3, 0xc5, 0xc2, 0x41, 0x48, 0x40, 0x8b, 0x21, 0x80, 0x29, 0xd2
	.byte 0xe0, 0x0b, 0xc0, 0x5a, 0x5f, 0xfc, 0x01, 0x08, 0xde, 0x32, 0x25, 0xf0, 0x00, 0x12, 0xc5, 0xc2
	.byte 0x1d, 0x08, 0xc3, 0x1a, 0xc2, 0xc3, 0xaa, 0xc2, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x40000000068900050000000000400004
	/* C3 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C16 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x100000006003000004a65b000
	/* C3 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x100000006003000004a65b000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001effdeff0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x1000000060030000000000800
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd63f0040 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.inst 0xc2c5d3e0 // CVTDZ-C.R-C Cd:0 Rn:31 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x8b404841 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:2 imm6:010010 Rm:0 0:0 shift:01 01011:01011 S:0 op:0 sf:1
	.inst 0xd2298021 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:1 imms:100000 immr:101001 N:0 100100:100100 opc:10 sf:1
	.inst 0x5ac00be0 // rev:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:31 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0x0801fc5f // stlxrb:aarch64/instrs/memory/exclusive/single Rt:31 Rn:2 Rt2:11111 o0:1 Rs:1 0:0 L:0 0010000:0010000 size:00
	.inst 0xf02532de // ADRP-C.I-C Rd:30 immhi:010010100110010110 P:0 10000:10000 immlo:11 op:1
	.inst 0xc2c51200 // CVTD-R.C-C Rd:0 Cn:16 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x1ac3081d // udiv:aarch64/instrs/integer/arithmetic/div Rd:29 Rn:0 o1:0 00001:00001 Rm:3 0011010110:0011010110 sf:0
	.inst 0xc2aac3c2 // ADD-C.CRI-C Cd:2 Cn:30 imm3:000 option:110 Rm:10 11000010101:11000010101
	.inst 0xc2c211c0
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
	ldr x4, =initial_cap_values
	.inst 0xc2400082 // ldr c2, [x4, #0]
	.inst 0xc2400483 // ldr c3, [x4, #1]
	.inst 0xc240088a // ldr c10, [x4, #2]
	.inst 0xc2400c90 // ldr c16, [x4, #3]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	ldr x4, =0x80
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c4 // ldr c4, [c14, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826011c4 // ldr c4, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x14, #0xf
	and x4, x4, x14
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008e // ldr c14, [x4, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240048e // ldr c14, [x4, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240088e // ldr c14, [x4, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400c8e // ldr c14, [x4, #3]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc240108e // ldr c14, [x4, #4]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc240148e // ldr c14, [x4, #5]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc240188e // ldr c14, [x4, #6]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc2401c8e // ldr c14, [x4, #7]
	.inst 0xc2cea7c1 // chkeq c30, c14
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
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
