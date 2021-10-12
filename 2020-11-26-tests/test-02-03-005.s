.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x6b, 0xd8, 0x45, 0xa2, 0xb9, 0x48, 0xbf, 0xf8, 0x1b, 0xfd, 0x5f, 0x88, 0xbe, 0x4b, 0xf0, 0xc2
	.byte 0x01, 0xfc, 0x48, 0x38, 0x81, 0x20, 0x0a, 0xa2, 0x00, 0x48, 0xe2, 0xc2, 0x07, 0x50, 0xf4, 0xc2
	.byte 0xa2, 0x7f, 0x7f, 0x88, 0xf9, 0x37, 0xb4, 0xe2, 0x40, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 8
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1f6e
	/* C3 */
	.octa 0x1210
	/* C4 */
	.octa 0x100e
	/* C8 */
	.octa 0x4bffd0
	/* C29 */
	.octa 0x800000000000000000409bc0
final_cap_values:
	/* C0 */
	.octa 0x1200000000001ffd
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1210
	/* C4 */
	.octa 0x100e
	/* C7 */
	.octa 0xb000000000001ffd
	/* C8 */
	.octa 0x4bffd0
	/* C11 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x800000000000000000409bc0
	/* C30 */
	.octa 0x800000008200000000409bc0
initial_SP_EL3_value:
	.octa 0x80000000500150020000000000408401
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000110200070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000017e0
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa245d86b // LDTR-C.RIB-C Ct:11 Rn:3 10:10 imm9:001011101 0:0 opc:01 10100010:10100010
	.inst 0xf8bf48b9 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:25 Rn:5 10:10 S:0 option:010 Rm:31 1:1 opc:10 111000:111000 size:11
	.inst 0x885ffd1b // ldaxr:aarch64/instrs/memory/exclusive/single Rt:27 Rn:8 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0xc2f04bbe // ORRFLGS-C.CI-C Cd:30 Cn:29 0:0 01:01 imm8:10000010 11000010111:11000010111
	.inst 0x3848fc01 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:0 11:11 imm9:010001111 0:0 opc:01 111000:111000 size:00
	.inst 0xa20a2081 // STUR-C.RI-C Ct:1 Rn:4 00:00 imm9:010100010 0:0 opc:00 10100010:10100010
	.inst 0xc2e24800 // ORRFLGS-C.CI-C Cd:0 Cn:0 0:0 01:01 imm8:00010010 11000010111:11000010111
	.inst 0xc2f45007 // EORFLGS-C.CI-C Cd:7 Cn:0 0:0 10:10 imm8:10100010 11000010111:11000010111
	.inst 0x887f7fa2 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:2 Rn:29 Rt2:11111 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0xe2b437f9 // ALDUR-V.RI-S Rt:25 Rn:31 op2:01 imm9:101000011 V:1 op1:10 11100010:11100010
	.inst 0xc2c21340
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400603 // ldr c3, [x16, #1]
	.inst 0xc2400a04 // ldr c4, [x16, #2]
	.inst 0xc2400e08 // ldr c8, [x16, #3]
	.inst 0xc240121d // ldr c29, [x16, #4]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851037
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603350 // ldr c16, [c26, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601350 // ldr c16, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240021a // ldr c26, [x16, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240061a // ldr c26, [x16, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a1a // ldr c26, [x16, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400e1a // ldr c26, [x16, #3]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc240121a // ldr c26, [x16, #4]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc240161a // ldr c26, [x16, #5]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc2401a1a // ldr c26, [x16, #6]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc2401e1a // ldr c26, [x16, #7]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc240221a // ldr c26, [x16, #8]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	.inst 0xc240261a // ldr c26, [x16, #9]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2402a1a // ldr c26, [x16, #10]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x26, v25.d[0]
	cmp x16, x26
	b.ne comparison_fail
	ldr x16, =0x0
	mov x26, v25.d[1]
	cmp x16, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010b0
	ldr x1, =check_data0
	ldr x2, =0x000010c0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017e0
	ldr x1, =check_data1
	ldr x2, =0x000017f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffd
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
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
	ldr x0, =0x00408344
	ldr x1, =check_data4
	ldr x2, =0x00408348
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00409bc0
	ldr x1, =check_data5
	ldr x2, =0x00409bc8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004bffd0
	ldr x1, =check_data6
	ldr x2, =0x004bffd4
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
