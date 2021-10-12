.section data0, #alloc, #write
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x18
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x5e, 0x68, 0x5d, 0x82, 0x01, 0xee, 0x6a, 0xf2, 0x60, 0x52, 0xc2, 0xc2
.data
check_data4:
	.byte 0xdf, 0x53, 0x3c, 0x38, 0xe0, 0x7f, 0x5f, 0x88, 0x69, 0xb8, 0x53, 0x7a, 0xa0, 0xc6, 0xc8, 0xc2
.data
check_data5:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data6:
	.byte 0x1f, 0x30, 0x62, 0x38, 0xc4, 0x0e, 0x0d, 0xe2, 0x7e, 0xfe, 0xdf, 0x88, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1010
	/* C8 */
	.octa 0x400002000000000000000000000000
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x20008000800100050000000000400014
	/* C21 */
	.octa 0x204080020007bff7000000000043bff0
	/* C22 */
	.octa 0x80000000000100050000000000001f2e
	/* C28 */
	.octa 0x40
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1010
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x400002000000000000000000000000
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x20008000800100050000000000400014
	/* C21 */
	.octa 0x204080020007bff7000000000043bff0
	/* C22 */
	.octa 0x80000000000100050000000000001f2e
	/* C28 */
	.octa 0x40
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x383c53df
initial_SP_EL3_value:
	.octa 0x400ffc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x825d685e // ASTR-R.RI-32 Rt:30 Rn:2 op:10 imm9:111010110 L:0 1000001001:1000001001
	.inst 0xf26aee01 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:16 imms:111011 immr:101010 N:1 100100:100100 opc:11 sf:1
	.inst 0xc2c25260 // RET-C-C 00000:00000 Cn:19 100:100 opc:10 11000010110000100:11000010110000100
	.zero 8
	.inst 0x383c53df // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:101 o3:0 Rs:28 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x885f7fe0 // ldxr:aarch64/instrs/memory/exclusive/single Rt:0 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0x7a53b869 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1001 0:0 Rn:3 10:10 cond:1011 imm5:10011 111010010:111010010 op:1 sf:0
	.inst 0xc2c8c6a0 // RETS-C.C-C 00000:00000 Cn:21 001:001 opc:10 1:1 Cm:8 11000010110:11000010110
	.zero 4056
	.inst 0x00001000
	.zero 241648
	.inst 0x3862301f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:011 o3:0 Rs:2 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xe20d0ec4 // ALDURSB-R.RI-32 Rt:4 Rn:22 op2:11 imm9:011010000 V:0 op1:00 11100010:11100010
	.inst 0x88dffe7e // ldar:aarch64/instrs/memory/ordered Rt:30 Rn:19 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xc2c210c0
	.zero 802816
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a2 // ldr c2, [x5, #0]
	.inst 0xc24004a8 // ldr c8, [x5, #1]
	.inst 0xc24008b0 // ldr c16, [x5, #2]
	.inst 0xc2400cb3 // ldr c19, [x5, #3]
	.inst 0xc24010b5 // ldr c21, [x5, #4]
	.inst 0xc24014b6 // ldr c22, [x5, #5]
	.inst 0xc24018bc // ldr c28, [x5, #6]
	.inst 0xc2401cbe // ldr c30, [x5, #7]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030c5 // ldr c5, [c6, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x826010c5 // ldr c5, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x6, #0xf
	and x5, x5, x6
	cmp x5, #0x9
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a6 // ldr c6, [x5, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24004a6 // ldr c6, [x5, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc24008a6 // ldr c6, [x5, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400ca6 // ldr c6, [x5, #3]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc24010a6 // ldr c6, [x5, #4]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc24014a6 // ldr c6, [x5, #5]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc24018a6 // ldr c6, [x5, #6]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2401ca6 // ldr c6, [x5, #7]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc24020a6 // ldr c6, [x5, #8]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc24024a6 // ldr c6, [x5, #9]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc24028a6 // ldr c6, [x5, #10]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402ca6 // ldr c6, [x5, #11]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001768
	ldr x1, =check_data1
	ldr x2, =0x0000176c
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
	ldr x2, =0x0040000c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400014
	ldr x1, =check_data4
	ldr x2, =0x00400024
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400ffc
	ldr x1, =check_data5
	ldr x2, =0x00401000
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0043bff0
	ldr x1, =check_data6
	ldr x2, =0x0043c000
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
