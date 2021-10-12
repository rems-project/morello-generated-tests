.section data0, #alloc, #write
	.zero 2544
	.byte 0x01, 0x40, 0x4a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x01, 0xd0, 0x00, 0x80, 0x00, 0x20
	.zero 1536
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
	.byte 0x01, 0x40, 0x4a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x01, 0xd0, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x04, 0x10, 0x00, 0x00
.data
check_data5:
	.byte 0x6e, 0x05, 0x81, 0xda, 0x61, 0x7b, 0xa4, 0xf8, 0x02, 0xfc, 0x9f, 0x88, 0x49, 0x60, 0xc3, 0x38
	.byte 0xd3, 0x13, 0xc4, 0xc2
.data
check_data6:
	.byte 0xcf, 0xe3, 0x69, 0xe2, 0xcf, 0x7f, 0xdf, 0x88, 0x40, 0x9c, 0x38, 0x90, 0xf2, 0x06, 0xe5, 0xe2
	.byte 0x01, 0xc1, 0x3d, 0x90, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1df0
	/* C2 */
	.octa 0x1004
	/* C23 */
	.octa 0xfb0
	/* C30 */
	.octa 0x900000000001000500000000000019e0
final_cap_values:
	/* C0 */
	.octa 0xc0000000000700070100000071387000
	/* C1 */
	.octa 0xc000000000070007010000007b81f000
	/* C2 */
	.octa 0x1004
	/* C9 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0xfb0
	/* C30 */
	.octa 0x900000000001000500000000000019e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040780000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000700fffffffffff000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000019f0
	.dword initial_cap_values + 48
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xda81056e // csneg:aarch64/instrs/integer/conditional/select Rd:14 Rn:11 o2:1 0:0 cond:0000 Rm:1 011010100:011010100 op:1 sf:1
	.inst 0xf8a47b61 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:27 10:10 S:1 option:011 Rm:4 1:1 opc:10 111000:111000 size:11
	.inst 0x889ffc02 // stlr:aarch64/instrs/memory/ordered Rt:2 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x38c36049 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:9 Rn:2 00:00 imm9:000110110 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c413d3 // LDPBR-C.C-C Ct:19 Cn:30 100:100 opc:00 11000010110001000:11000010110001000
	.zero 671724
	.inst 0xe269e3cf // ASTUR-V.RI-H Rt:15 Rn:30 op2:00 imm9:010011110 V:1 op1:01 11100010:11100010
	.inst 0x88df7fcf // ldlar:aarch64/instrs/memory/ordered Rt:15 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x90389c40 // ADRP-C.I-C Rd:0 immhi:011100010011100010 P:0 10000:10000 immlo:00 op:1
	.inst 0xe2e506f2 // ALDUR-V.RI-D Rt:18 Rn:23 op2:01 imm9:001010000 V:1 op1:11 11100010:11100010
	.inst 0x903dc101 // ADRDP-C.ID-C Rd:1 immhi:011110111000001000 P:0 10000:10000 immlo:00 op:1
	.inst 0xc2c210c0
	.zero 376808
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400ab7 // ldr c23, [x21, #2]
	.inst 0xc2400ebe // ldr c30, [x21, #3]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q15, =0x0
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850032
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d5 // ldr c21, [c6, #3]
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	.inst 0x826010d5 // ldr c21, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x6, #0x4
	and x21, x21, x6
	cmp x21, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a6 // ldr c6, [x21, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24006a6 // ldr c6, [x21, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400aa6 // ldr c6, [x21, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400ea6 // ldr c6, [x21, #3]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc24012a6 // ldr c6, [x21, #4]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc24016a6 // ldr c6, [x21, #5]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2401aa6 // ldr c6, [x21, #6]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2401ea6 // ldr c6, [x21, #7]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x6, v15.d[0]
	cmp x21, x6
	b.ne comparison_fail
	ldr x21, =0x0
	mov x6, v15.d[1]
	cmp x21, x6
	b.ne comparison_fail
	ldr x21, =0x0
	mov x6, v18.d[0]
	cmp x21, x6
	b.ne comparison_fail
	ldr x21, =0x0
	mov x6, v18.d[1]
	cmp x21, x6
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
	ldr x0, =0x0000103a
	ldr x1, =check_data1
	ldr x2, =0x0000103b
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000019e0
	ldr x1, =check_data2
	ldr x2, =0x00001a00
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a7e
	ldr x1, =check_data3
	ldr x2, =0x00001a80
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001df0
	ldr x1, =check_data4
	ldr x2, =0x00001df4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004a4000
	ldr x1, =check_data6
	ldr x2, =0x004a4018
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
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
