.section data0, #alloc, #write
	.zero 4032
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xe1, 0xc7, 0x75, 0x82, 0x7c, 0x7d, 0x9f, 0x08, 0xe3, 0x3e, 0x38, 0x02, 0x14, 0x7c, 0x9f, 0x48
	.byte 0xc0, 0x03, 0x5f, 0xd6
.data
check_data3:
	.byte 0x4b, 0x53, 0xb4, 0x38, 0x1e, 0xc0, 0x3f, 0xa2, 0xc6, 0x01, 0x41, 0x78, 0xc7, 0x6b, 0xd6, 0xc2
	.byte 0x8f, 0x41, 0xe9, 0xc2, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001fc0
	/* C11 */
	.octa 0x40000000000100050000000000001ffe
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000000403fec
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x8007400000000000000ff800
	/* C26 */
	.octa 0xc0000000000100050000000000001ffe
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x400018
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001fc0
	/* C1 */
	.octa 0x10
	/* C3 */
	.octa 0x80074000000000000010060f
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000000403fec
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x8007400000000000000ff800
	/* C26 */
	.octa 0xc0000000000100050000000000001ffe
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x101800000000000000000000000
initial_SP_EL3_value:
	.octa 0x1ea2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
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
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8275c7e1 // ALDRB-R.RI-B Rt:1 Rn:31 op:01 imm9:101011100 L:1 1000001001:1000001001
	.inst 0x089f7d7c // stllrb:aarch64/instrs/memory/ordered Rt:28 Rn:11 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x02383ee3 // ADD-C.CIS-C Cd:3 Cn:23 imm12:111000001111 sh:0 A:0 00000010:00000010
	.inst 0x489f7c14 // stllrh:aarch64/instrs/memory/ordered Rt:20 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xd65f03c0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:30 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 4
	.inst 0x38b4534b // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:11 Rn:26 00:00 opc:101 0:0 Rs:20 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xa23fc01e // LDAPR-C.R-C Ct:30 Rn:0 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x784101c6 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:6 Rn:14 00:00 imm9:000010000 0:0 opc:01 111000:111000 size:01
	.inst 0xc2d66bc7 // ORRFLGS-C.CR-C Cd:7 Cn:30 1010:1010 opc:01 Rm:22 11000010110:11000010110
	.inst 0xc2e9418f // BICFLGS-C.CI-C Cd:15 Cn:12 0:0 00:00 imm8:01001010 11000010111:11000010111
	.inst 0xc2c213a0
	.zero 1048528
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
	.inst 0xc24006ab // ldr c11, [x21, #1]
	.inst 0xc2400aac // ldr c12, [x21, #2]
	.inst 0xc2400eae // ldr c14, [x21, #3]
	.inst 0xc24012b4 // ldr c20, [x21, #4]
	.inst 0xc24016b7 // ldr c23, [x21, #5]
	.inst 0xc2401aba // ldr c26, [x21, #6]
	.inst 0xc2401ebc // ldr c28, [x21, #7]
	.inst 0xc24022be // ldr c30, [x21, #8]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033b5 // ldr c21, [c29, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826013b5 // ldr c21, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002bd // ldr c29, [x21, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc24006bd // ldr c29, [x21, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc2400abd // ldr c29, [x21, #2]
	.inst 0xc2dda461 // chkeq c3, c29
	b.ne comparison_fail
	.inst 0xc2400ebd // ldr c29, [x21, #3]
	.inst 0xc2dda4c1 // chkeq c6, c29
	b.ne comparison_fail
	.inst 0xc24012bd // ldr c29, [x21, #4]
	.inst 0xc2dda561 // chkeq c11, c29
	b.ne comparison_fail
	.inst 0xc24016bd // ldr c29, [x21, #5]
	.inst 0xc2dda581 // chkeq c12, c29
	b.ne comparison_fail
	.inst 0xc2401abd // ldr c29, [x21, #6]
	.inst 0xc2dda5c1 // chkeq c14, c29
	b.ne comparison_fail
	.inst 0xc2401ebd // ldr c29, [x21, #7]
	.inst 0xc2dda5e1 // chkeq c15, c29
	b.ne comparison_fail
	.inst 0xc24022bd // ldr c29, [x21, #8]
	.inst 0xc2dda681 // chkeq c20, c29
	b.ne comparison_fail
	.inst 0xc24026bd // ldr c29, [x21, #9]
	.inst 0xc2dda6e1 // chkeq c23, c29
	b.ne comparison_fail
	.inst 0xc2402abd // ldr c29, [x21, #10]
	.inst 0xc2dda741 // chkeq c26, c29
	b.ne comparison_fail
	.inst 0xc2402ebd // ldr c29, [x21, #11]
	.inst 0xc2dda781 // chkeq c28, c29
	b.ne comparison_fail
	.inst 0xc24032bd // ldr c29, [x21, #12]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fc0
	ldr x1, =check_data0
	ldr x2, =0x00001fd0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400018
	ldr x1, =check_data3
	ldr x2, =0x00400030
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00403ffc
	ldr x1, =check_data4
	ldr x2, =0x00403ffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
