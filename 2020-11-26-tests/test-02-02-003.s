.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x74, 0x1d, 0x44, 0xa2, 0x5f, 0x6a, 0x16, 0xa2, 0x08, 0x02, 0xa0, 0x38, 0xf7, 0xe3, 0xe3, 0xc2
	.byte 0xe0, 0x53, 0xc0, 0xc2, 0x32, 0xec, 0x73, 0xd1, 0x2c, 0xc2, 0x3f, 0xa2, 0x80, 0xc3, 0x7d, 0xe2
	.byte 0xc2, 0x63, 0x9f, 0x82, 0x41, 0xe3, 0x8e, 0x3d, 0x60, 0x12, 0xc2, 0xc2
.data
check_data7:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0x90100000000700870000000000001510
	/* C16 */
	.octa 0xc0000000000700030000000000001200
	/* C17 */
	.octa 0x90100000500ad44a00000000004001e0
	/* C18 */
	.octa 0x40000000000600050000000000002220
	/* C26 */
	.octa 0x4000000004a10006ffffffffffffe160
	/* C28 */
	.octa 0x2010
	/* C30 */
	.octa 0x1800
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x90100000000700870000000000001920
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0xc0000000000700030000000000001200
	/* C17 */
	.octa 0x90100000500ad44a00000000004001e0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x3fff800000000000000000000000
	/* C26 */
	.octa 0x4000000004a10006ffffffffffffe160
	/* C28 */
	.octa 0x2010
	/* C30 */
	.octa 0x1800
initial_SP_EL3_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004140050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000003000700ffe0000000e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001920
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2441d74 // LDR-C.RIBW-C Ct:20 Rn:11 11:11 imm9:001000001 0:0 opc:01 10100010:10100010
	.inst 0xa2166a5f // STTR-C.RIB-C Ct:31 Rn:18 10:10 imm9:101100110 0:0 opc:00 10100010:10100010
	.inst 0x38a00208 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:8 Rn:16 00:00 opc:000 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xc2e3e3f7 // BICFLGS-C.CI-C Cd:23 Cn:31 0:0 00:00 imm8:00011111 11000010111:11000010111
	.inst 0xc2c053e0 // GCVALUE-R.C-C Rd:0 Cn:31 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xd173ec32 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:18 Rn:1 imm12:110011111011 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xa23fc22c // LDAPR-C.R-C Ct:12 Rn:17 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0xe27dc380 // ASTUR-V.RI-H Rt:0 Rn:28 op2:00 imm9:111011100 V:1 op1:01 11100010:11100010
	.inst 0x829f63c2 // ASTRB-R.RRB-B Rt:2 Rn:30 opc:00 S:0 option:011 Rm:31 0:0 L:0 100000101:100000101
	.inst 0x3d8ee341 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:1 Rn:26 imm12:001110111000 opc:10 111101:111101 size:00
	.inst 0xc2c21260
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008cb // ldr c11, [x6, #2]
	.inst 0xc2400cd0 // ldr c16, [x6, #3]
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc24014d2 // ldr c18, [x6, #5]
	.inst 0xc24018da // ldr c26, [x6, #6]
	.inst 0xc2401cdc // ldr c28, [x6, #7]
	.inst 0xc24020de // ldr c30, [x6, #8]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q0, =0x0
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851037
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603266 // ldr c6, [c19, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601266 // ldr c6, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d3 // ldr c19, [x6, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24004d3 // ldr c19, [x6, #1]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc24008d3 // ldr c19, [x6, #2]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc2400cd3 // ldr c19, [x6, #3]
	.inst 0xc2d3a561 // chkeq c11, c19
	b.ne comparison_fail
	.inst 0xc24010d3 // ldr c19, [x6, #4]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc24014d3 // ldr c19, [x6, #5]
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	.inst 0xc24018d3 // ldr c19, [x6, #6]
	.inst 0xc2d3a621 // chkeq c17, c19
	b.ne comparison_fail
	.inst 0xc2401cd3 // ldr c19, [x6, #7]
	.inst 0xc2d3a681 // chkeq c20, c19
	b.ne comparison_fail
	.inst 0xc24020d3 // ldr c19, [x6, #8]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc24024d3 // ldr c19, [x6, #9]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc24028d3 // ldr c19, [x6, #10]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc2402cd3 // ldr c19, [x6, #11]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x19, v0.d[0]
	cmp x6, x19
	b.ne comparison_fail
	ldr x6, =0x0
	mov x19, v0.d[1]
	cmp x6, x19
	b.ne comparison_fail
	ldr x6, =0x0
	mov x19, v1.d[0]
	cmp x6, x19
	b.ne comparison_fail
	ldr x6, =0x0
	mov x19, v1.d[1]
	cmp x6, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001200
	ldr x1, =check_data0
	ldr x2, =0x00001201
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001801
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001880
	ldr x1, =check_data2
	ldr x2, =0x00001890
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001920
	ldr x1, =check_data3
	ldr x2, =0x00001930
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ce0
	ldr x1, =check_data4
	ldr x2, =0x00001cf0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fec
	ldr x1, =check_data5
	ldr x2, =0x00001fee
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
	ldr x0, =0x004001e0
	ldr x1, =check_data7
	ldr x2, =0x004001f0
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
