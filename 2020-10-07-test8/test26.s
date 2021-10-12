.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xff, 0xff, 0xdf, 0x48, 0x20, 0x05, 0xc1, 0xc2, 0xbf, 0x7f, 0xdf, 0xc8, 0xf9, 0xb3, 0x38, 0xe2
	.byte 0xa0, 0x87, 0xca, 0xc2, 0x47, 0xc0, 0x4f, 0x3a, 0x7f, 0x05, 0xc0, 0xda, 0xc0, 0x7b, 0x62, 0xb8
	.byte 0x00, 0x90, 0x41, 0xba, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data3:
	.byte 0x20, 0x50, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20008000000100050000000000400015
	/* C2 */
	.octa 0x13fffe
	/* C9 */
	.octa 0x40000000000000000
	/* C10 */
	.octa 0x400800000000000000000000000000
	/* C29 */
	.octa 0x204088000001000500000000004ffff0
	/* C30 */
	.octa 0x80000000000100050000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x20008000000100050000000000400015
	/* C2 */
	.octa 0x13fffe
	/* C9 */
	.octa 0x40000000000000000
	/* C10 */
	.octa 0x400800000000000000000000000000
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x80000000000100050000000000000000
initial_SP_EL3_value:
	.octa 0x40000000000300070000000000001240
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001007900e0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000300030000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x48dfffff // ldarh:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c10520 // BUILD-C.C-C Cd:0 Cn:9 001:001 opc:00 0:0 Cm:1 11000010110:11000010110
	.inst 0xc8df7fbf // ldlar:aarch64/instrs/memory/ordered Rt:31 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xe238b3f9 // ASTUR-V.RI-B Rt:25 Rn:31 op2:00 imm9:110001011 V:1 op1:00 11100010:11100010
	.inst 0xc2ca87a0 // BRS-C.C-C 00000:00000 Cn:29 001:001 opc:00 1:1 Cm:10 11000010110:11000010110
	.inst 0x3a4fc047 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0111 0:0 Rn:2 00:00 cond:1100 Rm:15 111010010:111010010 op:0 sf:0
	.inst 0xdac0057f // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:11 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xb8627bc0 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:0 Rn:30 10:10 S:1 option:011 Rm:2 1:1 opc:01 111000:111000 size:10
	.inst 0xba419000 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:0 00:00 cond:1001 Rm:1 111010010:111010010 op:0 sf:1
	.inst 0xc2c211c0
	.zero 1048520
	.inst 0xc2c25020 // RET-C-C 00000:00000 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.zero 12
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c9 // ldr c9, [x6, #2]
	.inst 0xc2400cca // ldr c10, [x6, #3]
	.inst 0xc24010dd // ldr c29, [x6, #4]
	.inst 0xc24014de // ldr c30, [x6, #5]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q25, =0x0
	/* Set up flags and system registers */
	mov x6, #0x80000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x3085003a
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c6 // ldr c6, [c14, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826011c6 // ldr c6, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x14, #0xf
	and x6, x6, x14
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000ce // ldr c14, [x6, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24004ce // ldr c14, [x6, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24008ce // ldr c14, [x6, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400cce // ldr c14, [x6, #3]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc24010ce // ldr c14, [x6, #4]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc24014ce // ldr c14, [x6, #5]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc24018ce // ldr c14, [x6, #6]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x14, v25.d[0]
	cmp x6, x14
	b.ne comparison_fail
	ldr x6, =0x0
	mov x14, v25.d[1]
	cmp x6, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011cb
	ldr x1, =check_data0
	ldr x2, =0x000011cc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001240
	ldr x1, =check_data1
	ldr x2, =0x00001242
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffff0
	ldr x1, =check_data3
	ldr x2, =0x004ffffc
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
