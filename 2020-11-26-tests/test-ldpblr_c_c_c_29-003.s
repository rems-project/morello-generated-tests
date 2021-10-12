.section data0, #alloc, #write
	.byte 0x21, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2592
	.byte 0x01, 0x05, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x40, 0x41, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 1472
.data
check_data0:
	.byte 0x21, 0x0a
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 32
	.byte 0x01, 0x05, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x40, 0x41, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x85, 0x72, 0xa0, 0x78, 0x91, 0xfc, 0x5f, 0x22, 0x01, 0x70, 0xc0, 0xc2, 0xa8, 0xf3, 0x69, 0x82
	.byte 0xa6, 0xf9, 0x57, 0xa2, 0x1d, 0x30, 0xc4, 0xc2
.data
check_data7:
	.byte 0x1d, 0xb0, 0xdc, 0x38, 0x1d, 0x08, 0x0c, 0xb8, 0xfd, 0xa5, 0x10, 0xe2, 0x20, 0x13, 0xc2, 0xc2
.data
check_data8:
	.byte 0x20, 0x18, 0xd9, 0xb5
.data
check_data9:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xd0000000581e18f10000000000001a20
	/* C4 */
	.octa 0x1040
	/* C13 */
	.octa 0x2010
	/* C15 */
	.octa 0x500000
	/* C20 */
	.octa 0x1000
	/* C29 */
	.octa 0x90000000000300050000000000001020
final_cap_values:
	/* C0 */
	.octa 0xd0000000581e18f10000000000001a20
	/* C1 */
	.octa 0x12f
	/* C4 */
	.octa 0x1040
	/* C5 */
	.octa 0xa21
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x2010
	/* C15 */
	.octa 0x500000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x1000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000800700030000000000400018
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000000000080000000000010001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001040
	.dword 0x0000000000001800
	.dword 0x0000000000001a30
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78a07285 // lduminh:aarch64/instrs/memory/atomicops/ld Rt:5 Rn:20 00:00 opc:111 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x225ffc91 // LDAXR-C.R-C Ct:17 Rn:4 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xc2c07001 // GCOFF-R.C-C Rd:1 Cn:0 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x8269f3a8 // ALDR-C.RI-C Ct:8 Rn:29 op:00 imm9:010011111 L:1 1000001001:1000001001
	.inst 0xa257f9a6 // LDTR-C.RIB-C Ct:6 Rn:13 10:10 imm9:101111111 0:0 opc:01 10100010:10100010
	.inst 0xc2c4301d // 0xc2c4301d
	.zero 206828
	.inst 0x38dcb01d // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:0 00:00 imm9:111001011 0:0 opc:11 111000:111000 size:00
	.inst 0xb80c081d // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:29 Rn:0 10:10 imm9:011000000 0:0 opc:00 111000:111000 size:10
	.inst 0xe210a5fd // ALDURB-R.RI-32 Rt:29 Rn:15 op2:01 imm9:100001010 V:0 op1:00 11100010:11100010
	.inst 0xc2c21320
	.zero 318700
	.inst 0xb5d91820 // cbnz:aarch64/instrs/branch/conditional/compare Rt:0 imm19:1101100100011000001 op:1 011010:011010 sf:1
	.zero 523004
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
	.inst 0xc24006a4 // ldr c4, [x21, #1]
	.inst 0xc2400aad // ldr c13, [x21, #2]
	.inst 0xc2400eaf // ldr c15, [x21, #3]
	.inst 0xc24012b4 // ldr c20, [x21, #4]
	.inst 0xc24016bd // ldr c29, [x21, #5]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	ldr x21, =0x84
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603335 // ldr c21, [c25, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601335 // ldr c21, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	.inst 0xc24002b9 // ldr c25, [x21, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24006b9 // ldr c25, [x21, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400ab9 // ldr c25, [x21, #2]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400eb9 // ldr c25, [x21, #3]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc24012b9 // ldr c25, [x21, #4]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc24016b9 // ldr c25, [x21, #5]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2401ab9 // ldr c25, [x21, #6]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc2401eb9 // ldr c25, [x21, #7]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc24022b9 // ldr c25, [x21, #8]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc24026b9 // ldr c25, [x21, #9]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2402ab9 // ldr c25, [x21, #10]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402eb9 // ldr c25, [x21, #11]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001810
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000019eb
	ldr x1, =check_data3
	ldr x2, =0x000019ec
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001a10
	ldr x1, =check_data4
	ldr x2, =0x00001a40
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ae0
	ldr x1, =check_data5
	ldr x2, =0x00001ae4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400018
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00432804
	ldr x1, =check_data7
	ldr x2, =0x00432814
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00480500
	ldr x1, =check_data8
	ldr x2, =0x00480504
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	ldr x0, =0x004fff0a
	ldr x1, =check_data9
	ldr x2, =0x004fff0b
check_data_loop9:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop9
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
