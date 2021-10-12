.section data0, #alloc, #write
	.zero 16
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4032
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xa6, 0xff, 0x7f, 0x42, 0xc0, 0xb3, 0xc5, 0xc2, 0xe4, 0x63, 0xc2, 0xc2, 0x50, 0xd0, 0xc1, 0xc2
	.byte 0x6b, 0xce, 0x0a, 0x54, 0x0b, 0x4c, 0x1e, 0x9b, 0x34, 0x08, 0xdc, 0x69, 0xe1, 0x2b, 0x3a, 0x31
	.byte 0x41, 0x28, 0x6b, 0x82, 0xbe, 0x3a, 0x0f, 0xe2, 0x20, 0x11, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x20, 0x1d, 0x00, 0x00
.data
check_data4:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000000001000700000000003fffe4
	/* C2 */
	.octa 0x200000000140000
	/* C21 */
	.octa 0x407f0b
	/* C29 */
	.octa 0x1010
	/* C30 */
	.octa 0x28a0a0e021
final_cap_values:
	/* C0 */
	.octa 0x200080000006400700000028a0a0e021
	/* C1 */
	.octa 0xc2c2c2c2
	/* C2 */
	.octa 0x1d20
	/* C4 */
	.octa 0x80069007017fffffffa40000
	/* C6 */
	.octa 0xc2c2c2c2
	/* C16 */
	.octa 0x200000000140000
	/* C20 */
	.octa 0xffffffffc2c2c2c2
	/* C21 */
	.octa 0x407f0b
	/* C29 */
	.octa 0x1010
	/* C30 */
	.octa 0xffffffffffffffc2
initial_csp_value:
	.octa 0x800690070080000000210000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000080080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x427fffa6 // ALDAR-R.R-32 Rt:6 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c5b3c0 // CVTP-C.R-C Cd:0 Rn:30 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c263e4 // SCOFF-C.CR-C Cd:4 Cn:31 000:000 opc:11 0:0 Rm:2 11000010110:11000010110
	.inst 0xc2c1d050 // CPY-C.C-C Cd:16 Cn:2 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x540ace6b // b_cond:aarch64/instrs/branch/conditional/cond cond:1011 0:0 imm19:0000101011001110011 01010100:01010100
	.inst 0x9b1e4c0b // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:11 Rn:0 Ra:19 o0:0 Rm:30 0011011000:0011011000 sf:1
	.inst 0x69dc0834 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:20 Rn:1 Rt2:00010 imm7:0111000 L:1 1010011:1010011 opc:01
	.inst 0x313a2be1 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:31 imm12:111010001010 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0x826b2841 // ALDR-R.RI-32 Rt:1 Rn:2 op:10 imm9:010110010 L:1 1000001001:1000001001
	.inst 0xe20f3abe // ALDURSB-R.RI-64 Rt:30 Rn:21 op2:10 imm9:011110011 V:0 op1:00 11100010:11100010
	.inst 0xc2c21120
	.zero 152
	.inst 0xc2c2c2c2
	.inst 0x00001d20
	.zero 32560
	.inst 0x00c20000
	.zero 1015808
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc2400995 // ldr c21, [x12, #2]
	.inst 0xc2400d9d // ldr c29, [x12, #3]
	.inst 0xc240119e // ldr c30, [x12, #4]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_csp_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850032
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260312c // ldr c12, [c9, #3]
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	.inst 0x8260112c // ldr c12, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x9, #0xf
	and x12, x12, x9
	cmp x12, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400189 // ldr c9, [x12, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400589 // ldr c9, [x12, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400989 // ldr c9, [x12, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400d89 // ldr c9, [x12, #3]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2401189 // ldr c9, [x12, #4]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401589 // ldr c9, [x12, #5]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401989 // ldr c9, [x12, #6]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2401d89 // ldr c9, [x12, #7]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2402189 // ldr c9, [x12, #8]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402589 // ldr c9, [x12, #9]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fe8
	ldr x1, =check_data1
	ldr x2, =0x00001fec
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004000c4
	ldr x1, =check_data3
	ldr x2, =0x004000cc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00407ffe
	ldr x1, =check_data4
	ldr x2, =0x00407fff
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
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr ddc_el3, c12
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
