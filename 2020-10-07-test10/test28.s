.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x5a, 0x7e, 0xd4, 0x9b, 0x5f, 0xe8, 0x08, 0x38, 0xc1, 0xf9, 0x46, 0xe2, 0x58, 0xfc, 0x3f, 0x42
	.byte 0x1f, 0x00, 0x13, 0x5a, 0x9f, 0x21, 0xc1, 0x9a, 0x7f, 0x02, 0x0c, 0x7d, 0xa1, 0xd9, 0xee, 0x38
	.byte 0xe1, 0x33, 0xc1, 0xc2, 0xc1, 0x2f, 0x5d, 0x11, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x40000000100140050000000000001008
	/* C13 */
	.octa 0x800
	/* C14 */
	.octa 0x80000000000180060000000000000fc1
	/* C19 */
	.octa 0xa00
	/* C24 */
	.octa 0x0
final_cap_values:
	/* C2 */
	.octa 0x40000000100140050000000000001008
	/* C13 */
	.octa 0x800
	/* C14 */
	.octa 0x80000000000180060000000000000fc1
	/* C19 */
	.octa 0xa00
	/* C24 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000000000000000000000f001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9bd47e5a // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:26 Rn:18 Ra:11111 0:0 Rm:20 10:10 U:1 10011011:10011011
	.inst 0x3808e85f // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:2 10:10 imm9:010001110 0:0 opc:00 111000:111000 size:00
	.inst 0xe246f9c1 // ALDURSH-R.RI-64 Rt:1 Rn:14 op2:10 imm9:001101111 V:0 op1:01 11100010:11100010
	.inst 0x423ffc58 // ASTLR-R.R-32 Rt:24 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x5a13001f // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:0 000000:000000 Rm:19 11010000:11010000 S:0 op:1 sf:0
	.inst 0x9ac1219f // lslv:aarch64/instrs/integer/shift/variable Rd:31 Rn:12 op2:00 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0x7d0c027f // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:31 Rn:19 imm12:001100000000 opc:00 111101:111101 size:01
	.inst 0x38eed9a1 // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:13 10:10 S:1 option:110 Rm:14 1:1 opc:11 111000:111000 size:00
	.inst 0xc2c133e1 // GCFLGS-R.C-C Rd:1 Cn:31 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x115d2fc1 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:30 imm12:011101001011 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xc2c21080
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a2 // ldr c2, [x5, #0]
	.inst 0xc24004ad // ldr c13, [x5, #1]
	.inst 0xc24008ae // ldr c14, [x5, #2]
	.inst 0xc2400cb3 // ldr c19, [x5, #3]
	.inst 0xc24010b8 // ldr c24, [x5, #4]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603085 // ldr c5, [c4, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601085 // ldr c5, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a4 // ldr c4, [x5, #0]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc24004a4 // ldr c4, [x5, #1]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc24008a4 // ldr c4, [x5, #2]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc2400ca4 // ldr c4, [x5, #3]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc24010a4 // ldr c4, [x5, #4]
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x4, v31.d[0]
	cmp x5, x4
	b.ne comparison_fail
	ldr x5, =0x0
	mov x4, v31.d[1]
	cmp x5, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001030
	ldr x1, =check_data2
	ldr x2, =0x00001032
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001096
	ldr x1, =check_data3
	ldr x2, =0x00001097
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000017c1
	ldr x1, =check_data4
	ldr x2, =0x000017c2
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
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
