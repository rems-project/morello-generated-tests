.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x3c, 0x20, 0xfc, 0xc2, 0xe9, 0xe3, 0xdf, 0xc2, 0x29, 0xf4, 0x00, 0x3c, 0x3f, 0x24, 0xdf, 0x9a
	.byte 0x7f, 0xcd, 0x1e, 0xb8, 0x31, 0x07, 0xdf, 0xc2, 0x22, 0x99, 0xf3, 0xc2, 0x02, 0x58, 0xe1, 0xc2
	.byte 0x3e, 0xf8, 0x69, 0xfc, 0x1e, 0x9a, 0x6b, 0x30, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x300070080e00000000001
	/* C1 */
	.octa 0xc000000040010ff10000000000001001
	/* C11 */
	.octa 0x400000000000a000000000000000141c
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x300070080e00000000001
	/* C1 */
	.octa 0xc000000040010ff10000000000001010
	/* C2 */
	.octa 0x300070000000000001010
	/* C9 */
	.octa 0x8000000000000000000001fc
	/* C11 */
	.octa 0x400000000000a0000000000000001408
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0xc000000040010ff10000000000001001
	/* C30 */
	.octa 0x200080000001000500000000004d7365
initial_SP_EL3_value:
	.octa 0x8000000000000000000001fc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2fc203c // BICFLGS-C.CI-C Cd:28 Cn:1 0:0 00:00 imm8:11100001 11000010111:11000010111
	.inst 0xc2dfe3e9 // SCFLGS-C.CR-C Cd:9 Cn:31 111000:111000 Rm:31 11000010110:11000010110
	.inst 0x3c00f429 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:9 Rn:1 01:01 imm9:000001111 0:0 opc:00 111100:111100 size:00
	.inst 0x9adf243f // lsrv:aarch64/instrs/integer/shift/variable Rd:31 Rn:1 op2:01 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0xb81ecd7f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:11 11:11 imm9:111101100 0:0 opc:00 111000:111000 size:10
	.inst 0xc2df0731 // BUILD-C.C-C Cd:17 Cn:25 001:001 opc:00 0:0 Cm:31 11000010110:11000010110
	.inst 0xc2f39922 // SUBS-R.CC-C Rd:2 Cn:9 100110:100110 Cm:19 11000010111:11000010111
	.inst 0xc2e15802 // CVTZ-C.CR-C Cd:2 Cn:0 0110:0110 1:1 0:0 Rm:1 11000010111:11000010111
	.inst 0xfc69f83e // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:30 Rn:1 10:10 S:1 option:111 Rm:9 1:1 opc:01 111100:111100 size:11
	.inst 0x306b9a1e // ADR-C.I-C Rd:30 immhi:110101110011010000 P:0 10000:10000 immlo:01 op:0
	.inst 0xc2c210c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008eb // ldr c11, [x7, #2]
	.inst 0xc2400cf3 // ldr c19, [x7, #3]
	.inst 0xc24010f9 // ldr c25, [x7, #4]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q9, =0x0
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850032
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010c7 // ldr c7, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x6, #0xf
	and x7, x7, x6
	cmp x7, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000e6 // ldr c6, [x7, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24004e6 // ldr c6, [x7, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc24008e6 // ldr c6, [x7, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400ce6 // ldr c6, [x7, #3]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc24010e6 // ldr c6, [x7, #4]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc24014e6 // ldr c6, [x7, #5]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc24018e6 // ldr c6, [x7, #6]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2401ce6 // ldr c6, [x7, #7]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc24020e6 // ldr c6, [x7, #8]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc24024e6 // ldr c6, [x7, #9]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x6, v9.d[0]
	cmp x7, x6
	b.ne comparison_fail
	ldr x7, =0x0
	mov x6, v9.d[1]
	cmp x7, x6
	b.ne comparison_fail
	ldr x7, =0x0
	mov x6, v30.d[0]
	cmp x7, x6
	b.ne comparison_fail
	ldr x7, =0x0
	mov x6, v30.d[1]
	cmp x7, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001001
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001408
	ldr x1, =check_data1
	ldr x2, =0x0000140c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
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
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
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
