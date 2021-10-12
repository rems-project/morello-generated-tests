.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xa0, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x80
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x26, 0x49, 0x20, 0xb8, 0x21, 0x10, 0x7a, 0x92, 0x6b, 0x4f, 0x59, 0xb7
.data
check_data4:
	.byte 0xc0, 0x7f, 0x1f, 0x42, 0xfe, 0xb3, 0xc5, 0xc2, 0xa2, 0x1d, 0x40, 0x82, 0x05, 0xb4, 0x7a, 0x82
	.byte 0x6f, 0x69, 0x74, 0xf8, 0x9f, 0x0a, 0xc0, 0xda, 0x04, 0xd0, 0xc0, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc62200000000000000000000000010a0
	/* C2 */
	.octa 0x8000000000070000
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x40000000180700070000000000000020
	/* C11 */
	.octa 0x8000000000030005baff880000000000
	/* C13 */
	.octa 0x1000
	/* C20 */
	.octa 0x4500780000001010
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0xc62200000000000000000000000010a0
	/* C2 */
	.octa 0x8000000000070000
	/* C4 */
	.octa 0x31888
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x40000000180700070000000000000020
	/* C11 */
	.octa 0x8000000000030005baff880000000000
	/* C13 */
	.octa 0x1000
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x4500780000001010
	/* C30 */
	.octa 0x20008000011100070000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000011100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc00000020014005008080000000e000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb8204926 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:6 Rn:9 10:10 S:0 option:010 Rm:0 1:1 opc:00 111000:111000 size:10
	.inst 0x927a1021 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:1 imms:000100 immr:111010 N:1 100100:100100 opc:00 sf:1
	.inst 0xb7594f6b // tbnz:aarch64/instrs/branch/conditional/test Rt:11 imm14:00101001111011 b40:01011 op:1 011011:011011 b5:1
	.zero 10728
	.inst 0x421f7fc0 // ASTLR-C.R-C Ct:0 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2c5b3fe // CVTP-C.R-C Cd:30 Rn:31 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x82401da2 // ASTR-R.RI-64 Rt:2 Rn:13 op:11 imm9:000000001 L:0 1000001001:1000001001
	.inst 0x827ab405 // ALDRB-R.RI-B Rt:5 Rn:0 op:01 imm9:110101011 L:1 1000001001:1000001001
	.inst 0xf874696f // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:15 Rn:11 10:10 S:0 option:011 Rm:20 1:1 opc:01 111000:111000 size:11
	.inst 0xdac00a9f // rev:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:20 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c0d004 // GCPERM-R.C-C Rd:4 Cn:0 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2c212c0
	.zero 1037804
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400866 // ldr c6, [x3, #2]
	.inst 0xc2400c69 // ldr c9, [x3, #3]
	.inst 0xc240106b // ldr c11, [x3, #4]
	.inst 0xc240146d // ldr c13, [x3, #5]
	.inst 0xc2401874 // ldr c20, [x3, #6]
	.inst 0xc2401c7e // ldr c30, [x3, #7]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032c3 // ldr c3, [c22, #3]
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	.inst 0x826012c3 // ldr c3, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400076 // ldr c22, [x3, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400476 // ldr c22, [x3, #1]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400876 // ldr c22, [x3, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400c76 // ldr c22, [x3, #3]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2401076 // ldr c22, [x3, #4]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401476 // ldr c22, [x3, #5]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401876 // ldr c22, [x3, #6]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc2401c76 // ldr c22, [x3, #7]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2402076 // ldr c22, [x3, #8]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2402476 // ldr c22, [x3, #9]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2402876 // ldr c22, [x3, #10]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c0
	ldr x1, =check_data1
	ldr x2, =0x000010c4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000124b
	ldr x1, =check_data2
	ldr x2, =0x0000124c
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
	ldr x0, =0x004029f4
	ldr x1, =check_data4
	ldr x2, =0x00402a14
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
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
