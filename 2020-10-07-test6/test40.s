.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x5f, 0x0c, 0xdf, 0x9a, 0xa2, 0x01, 0x03, 0x5a, 0xdf, 0x03, 0x1f, 0x1a, 0xd6, 0xff, 0x9f, 0x48
	.byte 0x7f, 0xc0, 0xc0, 0xc2, 0xfb, 0xe2, 0xe7, 0xe2, 0x1f, 0xa8, 0xdf, 0xc2, 0xde, 0x11, 0x52, 0x78
	.byte 0x0e, 0x20, 0x3f, 0xeb, 0x1b, 0x30, 0xc1, 0xc2, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C3 */
	.octa 0x0
	/* C14 */
	.octa 0x8000000060010002000000000000205b
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0xf82
	/* C30 */
	.octa 0x400000000001000500000000000011fc
final_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C3 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0xf82
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000001007000f0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9adf0c5f // sdiv:aarch64/instrs/integer/arithmetic/div Rd:31 Rn:2 o1:1 00001:00001 Rm:31 0011010110:0011010110 sf:1
	.inst 0x5a0301a2 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:13 000000:000000 Rm:3 11010000:11010000 S:0 op:1 sf:0
	.inst 0x1a1f03df // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:30 000000:000000 Rm:31 11010000:11010000 S:0 op:0 sf:0
	.inst 0x489fffd6 // stlrh:aarch64/instrs/memory/ordered Rt:22 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c0c07f // CVT-R.CC-C Rd:31 Cn:3 110000:110000 Cm:0 11000010110:11000010110
	.inst 0xe2e7e2fb // ASTUR-V.RI-D Rt:27 Rn:23 op2:00 imm9:001111110 V:1 op1:11 11100010:11100010
	.inst 0xc2dfa81f // EORFLGS-C.CR-C Cd:31 Cn:0 1010:1010 opc:10 Rm:31 11000010110:11000010110
	.inst 0x785211de // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:14 00:00 imm9:100100001 0:0 opc:01 111000:111000 size:01
	.inst 0xeb3f200e // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:14 Rn:0 imm3:000 option:001 Rm:31 01011001:01011001 S:1 op:1 sf:1
	.inst 0xc2c1301b // GCFLGS-R.C-C Rd:27 Cn:0 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c210c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400743 // ldr c3, [x26, #1]
	.inst 0xc2400b4e // ldr c14, [x26, #2]
	.inst 0xc2400f56 // ldr c22, [x26, #3]
	.inst 0xc2401357 // ldr c23, [x26, #4]
	.inst 0xc240175e // ldr c30, [x26, #5]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q27, =0x0
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850032
	msr SCTLR_EL3, x26
	ldr x26, =0x0
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030da // ldr c26, [c6, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x826010da // ldr c26, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x6, #0xf
	and x26, x26, x6
	cmp x26, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400346 // ldr c6, [x26, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400746 // ldr c6, [x26, #1]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2400b46 // ldr c6, [x26, #2]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2400f46 // ldr c6, [x26, #3]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc2401346 // ldr c6, [x26, #4]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2401746 // ldr c6, [x26, #5]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2401b46 // ldr c6, [x26, #6]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x6, v27.d[0]
	cmp x26, x6
	b.ne comparison_fail
	ldr x26, =0x0
	mov x6, v27.d[1]
	cmp x26, x6
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
	ldr x0, =0x000011fc
	ldr x1, =check_data1
	ldr x2, =0x000011fe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f7c
	ldr x1, =check_data2
	ldr x2, =0x00001f7e
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
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
