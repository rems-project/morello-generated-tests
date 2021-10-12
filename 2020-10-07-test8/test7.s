.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 3
.data
check_data3:
	.byte 0xda, 0x03, 0xc0, 0xc2, 0x5d, 0xc4, 0x77, 0x62, 0x00, 0x80, 0xc6, 0xc2, 0x5e, 0xb4, 0x50, 0xe2
	.byte 0x02, 0x53, 0xc1, 0xc2, 0xe2, 0xc3, 0xdc, 0xc2, 0x44, 0xf0, 0x1f, 0xf2, 0x9f, 0xa9, 0x49, 0x38
	.byte 0xf9, 0xfb, 0x04, 0x78, 0xfc, 0x0b, 0xc0, 0x9a, 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x90100000000300070000000000001120
	/* C6 */
	.octa 0x1
	/* C12 */
	.octa 0x80000000000100050000000000001f64
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x120070000000000000001
	/* C30 */
	.octa 0xc00000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0xe000000000001fad
	/* C4 */
	.octa 0xa000000000000aa8
	/* C6 */
	.octa 0x1
	/* C12 */
	.octa 0x80000000000100050000000000001f64
	/* C17 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0xc00000000000000000000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000000100050000000000001fad
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000000040080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004113030500ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c003da // SCBNDS-C.CR-C Cd:26 Cn:30 000:000 opc:00 0:0 Rm:0 11000010110:11000010110
	.inst 0x6277c45d // LDNP-C.RIB-C Ct:29 Rn:2 Ct2:10001 imm7:1101111 L:1 011000100:011000100
	.inst 0xc2c68000 // SCTAG-C.CR-C Cd:0 Cn:0 000:000 0:0 10:10 Rm:6 11000010110:11000010110
	.inst 0xe250b45e // ALDURH-R.RI-32 Rt:30 Rn:2 op2:01 imm9:100001011 V:0 op1:01 11100010:11100010
	.inst 0xc2c15302 // CFHI-R.C-C Rd:2 Cn:24 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2dcc3e2 // CVT-R.CC-C Rd:2 Cn:31 110000:110000 Cm:28 11000010110:11000010110
	.inst 0xf21ff044 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:4 Rn:2 imms:111100 immr:011111 N:0 100100:100100 opc:11 sf:1
	.inst 0x3849a99f // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:12 10:10 imm9:010011010 0:0 opc:01 111000:111000 size:00
	.inst 0x7804fbf9 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:25 Rn:31 10:10 imm9:001001111 0:0 opc:00 111000:111000 size:01
	.inst 0x9ac00bfc // udiv:aarch64/instrs/integer/arithmetic/div Rd:28 Rn:31 o1:0 00001:00001 Rm:0 0011010110:0011010110 sf:1
	.inst 0xc2c21100
	.zero 1048532
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
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400966 // ldr c6, [x11, #2]
	.inst 0xc2400d6c // ldr c12, [x11, #3]
	.inst 0xc2401179 // ldr c25, [x11, #4]
	.inst 0xc240157c // ldr c28, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260310b // ldr c11, [c8, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260110b // ldr c11, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	mov x8, #0xf
	and x11, x11, x8
	cmp x11, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400168 // ldr c8, [x11, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400568 // ldr c8, [x11, #1]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400968 // ldr c8, [x11, #2]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc2400d68 // ldr c8, [x11, #3]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc2401168 // ldr c8, [x11, #4]
	.inst 0xc2c8a581 // chkeq c12, c8
	b.ne comparison_fail
	.inst 0xc2401568 // ldr c8, [x11, #5]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc2401968 // ldr c8, [x11, #6]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc2401d68 // ldr c8, [x11, #7]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2402168 // ldr c8, [x11, #8]
	.inst 0xc2c8a781 // chkeq c28, c8
	b.ne comparison_fail
	.inst 0xc2402568 // ldr c8, [x11, #9]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2402968 // ldr c8, [x11, #10]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001330
	ldr x1, =check_data1
	ldr x2, =0x00001332
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
