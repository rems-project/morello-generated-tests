.section data0, #alloc, #write
	.zero 1744
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00
	.zero 2336
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00
.data
check_data4:
	.byte 0x2b, 0xd8, 0x68, 0xca, 0x60, 0x30, 0x46, 0xa2, 0x80, 0x7f, 0x1f, 0x42, 0x41, 0x00, 0xe1, 0x29
	.byte 0x1e, 0x28, 0xd0, 0xc2, 0xde, 0xff, 0x3f, 0x42, 0xa5, 0x7d, 0x9f, 0x08, 0x00, 0x02, 0xc0, 0xda
	.byte 0xff, 0x02, 0x2c, 0x38, 0xfe, 0xfb, 0xdb, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x800000002005000600000000000017d0
	/* C3 */
	.octa 0x8010000020220004000000000000120d
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x40000000000300060000000000001000
	/* C23 */
	.octa 0xc00000000801c0050000000000001000
	/* C28 */
	.octa 0x12d0
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x800000002005000600000000000016d8
	/* C3 */
	.octa 0x8010000020220004000000000000120d
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x40000000000300060000000000001000
	/* C23 */
	.octa 0xc00000000801c0050000000000001000
	/* C28 */
	.octa 0x12d0
	/* C30 */
	.octa 0x200437000000000000000000000
initial_SP_EL3_value:
	.octa 0x200000700070000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000400100040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xca68d82b // eon:aarch64/instrs/integer/logical/shiftedreg Rd:11 Rn:1 imm6:110110 Rm:8 N:1 shift:01 01010:01010 opc:10 sf:1
	.inst 0xa2463060 // LDUR-C.RI-C Ct:0 Rn:3 00:00 imm9:001100011 0:0 opc:01 10100010:10100010
	.inst 0x421f7f80 // ASTLR-C.R-C Ct:0 Rn:28 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x29e10041 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:2 Rt2:00000 imm7:1000010 L:1 1010011:1010011 opc:00
	.inst 0xc2d0281e // BICFLGS-C.CR-C Cd:30 Cn:0 1010:1010 opc:00 Rm:16 11000010110:11000010110
	.inst 0x423fffde // ASTLR-R.R-32 Rt:30 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x089f7da5 // stllrb:aarch64/instrs/memory/ordered Rt:5 Rn:13 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xdac00200 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:0 Rn:16 101101011000000000000:101101011000000000000 sf:1
	.inst 0x382c02ff // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:000 o3:0 Rs:12 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2dbfbfe // SCBNDS-C.CI-S Cd:30 Cn:31 1110:1110 S:1 imm6:110111 11000010110:11000010110
	.inst 0xc2c21120
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
	ldr x10, =initial_cap_values
	.inst 0xc2400142 // ldr c2, [x10, #0]
	.inst 0xc2400543 // ldr c3, [x10, #1]
	.inst 0xc2400945 // ldr c5, [x10, #2]
	.inst 0xc2400d4c // ldr c12, [x10, #3]
	.inst 0xc240114d // ldr c13, [x10, #4]
	.inst 0xc2401557 // ldr c23, [x10, #5]
	.inst 0xc240195c // ldr c28, [x10, #6]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851037
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260312a // ldr c10, [c9, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260112a // ldr c10, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400149 // ldr c9, [x10, #0]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400549 // ldr c9, [x10, #1]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400949 // ldr c9, [x10, #2]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2400d49 // ldr c9, [x10, #3]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2401149 // ldr c9, [x10, #4]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401549 // ldr c9, [x10, #5]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc2401949 // ldr c9, [x10, #6]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2401d49 // ldr c9, [x10, #7]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402149 // ldr c9, [x10, #8]
	.inst 0xc2c9a7c1 // chkeq c30, c9
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
	ldr x0, =0x00001270
	ldr x1, =check_data1
	ldr x2, =0x00001280
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012d0
	ldr x1, =check_data2
	ldr x2, =0x000012e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000016d8
	ldr x1, =check_data3
	ldr x2, =0x000016e0
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
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
