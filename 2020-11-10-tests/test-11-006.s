.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x82, 0x00, 0x00, 0x00, 0xf5
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x21, 0xb0, 0xc0, 0xc2, 0x9f, 0xd2, 0xc0, 0xc2, 0xa0, 0x4d, 0x27, 0x2d, 0x25, 0xb0, 0xc5, 0xc2
	.byte 0xf5, 0x7f, 0x47, 0x9b, 0xa0, 0x7f, 0xdf, 0x08, 0xe8, 0x7f, 0x3f, 0x42, 0x51, 0x50, 0x4b, 0x82
	.byte 0x1f, 0xfe, 0x7f, 0x42, 0x9d, 0xc6, 0x09, 0x50, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4c0000000005000300000000000010b0
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x1204
	/* C16 */
	.octa 0x800000004004000a0000000000001000
	/* C17 */
	.octa 0x0
	/* C29 */
	.octa 0x401900
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4c0000000005000300000000000010b0
	/* C5 */
	.octa 0x20008000204700070000000000400000
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x1204
	/* C16 */
	.octa 0x800000004004000a0000000000001000
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x138f6
initial_SP_EL3_value:
	.octa 0x400000000000a0000000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000204700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000006fb000700ffe0000000e000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0b021 // GCSEAL-R.C-C Rd:1 Cn:1 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2c0d29f // GCPERM-R.C-C Rd:31 Cn:20 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x2d274da0 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:0 Rn:13 Rt2:10011 imm7:1001110 L:0 1011010:1011010 opc:00
	.inst 0xc2c5b025 // CVTP-C.R-C Cd:5 Rn:1 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x9b477ff5 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:21 Rn:31 Ra:11111 0:0 Rm:7 10:10 U:0 10011011:10011011
	.inst 0x08df7fa0 // ldlarb:aarch64/instrs/memory/ordered Rt:0 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x423f7fe8 // ASTLRB-R.R-B Rt:8 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x824b5051 // ASTR-C.RI-C Ct:17 Rn:2 op:00 imm9:010110101 L:0 1000001001:1000001001
	.inst 0x427ffe1f // ALDAR-R.R-32 Rt:31 Rn:16 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x5009c69d // ADR-C.I-C Rd:29 immhi:000100111000110100 P:0 10000:10000 immlo:10 op:0
	.inst 0xc2c212e0
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
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400868 // ldr c8, [x3, #2]
	.inst 0xc2400c6d // ldr c13, [x3, #3]
	.inst 0xc2401070 // ldr c16, [x3, #4]
	.inst 0xc2401471 // ldr c17, [x3, #5]
	.inst 0xc240187d // ldr c29, [x3, #6]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q0, =0x82000000
	ldr q19, =0xf5000000
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	ldr x3, =0xc
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032e3 // ldr c3, [c23, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x826012e3 // ldr c3, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	.inst 0xc2400077 // ldr c23, [x3, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400477 // ldr c23, [x3, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400877 // ldr c23, [x3, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400c77 // ldr c23, [x3, #3]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc2401077 // ldr c23, [x3, #4]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc2401477 // ldr c23, [x3, #5]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc2401877 // ldr c23, [x3, #6]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2401c77 // ldr c23, [x3, #7]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2402077 // ldr c23, [x3, #8]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc2402477 // ldr c23, [x3, #9]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x82000000
	mov x23, v0.d[0]
	cmp x3, x23
	b.ne comparison_fail
	ldr x3, =0x0
	mov x23, v0.d[1]
	cmp x3, x23
	b.ne comparison_fail
	ldr x3, =0xf5000000
	mov x23, v19.d[0]
	cmp x3, x23
	b.ne comparison_fail
	ldr x3, =0x0
	mov x23, v19.d[1]
	cmp x3, x23
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
	ldr x0, =0x0000113c
	ldr x1, =check_data1
	ldr x2, =0x00001144
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c00
	ldr x1, =check_data2
	ldr x2, =0x00001c10
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
	ldr x0, =0x00401900
	ldr x1, =check_data4
	ldr x2, =0x00401901
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
