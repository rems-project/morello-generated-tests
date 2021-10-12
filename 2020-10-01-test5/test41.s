.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x41, 0x29, 0x1d, 0xb8, 0xff, 0x0f, 0xd7, 0x9a, 0x26, 0xc4, 0xca, 0xe2, 0xaa, 0xbd, 0x9b, 0xa8
	.byte 0xdf, 0x6f, 0x5e, 0x78, 0xbf, 0xab, 0xc1, 0xc2, 0xd2, 0xd3, 0xc1, 0xc2, 0x0b, 0xdc, 0x89, 0x82
	.byte 0x25, 0x90, 0xc5, 0xc2, 0x22, 0x50, 0xc2, 0xc2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x00, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000700070000000000000c00
	/* C1 */
	.octa 0xa0008000420400040000000000410004
	/* C9 */
	.octa 0x200
	/* C10 */
	.octa 0x1032
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x1000
	/* C15 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x400080
final_cap_values:
	/* C0 */
	.octa 0x40000000000700070000000000000c00
	/* C1 */
	.octa 0xa0008000420400040000000000410004
	/* C5 */
	.octa 0xc0000000000600000000000000410004
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x200
	/* C10 */
	.octa 0x1032
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x11b8
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x400066
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x400066
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200002000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000006000000fffffff000e000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb81d2941 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:10 10:10 imm9:111010010 0:0 opc:00 111000:111000 size:10
	.inst 0x9ad70fff // sdiv:aarch64/instrs/integer/arithmetic/div Rd:31 Rn:31 o1:1 00001:00001 Rm:23 0011010110:0011010110 sf:1
	.inst 0xe2cac426 // ALDUR-R.RI-64 Rt:6 Rn:1 op2:01 imm9:010101100 V:0 op1:11 11100010:11100010
	.inst 0xa89bbdaa // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:10 Rn:13 Rt2:01111 imm7:0110111 L:0 1010001:1010001 opc:10
	.inst 0x785e6fdf // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:30 11:11 imm9:111100110 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c1abbf // EORFLGS-C.CR-C Cd:31 Cn:29 1010:1010 opc:10 Rm:1 11000010110:11000010110
	.inst 0xc2c1d3d2 // CPY-C.C-C Cd:18 Cn:30 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x8289dc0b // ASTRH-R.RRB-32 Rt:11 Rn:0 opc:11 S:1 option:110 Rm:9 0:0 L:0 100000101:100000101
	.inst 0xc2c59025 // CVTD-C.R-C Cd:5 Rn:1 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c25022 // RETS-C-C 00010:00010 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.zero 65500
	.inst 0xc2c21200
	.zero 983032
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400909 // ldr c9, [x8, #2]
	.inst 0xc2400d0a // ldr c10, [x8, #3]
	.inst 0xc240110b // ldr c11, [x8, #4]
	.inst 0xc240150d // ldr c13, [x8, #5]
	.inst 0xc240190f // ldr c15, [x8, #6]
	.inst 0xc2401d17 // ldr c23, [x8, #7]
	.inst 0xc240211d // ldr c29, [x8, #8]
	.inst 0xc240251e // ldr c30, [x8, #9]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603208 // ldr c8, [c16, #3]
	.inst 0xc28b4128 // msr ddc_el3, c8
	isb
	.inst 0x82601208 // ldr c8, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr ddc_el3, c8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400110 // ldr c16, [x8, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400510 // ldr c16, [x8, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400910 // ldr c16, [x8, #2]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc2400d10 // ldr c16, [x8, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2401110 // ldr c16, [x8, #4]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc2401510 // ldr c16, [x8, #5]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc2401910 // ldr c16, [x8, #6]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc2401d10 // ldr c16, [x8, #7]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc2402110 // ldr c16, [x8, #8]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2402510 // ldr c16, [x8, #9]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc2402910 // ldr c16, [x8, #10]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc2402d10 // ldr c16, [x8, #11]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2403110 // ldr c16, [x8, #12]
	.inst 0xc2d0a7c1 // chkeq c30, c16
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
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400066
	ldr x1, =check_data2
	ldr x2, =0x00400068
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00410004
	ldr x1, =check_data3
	ldr x2, =0x00410008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004100b0
	ldr x1, =check_data4
	ldr x2, =0x004100b8
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
	.inst 0xc28b4128 // msr ddc_el3, c8
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
