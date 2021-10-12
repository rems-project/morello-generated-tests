.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x5f, 0x0f, 0xc0, 0xda, 0x01, 0xa4, 0x9e, 0xda, 0xed, 0xc9, 0xbe, 0x78, 0xc1, 0x4b, 0x1e, 0xa2
	.byte 0x09, 0xbc, 0xd7, 0x38, 0xfe, 0x07, 0xd6, 0xc2, 0x5f, 0x11, 0xc1, 0xc2, 0x13, 0x7e, 0xdf, 0x48
	.byte 0x5e, 0x94, 0x08, 0x3c, 0x13, 0xfc, 0xdf, 0x08, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000
	/* C2 */
	.octa 0x141c
	/* C10 */
	.octa 0x3000e0100000000000000000
	/* C15 */
	.octa 0xffffffffffffefcc
	/* C16 */
	.octa 0x10c0
	/* C22 */
	.octa 0x2100240000000000000000
	/* C30 */
	.octa 0x2120
final_cap_values:
	/* C0 */
	.octa 0x1f7b
	/* C1 */
	.octa 0x2000
	/* C2 */
	.octa 0x14a5
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x3000e0100000000000000000
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0xffffffffffffefcc
	/* C16 */
	.octa 0x10c0
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x2100240000000000000000
	/* C30 */
	.octa 0x10000000000000000
initial_SP_EL3_value:
	.octa 0x10000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000700470000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac00f5f // rev:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:26 opc:11 1011010110000000000:1011010110000000000 sf:1
	.inst 0xda9ea401 // csneg:aarch64/instrs/integer/conditional/select Rd:1 Rn:0 o2:1 0:0 cond:1010 Rm:30 011010100:011010100 op:1 sf:1
	.inst 0x78bec9ed // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:13 Rn:15 10:10 S:0 option:110 Rm:30 1:1 opc:10 111000:111000 size:01
	.inst 0xa21e4bc1 // STTR-C.RIB-C Ct:1 Rn:30 10:10 imm9:111100100 0:0 opc:00 10100010:10100010
	.inst 0x38d7bc09 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:9 Rn:0 11:11 imm9:101111011 0:0 opc:11 111000:111000 size:00
	.inst 0xc2d607fe // BUILD-C.C-C Cd:30 Cn:31 001:001 opc:00 0:0 Cm:22 11000010110:11000010110
	.inst 0xc2c1115f // GCLIM-R.C-C Rd:31 Cn:10 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x48df7e13 // ldlarh:aarch64/instrs/memory/ordered Rt:19 Rn:16 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x3c08945e // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:30 Rn:2 01:01 imm9:010001001 0:0 opc:00 111100:111100 size:00
	.inst 0x08dffc13 // ldarb:aarch64/instrs/memory/ordered Rt:19 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400782 // ldr c2, [x28, #1]
	.inst 0xc2400b8a // ldr c10, [x28, #2]
	.inst 0xc2400f8f // ldr c15, [x28, #3]
	.inst 0xc2401390 // ldr c16, [x28, #4]
	.inst 0xc2401796 // ldr c22, [x28, #5]
	.inst 0xc2401b9e // ldr c30, [x28, #6]
	/* Vector registers */
	mrs x28, cptr_el3
	bfc x28, #10, #1
	msr cptr_el3, x28
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850032
	msr SCTLR_EL3, x28
	ldr x28, =0x4
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032bc // ldr c28, [c21, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x826012bc // ldr c28, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x21, #0x9
	and x28, x28, x21
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400395 // ldr c21, [x28, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400795 // ldr c21, [x28, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400b95 // ldr c21, [x28, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400f95 // ldr c21, [x28, #3]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc2401395 // ldr c21, [x28, #4]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401795 // ldr c21, [x28, #5]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2401b95 // ldr c21, [x28, #6]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2401f95 // ldr c21, [x28, #7]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2402395 // ldr c21, [x28, #8]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc2402795 // ldr c21, [x28, #9]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2402b95 // ldr c21, [x28, #10]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x21, v30.d[0]
	cmp x28, x21
	b.ne comparison_fail
	ldr x28, =0x0
	mov x21, v30.d[1]
	cmp x28, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001100
	ldr x1, =check_data0
	ldr x2, =0x00001102
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000112c
	ldr x1, =check_data1
	ldr x2, =0x0000112e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000145c
	ldr x1, =check_data2
	ldr x2, =0x0000145d
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fa0
	ldr x1, =check_data3
	ldr x2, =0x00001fb0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fbb
	ldr x1, =check_data4
	ldr x2, =0x00001fbc
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
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
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
