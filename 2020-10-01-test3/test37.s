.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xc0, 0x27, 0x0b, 0x78, 0x43, 0xc8, 0x22, 0xf8, 0x4c, 0xd8, 0x36, 0x38, 0x6b, 0x74, 0x9b, 0xb8
	.byte 0xd4, 0xf3, 0xf5, 0xc2, 0x2c, 0x00, 0xc0, 0xda, 0xfe, 0x83, 0xd1, 0x38, 0x42, 0x53, 0xc2, 0xc2
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xc1, 0xfb, 0xcb, 0xc2, 0x1f, 0xac, 0xc2, 0xe2, 0x00, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000f6
	/* C2 */
	.octa 0x40000000080f02070000000000000800
	/* C3 */
	.octa 0x800000003000e0800000000000400018
	/* C12 */
	.octa 0x0
	/* C22 */
	.octa 0x800
	/* C26 */
	.octa 0x20008000200700070000000000400289
	/* C30 */
	.octa 0x40000000000100050000000000001000
final_cap_values:
	/* C0 */
	.octa 0x4000f6
	/* C1 */
	.octa 0x417000000000000000000000
	/* C2 */
	.octa 0x40000000080f02070000000000000800
	/* C3 */
	.octa 0x800000003000e08000000000003fffcf
	/* C11 */
	.octa 0x38d183fe
	/* C20 */
	.octa 0x4000000000010005af000000000010b2
	/* C22 */
	.octa 0x800
	/* C26 */
	.octa 0x20008000200700070000000000400289
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x800000004001ef02000000000040f000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000800000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80100000200140050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x780b27c0 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:30 01:01 imm9:010110010 0:0 opc:00 111000:111000 size:01
	.inst 0xf822c843 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:3 Rn:2 10:10 S:0 option:110 Rm:2 1:1 opc:00 111000:111000 size:11
	.inst 0x3836d84c // strb_reg:aarch64/instrs/memory/single/general/register Rt:12 Rn:2 10:10 S:1 option:110 Rm:22 1:1 opc:00 111000:111000 size:00
	.inst 0xb89b746b // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:11 Rn:3 01:01 imm9:110110111 0:0 opc:10 111000:111000 size:10
	.inst 0xc2f5f3d4 // EORFLGS-C.CI-C Cd:20 Cn:30 0:0 10:10 imm8:10101111 11000010111:11000010111
	.inst 0xdac0002c // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:12 Rn:1 101101011000000000000:101101011000000000000 sf:1
	.inst 0x38d183fe // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:31 00:00 imm9:100011000 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c25342 // RETS-C-C 00010:00010 Cn:26 100:100 opc:10 11000010110000100:11000010110000100
	.zero 616
	.inst 0xc2cbfbc1 // SCBNDS-C.CI-S Cd:1 Cn:30 1110:1110 S:1 imm6:010111 11000010110:11000010110
	.inst 0xe2c2ac1f // ALDUR-C.RI-C Ct:31 Rn:0 op2:11 imm9:000101010 V:0 op1:11 11100010:11100010
	.inst 0xc2c21100
	.zero 1047916
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc2400883 // ldr c3, [x4, #2]
	.inst 0xc2400c8c // ldr c12, [x4, #3]
	.inst 0xc2401096 // ldr c22, [x4, #4]
	.inst 0xc240149a // ldr c26, [x4, #5]
	.inst 0xc240189e // ldr c30, [x4, #6]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_csp_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603104 // ldr c4, [c8, #3]
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	.inst 0x82601104 // ldr c4, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400088 // ldr c8, [x4, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400488 // ldr c8, [x4, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400888 // ldr c8, [x4, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400c88 // ldr c8, [x4, #3]
	.inst 0xc2c8a461 // chkeq c3, c8
	b.ne comparison_fail
	.inst 0xc2401088 // ldr c8, [x4, #4]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc2401488 // ldr c8, [x4, #5]
	.inst 0xc2c8a681 // chkeq c20, c8
	b.ne comparison_fail
	.inst 0xc2401888 // ldr c8, [x4, #6]
	.inst 0xc2c8a6c1 // chkeq c22, c8
	b.ne comparison_fail
	.inst 0xc2401c88 // ldr c8, [x4, #7]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2402088 // ldr c8, [x4, #8]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400120
	ldr x1, =check_data2
	ldr x2, =0x00400130
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400288
	ldr x1, =check_data3
	ldr x2, =0x00400294
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040ef18
	ldr x1, =check_data4
	ldr x2, =0x0040ef19
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
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
