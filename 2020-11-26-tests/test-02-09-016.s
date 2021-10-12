.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x80, 0x00, 0x00, 0x00, 0x9f, 0x3f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xaf, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x8f, 0xf2, 0xfe, 0xc2, 0xc1, 0x57, 0x0e, 0xa2, 0xbf, 0x2b, 0x7f, 0x88, 0x40, 0x7e, 0x57, 0xd3
	.byte 0xbf, 0x7d, 0x15, 0xc8, 0x6f, 0x63, 0xff, 0x82, 0x0a, 0x00, 0xc0, 0xda, 0x1f, 0x53, 0x34, 0x38
	.byte 0x01, 0x30, 0xc2, 0xc2, 0xd1, 0x20, 0x29, 0x78, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xaf000000000000003f9f00000000
	/* C6 */
	.octa 0x1040
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x1fc0
	/* C20 */
	.octa 0x80
	/* C24 */
	.octa 0x1000
	/* C27 */
	.octa 0x80000000480100000000000000400000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C1 */
	.octa 0xaf000000000000003f9f00000000
	/* C6 */
	.octa 0x1040
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x1fc0
	/* C15 */
	.octa 0xc2fef28f
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x80
	/* C21 */
	.octa 0x1
	/* C24 */
	.octa 0x1000
	/* C27 */
	.octa 0x80000000480100000000000000400000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1e50
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000000080000000802007ff0f6300
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2fef28f // EORFLGS-C.CI-C Cd:15 Cn:20 0:0 10:10 imm8:11110111 11000010111:11000010111
	.inst 0xa20e57c1 // STR-C.RIAW-C Ct:1 Rn:30 01:01 imm9:011100101 0:0 opc:00 10100010:10100010
	.inst 0x887f2bbf // ldxp:aarch64/instrs/memory/exclusive/pair Rt:31 Rn:29 Rt2:01010 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0xd3577e40 // ubfm:aarch64/instrs/integer/bitfield Rd:0 Rn:18 imms:011111 immr:010111 N:1 100110:100110 opc:10 sf:1
	.inst 0xc8157dbf // stxr:aarch64/instrs/memory/exclusive/single Rt:31 Rn:13 Rt2:11111 o0:0 Rs:21 0:0 L:0 0010000:0010000 size:11
	.inst 0x82ff636f // ALDR-R.RRB-32 Rt:15 Rn:27 opc:00 S:0 option:011 Rm:31 1:1 L:1 100000101:100000101
	.inst 0xdac0000a // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:10 Rn:0 101101011000000000000:101101011000000000000 sf:1
	.inst 0x3834531f // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:24 00:00 opc:101 0:0 Rs:20 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xc2c23001 // CHKTGD-C-C 00001:00001 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x782920d1 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:17 Rn:6 00:00 opc:010 0:0 Rs:9 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xc2c21160
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
	.inst 0xc2400341 // ldr c1, [x26, #0]
	.inst 0xc2400746 // ldr c6, [x26, #1]
	.inst 0xc2400b49 // ldr c9, [x26, #2]
	.inst 0xc2400f4d // ldr c13, [x26, #3]
	.inst 0xc2401354 // ldr c20, [x26, #4]
	.inst 0xc2401758 // ldr c24, [x26, #5]
	.inst 0xc2401b5b // ldr c27, [x26, #6]
	.inst 0xc2401f5d // ldr c29, [x26, #7]
	.inst 0xc240235e // ldr c30, [x26, #8]
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
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260317a // ldr c26, [c11, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260117a // ldr c26, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	mov x11, #0xf
	and x26, x26, x11
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034b // ldr c11, [x26, #0]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240074b // ldr c11, [x26, #1]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc2400b4b // ldr c11, [x26, #2]
	.inst 0xc2cba521 // chkeq c9, c11
	b.ne comparison_fail
	.inst 0xc2400f4b // ldr c11, [x26, #3]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240134b // ldr c11, [x26, #4]
	.inst 0xc2cba5e1 // chkeq c15, c11
	b.ne comparison_fail
	.inst 0xc240174b // ldr c11, [x26, #5]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc2401b4b // ldr c11, [x26, #6]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc2401f4b // ldr c11, [x26, #7]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc240234b // ldr c11, [x26, #8]
	.inst 0xc2cba701 // chkeq c24, c11
	b.ne comparison_fail
	.inst 0xc240274b // ldr c11, [x26, #9]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc2402b4b // ldr c11, [x26, #10]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc2402f4b // ldr c11, [x26, #11]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001042
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc0
	ldr x1, =check_data2
	ldr x2, =0x00001fc8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
