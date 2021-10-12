.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1536
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0
	.zero 400
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0
	.zero 1680
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0
	.zero 400
.data
check_data0:
	.byte 0xc0
.data
check_data1:
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0
.data
check_data2:
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0
.data
check_data3:
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0
.data
check_data4:
	.byte 0x42, 0x48, 0xc0, 0xc2, 0xd1, 0xff, 0xf0, 0x42, 0x1e, 0x04, 0xc0, 0xda, 0x8a, 0x22, 0x40, 0x3a
	.byte 0x43, 0x8d, 0x9e, 0x38, 0x1d, 0x08, 0xc0, 0xda, 0x01, 0xb9, 0xd4, 0x69, 0x2e, 0xc0, 0x3f, 0xa2
	.byte 0x1f, 0x68, 0x5e, 0xa2, 0x80, 0x00, 0x3f, 0xd6
.data
check_data5:
	.byte 0x60, 0x13, 0xc2, 0xc2
.data
check_data6:
	.byte 0xc0, 0x17, 0x00, 0x00, 0xc0, 0xc0, 0xc0, 0xc0
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000000000000000000002000
	/* C2 */
	.octa 0x200000000000000000000000000
	/* C4 */
	.octa 0x402000
	/* C8 */
	.octa 0x420840
	/* C10 */
	.octa 0x1020
	/* C30 */
	.octa 0x1800
final_cap_values:
	/* C0 */
	.octa 0x2000000000000000000002000
	/* C1 */
	.octa 0x17c0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xffffffffffffffc0
	/* C4 */
	.octa 0x402000
	/* C8 */
	.octa 0x4208e4
	/* C10 */
	.octa 0x1008
	/* C14 */
	.octa 0xc0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0
	/* C17 */
	.octa 0xc0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0
	/* C29 */
	.octa 0x200000
	/* C30 */
	.octa 0x400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x801000001f0900070082007ffffa0001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001610
	.dword 0x0000000000001620
	.dword 0x00000000000017c0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c04842 // UNSEAL-C.CC-C Cd:2 Cn:2 0010:0010 opc:01 Cm:0 11000010110:11000010110
	.inst 0x42f0ffd1 // LDP-C.RIB-C Ct:17 Rn:30 Ct2:11111 imm7:1100001 L:1 010000101:010000101
	.inst 0xdac0041e // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:0 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0x3a40228a // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1010 0:0 Rn:20 00:00 cond:0010 Rm:0 111010010:111010010 op:0 sf:0
	.inst 0x389e8d43 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:3 Rn:10 11:11 imm9:111101000 0:0 opc:10 111000:111000 size:00
	.inst 0xdac0081d // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:29 Rn:0 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x69d4b901 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:8 Rt2:01110 imm7:0101001 L:1 1010011:1010011 opc:01
	.inst 0xa23fc02e // LDAPR-C.R-C Ct:14 Rn:1 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0xa25e681f // LDTR-C.RIB-C Ct:31 Rn:0 10:10 imm9:111100110 0:0 opc:01 10100010:10100010
	.inst 0xd63f0080 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:4 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 8152
	.inst 0xc2c21360
	.zero 125152
	.inst 0x000017c0
	.inst 0xc0c0c0c0
	.zero 915220
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
	.inst 0xc2400742 // ldr c2, [x26, #1]
	.inst 0xc2400b44 // ldr c4, [x26, #2]
	.inst 0xc2400f48 // ldr c8, [x26, #3]
	.inst 0xc240134a // ldr c10, [x26, #4]
	.inst 0xc240175e // ldr c30, [x26, #5]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30851035
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
	cmp x26, #0xa
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
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc240135b // ldr c27, [x26, #4]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc240175b // ldr c27, [x26, #5]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc2401b5b // ldr c27, [x26, #6]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc2401f5b // ldr c27, [x26, #7]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc240235b // ldr c27, [x26, #8]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc240275b // ldr c27, [x26, #9]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc2402b5b // ldr c27, [x26, #10]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x00001009
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001610
	ldr x1, =check_data1
	ldr x2, =0x00001630
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017c0
	ldr x1, =check_data2
	ldr x2, =0x000017d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e60
	ldr x1, =check_data3
	ldr x2, =0x00001e70
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00402000
	ldr x1, =check_data5
	ldr x2, =0x00402004
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004208e4
	ldr x1, =check_data6
	ldr x2, =0x004208ec
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
