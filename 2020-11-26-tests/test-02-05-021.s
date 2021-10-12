.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x1f, 0xb4, 0x5d, 0x39, 0x61, 0x26, 0xde, 0xc2, 0x36, 0xb1, 0xc0, 0xc2, 0xa0, 0x53, 0xc0, 0xc2
	.byte 0x3f, 0x11, 0x4a, 0x38, 0xcb, 0x54, 0x49, 0xb3, 0xc0, 0x00, 0x1f, 0xd6
.data
check_data1:
	.byte 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0x7d, 0x30, 0xc7, 0xc2, 0x30, 0x69, 0x35, 0x82, 0x20, 0x68, 0xca, 0xc2, 0x40, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x41294f
	/* C3 */
	.octa 0x40c00f9f60060000
	/* C6 */
	.octa 0x480000
	/* C9 */
	.octa 0x414020
	/* C19 */
	.octa 0xb239b3470080000000000000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xb239b347ffffffffffffffff
	/* C1 */
	.octa 0xb239b347ffffffffffffffff
	/* C3 */
	.octa 0x40c00f9f60060000
	/* C6 */
	.octa 0x480000
	/* C9 */
	.octa 0x414020
	/* C16 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C19 */
	.octa 0xb239b3470080000000000000
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0xfff8000000000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb0008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000500110c2000000000040e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x395db41f // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:0 imm12:011101101101 opc:01 111001:111001 size:00
	.inst 0xc2de2661 // CPYTYPE-C.C-C Cd:1 Cn:19 001:001 opc:01 0:0 Cm:30 11000010110:11000010110
	.inst 0xc2c0b136 // GCSEAL-R.C-C Rd:22 Cn:9 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2c053a0 // GCVALUE-R.C-C Rd:0 Cn:29 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x384a113f // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:9 00:00 imm9:010100001 0:0 opc:01 111000:111000 size:00
	.inst 0xb34954cb // bfm:aarch64/instrs/integer/bitfield Rd:11 Rn:6 imms:010101 immr:001001 N:1 100110:100110 opc:01 sf:1
	.inst 0xd61f00c0 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:6 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 77984
	.inst 0x000000c2
	.zero 4096
	.inst 0x0000c200
	.zero 95180
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 346976
	.inst 0xc2c7307d // RRMASK-R.R-C Rd:29 Rn:3 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x82356930 // LDR-C.I-C Ct:16 imm17:11010101101001001 1000001000:1000001000
	.inst 0xc2ca6820 // ORRFLGS-C.CR-C Cd:0 Cn:1 1010:1010 opc:01 Rm:10 11000010110:11000010110
	.inst 0xc2c21040
	.zero 524272
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e3 // ldr c3, [x15, #1]
	.inst 0xc24009e6 // ldr c6, [x15, #2]
	.inst 0xc2400de9 // ldr c9, [x15, #3]
	.inst 0xc24011f3 // ldr c19, [x15, #4]
	.inst 0xc24015fe // ldr c30, [x15, #5]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851037
	msr SCTLR_EL3, x15
	ldr x15, =0x8
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x8260304f // ldr c15, [c2, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260104f // ldr c15, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e2 // ldr c2, [x15, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	.inst 0xc2400de2 // ldr c2, [x15, #3]
	.inst 0xc2c2a4c1 // chkeq c6, c2
	b.ne comparison_fail
	.inst 0xc24011e2 // ldr c2, [x15, #4]
	.inst 0xc2c2a521 // chkeq c9, c2
	b.ne comparison_fail
	.inst 0xc24015e2 // ldr c2, [x15, #5]
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	.inst 0xc24019e2 // ldr c2, [x15, #6]
	.inst 0xc2c2a661 // chkeq c19, c2
	b.ne comparison_fail
	.inst 0xc2401de2 // ldr c2, [x15, #7]
	.inst 0xc2c2a6c1 // chkeq c22, c2
	b.ne comparison_fail
	.inst 0xc24021e2 // ldr c2, [x15, #8]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc24025e2 // ldr c2, [x15, #9]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040001c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x004130bc
	ldr x1, =check_data1
	ldr x2, =0x004130bd
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004140c1
	ldr x1, =check_data2
	ldr x2, =0x004140c2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0042b490
	ldr x1, =check_data3
	ldr x2, =0x0042b4a0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00480000
	ldr x1, =check_data4
	ldr x2, =0x00480010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
