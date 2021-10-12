.section data0, #alloc, #write
	.zero 144
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3936
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.byte 0x98, 0x10, 0x00, 0x00
.data
check_data2:
	.byte 0x20
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x95, 0xc3, 0xbf, 0x38, 0x5e, 0xc0, 0x80, 0xe2, 0x37, 0x24, 0x82, 0xb9, 0x52, 0xfe, 0x00, 0x22
	.byte 0xcb, 0x73, 0xc0, 0xc2, 0xa1, 0xb9, 0x0a, 0xb8, 0xc0, 0x2f, 0x99, 0x22, 0xf3, 0x99, 0x5c, 0xb8
	.byte 0x3f, 0x40, 0x2b, 0x38, 0x19, 0x4f, 0x05, 0x32, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000200400050000000000001098
	/* C2 */
	.octa 0xfffffffffffffff4
	/* C13 */
	.octa 0x40000000000100050000000000000f8d
	/* C15 */
	.octa 0x8000000000030007000000000050002f
	/* C18 */
	.octa 0x48004000400000010000000000001fe0
	/* C28 */
	.octa 0x800000001007400f0000000000408004
	/* C30 */
	.octa 0x40000000020700410000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0xc0000000200400050000000000001098
	/* C2 */
	.octa 0xfffffffffffffff4
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x40000000000100050000000000000f8d
	/* C15 */
	.octa 0x8000000000030007000000000050002f
	/* C18 */
	.octa 0x48004000400000010000000000001fe0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x800000001007400f0000000000408004
	/* C30 */
	.octa 0x40000000020700410000000000001320
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000500000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4000000070121010000000000000c001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bfc395 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:21 Rn:28 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0xe280c05e // ASTUR-R.RI-32 Rt:30 Rn:2 op2:00 imm9:000001100 V:0 op1:10 11100010:11100010
	.inst 0xb9822437 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:23 Rn:1 imm12:000010001001 opc:10 111001:111001 size:10
	.inst 0x2200fe52 // STLXR-R.CR-C Ct:18 Rn:18 (1)(1)(1)(1)(1):11111 1:1 Rs:0 0:0 L:0 001000100:001000100
	.inst 0xc2c073cb // GCOFF-R.C-C Rd:11 Cn:30 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xb80ab9a1 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:13 10:10 imm9:010101011 0:0 opc:00 111000:111000 size:10
	.inst 0x22992fc0 // STP-CC.RIAW-C Ct:0 Rn:30 Ct2:01011 imm7:0110010 L:0 001000101:001000101
	.inst 0xb85c99f3 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:19 Rn:15 10:10 imm9:111001001 0:0 opc:01 111000:111000 size:10
	.inst 0x382b403f // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:1 00:00 opc:100 0:0 Rs:11 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x32054f19 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:25 Rn:24 imms:010011 immr:000101 N:0 100100:100100 opc:01 sf:0
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc240086d // ldr c13, [x3, #2]
	.inst 0xc2400c6f // ldr c15, [x3, #3]
	.inst 0xc2401072 // ldr c18, [x3, #4]
	.inst 0xc240147c // ldr c28, [x3, #5]
	.inst 0xc240187e // ldr c30, [x3, #6]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c3 // ldr c3, [c14, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x826011c3 // ldr c3, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006e // ldr c14, [x3, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240046e // ldr c14, [x3, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240086e // ldr c14, [x3, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400c6e // ldr c14, [x3, #3]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc240106e // ldr c14, [x3, #4]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc240146e // ldr c14, [x3, #5]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc240186e // ldr c14, [x3, #6]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc2401c6e // ldr c14, [x3, #7]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc240206e // ldr c14, [x3, #8]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc240246e // ldr c14, [x3, #9]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc240286e // ldr c14, [x3, #10]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc2402c6e // ldr c14, [x3, #11]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001038
	ldr x1, =check_data1
	ldr x2, =0x0000103c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001098
	ldr x1, =check_data2
	ldr x2, =0x00001099
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000012bc
	ldr x1, =check_data3
	ldr x2, =0x000012c0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001ff0
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
	ldr x0, =0x00408004
	ldr x1, =check_data6
	ldr x2, =0x00408005
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffff8
	ldr x1, =check_data7
	ldr x2, =0x004ffffc
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
