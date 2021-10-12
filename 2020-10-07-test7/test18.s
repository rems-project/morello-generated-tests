.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x1a, 0x90, 0xc0, 0xc2, 0x12, 0x10, 0xc0, 0xc2, 0xa0, 0xd9, 0x4d, 0x82, 0x2b, 0xe0, 0x82, 0x82
	.byte 0x02, 0x0b, 0x17, 0xe2, 0xfe, 0xe5, 0x01, 0xa2, 0x60, 0x07, 0xc0, 0x5a, 0x64, 0x34, 0x1c, 0x4a
	.byte 0x05, 0xd7, 0x82, 0xda, 0xde, 0xfd, 0x9f, 0x48, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000000000000000000
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0xe0c
	/* C14 */
	.octa 0x40000000400402040000000000001000
	/* C15 */
	.octa 0x4c000000520102000000000000001000
	/* C24 */
	.octa 0x2008
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x2008
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0xe0c
	/* C14 */
	.octa 0x40000000400402040000000000001000
	/* C15 */
	.octa 0x4c0000005201020000000000000011e0
	/* C18 */
	.octa 0x0
	/* C24 */
	.octa 0x2008
	/* C26 */
	.octa 0x1
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004040c0410000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0901a // GCTAG-R.C-C Rd:26 Cn:0 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc2c01012 // GCBASE-R.C-C Rd:18 Cn:0 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x824dd9a0 // ASTR-R.RI-32 Rt:0 Rn:13 op:10 imm9:011011101 L:0 1000001001:1000001001
	.inst 0x8282e02b // ASTRB-R.RRB-B Rt:11 Rn:1 opc:00 S:0 option:111 Rm:2 0:0 L:0 100000101:100000101
	.inst 0xe2170b02 // ALDURSB-R.RI-64 Rt:2 Rn:24 op2:10 imm9:101110000 V:0 op1:00 11100010:11100010
	.inst 0xa201e5fe // STR-C.RIAW-C Ct:30 Rn:15 01:01 imm9:000011110 0:0 opc:00 10100010:10100010
	.inst 0x5ac00760 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:27 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0x4a1c3464 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:4 Rn:3 imm6:001101 Rm:28 N:0 shift:00 01010:01010 opc:10 sf:0
	.inst 0xda82d705 // csneg:aarch64/instrs/integer/conditional/select Rd:5 Rn:24 o2:1 0:0 cond:1101 Rm:2 011010100:011010100 op:1 sf:1
	.inst 0x489ffdde // stlrh:aarch64/instrs/memory/ordered Rt:30 Rn:14 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c21260
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2400d4b // ldr c11, [x10, #3]
	.inst 0xc240114d // ldr c13, [x10, #4]
	.inst 0xc240154e // ldr c14, [x10, #5]
	.inst 0xc240194f // ldr c15, [x10, #6]
	.inst 0xc2401d58 // ldr c24, [x10, #7]
	.inst 0xc240215e // ldr c30, [x10, #8]
	/* Set up flags and system registers */
	mov x10, #0x80000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850032
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260326a // ldr c10, [c19, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260126a // ldr c10, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x19, #0x9
	and x10, x10, x19
	cmp x10, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400153 // ldr c19, [x10, #0]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400553 // ldr c19, [x10, #1]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400953 // ldr c19, [x10, #2]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc2400d53 // ldr c19, [x10, #3]
	.inst 0xc2d3a561 // chkeq c11, c19
	b.ne comparison_fail
	.inst 0xc2401153 // ldr c19, [x10, #4]
	.inst 0xc2d3a5a1 // chkeq c13, c19
	b.ne comparison_fail
	.inst 0xc2401553 // ldr c19, [x10, #5]
	.inst 0xc2d3a5c1 // chkeq c14, c19
	b.ne comparison_fail
	.inst 0xc2401953 // ldr c19, [x10, #6]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2401d53 // ldr c19, [x10, #7]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2402153 // ldr c19, [x10, #8]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc2402553 // ldr c19, [x10, #9]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2402953 // ldr c19, [x10, #10]
	.inst 0xc2d3a7c1 // chkeq c30, c19
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
	ldr x0, =0x00001180
	ldr x1, =check_data1
	ldr x2, =0x00001184
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f78
	ldr x1, =check_data2
	ldr x2, =0x00001f79
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
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

	.balign 128
vector_table:
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
