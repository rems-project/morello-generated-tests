.section data0, #alloc, #write
	.zero 1280
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2800
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x07, 0x14, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xc5, 0x43, 0x6b, 0x38, 0x02, 0x08, 0x41, 0x3a, 0x5f, 0x80, 0x8d, 0xb8, 0xe1, 0x84, 0xc1, 0xc2
	.byte 0x5e, 0x90, 0x92, 0xe2, 0xe0, 0x73, 0xc2, 0xc2, 0xef, 0x7f, 0x0d, 0x88, 0x01, 0x29, 0x5f, 0x78
	.byte 0xa0, 0x00, 0x04, 0xd8, 0x81, 0x9d, 0x5b, 0x92, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x2000c0080000000000000000
	/* C2 */
	.octa 0x40000000000700070000000000001417
	/* C7 */
	.octa 0x70007000000000000e000
	/* C8 */
	.octa 0x800000005004000a000000000000100e
	/* C11 */
	.octa 0x0
	/* C30 */
	.octa 0x1407
final_cap_values:
	/* C2 */
	.octa 0x40000000000700070000000000001417
	/* C5 */
	.octa 0x82
	/* C7 */
	.octa 0x70007000000000000e000
	/* C8 */
	.octa 0x800000005004000a000000000000100e
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x1
	/* C30 */
	.octa 0x1407
initial_SP_EL3_value:
	.octa 0x400000005402080a0000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480e00000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004000010100ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x386b43c5 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:5 Rn:30 00:00 opc:100 0:0 Rs:11 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x3a410802 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0010 0:0 Rn:0 10:10 cond:0000 imm5:00001 111010010:111010010 op:0 sf:0
	.inst 0xb88d805f // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:2 00:00 imm9:011011000 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c184e1 // CHKSS-_.CC-C 00001:00001 Cn:7 001:001 opc:00 1:1 Cm:1 11000010110:11000010110
	.inst 0xe292905e // ASTUR-R.RI-32 Rt:30 Rn:2 op2:00 imm9:100101001 V:0 op1:10 11100010:11100010
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x880d7fef // stxr:aarch64/instrs/memory/exclusive/single Rt:15 Rn:31 Rt2:11111 o0:0 Rs:13 0:0 L:0 0010000:0010000 size:10
	.inst 0x785f2901 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:8 10:10 imm9:111110010 0:0 opc:01 111000:111000 size:01
	.inst 0xd80400a0 // prfm_lit:aarch64/instrs/memory/literal/general Rt:0 imm19:0000010000000000101 011000:011000 opc:11
	.inst 0x925b9d81 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:12 imms:100111 immr:011011 N:1 100100:100100 opc:00 sf:1
	.inst 0xc2c21360
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c7 // ldr c7, [x14, #2]
	.inst 0xc2400dc8 // ldr c8, [x14, #3]
	.inst 0xc24011cb // ldr c11, [x14, #4]
	.inst 0xc24015de // ldr c30, [x14, #5]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260336e // ldr c14, [c27, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260136e // ldr c14, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x27, #0xf
	and x14, x14, x27
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001db // ldr c27, [x14, #0]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc24005db // ldr c27, [x14, #1]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc24009db // ldr c27, [x14, #2]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc2400ddb // ldr c27, [x14, #3]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc24011db // ldr c27, [x14, #4]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc24015db // ldr c27, [x14, #5]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc24019db // ldr c27, [x14, #6]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001340
	ldr x1, =check_data1
	ldr x2, =0x00001344
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001508
	ldr x1, =check_data2
	ldr x2, =0x00001509
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000015f0
	ldr x1, =check_data3
	ldr x2, =0x000015f4
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
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
