.section data0, #alloc, #write
	.zero 144
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00
	.zero 96
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x01
.data
check_data2:
	.byte 0x01, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x5e, 0xd8, 0xd9, 0x38, 0x1f, 0x22, 0x26, 0x38, 0x9e, 0x59, 0xfe, 0xc2, 0x36, 0x55, 0xf5, 0xe2
	.byte 0x6f, 0x92, 0xdf, 0x34, 0xc5, 0x51, 0x7f, 0x38, 0x9f, 0x60, 0x20, 0x38, 0x1e, 0x4c, 0x5a, 0xa2
	.byte 0x5f, 0x44, 0xbe, 0x52, 0x5f, 0x40, 0x61, 0x78, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2200
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1100
	/* C4 */
	.octa 0x1000
	/* C6 */
	.octa 0x1
	/* C9 */
	.octa 0x8000000020060003000000000000202b
	/* C12 */
	.octa 0x800280070000800000000000
	/* C14 */
	.octa 0x1000
	/* C15 */
	.octa 0xffffffff
	/* C16 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x1c40
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1100
	/* C4 */
	.octa 0x1000
	/* C5 */
	.octa 0x1
	/* C6 */
	.octa 0x1
	/* C9 */
	.octa 0x8000000020060003000000000000202b
	/* C12 */
	.octa 0x800280070000800000000000
	/* C14 */
	.octa 0x1000
	/* C15 */
	.octa 0xffffffff
	/* C16 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000007000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001c40
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38d9d85e // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:2 10:10 imm9:110011101 0:0 opc:11 111000:111000 size:00
	.inst 0x3826221f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:16 00:00 opc:010 o3:0 Rs:6 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2fe599e // CVTZ-C.CR-C Cd:30 Cn:12 0110:0110 1:1 0:0 Rm:30 11000010111:11000010111
	.inst 0xe2f55536 // ALDUR-V.RI-D Rt:22 Rn:9 op2:01 imm9:101010101 V:1 op1:11 11100010:11100010
	.inst 0x34df926f // cbz:aarch64/instrs/branch/conditional/compare Rt:15 imm19:1101111110010010011 op:0 011010:011010 sf:0
	.inst 0x387f51c5 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:5 Rn:14 00:00 opc:101 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x3820609f // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:4 00:00 opc:110 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa25a4c1e // LDR-C.RIBW-C Ct:30 Rn:0 11:11 imm9:110100100 0:0 opc:01 10100010:10100010
	.inst 0x52be445f // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:31 imm16:1111001000100010 hw:01 100101:100101 opc:10 sf:0
	.inst 0x7861405f // stsmaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:100 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c21060
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b02 // ldr c2, [x24, #2]
	.inst 0xc2400f04 // ldr c4, [x24, #3]
	.inst 0xc2401306 // ldr c6, [x24, #4]
	.inst 0xc2401709 // ldr c9, [x24, #5]
	.inst 0xc2401b0c // ldr c12, [x24, #6]
	.inst 0xc2401f0e // ldr c14, [x24, #7]
	.inst 0xc240230f // ldr c15, [x24, #8]
	.inst 0xc2402710 // ldr c16, [x24, #9]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851037
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603078 // ldr c24, [c3, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601078 // ldr c24, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400303 // ldr c3, [x24, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400703 // ldr c3, [x24, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400b03 // ldr c3, [x24, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400f03 // ldr c3, [x24, #3]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2401303 // ldr c3, [x24, #4]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc2401703 // ldr c3, [x24, #5]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc2401b03 // ldr c3, [x24, #6]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2401f03 // ldr c3, [x24, #7]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2402303 // ldr c3, [x24, #8]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2402703 // ldr c3, [x24, #9]
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	.inst 0xc2402b03 // ldr c3, [x24, #10]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2402f03 // ldr c3, [x24, #11]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x3, v22.d[0]
	cmp x24, x3
	b.ne comparison_fail
	ldr x24, =0x0
	mov x3, v22.d[1]
	cmp x24, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000109d
	ldr x1, =check_data1
	ldr x2, =0x0000109e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001102
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c40
	ldr x1, =check_data3
	ldr x2, =0x00001c50
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f80
	ldr x1, =check_data4
	ldr x2, =0x00001f88
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
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
