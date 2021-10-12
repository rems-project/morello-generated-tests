.section data0, #alloc, #write
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 160
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3872
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xa6, 0xde, 0xd5, 0x29, 0x3e, 0x0b, 0xc4, 0x9a, 0xe5, 0xf3, 0xc0, 0x78, 0x40, 0x82, 0xd6, 0xb6
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0x37, 0x00, 0x1c, 0xfa, 0xc0, 0x4e, 0x48, 0xb9, 0x82, 0xed, 0xd2, 0x82
	.byte 0x62, 0x50, 0xc2, 0xc2
.data
check_data4:
	.byte 0x41, 0x88, 0x22, 0x9b, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000000000
	/* C3 */
	.octa 0x20008000d00100150000000000400030
	/* C4 */
	.octa 0x0
	/* C12 */
	.octa 0x800000000007000e0000000000000000
	/* C18 */
	.octa 0x1ffc
	/* C21 */
	.octa 0x80000000000180060000000000001010
	/* C22 */
	.octa 0x7b4
final_cap_values:
	/* C0 */
	.octa 0xc2c2c2c2
	/* C1 */
	.octa 0xffffffff6bd627be
	/* C2 */
	.octa 0xc2c2
	/* C3 */
	.octa 0x20008000d00100150000000000400030
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0xffffdea6
	/* C6 */
	.octa 0xc2c2c2c2
	/* C12 */
	.octa 0x800000000007000e0000000000000000
	/* C18 */
	.octa 0x1ffc
	/* C21 */
	.octa 0x800000000001800600000000000010bc
	/* C22 */
	.octa 0x7b4
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800000000007000400000000003ffff1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000002fa0070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x29d5dea6 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:6 Rn:21 Rt2:10111 imm7:0101011 L:1 1010011:1010011 opc:00
	.inst 0x9ac40b3e // udiv:aarch64/instrs/integer/arithmetic/div Rd:30 Rn:25 o1:0 00001:00001 Rm:4 0011010110:0011010110 sf:1
	.inst 0x78c0f3e5 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:5 Rn:31 00:00 imm9:000001111 0:0 opc:11 111000:111000 size:01
	.inst 0xb6d68240 // tbz:aarch64/instrs/branch/conditional/test Rt:0 imm14:11010000010010 b40:11010 op:0 011011:011011 b5:1
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xfa1c0037 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:23 Rn:1 000000:000000 Rm:28 11010000:11010000 S:1 op:1 sf:1
	.inst 0xb9484ec0 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:22 imm12:001000010011 opc:01 111001:111001 size:10
	.inst 0x82d2ed82 // ALDRH-R.RRB-32 Rt:2 Rn:12 opc:11 S:0 option:111 Rm:18 0:0 L:1 100000101:100000101
	.inst 0xc2c25062 // RETS-C-C 00010:00010 Cn:3 100:100 opc:10 11000010110000100:11000010110000100
	.zero 12
	.inst 0x9b228841 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:2 Ra:2 o0:1 Rm:2 01:01 U:0 10011011:10011011
	.inst 0xc2c21360
	.zero 1048520
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
	.inst 0xc2400543 // ldr c3, [x10, #1]
	.inst 0xc2400944 // ldr c4, [x10, #2]
	.inst 0xc2400d4c // ldr c12, [x10, #3]
	.inst 0xc2401152 // ldr c18, [x10, #4]
	.inst 0xc2401555 // ldr c21, [x10, #5]
	.inst 0xc2401956 // ldr c22, [x10, #6]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260336a // ldr c10, [c27, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260136a // ldr c10, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240015b // ldr c27, [x10, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240055b // ldr c27, [x10, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240095b // ldr c27, [x10, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400d5b // ldr c27, [x10, #3]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc240115b // ldr c27, [x10, #4]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc240155b // ldr c27, [x10, #5]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc240195b // ldr c27, [x10, #6]
	.inst 0xc2dba4c1 // chkeq c6, c27
	b.ne comparison_fail
	.inst 0xc2401d5b // ldr c27, [x10, #7]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc240215b // ldr c27, [x10, #8]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240255b // ldr c27, [x10, #9]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc240295b // ldr c27, [x10, #10]
	.inst 0xc2dba6c1 // chkeq c22, c27
	b.ne comparison_fail
	.inst 0xc2402d5b // ldr c27, [x10, #11]
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
	ldr x0, =0x000010bc
	ldr x1, =check_data1
	ldr x2, =0x000010c4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400030
	ldr x1, =check_data4
	ldr x2, =0x00400038
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
