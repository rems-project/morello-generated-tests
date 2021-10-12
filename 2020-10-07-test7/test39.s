.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x33, 0xc0, 0xc2, 0xc0, 0x23, 0xc7, 0x9a, 0x3f, 0x82, 0xc1, 0xc2, 0xe1, 0x30, 0xc2, 0xc2
	.byte 0x19, 0xf3, 0x8c, 0xf8, 0x15, 0xa5, 0x31, 0xd8, 0xe7, 0x23, 0x94, 0x28, 0xe0, 0x7f, 0xdf, 0x08
	.byte 0xc1, 0x2f, 0xc1, 0x9a, 0x41, 0x1b, 0xd6, 0xc2, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C17 */
	.octa 0x1010
	/* C24 */
	.octa 0x80080f0000000000000001
	/* C26 */
	.octa 0xc0010001000000000000e001
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc00100010000000000000000
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C17 */
	.octa 0x1010
	/* C24 */
	.octa 0x80080f0000000000000001
	/* C26 */
	.octa 0xc0010001000000000000e001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000238620060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000400000fc0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c03300 // GCLEN-R.C-C Rd:0 Cn:24 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x9ac723c0 // lslv:aarch64/instrs/integer/shift/variable Rd:0 Rn:30 op2:00 0010:0010 Rm:7 0011010110:0011010110 sf:1
	.inst 0xc2c1823f // SCTAG-C.CR-C Cd:31 Cn:17 000:000 0:0 10:10 Rm:1 11000010110:11000010110
	.inst 0xc2c230e1 // CHKTGD-C-C 00001:00001 Cn:7 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xf88cf319 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:25 Rn:24 00:00 imm9:011001111 0:0 opc:10 111000:111000 size:11
	.inst 0xd831a515 // prfm_lit:aarch64/instrs/memory/literal/general Rt:21 imm19:0011000110100101000 011000:011000 opc:11
	.inst 0x289423e7 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:7 Rn:31 Rt2:01000 imm7:0101000 L:0 1010001:1010001 opc:00
	.inst 0x08df7fe0 // ldlarb:aarch64/instrs/memory/ordered Rt:0 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x9ac12fc1 // rorv:aarch64/instrs/integer/shift/variable Rd:1 Rn:30 op2:11 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0xc2d61b41 // ALIGND-C.CI-C Cd:1 Cn:26 0110:0110 U:0 imm6:101100 11000010110:11000010110
	.inst 0xc2c210c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400607 // ldr c7, [x16, #1]
	.inst 0xc2400a08 // ldr c8, [x16, #2]
	.inst 0xc2400e11 // ldr c17, [x16, #3]
	.inst 0xc2401218 // ldr c24, [x16, #4]
	.inst 0xc240161a // ldr c26, [x16, #5]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d0 // ldr c16, [c6, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x826010d0 // ldr c16, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x6, #0xf
	and x16, x16, x6
	cmp x16, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400206 // ldr c6, [x16, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400606 // ldr c6, [x16, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400a06 // ldr c6, [x16, #2]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2400e06 // ldr c6, [x16, #3]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2401206 // ldr c6, [x16, #4]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2401606 // ldr c6, [x16, #5]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2401a06 // ldr c6, [x16, #6]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010b0
	ldr x1, =check_data1
	ldr x2, =0x000010b1
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
