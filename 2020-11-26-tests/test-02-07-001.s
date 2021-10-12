.section data0, #alloc, #write
	.zero 2048
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x00, 0x10
.data
check_data1:
	.byte 0x00, 0x18, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xe3, 0xfb, 0x3d, 0xa2, 0xc1, 0x22, 0xdf, 0xc2, 0xd1, 0x53, 0xf9, 0xc2, 0xbd, 0x7f, 0x1f, 0x48
	.byte 0xff, 0x03, 0x07, 0x5a, 0x5f, 0x36, 0x35, 0x39, 0x07, 0x1b, 0xce, 0xca, 0x20, 0x30, 0xe1, 0xb8
	.byte 0xbf, 0x03, 0x3f, 0xf8, 0x00, 0x08, 0x0d, 0x78, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x0
	/* C18 */
	.octa 0x1004
	/* C22 */
	.octa 0x10000500070000000000001800
	/* C29 */
	.octa 0x1df0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x10580018000000000000001800
	/* C3 */
	.octa 0x0
	/* C17 */
	.octa 0xca00000000000000
	/* C18 */
	.octa 0x1004
	/* C22 */
	.octa 0x10000500070000000000001800
	/* C29 */
	.octa 0x1df0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xfffffffffffe4000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005f810ffc0000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa23dfbe3 // STR-C.RRB-C Ct:3 Rn:31 10:10 S:1 option:111 Rm:29 1:1 opc:00 10100010:10100010
	.inst 0xc2df22c1 // SCBNDSE-C.CR-C Cd:1 Cn:22 000:000 opc:01 0:0 Rm:31 11000010110:11000010110
	.inst 0xc2f953d1 // EORFLGS-C.CI-C Cd:17 Cn:30 0:0 10:10 imm8:11001010 11000010111:11000010111
	.inst 0x481f7fbd // stxrh:aarch64/instrs/memory/exclusive/single Rt:29 Rn:29 Rt2:11111 o0:0 Rs:31 0:0 L:0 0010000:0010000 size:01
	.inst 0x5a0703ff // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:31 000000:000000 Rm:7 11010000:11010000 S:0 op:1 sf:0
	.inst 0x3935365f // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:18 imm12:110101001101 opc:00 111001:111001 size:00
	.inst 0xcace1b07 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:7 Rn:24 imm6:000110 Rm:14 N:0 shift:11 01010:01010 opc:10 sf:1
	.inst 0xb8e13020 // ldset:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:1 00:00 opc:011 0:0 Rs:1 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xf83f03bf // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:000 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x780d0800 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:0 10:10 imm9:011010000 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c211a0
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
	.inst 0xc2400343 // ldr c3, [x26, #0]
	.inst 0xc2400752 // ldr c18, [x26, #1]
	.inst 0xc2400b56 // ldr c22, [x26, #2]
	.inst 0xc2400f5d // ldr c29, [x26, #3]
	.inst 0xc240135e // ldr c30, [x26, #4]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	ldr x26, =0x0
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031ba // ldr c26, [c13, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x826011ba // ldr c26, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
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
	.inst 0xc240034d // ldr c13, [x26, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240074d // ldr c13, [x26, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400b4d // ldr c13, [x26, #2]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc2400f4d // ldr c13, [x26, #3]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc240134d // ldr c13, [x26, #4]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc240174d // ldr c13, [x26, #5]
	.inst 0xc2cda6c1 // chkeq c22, c13
	b.ne comparison_fail
	.inst 0xc2401b4d // ldr c13, [x26, #6]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc2401f4d // ldr c13, [x26, #7]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010d0
	ldr x1, =check_data0
	ldr x2, =0x000010d2
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001804
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001d51
	ldr x1, =check_data2
	ldr x2, =0x00001d52
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001df0
	ldr x1, =check_data3
	ldr x2, =0x00001df8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f00
	ldr x1, =check_data4
	ldr x2, =0x00001f10
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
