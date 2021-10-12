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
	.byte 0xa2, 0x4d, 0x28, 0x2b, 0x1f, 0xc0, 0xc3, 0xc2, 0x51, 0x20, 0xc1, 0x1a, 0x4c, 0x80, 0x21, 0xa2
	.byte 0xc6, 0x9b, 0xe2, 0xc2, 0x27, 0x20, 0x60, 0xea, 0xdf, 0x41, 0x3b, 0x78, 0xc2, 0xff, 0x5f, 0x42
	.byte 0xcb, 0x33, 0xe0, 0x38, 0x1f, 0x78, 0x7f, 0xf2, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x1000
	/* C14 */
	.octa 0x1000
	/* C27 */
	.octa 0x8000
	/* C30 */
	.octa 0x1100
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x100
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x1000
	/* C14 */
	.octa 0x1000
	/* C17 */
	.octa 0x1000
	/* C27 */
	.octa 0x8000
	/* C30 */
	.octa 0x1100
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000200070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd01000005800000400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001100
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2b284da2 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:2 Rn:13 imm3:011 option:010 Rm:8 01011001:01011001 S:1 op:0 sf:0
	.inst 0xc2c3c01f // CVT-R.CC-C Rd:31 Cn:0 110000:110000 Cm:3 11000010110:11000010110
	.inst 0x1ac12051 // lslv:aarch64/instrs/integer/shift/variable Rd:17 Rn:2 op2:00 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0xa221804c // SWP-CC.R-C Ct:12 Rn:2 100000:100000 Cs:1 1:1 R:0 A:0 10100010:10100010
	.inst 0xc2e29bc6 // SUBS-R.CC-C Rd:6 Cn:30 100110:100110 Cm:2 11000010111:11000010111
	.inst 0xea602027 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:7 Rn:1 imm6:001000 Rm:0 N:1 shift:01 01010:01010 opc:11 sf:1
	.inst 0x783b41df // stsmaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:14 00:00 opc:100 o3:0 Rs:27 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x425fffc2 // LDAR-C.R-C Ct:2 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x38e033cb // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:11 Rn:30 00:00 opc:011 0:0 Rs:0 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xf27f781f // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:0 imms:011110 immr:111111 N:1 100100:100100 opc:11 sf:1
	.inst 0xc2c21300
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400888 // ldr c8, [x4, #2]
	.inst 0xc2400c8d // ldr c13, [x4, #3]
	.inst 0xc240108e // ldr c14, [x4, #4]
	.inst 0xc240149b // ldr c27, [x4, #5]
	.inst 0xc240189e // ldr c30, [x4, #6]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603304 // ldr c4, [c24, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601304 // ldr c4, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
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
	mov x24, #0xf
	and x4, x4, x24
	cmp x4, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400098 // ldr c24, [x4, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400498 // ldr c24, [x4, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400898 // ldr c24, [x4, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400c98 // ldr c24, [x4, #3]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2401098 // ldr c24, [x4, #4]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2401498 // ldr c24, [x4, #5]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc2401898 // ldr c24, [x4, #6]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc2401c98 // ldr c24, [x4, #7]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc2402098 // ldr c24, [x4, #8]
	.inst 0xc2d8a5a1 // chkeq c13, c24
	b.ne comparison_fail
	.inst 0xc2402498 // ldr c24, [x4, #9]
	.inst 0xc2d8a5c1 // chkeq c14, c24
	b.ne comparison_fail
	.inst 0xc2402898 // ldr c24, [x4, #10]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2402c98 // ldr c24, [x4, #11]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc2403098 // ldr c24, [x4, #12]
	.inst 0xc2d8a7c1 // chkeq c30, c24
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
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
