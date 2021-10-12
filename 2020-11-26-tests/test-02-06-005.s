.section data0, #alloc, #write
	.zero 2048
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x01, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x01
.data
check_data3:
	.byte 0x01
.data
check_data4:
	.byte 0x0b, 0xc9, 0xb2, 0xb8, 0xf4, 0x63, 0xbf, 0x38, 0xf9, 0xc0, 0xd3, 0xc2, 0x1f, 0x30, 0x3f, 0x38
	.byte 0x20, 0xb0, 0xc5, 0xc2, 0x89, 0x33, 0xe0, 0x78, 0xbf, 0x9b, 0xf9, 0xc2, 0xce, 0xd3, 0x40, 0x7a
	.byte 0xfd, 0xe3, 0xda, 0xc2, 0xbf, 0x82, 0x60, 0x38, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ffe
	/* C1 */
	.octa 0x1
	/* C7 */
	.octa 0x1
	/* C8 */
	.octa 0x80000000400000040000000000000004
	/* C18 */
	.octa 0x11fc
	/* C21 */
	.octa 0xc0000000000100050000000000001ffe
	/* C28 */
	.octa 0xc0000000400000040000000000001004
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x20008000000040080000000000000001
	/* C1 */
	.octa 0x1
	/* C7 */
	.octa 0x1
	/* C8 */
	.octa 0x80000000400000040000000000000004
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C18 */
	.octa 0x11fc
	/* C20 */
	.octa 0x1
	/* C21 */
	.octa 0xc0000000000100050000000000001ffe
	/* C25 */
	.octa 0x1
	/* C28 */
	.octa 0xc0000000400000040000000000001004
initial_SP_EL3_value:
	.octa 0xc0000000100704150000000000001800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb8b2c90b // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:11 Rn:8 10:10 S:0 option:110 Rm:18 1:1 opc:10 111000:111000 size:10
	.inst 0x38bf63f4 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:20 Rn:31 00:00 opc:110 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xc2d3c0f9 // CVT-R.CC-C Rd:25 Cn:7 110000:110000 Cm:19 11000010110:11000010110
	.inst 0x383f301f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:011 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c5b020 // CVTP-C.R-C Cd:0 Rn:1 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x78e03389 // ldseth:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:28 00:00 opc:011 0:0 Rs:0 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xc2f99bbf // SUBS-R.CC-C Rd:31 Cn:29 100110:100110 Cm:25 11000010111:11000010111
	.inst 0x7a40d3ce // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1110 0:0 Rn:30 00:00 cond:1101 Rm:0 111010010:111010010 op:1 sf:0
	.inst 0xc2dae3fd // SCFLGS-C.CR-C Cd:29 Cn:31 111000:111000 Rm:26 11000010110:11000010110
	.inst 0x386082bf // swpb:aarch64/instrs/memory/atomicops/swp Rt:31 Rn:21 100000:100000 Rs:0 1:1 R:1 A:0 111000:111000 size:00
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a7 // ldr c7, [x5, #2]
	.inst 0xc2400ca8 // ldr c8, [x5, #3]
	.inst 0xc24010b2 // ldr c18, [x5, #4]
	.inst 0xc24014b5 // ldr c21, [x5, #5]
	.inst 0xc24018bc // ldr c28, [x5, #6]
	.inst 0xc2401cbd // ldr c29, [x5, #7]
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
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601185 // ldr c5, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
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
	mov x12, #0xf
	and x5, x5, x12
	cmp x5, #0xe
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000ac // ldr c12, [x5, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24004ac // ldr c12, [x5, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24008ac // ldr c12, [x5, #2]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc2400cac // ldr c12, [x5, #3]
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	.inst 0xc24010ac // ldr c12, [x5, #4]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc24014ac // ldr c12, [x5, #5]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc24018ac // ldr c12, [x5, #6]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc2401cac // ldr c12, [x5, #7]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc24020ac // ldr c12, [x5, #8]
	.inst 0xc2cca6a1 // chkeq c21, c12
	b.ne comparison_fail
	.inst 0xc24024ac // ldr c12, [x5, #9]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc24028ac // ldr c12, [x5, #10]
	.inst 0xc2cca781 // chkeq c28, c12
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
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001204
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001801
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
