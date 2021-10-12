.section data0, #alloc, #write
	.byte 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x20, 0x00, 0x02
.data
check_data1:
	.byte 0x00, 0x20, 0x00, 0x02
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x50, 0x00, 0x00, 0x00, 0xc0
.data
check_data4:
	.byte 0xf9, 0xa5, 0x99, 0x5a, 0xe0, 0x73, 0xc0, 0xc2, 0x11, 0xfe, 0x3f, 0x42, 0x5e, 0x00, 0x7a, 0x78
	.byte 0x40, 0xfc, 0xdf, 0x88, 0x22, 0xdc, 0x02, 0xa2, 0x24, 0x7c, 0x1e, 0x1b, 0x93, 0x73, 0x24, 0xe2
	.byte 0xff, 0x10, 0x22, 0xb8, 0x01, 0x7d, 0xe0, 0xa2, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4c000000000100060000000000001c20
	/* C2 */
	.octa 0xc0000000504000000000000000001000
	/* C7 */
	.octa 0xc0000000000200070000000000001000
	/* C8 */
	.octa 0xdc000000400000040000000000001b80
	/* C16 */
	.octa 0x1800
	/* C17 */
	.octa 0x2002000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0xfbc
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4c000000000100060000000000001ef0
	/* C2 */
	.octa 0xc0000000504000000000000000001000
	/* C4 */
	.octa 0x3de0000
	/* C7 */
	.octa 0xc0000000000200070000000000001000
	/* C8 */
	.octa 0xdc000000400000040000000000001b80
	/* C16 */
	.octa 0x1800
	/* C17 */
	.octa 0x2002000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0xfbc
	/* C30 */
	.octa 0x2000
initial_SP_EL3_value:
	.octa 0x400000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4000000040000f890000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001b80
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5a99a5f9 // csneg:aarch64/instrs/integer/conditional/select Rd:25 Rn:15 o2:1 0:0 cond:1010 Rm:25 011010100:011010100 op:1 sf:0
	.inst 0xc2c073e0 // GCOFF-R.C-C Rd:0 Cn:31 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x423ffe11 // ASTLR-R.R-32 Rt:17 Rn:16 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x787a005e // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:2 00:00 opc:000 0:0 Rs:26 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x88dffc40 // ldar:aarch64/instrs/memory/ordered Rt:0 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xa202dc22 // STR-C.RIBW-C Ct:2 Rn:1 11:11 imm9:000101101 0:0 opc:00 10100010:10100010
	.inst 0x1b1e7c24 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:4 Rn:1 Ra:31 o0:0 Rm:30 0011011000:0011011000 sf:0
	.inst 0xe2247393 // ASTUR-V.RI-B Rt:19 Rn:28 op2:00 imm9:001000111 V:1 op1:00 11100010:11100010
	.inst 0xb82210ff // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:7 00:00 opc:001 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xa2e07d01 // CASA-C.R-C Ct:1 Rn:8 11111:11111 R:0 Cs:0 1:1 L:1 1:1 10100010:10100010
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400ae7 // ldr c7, [x23, #2]
	.inst 0xc2400ee8 // ldr c8, [x23, #3]
	.inst 0xc24012f0 // ldr c16, [x23, #4]
	.inst 0xc24016f1 // ldr c17, [x23, #5]
	.inst 0xc2401afa // ldr c26, [x23, #6]
	.inst 0xc2401efc // ldr c28, [x23, #7]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q19, =0x2
	/* Set up flags and system registers */
	mov x23, #0x80000000
	msr nzcv, x23
	ldr x23, =initial_SP_EL3_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	ldr x23, =0x0
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603137 // ldr c23, [c9, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601137 // ldr c23, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x9, #0x9
	and x23, x23, x9
	cmp x23, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e9 // ldr c9, [x23, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24006e9 // ldr c9, [x23, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400ae9 // ldr c9, [x23, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400ee9 // ldr c9, [x23, #3]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc24012e9 // ldr c9, [x23, #4]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc24016e9 // ldr c9, [x23, #5]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc2401ae9 // ldr c9, [x23, #6]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401ee9 // ldr c9, [x23, #7]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc24022e9 // ldr c9, [x23, #8]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc24026e9 // ldr c9, [x23, #9]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402ae9 // ldr c9, [x23, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x2
	mov x9, v19.d[0]
	cmp x23, x9
	b.ne comparison_fail
	ldr x23, =0x0
	mov x9, v19.d[1]
	cmp x23, x9
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
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001804
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b80
	ldr x1, =check_data2
	ldr x2, =0x00001b90
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ef0
	ldr x1, =check_data3
	ldr x2, =0x00001f00
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
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
