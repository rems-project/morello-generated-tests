.section data0, #alloc, #write
	.zero 80
	.byte 0xfe, 0xff, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4000
.data
check_data0:
	.byte 0xfe, 0xff, 0x4f, 0x00
.data
check_data1:
	.byte 0x3e, 0xcb, 0xfe, 0xca, 0x23, 0xfc, 0x5f, 0x42, 0xf2, 0xc6, 0x71, 0x69, 0x7e, 0x19, 0x9d, 0x38
	.byte 0x61, 0x7c, 0x52, 0x9b, 0x1c, 0x20, 0xbf, 0xb8, 0x14, 0x10, 0x85, 0xf9, 0xbf, 0xa3, 0x4d, 0x38
	.byte 0xfd, 0xb1, 0x7d, 0xca, 0x8a, 0x7f, 0x1e, 0x08, 0x00, 0x13, 0xc2, 0xc2
.data
check_data2:
	.byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
.data
check_data3:
	.byte 0xfe
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1050
	/* C1 */
	.octa 0x4c7fe0
	/* C11 */
	.octa 0x50002d
	/* C23 */
	.octa 0x400074
	/* C29 */
	.octa 0x4fff24
final_cap_values:
	/* C0 */
	.octa 0x1050
	/* C1 */
	.octa 0x35366b
	/* C3 */
	.octa 0xfefefefefefefefefefefefefefefefe
	/* C11 */
	.octa 0x50002d
	/* C17 */
	.octa 0x425ffc23
	/* C18 */
	.octa 0xffffffffcafecb3e
	/* C23 */
	.octa 0x400074
	/* C28 */
	.octa 0x4ffffe
	/* C30 */
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000001100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xcafecb3e // eon:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:25 imm6:110010 Rm:30 N:1 shift:11 01010:01010 opc:10 sf:1
	.inst 0x425ffc23 // LDAR-C.R-C Ct:3 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x6971c6f2 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:18 Rn:23 Rt2:10001 imm7:1100011 L:1 1010010:1010010 opc:01
	.inst 0x389d197e // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:11 10:10 imm9:111010001 0:0 opc:10 111000:111000 size:00
	.inst 0x9b527c61 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:3 Ra:11111 0:0 Rm:18 10:10 U:0 10011011:10011011
	.inst 0xb8bf201c // ldeor:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:0 00:00 opc:010 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:10
	.inst 0xf9851014 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:20 Rn:0 imm12:000101000100 opc:10 111001:111001 size:11
	.inst 0x384da3bf // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:29 00:00 imm9:011011010 0:0 opc:01 111000:111000 size:00
	.inst 0xca7db1fd // eon:aarch64/instrs/integer/logical/shiftedreg Rd:29 Rn:15 imm6:101100 Rm:29 N:1 shift:01 01010:01010 opc:10 sf:1
	.inst 0x081e7f8a // stxrb:aarch64/instrs/memory/exclusive/single Rt:10 Rn:28 Rt2:11111 o0:0 Rs:30 0:0 L:0 0010000:0010000 size:00
	.inst 0xc2c21300
	.zero 819124
	.inst 0xfefefefe
	.inst 0xfefefefe
	.inst 0xfefefefe
	.inst 0xfefefefe
	.zero 229388
	.inst 0x00fe0000
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009ab // ldr c11, [x13, #2]
	.inst 0xc2400db7 // ldr c23, [x13, #3]
	.inst 0xc24011bd // ldr c29, [x13, #4]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851037
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260330d // ldr c13, [c24, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260130d // ldr c13, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b8 // ldr c24, [x13, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24005b8 // ldr c24, [x13, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24009b8 // ldr c24, [x13, #2]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc2400db8 // ldr c24, [x13, #3]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc24011b8 // ldr c24, [x13, #4]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc24015b8 // ldr c24, [x13, #5]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc24019b8 // ldr c24, [x13, #6]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc2401db8 // ldr c24, [x13, #7]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc24021b8 // ldr c24, [x13, #8]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001050
	ldr x1, =check_data0
	ldr x2, =0x00001054
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004c7fe0
	ldr x1, =check_data2
	ldr x2, =0x004c7ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffffe
	ldr x1, =check_data3
	ldr x2, =0x004fffff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
