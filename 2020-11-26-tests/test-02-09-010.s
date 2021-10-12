.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xde, 0x69, 0xc1, 0xc2, 0x4b, 0x2b, 0x9d, 0x2b, 0x1e, 0x92, 0x52, 0x78, 0xbd, 0xff, 0x32, 0x22
	.byte 0x49, 0x4b, 0x15, 0xe2, 0xe0, 0x33, 0xc6, 0xc2, 0xdd, 0x03, 0xb5, 0x9b, 0x1f, 0x00, 0x1d, 0x9a
	.byte 0xe1, 0xa7, 0xde, 0xc2, 0x5f, 0x3b, 0x03, 0xd5, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x800000000001000500000000004000f1
	/* C26 */
	.octa 0x5000aa
	/* C29 */
	.octa 0x480040000001000600000000004fffc0
final_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C9 */
	.octa 0xffffffffffffffc2
	/* C11 */
	.octa 0x5014a9
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x800000000001000500000000004000f1
	/* C18 */
	.octa 0x1
	/* C26 */
	.octa 0x5000aa
	/* C30 */
	.octa 0x9bb5
initial_SP_EL3_value:
	.octa 0x800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c169de // ORRFLGS-C.CR-C Cd:30 Cn:14 1010:1010 opc:01 Rm:1 11000010110:11000010110
	.inst 0x2b9d2b4b // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:11 Rn:26 imm6:001010 Rm:29 0:0 shift:10 01011:01011 S:1 op:0 sf:0
	.inst 0x7852921e // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:16 00:00 imm9:100101001 0:0 opc:01 111000:111000 size:01
	.inst 0x2232ffbd // STLXP-R.CR-C Ct:29 Rn:29 Ct2:11111 1:1 Rs:18 1:1 L:0 001000100:001000100
	.inst 0xe2154b49 // ALDURSB-R.RI-64 Rt:9 Rn:26 op2:10 imm9:101010100 V:0 op1:00 11100010:11100010
	.inst 0xc2c633e0 // CLRPERM-C.CI-C Cd:0 Cn:31 100:100 perm:001 1100001011000110:1100001011000110
	.inst 0x9bb503dd // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:30 Ra:0 o0:0 Rm:21 01:01 U:1 10011011:10011011
	.inst 0x9a1d001f // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:0 000000:000000 Rm:29 11010000:11010000 S:0 op:0 sf:1
	.inst 0xc2dea7e1 // CHKEQ-_.CC-C 00001:00001 Cn:31 001:001 opc:01 1:1 Cm:30 11000010110:11000010110
	.inst 0xd5033b5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1011 11010101000000110011:11010101000000110011
	.inst 0xc2c210a0
	.zero 1048528
	.inst 0x00c20000
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
	ldr x2, =initial_cap_values
	.inst 0xc240004e // ldr c14, [x2, #0]
	.inst 0xc2400450 // ldr c16, [x2, #1]
	.inst 0xc240085a // ldr c26, [x2, #2]
	.inst 0xc2400c5d // ldr c29, [x2, #3]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =initial_SP_EL3_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2c1d05f // cpy c31, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	ldr x2, =0x0
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030a2 // ldr c2, [c5, #3]
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	.inst 0x826010a2 // ldr c2, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x5, #0xf
	and x2, x2, x5
	cmp x2, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400045 // ldr c5, [x2, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400445 // ldr c5, [x2, #1]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc2400845 // ldr c5, [x2, #2]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2400c45 // ldr c5, [x2, #3]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2401045 // ldr c5, [x2, #4]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc2401445 // ldr c5, [x2, #5]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2401845 // ldr c5, [x2, #6]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2401c45 // ldr c5, [x2, #7]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040002c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x004ffffe
	ldr x1, =check_data1
	ldr x2, =0x004fffff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	/* Done print message */
	/* turn off MMU */
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
