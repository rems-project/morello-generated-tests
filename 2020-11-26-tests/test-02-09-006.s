.section data0, #alloc, #write
	.zero 1648
	.byte 0x00, 0xa0, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0xfb, 0xbf, 0x00, 0x80, 0x00, 0x20
	.zero 2432
.data
check_data0:
	.byte 0x00, 0xa0, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0xfb, 0xbf, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x00
.data
check_data3:
	.byte 0xe1, 0x7f, 0x1d, 0x9b, 0xa2, 0x13, 0xc2, 0xc2
.data
check_data4:
	.byte 0xab, 0xe3, 0x84, 0x38, 0x8d, 0x0b, 0xc0, 0xc2, 0x43, 0x4c, 0x55, 0x62, 0xd5, 0x54, 0x37, 0x90
	.byte 0x5f, 0x3f, 0x03, 0xd5, 0x9b, 0xbd, 0x44, 0x82, 0xc0, 0x13, 0xc7, 0xc2, 0xe1, 0x70, 0xd1, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000000080710070000000000008001
	/* C2 */
	.octa 0x1560
	/* C7 */
	.octa 0x900000000003000700000000000015c0
	/* C12 */
	.octa 0x40000000000100070000000000001c20
	/* C27 */
	.octa 0x800080000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x2000800020014005000000000043fff0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1560
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x900000000003000700000000000015c0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x40000000000100070000000000001c20
	/* C13 */
	.octa 0x800000000000000000000000
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x6eed7000
	/* C27 */
	.octa 0x800080000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x2000800020014005000000000043fff0
	/* C30 */
	.octa 0x20008000200140050000000000440010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90100000000180050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001670
	.dword 0x0000000000001810
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b1d7fe1 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:1 Rn:31 Ra:31 o0:0 Rm:29 0011011000:0011011000 sf:1
	.inst 0xc2c213a2 // BRS-C-C 00010:00010 Cn:29 100:100 opc:00 11000010110000100:11000010110000100
	.zero 262120
	.inst 0x3884e3ab // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:11 Rn:29 00:00 imm9:001001110 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c00b8d // SEAL-C.CC-C Cd:13 Cn:28 0010:0010 opc:00 Cm:0 11000010110:11000010110
	.inst 0x62554c43 // LDNP-C.RIB-C Ct:3 Rn:2 Ct2:10011 imm7:0101010 L:1 011000100:011000100
	.inst 0x903754d5 // ADRDP-C.ID-C Rd:21 immhi:011011101010100110 P:0 10000:10000 immlo:00 op:1
	.inst 0xd5033f5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1111 11010101000000110011:11010101000000110011
	.inst 0x8244bd9b // ASTR-R.RI-64 Rt:27 Rn:12 op:11 imm9:001001011 L:0 1000001001:1000001001
	.inst 0xc2c713c0 // RRLEN-R.R-C Rd:0 Rn:30 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xc2d170e1 // BLR-CI-C 1:1 0000:0000 Cn:7 100:100 imm7:0001011 110000101101:110000101101
	.zero 303088
	.inst 0xc2c210a0
	.zero 483324
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400682 // ldr c2, [x20, #1]
	.inst 0xc2400a87 // ldr c7, [x20, #2]
	.inst 0xc2400e8c // ldr c12, [x20, #3]
	.inst 0xc240129b // ldr c27, [x20, #4]
	.inst 0xc240169c // ldr c28, [x20, #5]
	.inst 0xc2401a9d // ldr c29, [x20, #6]
	.inst 0xc2401e9e // ldr c30, [x20, #7]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	ldr x20, =0x8
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b4 // ldr c20, [c5, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826010b4 // ldr c20, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400285 // ldr c5, [x20, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400685 // ldr c5, [x20, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a85 // ldr c5, [x20, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400e85 // ldr c5, [x20, #3]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc2401285 // ldr c5, [x20, #4]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2401685 // ldr c5, [x20, #5]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2401a85 // ldr c5, [x20, #6]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc2401e85 // ldr c5, [x20, #7]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2402285 // ldr c5, [x20, #8]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2402685 // ldr c5, [x20, #9]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2402a85 // ldr c5, [x20, #10]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc2402e85 // ldr c5, [x20, #11]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc2403285 // ldr c5, [x20, #12]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2403685 // ldr c5, [x20, #13]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001670
	ldr x1, =check_data0
	ldr x2, =0x00001680
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001820
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e78
	ldr x1, =check_data2
	ldr x2, =0x00001e80
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0043fff0
	ldr x1, =check_data4
	ldr x2, =0x00440010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0044003e
	ldr x1, =check_data5
	ldr x2, =0x0044003f
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0048a000
	ldr x1, =check_data6
	ldr x2, =0x0048a004
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
