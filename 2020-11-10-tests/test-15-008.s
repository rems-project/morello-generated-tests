.section data0, #alloc, #write
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x1d, 0xc8, 0xcd, 0x82, 0x62, 0xf1, 0x93, 0x82, 0xfe, 0x03, 0x1d, 0xda, 0x1e, 0x9c, 0xca, 0x78
	.byte 0xd3, 0x71, 0xb0, 0xf8, 0x4c, 0xb0, 0xc0, 0xc2, 0x20, 0x1c, 0x52, 0x79, 0xc9, 0x33, 0x34, 0xe2
	.byte 0x5f, 0xfc, 0x54, 0x82, 0x53, 0x92, 0x36, 0xf2, 0x60, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x3d, 0x11
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100070000000000400041
	/* C1 */
	.octa 0x8000000058010002000000000000070e
	/* C2 */
	.octa 0x1000
	/* C11 */
	.octa 0x1000
	/* C13 */
	.octa 0x1
	/* C14 */
	.octa 0xc0000000000700070000000000001000
	/* C16 */
	.octa 0x8000000000000000
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x8000000058010002000000000000070e
	/* C2 */
	.octa 0x1000
	/* C11 */
	.octa 0x1000
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x1
	/* C14 */
	.octa 0xc0000000000700070000000000001000
	/* C16 */
	.octa 0x8000000000000000
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x113d
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000000000000000080000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82cdc81d // ALDRSH-R.RRB-32 Rt:29 Rn:0 opc:10 S:0 option:110 Rm:13 0:0 L:1 100000101:100000101
	.inst 0x8293f162 // ASTRB-R.RRB-B Rt:2 Rn:11 opc:00 S:1 option:111 Rm:19 0:0 L:0 100000101:100000101
	.inst 0xda1d03fe // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:31 000000:000000 Rm:29 11010000:11010000 S:0 op:1 sf:1
	.inst 0x78ca9c1e // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:0 11:11 imm9:010101001 0:0 opc:11 111000:111000 size:01
	.inst 0xf8b071d3 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:19 Rn:14 00:00 opc:111 0:0 Rs:16 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xc2c0b04c // GCSEAL-R.C-C Rd:12 Cn:2 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x79521c20 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:1 imm12:010010000111 opc:01 111001:111001 size:01
	.inst 0xe23433c9 // ASTUR-V.RI-B Rt:9 Rn:30 op2:00 imm9:101000011 V:1 op1:00 11100010:11100010
	.inst 0x8254fc5f // ASTR-R.RI-64 Rt:31 Rn:2 op:11 imm9:101001111 L:0 1000001001:1000001001
	.inst 0xf2369253 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:19 Rn:18 imms:100100 immr:110110 N:0 100100:100100 opc:11 sf:1
	.inst 0xc2c21360
	.zero 188
	.inst 0x113d0000
	.zero 1048340
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b42 // ldr c2, [x26, #2]
	.inst 0xc2400f4b // ldr c11, [x26, #3]
	.inst 0xc240134d // ldr c13, [x26, #4]
	.inst 0xc240174e // ldr c14, [x26, #5]
	.inst 0xc2401b50 // ldr c16, [x26, #6]
	.inst 0xc2401f52 // ldr c18, [x26, #7]
	.inst 0xc2402353 // ldr c19, [x26, #8]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q9, =0x0
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30851037
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260337a // ldr c26, [c27, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260137a // ldr c26, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x27, #0xf
	and x26, x26, x27
	cmp x26, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240035b // ldr c27, [x26, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240075b // ldr c27, [x26, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400b5b // ldr c27, [x26, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400f5b // ldr c27, [x26, #3]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc240135b // ldr c27, [x26, #4]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc240175b // ldr c27, [x26, #5]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc2401b5b // ldr c27, [x26, #6]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc2401f5b // ldr c27, [x26, #7]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc240235b // ldr c27, [x26, #8]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240275b // ldr c27, [x26, #9]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc2402b5b // ldr c27, [x26, #10]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc2402f5b // ldr c27, [x26, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x27, v9.d[0]
	cmp x26, x27
	b.ne comparison_fail
	ldr x26, =0x0
	mov x27, v9.d[1]
	cmp x26, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000101c
	ldr x1, =check_data1
	ldr x2, =0x0000101e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001081
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a78
	ldr x1, =check_data3
	ldr x2, =0x00001a80
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
	ldr x0, =0x00400042
	ldr x1, =check_data5
	ldr x2, =0x00400044
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004000ea
	ldr x1, =check_data6
	ldr x2, =0x004000ec
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
