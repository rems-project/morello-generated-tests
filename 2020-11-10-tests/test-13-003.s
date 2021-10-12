.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0xc8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xc8, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0xc8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x01, 0xfc, 0x5f, 0x48, 0xdf, 0x13, 0xc5, 0xc2, 0x42, 0x6b, 0xc6, 0xc2, 0x21, 0x19, 0xff, 0xc2
	.byte 0xcc, 0xff, 0xe7, 0xa2, 0x21, 0x10, 0x61, 0x38, 0x54, 0x80, 0xa0, 0xb8, 0x20, 0xc8, 0xd3, 0x38
	.byte 0x13, 0xe2, 0x9e, 0x82, 0x49, 0x9d, 0x55, 0x38, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x1000600070000000000b0b000
	/* C10 */
	.octa 0x3fc
	/* C12 */
	.octa 0xc800000000
	/* C16 */
	.octa 0x400000000001000500000000000010b7
	/* C19 */
	.octa 0x0
	/* C26 */
	.octa 0xc00
	/* C30 */
	.octa 0x60c
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc8
	/* C2 */
	.octa 0xc00
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x355
	/* C12 */
	.octa 0xc800000000
	/* C16 */
	.octa 0x400000000001000500000000000010b7
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C26 */
	.octa 0xc00
	/* C30 */
	.octa 0x60c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000438010040000000000000023
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 144
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x485ffc01 // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:1 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xc2c513df // CVTD-R.C-C Rd:31 Cn:30 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2c66b42 // ORRFLGS-C.CR-C Cd:2 Cn:26 1010:1010 opc:01 Rm:6 11000010110:11000010110
	.inst 0xc2ff1921 // CVT-C.CR-C Cd:1 Cn:9 0110:0110 0:0 0:0 Rm:31 11000010111:11000010111
	.inst 0xa2e7ffcc // CASAL-C.R-C Ct:12 Rn:30 11111:11111 R:1 Cs:7 1:1 L:1 1:1 10100010:10100010
	.inst 0x38611021 // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:1 00:00 opc:001 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xb8a08054 // swp:aarch64/instrs/memory/atomicops/swp Rt:20 Rn:2 100000:100000 Rs:0 1:1 R:0 A:1 111000:111000 size:10
	.inst 0x38d3c820 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:1 10:10 imm9:100111100 0:0 opc:11 111000:111000 size:00
	.inst 0x829ee213 // ASTRB-R.RRB-B Rt:19 Rn:16 opc:00 S:0 option:111 Rm:30 0:0 L:0 100000101:100000101
	.inst 0x38559d49 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:9 Rn:10 11:11 imm9:101011001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c21240
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
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400466 // ldr c6, [x3, #1]
	.inst 0xc2400867 // ldr c7, [x3, #2]
	.inst 0xc2400c69 // ldr c9, [x3, #3]
	.inst 0xc240106a // ldr c10, [x3, #4]
	.inst 0xc240146c // ldr c12, [x3, #5]
	.inst 0xc2401870 // ldr c16, [x3, #6]
	.inst 0xc2401c73 // ldr c19, [x3, #7]
	.inst 0xc240207a // ldr c26, [x3, #8]
	.inst 0xc240247e // ldr c30, [x3, #9]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851037
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603243 // ldr c3, [c18, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601243 // ldr c3, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x18, #0xf
	and x3, x3, x18
	cmp x3, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400072 // ldr c18, [x3, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400472 // ldr c18, [x3, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400872 // ldr c18, [x3, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400c72 // ldr c18, [x3, #3]
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	.inst 0xc2401072 // ldr c18, [x3, #4]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc2401472 // ldr c18, [x3, #5]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2401872 // ldr c18, [x3, #6]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401c72 // ldr c18, [x3, #7]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2402072 // ldr c18, [x3, #8]
	.inst 0xc2d2a601 // chkeq c16, c18
	b.ne comparison_fail
	.inst 0xc2402472 // ldr c18, [x3, #9]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2402872 // ldr c18, [x3, #10]
	.inst 0xc2d2a681 // chkeq c20, c18
	b.ne comparison_fail
	.inst 0xc2402c72 // ldr c18, [x3, #11]
	.inst 0xc2d2a741 // chkeq c26, c18
	b.ne comparison_fail
	.inst 0xc2403072 // ldr c18, [x3, #12]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001006
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001009
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001359
	ldr x1, =check_data2
	ldr x2, =0x0000135a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001610
	ldr x1, =check_data3
	ldr x2, =0x00001620
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000016c3
	ldr x1, =check_data4
	ldr x2, =0x000016c4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001c04
	ldr x1, =check_data5
	ldr x2, =0x00001c08
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
