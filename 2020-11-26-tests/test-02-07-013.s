.section data0, #alloc, #write
	.byte 0xbe, 0xff, 0x36, 0xff, 0xdf, 0x7f, 0xff, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
	.byte 0x01, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2000
	.byte 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0xf7, 0xff, 0x36, 0xff, 0xdf, 0x7f, 0xff, 0xfc
.data
check_data1:
	.byte 0x01, 0x80
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0xc3, 0x24, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data4:
	.byte 0x1f, 0x53, 0x70, 0x78, 0xc1, 0x2f, 0x40, 0xeb, 0x6c, 0x28, 0xdb, 0x1a, 0x03, 0x41, 0x72, 0x38
	.byte 0xfb, 0xab, 0x69, 0x92, 0x0d, 0x11, 0xa4, 0xf8, 0x0d, 0x14, 0x56, 0x11, 0xdf, 0x53, 0x7c, 0xf8
	.byte 0x38, 0xc6, 0x63, 0x50, 0x31, 0x91, 0x58, 0x82, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0xc00000007ffa0c700000000000001000
	/* C9 */
	.octa 0xfffffffffffff900
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x40000000000000000024c3000000
	/* C18 */
	.octa 0xf7
	/* C24 */
	.octa 0xc0000000000700040000000000001020
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0xc0000000000500060000000000001800
final_cap_values:
	/* C3 */
	.octa 0xbe
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0xc00000007ffa0c700000000000001000
	/* C9 */
	.octa 0xfffffffffffff900
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x40000000000000000024c3000000
	/* C18 */
	.octa 0xf7
	/* C24 */
	.octa 0x200080000001000700000000004c78e6
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0xc0000000000500060000000000001800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x48000000588200800000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7870531f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:24 00:00 opc:101 o3:0 Rs:16 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xeb402fc1 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:30 imm6:001011 Rm:0 0:0 shift:01 01011:01011 S:1 op:1 sf:1
	.inst 0x1adb286c // asrv:aarch64/instrs/integer/shift/variable Rd:12 Rn:3 op2:10 0010:0010 Rm:27 0011010110:0011010110 sf:0
	.inst 0x38724103 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:8 00:00 opc:100 0:0 Rs:18 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x9269abfb // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:27 Rn:31 imms:101010 immr:101001 N:1 100100:100100 opc:00 sf:1
	.inst 0xf8a4110d // ldclr:aarch64/instrs/memory/atomicops/ld Rt:13 Rn:8 00:00 opc:001 0:0 Rs:4 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x1156140d // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:13 Rn:0 imm12:010110000101 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xf87c53df // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:101 o3:0 Rs:28 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x5063c638 // ADR-C.I-C Rd:24 immhi:110001111000110001 P:0 10000:10000 immlo:10 op:0
	.inst 0x82589131 // ASTR-C.RI-C Ct:17 Rn:9 op:00 imm9:110001001 L:0 1000001001:1000001001
	.inst 0xc2c21320
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
	ldr x26, =initial_cap_values
	.inst 0xc2400344 // ldr c4, [x26, #0]
	.inst 0xc2400748 // ldr c8, [x26, #1]
	.inst 0xc2400b49 // ldr c9, [x26, #2]
	.inst 0xc2400f50 // ldr c16, [x26, #3]
	.inst 0xc2401351 // ldr c17, [x26, #4]
	.inst 0xc2401752 // ldr c18, [x26, #5]
	.inst 0xc2401b58 // ldr c24, [x26, #6]
	.inst 0xc2401f5c // ldr c28, [x26, #7]
	.inst 0xc240235e // ldr c30, [x26, #8]
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
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260333a // ldr c26, [c25, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260133a // ldr c26, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400359 // ldr c25, [x26, #0]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2400759 // ldr c25, [x26, #1]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400b59 // ldr c25, [x26, #2]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2400f59 // ldr c25, [x26, #3]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc2401359 // ldr c25, [x26, #4]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401759 // ldr c25, [x26, #5]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc2401b59 // ldr c25, [x26, #6]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2401f59 // ldr c25, [x26, #7]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc2402359 // ldr c25, [x26, #8]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc2402759 // ldr c25, [x26, #9]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc2402b59 // ldr c25, [x26, #10]
	.inst 0xc2d9a7c1 // chkeq c30, c25
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001022
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001210
	ldr x1, =check_data2
	ldr x2, =0x00001220
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001808
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
