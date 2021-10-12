.section data0, #alloc, #write
	.zero 2048
	.byte 0x08, 0x7e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x00, 0x7d
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x01, 0x7d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x3e, 0x0f, 0x08, 0x78, 0xc0, 0x8b, 0xc4, 0xc2, 0x60, 0x78, 0x16, 0x1c, 0x40, 0xb8, 0x35, 0xc8
	.byte 0xdd, 0x7c, 0x3f, 0x42, 0x21, 0x50, 0xbe, 0xf8, 0x3e, 0x08, 0x3e, 0x9b, 0xfd, 0x0f, 0x8b, 0xb8
	.byte 0xbd, 0x67, 0xcc, 0xc2, 0x7d, 0x20, 0xde, 0xc2, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1800
	/* C2 */
	.octa 0x1400
	/* C3 */
	.octa 0x400000000000000000000000
	/* C4 */
	.octa 0x6000000600ffffffffffe000
	/* C6 */
	.octa 0x40000000588208840000000000001080
	/* C25 */
	.octa 0x1000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x600020000000000000007d01
final_cap_values:
	/* C0 */
	.octa 0x600020000000000000007d01
	/* C1 */
	.octa 0x7e08
	/* C2 */
	.octa 0x1400
	/* C3 */
	.octa 0x400000000000000000000000
	/* C4 */
	.octa 0x6000000600ffffffffffe000
	/* C6 */
	.octa 0x40000000588208840000000000001080
	/* C21 */
	.octa 0x1
	/* C25 */
	.octa 0x1080
	/* C29 */
	.octa 0x3b1e00000000000000000000
	/* C30 */
	.octa 0x3d8a7a08
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa00080000406001f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000600200000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78080f3e // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:25 11:11 imm9:010000000 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c48bc0 // CHKSSU-C.CC-C Cd:0 Cn:30 0010:0010 opc:10 Cm:4 11000010110:11000010110
	.inst 0x1c167860 // ldr_lit_fpsimd:aarch64/instrs/memory/literal/simdfp Rt:0 imm19:0001011001111000011 011100:011100 opc:00
	.inst 0xc835b840 // stlxp:aarch64/instrs/memory/exclusive/pair Rt:0 Rn:2 Rt2:01110 o0:1 Rs:21 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0x423f7cdd // ASTLRB-R.R-B Rt:29 Rn:6 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xf8be5021 // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:1 00:00 opc:101 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x9b3e083e // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:1 Ra:2 o0:0 Rm:30 01:01 U:0 10011011:10011011
	.inst 0xb88b0ffd // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:29 Rn:31 11:11 imm9:010110000 0:0 opc:10 111000:111000 size:10
	.inst 0xc2cc67bd // CPYVALUE-C.C-C Cd:29 Cn:29 001:001 opc:11 0:0 Cm:12 11000010110:11000010110
	.inst 0xc2de207d // SCBNDSE-C.CR-C Cd:29 Cn:3 000:000 opc:01 0:0 Rm:30 11000010110:11000010110
	.inst 0xc2c211e0
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
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400903 // ldr c3, [x8, #2]
	.inst 0xc2400d04 // ldr c4, [x8, #3]
	.inst 0xc2401106 // ldr c6, [x8, #4]
	.inst 0xc2401519 // ldr c25, [x8, #5]
	.inst 0xc240191d // ldr c29, [x8, #6]
	.inst 0xc2401d1e // ldr c30, [x8, #7]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x3085103f
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031e8 // ldr c8, [c15, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826011e8 // ldr c8, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x15, #0xf
	and x8, x8, x15
	cmp x8, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010f // ldr c15, [x8, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240050f // ldr c15, [x8, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240090f // ldr c15, [x8, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400d0f // ldr c15, [x8, #3]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc240110f // ldr c15, [x8, #4]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc240150f // ldr c15, [x8, #5]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc240190f // ldr c15, [x8, #6]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc2401d0f // ldr c15, [x8, #7]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc240210f // ldr c15, [x8, #8]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc240250f // ldr c15, [x8, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x15, v0.d[0]
	cmp x8, x15
	b.ne comparison_fail
	ldr x8, =0x0
	mov x15, v0.d[1]
	cmp x8, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x00001082
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010b0
	ldr x1, =check_data1
	ldr x2, =0x000010b4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001410
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
	ldr x0, =0x0042cf14
	ldr x1, =check_data5
	ldr x2, =0x0042cf18
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
