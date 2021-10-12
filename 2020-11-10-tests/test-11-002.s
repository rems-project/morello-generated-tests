.section data0, #alloc, #write
	.byte 0xe9, 0x7f, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 4080
.data
check_data0:
	.byte 0xe9, 0x7f, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xf0
.data
check_data3:
	.byte 0xe0, 0xb3, 0xde, 0xc2
.data
check_data4:
	.byte 0xbf, 0x09, 0x3f, 0xca, 0x1f, 0xfa, 0x90, 0xb8, 0x1f, 0x30, 0x36, 0xb8, 0x5d, 0x0f, 0x2d, 0x9b
	.byte 0x1f, 0xfc, 0x3f, 0x42, 0xc0, 0x7f, 0x3f, 0x42, 0xbf, 0xa2, 0xdf, 0xc2, 0x57, 0xb8, 0x3e, 0x9b
	.byte 0x1e, 0x30, 0xe1, 0x38, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc000000057be17d800000000000017f0
	/* C1 */
	.octa 0x0
	/* C16 */
	.octa 0x80000000000100050000000000410049
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x1ffe
final_cap_values:
	/* C0 */
	.octa 0xc000000057be17d800000000000017f0
	/* C1 */
	.octa 0x0
	/* C16 */
	.octa 0x80000000000100050000000000410049
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x901000000001000700000000000010b0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2deb3e0 // BR-CI-C 0:0 0000:0000 Cn:31 100:100 imm7:1110101 110000101101:110000101101
	.zero 32740
	.inst 0xca3f09bf // eon:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:13 imm6:000010 Rm:31 N:1 shift:00 01010:01010 opc:10 sf:1
	.inst 0xb890fa1f // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:16 10:10 imm9:100001111 0:0 opc:10 111000:111000 size:10
	.inst 0xb836301f // ldset:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:0 00:00 opc:011 0:0 Rs:22 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x9b2d0f5d // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:26 Ra:3 o0:0 Rm:13 01:01 U:0 10011011:10011011
	.inst 0x423ffc1f // ASTLR-R.R-32 Rt:31 Rn:0 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x423f7fc0 // ASTLRB-R.R-B Rt:0 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2dfa2bf // CLRPERM-C.CR-C Cd:31 Cn:21 000:000 1:1 10:10 Rm:31 11000010110:11000010110
	.inst 0x9b3eb857 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:23 Rn:2 Ra:14 o0:1 Rm:30 01:01 U:0 10011011:10011011
	.inst 0x38e1301e // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:0 00:00 opc:011 0:0 Rs:1 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xc2c210a0
	.zero 1015792
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009f0 // ldr c16, [x15, #2]
	.inst 0xc2400df5 // ldr c21, [x15, #3]
	.inst 0xc24011f6 // ldr c22, [x15, #4]
	.inst 0xc24015fe // ldr c30, [x15, #5]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851037
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030af // ldr c15, [c5, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x826010af // ldr c15, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e5 // ldr c5, [x15, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24005e5 // ldr c5, [x15, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc24009e5 // ldr c5, [x15, #2]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc2400de5 // ldr c5, [x15, #3]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc24011e5 // ldr c5, [x15, #4]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc24015e5 // ldr c5, [x15, #5]
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
	ldr x0, =0x000017f0
	ldr x1, =check_data1
	ldr x2, =0x000017f4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00407fe8
	ldr x1, =check_data4
	ldr x2, =0x00408010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040ff58
	ldr x1, =check_data5
	ldr x2, =0x0040ff5c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
