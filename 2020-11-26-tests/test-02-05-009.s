.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x80
.data
check_data2:
	.byte 0x1c
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x5f, 0x77, 0x77, 0x35, 0xfd, 0xcb, 0xc9, 0x39, 0x7e, 0xb8, 0xc1, 0xc2, 0x27, 0x50, 0xff, 0x78
	.byte 0xc0, 0x7f, 0x14, 0x08, 0x21, 0xa4, 0x45, 0x82, 0x31, 0x72, 0x7f, 0x78, 0xc5, 0x2f, 0xd1, 0xca
	.byte 0xdd, 0x53, 0xc0, 0xc2, 0xe0, 0x73, 0xc0, 0xc2, 0x40, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc000000000010005000000000000101c
	/* C3 */
	.octa 0x40000000500000010000000000400800
	/* C17 */
	.octa 0xc0000000000100050000000000001ffc
final_cap_values:
	/* C0 */
	.octa 0xd8c
	/* C1 */
	.octa 0xc000000000010005000000000000101c
	/* C3 */
	.octa 0x40000000500000010000000000400800
	/* C5 */
	.octa 0x400800
	/* C7 */
	.octa 0x8000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x1
	/* C29 */
	.octa 0x400800
	/* C30 */
	.octa 0x40000000480308000000000000400800
initial_SP_EL3_value:
	.octa 0x80000000600000040000000000000d90
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3577775f // cbnz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:0111011101110111010 op:1 011010:011010 sf:0
	.inst 0x39c9cbfd // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:31 imm12:001001110010 opc:11 111001:111001 size:00
	.inst 0xc2c1b87e // SCBNDS-C.CI-C Cd:30 Cn:3 1110:1110 S:0 imm6:000011 11000010110:11000010110
	.inst 0x78ff5027 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:7 Rn:1 00:00 opc:101 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x08147fc0 // stxrb:aarch64/instrs/memory/exclusive/single Rt:0 Rn:30 Rt2:11111 o0:0 Rs:20 0:0 L:0 0010000:0010000 size:00
	.inst 0x8245a421 // ASTRB-R.RI-B Rt:1 Rn:1 op:01 imm9:001011010 L:0 1000001001:1000001001
	.inst 0x787f7231 // lduminh:aarch64/instrs/memory/atomicops/ld Rt:17 Rn:17 00:00 opc:111 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xcad12fc5 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:5 Rn:30 imm6:001011 Rm:17 N:0 shift:11 01010:01010 opc:10 sf:1
	.inst 0xc2c053dd // GCVALUE-R.C-C Rd:29 Cn:30 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c073e0 // GCOFF-R.C-C Rd:0 Cn:31 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c21040
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a1 // ldr c1, [x13, #0]
	.inst 0xc24005a3 // ldr c3, [x13, #1]
	.inst 0xc24009b1 // ldr c17, [x13, #2]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x3085103d
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x8260304d // ldr c13, [c2, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260104d // ldr c13, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a2 // ldr c2, [x13, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc24009a2 // ldr c2, [x13, #2]
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	.inst 0xc2400da2 // ldr c2, [x13, #3]
	.inst 0xc2c2a4a1 // chkeq c5, c2
	b.ne comparison_fail
	.inst 0xc24011a2 // ldr c2, [x13, #4]
	.inst 0xc2c2a4e1 // chkeq c7, c2
	b.ne comparison_fail
	.inst 0xc24015a2 // ldr c2, [x13, #5]
	.inst 0xc2c2a621 // chkeq c17, c2
	b.ne comparison_fail
	.inst 0xc24019a2 // ldr c2, [x13, #6]
	.inst 0xc2c2a681 // chkeq c20, c2
	b.ne comparison_fail
	.inst 0xc2401da2 // ldr c2, [x13, #7]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc24021a2 // ldr c2, [x13, #8]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001003
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000101c
	ldr x1, =check_data1
	ldr x2, =0x0000101e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001076
	ldr x1, =check_data2
	ldr x2, =0x00001077
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
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
	ldr x0, =0x00400800
	ldr x1, =check_data5
	ldr x2, =0x00400801
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
