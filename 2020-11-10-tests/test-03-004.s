.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x06, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x1e, 0xb2, 0xc5, 0xc2, 0x3e, 0xfc, 0x9f, 0x08, 0xfe, 0x91, 0xc5, 0xc2, 0xff, 0x1b, 0xd7, 0xc2
	.byte 0x3f, 0x78, 0xad, 0x37, 0x41, 0xa7, 0xd8, 0xe2, 0xc7, 0x72, 0xc0, 0xc2, 0xe2, 0xa6, 0x06, 0xc2
	.byte 0xc1, 0x7b, 0x60, 0xf8, 0x81, 0x82, 0xe0, 0xa2, 0x00, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000000000000000060600
	/* C1 */
	.octa 0x40000000400101020000000000001000
	/* C2 */
	.octa 0x0
	/* C15 */
	.octa 0x1fcff0
	/* C16 */
	.octa 0x100040849fec01
	/* C20 */
	.octa 0xc80000004ffc0ffe0000000000001000
	/* C22 */
	.octa 0x400000000000000000000000
	/* C23 */
	.octa 0x40000000000000000000000000000040
	/* C26 */
	.octa 0x4f08e6
final_cap_values:
	/* C0 */
	.octa 0x4000000000000000000000060600
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C15 */
	.octa 0x1fcff0
	/* C16 */
	.octa 0x100040849fec01
	/* C20 */
	.octa 0xc80000004ffc0ffe0000000000001000
	/* C22 */
	.octa 0x400000000000000000000000
	/* C23 */
	.octa 0x40000000000000000000000000000040
	/* C26 */
	.octa 0x4f08e6
	/* C30 */
	.octa 0x800000000001000600000000001fcff0
initial_SP_EL3_value:
	.octa 0x8000070007000000000000e001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000001000600c0000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5b21e // CVTP-C.R-C Cd:30 Rn:16 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x089ffc3e // stlrb:aarch64/instrs/memory/ordered Rt:30 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c591fe // CVTD-C.R-C Cd:30 Rn:15 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2d71bff // ALIGND-C.CI-C Cd:31 Cn:31 0110:0110 U:0 imm6:101110 11000010110:11000010110
	.inst 0x37ad783f // tbnz:aarch64/instrs/branch/conditional/test Rt:31 imm14:10101111000001 b40:10101 op:1 011011:011011 b5:0
	.inst 0xe2d8a741 // ALDUR-R.RI-64 Rt:1 Rn:26 op2:01 imm9:110001010 V:0 op1:11 11100010:11100010
	.inst 0xc2c072c7 // GCOFF-R.C-C Rd:7 Cn:22 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc206a6e2 // STR-C.RIB-C Ct:2 Rn:23 imm12:000110101001 L:0 110000100:110000100
	.inst 0xf8607bc1 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:1 Rn:30 10:10 S:1 option:011 Rm:0 1:1 opc:01 111000:111000 size:11
	.inst 0xa2e08281 // SWPAL-CC.R-C Ct:1 Rn:20 100000:100000 Cs:0 1:1 R:1 A:1 10100010:10100010
	.inst 0xc2c21100
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400862 // ldr c2, [x3, #2]
	.inst 0xc2400c6f // ldr c15, [x3, #3]
	.inst 0xc2401070 // ldr c16, [x3, #4]
	.inst 0xc2401474 // ldr c20, [x3, #5]
	.inst 0xc2401876 // ldr c22, [x3, #6]
	.inst 0xc2401c77 // ldr c23, [x3, #7]
	.inst 0xc240207a // ldr c26, [x3, #8]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851037
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603103 // ldr c3, [c8, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601103 // ldr c3, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400068 // ldr c8, [x3, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400468 // ldr c8, [x3, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400868 // ldr c8, [x3, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400c68 // ldr c8, [x3, #3]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2401068 // ldr c8, [x3, #4]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc2401468 // ldr c8, [x3, #5]
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	.inst 0xc2401868 // ldr c8, [x3, #6]
	.inst 0xc2c8a681 // chkeq c20, c8
	b.ne comparison_fail
	.inst 0xc2401c68 // ldr c8, [x3, #7]
	.inst 0xc2c8a6c1 // chkeq c22, c8
	b.ne comparison_fail
	.inst 0xc2402068 // ldr c8, [x3, #8]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2402468 // ldr c8, [x3, #9]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2402868 // ldr c8, [x3, #10]
	.inst 0xc2c8a7c1 // chkeq c30, c8
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
	ldr x0, =0x00001ad0
	ldr x1, =check_data1
	ldr x2, =0x00001ae0
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
	ldr x0, =0x004f0870
	ldr x1, =check_data3
	ldr x2, =0x004f0878
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffff0
	ldr x1, =check_data4
	ldr x2, =0x004ffff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
