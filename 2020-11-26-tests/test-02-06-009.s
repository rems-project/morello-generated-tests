.section data0, #alloc, #write
	.zero 1952
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00
	.zero 1088
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00
	.zero 1008
.data
check_data0:
	.byte 0x00, 0x1c
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x20, 0x01, 0x40, 0x00, 0x40, 0x22, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0x1e, 0x21, 0xa0, 0x78, 0x6f, 0xfc, 0xba, 0xa2, 0x3b, 0xb8, 0x56, 0xa2, 0xa2, 0x5c, 0xe1, 0xc2
	.byte 0xd4, 0x60, 0xdc, 0x62, 0x1e, 0xfc, 0xfe, 0x48, 0x3f, 0xcf, 0x4f, 0xb8, 0xe0, 0x73, 0xc2, 0xc2
	.byte 0x1a, 0x7c, 0xc5, 0xc2, 0xa6, 0x1b, 0x5e, 0xfa, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1c00
	/* C1 */
	.octa 0x1960
	/* C3 */
	.octa 0x1c00
	/* C5 */
	.octa 0x8010000000030001fffffffffffe89e0
	/* C6 */
	.octa 0x1420
	/* C8 */
	.octa 0x1000
	/* C15 */
	.octa 0x4000000000224000400120000000
	/* C25 */
	.octa 0x1080
	/* C26 */
	.octa 0x400000000000000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1c00
	/* C1 */
	.octa 0x1960
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1c00
	/* C5 */
	.octa 0x8010000000030001fffffffffffe89e0
	/* C6 */
	.octa 0x17a0
	/* C8 */
	.octa 0x1000
	/* C15 */
	.octa 0x4000000000224000400120000000
	/* C20 */
	.octa 0x800000000000000000000000
	/* C24 */
	.octa 0x20000000000000000000000000
	/* C25 */
	.octa 0x117c
	/* C26 */
	.octa 0x1c00
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000025100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd8000000000000000000000000000c00
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000017a0
	.dword 0x00000000000017b0
	.dword 0x0000000000001c00
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78a0211e // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:8 00:00 opc:010 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xa2bafc6f // CASL-C.R-C Ct:15 Rn:3 11111:11111 R:1 Cs:26 1:1 L:0 1:1 10100010:10100010
	.inst 0xa256b83b // LDTR-C.RIB-C Ct:27 Rn:1 10:10 imm9:101101011 0:0 opc:01 10100010:10100010
	.inst 0xc2e15ca2 // ALDR-C.RRB-C Ct:2 Rn:5 1:1 L:1 S:1 option:010 Rm:1 11000010111:11000010111
	.inst 0x62dc60d4 // LDP-C.RIBW-C Ct:20 Rn:6 Ct2:11000 imm7:0111000 L:1 011000101:011000101
	.inst 0x48fefc1e // cash:aarch64/instrs/memory/atomicops/cas/single Rt:30 Rn:0 11111:11111 o0:1 Rs:30 1:1 L:1 0010001:0010001 size:01
	.inst 0xb84fcf3f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:25 11:11 imm9:011111100 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2c57c1a // CSEL-C.CI-C Cd:26 Cn:0 11:11 cond:0111 Cm:5 11000010110:11000010110
	.inst 0xfa5e1ba6 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0110 0:0 Rn:29 10:10 cond:0001 imm5:11110 111010010:111010010 op:1 sf:1
	.inst 0xc2c21180
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e3 // ldr c3, [x7, #2]
	.inst 0xc2400ce5 // ldr c5, [x7, #3]
	.inst 0xc24010e6 // ldr c6, [x7, #4]
	.inst 0xc24014e8 // ldr c8, [x7, #5]
	.inst 0xc24018ef // ldr c15, [x7, #6]
	.inst 0xc2401cf9 // ldr c25, [x7, #7]
	.inst 0xc24020fa // ldr c26, [x7, #8]
	/* Set up flags and system registers */
	mov x7, #0x40000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30851037
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603187 // ldr c7, [c12, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601187 // ldr c7, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x12, #0xf
	and x7, x7, x12
	cmp x7, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000ec // ldr c12, [x7, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24004ec // ldr c12, [x7, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24008ec // ldr c12, [x7, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400cec // ldr c12, [x7, #3]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc24010ec // ldr c12, [x7, #4]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc24014ec // ldr c12, [x7, #5]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc24018ec // ldr c12, [x7, #6]
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	.inst 0xc2401cec // ldr c12, [x7, #7]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc24020ec // ldr c12, [x7, #8]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc24024ec // ldr c12, [x7, #9]
	.inst 0xc2cca701 // chkeq c24, c12
	b.ne comparison_fail
	.inst 0xc24028ec // ldr c12, [x7, #10]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc2402cec // ldr c12, [x7, #11]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc24030ec // ldr c12, [x7, #12]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc24034ec // ldr c12, [x7, #13]
	.inst 0xc2cca7c1 // chkeq c30, c12
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000117c
	ldr x1, =check_data2
	ldr x2, =0x00001180
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017a0
	ldr x1, =check_data3
	ldr x2, =0x000017c0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001c00
	ldr x1, =check_data4
	ldr x2, =0x00001c10
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fe0
	ldr x1, =check_data5
	ldr x2, =0x00001ff0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
