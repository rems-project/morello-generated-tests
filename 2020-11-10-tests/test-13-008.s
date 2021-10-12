.section data0, #alloc, #write
	.zero 256
	.byte 0x01, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1776
	.byte 0xfd, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x01, 0x80
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xfd, 0x1f, 0x00, 0x00
.data
check_data6:
	.zero 8
.data
check_data7:
	.zero 1
.data
check_data8:
	.byte 0x1f, 0x40, 0x60, 0xb8, 0xe1, 0xa2, 0x63, 0xe2, 0xeb, 0x53, 0xbe, 0x78, 0x87, 0xfe, 0x3f, 0x42
	.byte 0x3f, 0x42, 0x7a, 0x38, 0x7e, 0x0c, 0x24, 0x5c, 0xe7, 0xf7, 0x12, 0xe2, 0xca, 0x41, 0x17, 0x02
	.byte 0x42, 0xe7, 0xa0, 0x82, 0x1c, 0x34, 0x97, 0xe2, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data9:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000604000320000000000001800
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C14 */
	.octa 0x620040000000007000000
	/* C17 */
	.octa 0xc0000000400200090000000000001ffd
	/* C20 */
	.octa 0xfc3
	/* C23 */
	.octa 0x11bb
	/* C26 */
	.octa 0xffffffffffffffc3
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc0000000604000320000000000001800
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x6200400000000070005d0
	/* C11 */
	.octa 0x8001
	/* C14 */
	.octa 0x620040000000007000000
	/* C17 */
	.octa 0xc0000000400200090000000000001ffd
	/* C20 */
	.octa 0xfc3
	/* C23 */
	.octa 0x11bb
	/* C26 */
	.octa 0xffffffffffffffc3
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc0000000608000000000000000001100
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000006380004d00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb860401f // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:100 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xe263a2e1 // ASTUR-V.RI-H Rt:1 Rn:23 op2:00 imm9:000111010 V:1 op1:01 11100010:11100010
	.inst 0x78be53eb // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:11 Rn:31 00:00 opc:101 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x423ffe87 // ASTLR-R.R-32 Rt:7 Rn:20 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x387a423f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:100 o3:0 Rs:26 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x5c240c7e // ldr_lit_fpsimd:aarch64/instrs/memory/literal/simdfp Rt:30 imm19:0010010000001100011 011100:011100 opc:01
	.inst 0xe212f7e7 // ALDURB-R.RI-32 Rt:7 Rn:31 op2:01 imm9:100101111 V:0 op1:00 11100010:11100010
	.inst 0x021741ca // ADD-C.CIS-C Cd:10 Cn:14 imm12:010111010000 sh:0 A:0 00000010:00000010
	.inst 0x82a0e742 // ASTR-R.RRB-64 Rt:2 Rn:26 opc:01 S:0 option:111 Rm:0 1:1 L:0 100000101:100000101
	.inst 0xe297341c // ALDUR-R.RI-32 Rt:28 Rn:0 op2:01 imm9:101110011 V:0 op1:10 11100010:11100010
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa7 // ldr c7, [x21, #2]
	.inst 0xc2400eae // ldr c14, [x21, #3]
	.inst 0xc24012b1 // ldr c17, [x21, #4]
	.inst 0xc24016b4 // ldr c20, [x21, #5]
	.inst 0xc2401ab7 // ldr c23, [x21, #6]
	.inst 0xc2401eba // ldr c26, [x21, #7]
	.inst 0xc24022be // ldr c30, [x21, #8]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851037
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f5 // ldr c21, [c15, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826011f5 // ldr c21, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002af // ldr c15, [x21, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24006af // ldr c15, [x21, #1]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400aaf // ldr c15, [x21, #2]
	.inst 0xc2cfa4e1 // chkeq c7, c15
	b.ne comparison_fail
	.inst 0xc2400eaf // ldr c15, [x21, #3]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc24012af // ldr c15, [x21, #4]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc24016af // ldr c15, [x21, #5]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc2401aaf // ldr c15, [x21, #6]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc2401eaf // ldr c15, [x21, #7]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc24022af // ldr c15, [x21, #8]
	.inst 0xc2cfa6e1 // chkeq c23, c15
	b.ne comparison_fail
	.inst 0xc24026af // ldr c15, [x21, #9]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc2402aaf // ldr c15, [x21, #10]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc2402eaf // ldr c15, [x21, #11]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x15, v1.d[0]
	cmp x21, x15
	b.ne comparison_fail
	ldr x21, =0x0
	mov x15, v1.d[1]
	cmp x21, x15
	b.ne comparison_fail
	ldr x21, =0x0
	mov x15, v30.d[0]
	cmp x21, x15
	b.ne comparison_fail
	ldr x21, =0x0
	mov x15, v30.d[1]
	cmp x21, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000107c
	ldr x1, =check_data1
	ldr x2, =0x0000107d
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001102
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001242
	ldr x1, =check_data3
	ldr x2, =0x00001244
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000017c0
	ldr x1, =check_data4
	ldr x2, =0x000017c4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001800
	ldr x1, =check_data5
	ldr x2, =0x00001804
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001810
	ldr x1, =check_data6
	ldr x2, =0x00001818
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00001ffd
	ldr x1, =check_data7
	ldr x2, =0x00001ffe
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400000
	ldr x1, =check_data8
	ldr x2, =0x0040002c
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	ldr x0, =0x004481a0
	ldr x1, =check_data9
	ldr x2, =0x004481a8
check_data_loop9:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop9
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
