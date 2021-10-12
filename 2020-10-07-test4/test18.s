.section data0, #alloc, #write
	.zero 1024
	.byte 0x01, 0xe0, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0xc0, 0x04, 0xc0, 0x00, 0x80, 0x00, 0x20
	.zero 3056
.data
check_data0:
	.byte 0x01, 0xe0, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0xc0, 0x04, 0xc0, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xc0, 0x13, 0xd8, 0xc2
.data
check_data3:
	.byte 0x02, 0x98, 0xe0, 0xc2, 0x41, 0x18, 0xf8, 0xc2, 0x02, 0xb0, 0x8f, 0xe2, 0x27, 0x00, 0xde, 0xc2
	.byte 0x0e, 0x80, 0x5f, 0xfa, 0xc1, 0x62, 0xe0, 0xc2, 0xd7, 0xf8, 0xce, 0xc2, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x46, 0x3a, 0x60, 0x29, 0x60, 0x52, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001efd
	/* C18 */
	.octa 0x8000000000010005000000000044d8fc
	/* C19 */
	.octa 0x20008000800100070000000000401030
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x90000000400100020000000000001800
final_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001efd
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x8000000000010005000000000044d8fc
	/* C19 */
	.octa 0x20008000800100070000000000401030
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C23 */
	.octa 0x41d000000000000000000000
	/* C30 */
	.octa 0x90000000400100020000000000001800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100000080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001400
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d813c0 // BR-CI-C 0:0 0000:0000 Cn:30 100:100 imm7:1000000 110000101101:110000101101
	.zero 4140
	.inst 0xc2e09802 // SUBS-R.CC-C Rd:2 Cn:0 100110:100110 Cm:0 11000010111:11000010111
	.inst 0xc2f81841 // CVT-C.CR-C Cd:1 Cn:2 0110:0110 0:0 0:0 Rm:24 11000010111:11000010111
	.inst 0xe28fb002 // ASTUR-R.RI-32 Rt:2 Rn:0 op2:00 imm9:011111011 V:0 op1:10 11100010:11100010
	.inst 0xc2de0027 // SCBNDS-C.CR-C Cd:7 Cn:1 000:000 opc:00 0:0 Rm:30 11000010110:11000010110
	.inst 0xfa5f800e // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1110 0:0 Rn:0 00:00 cond:1000 Rm:31 111010010:111010010 op:1 sf:1
	.inst 0xc2e062c1 // BICFLGS-C.CI-C Cd:1 Cn:22 0:0 00:00 imm8:00000011 11000010111:11000010111
	.inst 0xc2cef8d7 // SCBNDS-C.CI-S Cd:23 Cn:6 1110:1110 S:1 imm6:011101 11000010110:11000010110
	.inst 0xc2c210a0
	.zero 577456
	.inst 0x29603a46 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:6 Rn:18 Rt2:01110 imm7:1000000 L:1 1010010:1010010 opc:00
	.inst 0xc2c25260 // RET-C-C 00000:00000 Cn:19 100:100 opc:10 11000010110000100:11000010110000100
	.zero 466936
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400572 // ldr c18, [x11, #1]
	.inst 0xc2400973 // ldr c19, [x11, #2]
	.inst 0xc2400d76 // ldr c22, [x11, #3]
	.inst 0xc240117e // ldr c30, [x11, #4]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010ab // ldr c11, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x5, #0xf
	and x11, x11, x5
	cmp x11, #0xe
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400165 // ldr c5, [x11, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400565 // ldr c5, [x11, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400965 // ldr c5, [x11, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400d65 // ldr c5, [x11, #3]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2401165 // ldr c5, [x11, #4]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2401565 // ldr c5, [x11, #5]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2401965 // ldr c5, [x11, #6]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2401d65 // ldr c5, [x11, #7]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc2402165 // ldr c5, [x11, #8]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2402565 // ldr c5, [x11, #9]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001400
	ldr x1, =check_data0
	ldr x2, =0x00001410
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff8
	ldr x1, =check_data1
	ldr x2, =0x00001ffc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00401030
	ldr x1, =check_data3
	ldr x2, =0x00401050
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0044d7fc
	ldr x1, =check_data4
	ldr x2, =0x0044d804
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0048e000
	ldr x1, =check_data5
	ldr x2, =0x0048e008
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
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
