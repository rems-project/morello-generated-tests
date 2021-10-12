.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x43, 0x00, 0xbf, 0xf3, 0x03, 0x00, 0x00, 0xb2, 0x00, 0x00
.data
check_data2:
	.byte 0x1e, 0x30, 0xc0, 0xc2, 0x1e, 0x44, 0x84, 0xf9, 0x2b, 0xfc, 0xb3, 0xa2, 0xae, 0x83, 0x3b, 0xf8
	.byte 0x1e, 0x7f, 0x7f, 0x42, 0xde, 0x23, 0xa1, 0x38, 0x0d, 0x68, 0x16, 0xc2, 0x43, 0x68, 0x49, 0xf2
	.byte 0xbf, 0x33, 0x71, 0x38, 0x2c, 0x51, 0xc0, 0xc2, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data3:
	.byte 0xe0
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x7800fffffffffffffaf40
	/* C1 */
	.octa 0xe0
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0xd80000000000
	/* C13 */
	.octa 0xb2000003f3bf0043000000000000
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x1800000000000000000000000
	/* C24 */
	.octa 0x800000000001000500000000004ffffc
	/* C27 */
	.octa 0xe0
	/* C29 */
	.octa 0xe0
final_cap_values:
	/* C0 */
	.octa 0x7800fffffffffffffaf40
	/* C1 */
	.octa 0xe0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C11 */
	.octa 0xd80000000000
	/* C13 */
	.octa 0xb2000003f3bf0043000000000000
	/* C14 */
	.octa 0xd80000000000
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x1800000000000000000000000
	/* C24 */
	.octa 0x800000000001000500000000004ffffc
	/* C27 */
	.octa 0xe0
	/* C29 */
	.octa 0xe0
	/* C30 */
	.octa 0xe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000007e0070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc00000040020f200000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0301e // GCLEN-R.C-C Rd:30 Cn:0 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xf984441e // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:000100010001 opc:10 111001:111001 size:11
	.inst 0xa2b3fc2b // CASL-C.R-C Ct:11 Rn:1 11111:11111 R:1 Cs:19 1:1 L:0 1:1 10100010:10100010
	.inst 0xf83b83ae // swp:aarch64/instrs/memory/atomicops/swp Rt:14 Rn:29 100000:100000 Rs:27 1:1 R:0 A:0 111000:111000 size:11
	.inst 0x427f7f1e // ALDARB-R.R-B Rt:30 Rn:24 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x38a123de // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:30 00:00 opc:010 0:0 Rs:1 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xc216680d // STR-C.RIB-C Ct:13 Rn:0 imm12:010110011010 L:0 110000100:110000100
	.inst 0xf2496843 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:3 Rn:2 imms:011010 immr:001001 N:1 100100:100100 opc:11 sf:1
	.inst 0x387133bf // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:29 00:00 opc:011 0:0 Rs:17 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xc2c0512c // GCVALUE-R.C-C Rd:12 Cn:9 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c210a0
	.zero 1048528
	.inst 0x000000e0
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e0b // ldr c11, [x16, #3]
	.inst 0xc240120d // ldr c13, [x16, #4]
	.inst 0xc2401611 // ldr c17, [x16, #5]
	.inst 0xc2401a13 // ldr c19, [x16, #6]
	.inst 0xc2401e18 // ldr c24, [x16, #7]
	.inst 0xc240221b // ldr c27, [x16, #8]
	.inst 0xc240261d // ldr c29, [x16, #9]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b0 // ldr c16, [c5, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x826010b0 // ldr c16, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x5, #0xf
	and x16, x16, x5
	cmp x16, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400205 // ldr c5, [x16, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400605 // ldr c5, [x16, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a05 // ldr c5, [x16, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400e05 // ldr c5, [x16, #3]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc2401205 // ldr c5, [x16, #4]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2401605 // ldr c5, [x16, #5]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2401a05 // ldr c5, [x16, #6]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2401e05 // ldr c5, [x16, #7]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2402205 // ldr c5, [x16, #8]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2402605 // ldr c5, [x16, #9]
	.inst 0xc2c5a701 // chkeq c24, c5
	b.ne comparison_fail
	.inst 0xc2402a05 // ldr c5, [x16, #10]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc2402e05 // ldr c5, [x16, #11]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2403205 // ldr c5, [x16, #12]
	.inst 0xc2c5a7c1 // chkeq c30, c5
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
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001810
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffffc
	ldr x1, =check_data3
	ldr x2, =0x004ffffd
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
