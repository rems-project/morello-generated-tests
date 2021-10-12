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
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xe2, 0x03, 0x9c, 0xe2, 0xc1, 0x33, 0xc2, 0xc2, 0x0b, 0x73, 0xc0, 0xc2, 0xc2, 0xc3, 0x6c, 0x82
	.byte 0xfe, 0x97, 0xde, 0x78, 0xcd, 0x7f, 0xbf, 0x9b, 0x17, 0x68, 0x7f, 0x02, 0x3e, 0x7c, 0x3f, 0x42
	.byte 0x94, 0x9a, 0xff, 0xc2, 0x6c, 0xfc, 0x9f, 0x08, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000007400700ffffffff7c2000
	/* C1 */
	.octa 0x1696
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x40000000000700060000000000001000
	/* C12 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x100030000000000000000
	/* C30 */
	.octa 0x400
final_cap_values:
	/* C0 */
	.octa 0x2000007400700ffffffff7c2000
	/* C1 */
	.octa 0x1696
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x40000000000700060000000000001000
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x20000074007010000000079c000
	/* C24 */
	.octa 0x100030000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800000000407008f0000000000001080
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700030000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000000000000070025000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010c0
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe29c03e2 // ASTUR-R.RI-32 Rt:2 Rn:31 op2:00 imm9:111000000 V:0 op1:10 11100010:11100010
	.inst 0xc2c233c1 // CHKTGD-C-C 00001:00001 Cn:30 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c0730b // GCOFF-R.C-C Rd:11 Cn:24 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x826cc3c2 // ALDR-C.RI-C Ct:2 Rn:30 op:00 imm9:011001100 L:1 1000001001:1000001001
	.inst 0x78de97fe // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:31 01:01 imm9:111101001 0:0 opc:11 111000:111000 size:01
	.inst 0x9bbf7fcd // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:13 Rn:30 Ra:31 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0x027f6817 // ADD-C.CIS-C Cd:23 Cn:0 imm12:111111011010 sh:1 A:0 00000010:00000010
	.inst 0x423f7c3e // ASTLRB-R.R-B Rt:30 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2ff9a94 // SUBS-R.CC-C Rd:20 Cn:20 100110:100110 Cm:31 11000010111:11000010111
	.inst 0x089ffc6c // stlrb:aarch64/instrs/memory/ordered Rt:12 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c210c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a62 // ldr c2, [x19, #2]
	.inst 0xc2400e63 // ldr c3, [x19, #3]
	.inst 0xc240126c // ldr c12, [x19, #4]
	.inst 0xc2401674 // ldr c20, [x19, #5]
	.inst 0xc2401a78 // ldr c24, [x19, #6]
	.inst 0xc2401e7e // ldr c30, [x19, #7]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850038
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d3 // ldr c19, [c6, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826010d3 // ldr c19, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x6, #0xf
	and x19, x19, x6
	cmp x19, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400266 // ldr c6, [x19, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400666 // ldr c6, [x19, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400a66 // ldr c6, [x19, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400e66 // ldr c6, [x19, #3]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2401266 // ldr c6, [x19, #4]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2401666 // ldr c6, [x19, #5]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc2401a66 // ldr c6, [x19, #6]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2401e66 // ldr c6, [x19, #7]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2402266 // ldr c6, [x19, #8]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2402666 // ldr c6, [x19, #9]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2402a66 // ldr c6, [x19, #10]
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001082
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010c0
	ldr x1, =check_data3
	ldr x2, =0x000010d0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001696
	ldr x1, =check_data4
	ldr x2, =0x00001697
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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
