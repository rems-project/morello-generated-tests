.section data0, #alloc, #write
	.zero 64
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00
	.zero 816
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x20, 0x20, 0x00, 0x00
	.zero 3168
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x80, 0x80, 0x80, 0x00
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x20, 0x20, 0x00, 0x00
.data
check_data4:
	.byte 0x0b, 0x82, 0x01, 0x1b, 0x90, 0x59, 0xe2, 0xc2, 0xc2, 0xa3, 0x4d, 0x62, 0xe1, 0x87, 0xdf, 0xc2
	.byte 0xc0, 0xa5, 0xc0, 0xc2
.data
check_data5:
	.byte 0x4b, 0xcc, 0x10, 0x29, 0x5e, 0x98, 0x43, 0xa2, 0xbf, 0x91, 0xc5, 0xc2, 0x04, 0x00, 0xfe, 0x78
	.byte 0xfb, 0xc3, 0xd1, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x402000000000000000000000001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffffffe001
	/* C12 */
	.octa 0x4014049c0000000000000001
	/* C13 */
	.octa 0x80000000000000
	/* C14 */
	.octa 0x2040a0004c00cc210000000000400b18
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x808080
	/* C30 */
	.octa 0x90000000400001020000000000000e90
final_cap_values:
	/* C0 */
	.octa 0x402000000000000000000000001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1000
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x200000000000000000000000000
	/* C11 */
	.octa 0x1000
	/* C12 */
	.octa 0x4014049c0000000000000001
	/* C13 */
	.octa 0x80000000000000
	/* C14 */
	.octa 0x2040a0004c00cc210000000000400b18
	/* C16 */
	.octa 0x4014049c00ffffffffffe001
	/* C19 */
	.octa 0x808080
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000000000000000000001000
	/* C30 */
	.octa 0x2020800000000000000000000000
initial_SP_EL3_value:
	.octa 0x100030000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000207a0070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000100070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001040
	.dword 0x0000000000001050
	.dword 0x0000000000001390
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1b01820b // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:11 Rn:16 Ra:0 o0:1 Rm:1 0011011000:0011011000 sf:0
	.inst 0xc2e25990 // CVTZ-C.CR-C Cd:16 Cn:12 0110:0110 1:1 0:0 Rm:2 11000010111:11000010111
	.inst 0x624da3c2 // LDNP-C.RIB-C Ct:2 Rn:30 Ct2:01000 imm7:0011011 L:1 011000100:011000100
	.inst 0xc2df87e1 // CHKSS-_.CC-C 00001:00001 Cn:31 001:001 opc:00 1:1 Cm:31 11000010110:11000010110
	.inst 0xc2c0a5c0 // BLRS-C.C-C 00000:00000 Cn:14 001:001 opc:01 1:1 Cm:0 11000010110:11000010110
	.zero 2820
	.inst 0x2910cc4b // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:11 Rn:2 Rt2:10011 imm7:0100001 L:0 1010010:1010010 opc:00
	.inst 0xa243985e // LDTR-C.RIB-C Ct:30 Rn:2 10:10 imm9:000111001 0:0 opc:01 10100010:10100010
	.inst 0xc2c591bf // CVTD-C.R-C Cd:31 Rn:13 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x78fe0004 // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:4 Rn:0 00:00 opc:000 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xc2d1c3fb // CVT-R.CC-C Rd:27 Cn:31 110000:110000 Cm:17 11000010110:11000010110
	.inst 0xc2c210e0
	.zero 1045712
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a2 // ldr c2, [x5, #2]
	.inst 0xc2400cac // ldr c12, [x5, #3]
	.inst 0xc24010ad // ldr c13, [x5, #4]
	.inst 0xc24014ae // ldr c14, [x5, #5]
	.inst 0xc24018b0 // ldr c16, [x5, #6]
	.inst 0xc2401cb3 // ldr c19, [x5, #7]
	.inst 0xc24020be // ldr c30, [x5, #8]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e5 // ldr c5, [c7, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x826010e5 // ldr c5, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x7, #0xf
	and x5, x5, x7
	cmp x5, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a7 // ldr c7, [x5, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24004a7 // ldr c7, [x5, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24008a7 // ldr c7, [x5, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400ca7 // ldr c7, [x5, #3]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc24010a7 // ldr c7, [x5, #4]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc24014a7 // ldr c7, [x5, #5]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc24018a7 // ldr c7, [x5, #6]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401ca7 // ldr c7, [x5, #7]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc24020a7 // ldr c7, [x5, #8]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc24024a7 // ldr c7, [x5, #9]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc24028a7 // ldr c7, [x5, #10]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2402ca7 // ldr c7, [x5, #11]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc24030a7 // ldr c7, [x5, #12]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc24034a7 // ldr c7, [x5, #13]
	.inst 0xc2c7a7c1 // chkeq c30, c7
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
	ldr x2, =0x00001060
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001084
	ldr x1, =check_data2
	ldr x2, =0x0000108c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001390
	ldr x1, =check_data3
	ldr x2, =0x000013a0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400b18
	ldr x1, =check_data5
	ldr x2, =0x00400b30
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
