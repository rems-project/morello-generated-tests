.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xc3, 0xc3, 0x9e, 0x82, 0xa8, 0x53, 0xec, 0x54, 0x1e, 0x7c, 0x49, 0x9b, 0xdc, 0xab, 0x15, 0x38
	.byte 0xb9, 0x33, 0xc7, 0xc2, 0x20, 0x30, 0xc2, 0xc2
.data
check_data4:
	.byte 0xf8, 0xcf, 0x17, 0xf8, 0x01, 0x7c, 0x53, 0x9b, 0x45, 0x28, 0x7f, 0x22, 0xa1, 0xa2, 0xc1, 0xc2
	.byte 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000
	/* C1 */
	.octa 0x200080002007a007000000000042c000
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x4000000000000800
	/* C21 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000080080000000000000800
final_cap_values:
	/* C0 */
	.octa 0x8000
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x4000000000000800
	/* C10 */
	.octa 0x0
	/* C21 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0xffffffffffffffff
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000a00060000000000000400018
initial_SP_EL3_value:
	.octa 0x2004
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200060000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000001800400000f05ffb5e0d6401
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 16
	.dword initial_cap_values + 144
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x829ec3c3 // ASTRB-R.RRB-B Rt:3 Rn:30 opc:00 S:0 option:110 Rm:30 0:0 L:0 100000101:100000101
	.inst 0x54ec53a8 // b_cond:aarch64/instrs/branch/conditional/cond cond:1000 0:0 imm19:1110110001010011101 01010100:01010100
	.inst 0x9b497c1e // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:0 Ra:11111 0:0 Rm:9 10:10 U:0 10011011:10011011
	.inst 0x3815abdc // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:28 Rn:30 10:10 imm9:101011010 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c733b9 // RRMASK-R.R-C Rd:25 Rn:29 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c23020 // BLR-C-C 00000:00000 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.zero 180200
	.inst 0xf817cff8 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:24 Rn:31 11:11 imm9:101111100 0:0 opc:00 111000:111000 size:11
	.inst 0x9b537c01 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:0 Ra:11111 0:0 Rm:19 10:10 U:0 10011011:10011011
	.inst 0x227f2845 // LDXP-C.R-C Ct:5 Rn:2 Ct2:01010 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xc2c1a2a1 // CLRPERM-C.CR-C Cd:1 Cn:21 000:000 1:1 10:10 Rm:1 11000010110:11000010110
	.inst 0xc2c21200
	.zero 868332
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400882 // ldr c2, [x4, #2]
	.inst 0xc2400c83 // ldr c3, [x4, #3]
	.inst 0xc2401089 // ldr c9, [x4, #4]
	.inst 0xc2401495 // ldr c21, [x4, #5]
	.inst 0xc2401898 // ldr c24, [x4, #6]
	.inst 0xc2401c9c // ldr c28, [x4, #7]
	.inst 0xc240209d // ldr c29, [x4, #8]
	.inst 0xc240249e // ldr c30, [x4, #9]
	/* Set up flags and system registers */
	mov x4, #0x60000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	ldr x4, =0x84
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603204 // ldr c4, [c16, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601204 // ldr c4, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x16, #0x6
	and x4, x4, x16
	cmp x4, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400090 // ldr c16, [x4, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400490 // ldr c16, [x4, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400890 // ldr c16, [x4, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400c90 // ldr c16, [x4, #3]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2401090 // ldr c16, [x4, #4]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc2401490 // ldr c16, [x4, #5]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc2401890 // ldr c16, [x4, #6]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc2401c90 // ldr c16, [x4, #7]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc2402090 // ldr c16, [x4, #8]
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	.inst 0xc2402490 // ldr c16, [x4, #9]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2402890 // ldr c16, [x4, #10]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	.inst 0xc2402c90 // ldr c16, [x4, #11]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2403090 // ldr c16, [x4, #12]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f5a
	ldr x1, =check_data1
	ldr x2, =0x00001f5b
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f80
	ldr x1, =check_data2
	ldr x2, =0x00001f88
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400018
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0042c000
	ldr x1, =check_data4
	ldr x2, =0x0042c014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
