.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x40, 0x00, 0xc0, 0xda, 0x74, 0xe3, 0x81, 0x5a, 0x22, 0xfe, 0x3f, 0x42, 0x16, 0x34, 0x99, 0xa8
	.byte 0xa2, 0x7d, 0xdf, 0x48, 0x46, 0x4a, 0xa2, 0x78, 0x00, 0xfc, 0x26, 0x11, 0xc3, 0x93, 0xbc, 0xb9
	.byte 0x50, 0xe8, 0x6f, 0x69, 0xfe, 0x8b, 0xdf, 0xc2, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x8000000000000
	/* C13 */
	.octa 0x1000
	/* C17 */
	.octa 0x4000000000070b070000000000001000
	/* C18 */
	.octa 0xfffffffffffff290
	/* C22 */
	.octa 0x2000
	/* C30 */
	.octa 0xffffffffffffd800
final_cap_values:
	/* C0 */
	.octa 0x1b4f
	/* C2 */
	.octa 0x2000
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x1000
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x4000000000070b070000000000001000
	/* C18 */
	.octa 0xfffffffffffff290
	/* C22 */
	.octa 0x2000
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x70000000000000000
initial_SP_EL3_value:
	.octa 0x70000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000088700060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac00040 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:0 Rn:2 101101011000000000000:101101011000000000000 sf:1
	.inst 0x5a81e374 // csinv:aarch64/instrs/integer/conditional/select Rd:20 Rn:27 o2:0 0:0 cond:1110 Rm:1 011010100:011010100 op:1 sf:0
	.inst 0x423ffe22 // ASTLR-R.R-32 Rt:2 Rn:17 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xa8993416 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:22 Rn:0 Rt2:01101 imm7:0110010 L:0 1010001:1010001 opc:10
	.inst 0x48df7da2 // ldlarh:aarch64/instrs/memory/ordered Rt:2 Rn:13 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x78a24a46 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:6 Rn:18 10:10 S:0 option:010 Rm:2 1:1 opc:10 111000:111000 size:01
	.inst 0x1126fc00 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:0 imm12:100110111111 sh:0 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xb9bc93c3 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:3 Rn:30 imm12:111100100100 opc:10 111001:111001 size:10
	.inst 0x696fe850 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:16 Rn:2 Rt2:11010 imm7:1011111 L:1 1010010:1010010 opc:01
	.inst 0xc2df8bfe // CHKSSU-C.CC-C Cd:30 Cn:31 0010:0010 opc:10 Cm:31 11000010110:11000010110
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400102 // ldr c2, [x8, #0]
	.inst 0xc240050d // ldr c13, [x8, #1]
	.inst 0xc2400911 // ldr c17, [x8, #2]
	.inst 0xc2400d12 // ldr c18, [x8, #3]
	.inst 0xc2401116 // ldr c22, [x8, #4]
	.inst 0xc240151e // ldr c30, [x8, #5]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032a8 // ldr c8, [c21, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826012a8 // ldr c8, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x21, #0xf
	and x8, x8, x21
	cmp x8, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400115 // ldr c21, [x8, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400515 // ldr c21, [x8, #1]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400915 // ldr c21, [x8, #2]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2400d15 // ldr c21, [x8, #3]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc2401115 // ldr c21, [x8, #4]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2401515 // ldr c21, [x8, #5]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2401915 // ldr c21, [x8, #6]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2401d15 // ldr c21, [x8, #7]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc2402115 // ldr c21, [x8, #8]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2402515 // ldr c21, [x8, #9]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2402915 // ldr c21, [x8, #10]
	.inst 0xc2d5a7c1 // chkeq c30, c21
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
	ldr x0, =0x00001290
	ldr x1, =check_data1
	ldr x2, =0x00001292
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001490
	ldr x1, =check_data2
	ldr x2, =0x00001494
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f7c
	ldr x1, =check_data3
	ldr x2, =0x00001f84
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
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
