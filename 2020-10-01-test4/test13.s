.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x93, 0x9b, 0xc9, 0xc2, 0x41, 0x90, 0xc1, 0xc2, 0xe2, 0x03, 0xc4, 0xc2, 0x01, 0x00, 0x1d, 0x7a
	.byte 0x3b, 0x51, 0xc1, 0xc2, 0x22, 0xb0, 0xc5, 0xc2, 0x02, 0xb4, 0x36, 0x2d, 0x8e, 0xd5, 0x37, 0x39
	.byte 0xd0, 0x0f, 0xde, 0xc2, 0xc0, 0xe1, 0x88, 0xd0, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000
	/* C12 */
	.octa 0x8eb
	/* C14 */
	.octa 0x0
	/* C28 */
	.octa 0x100030000000000000000
	/* C29 */
	.octa 0x1fff
final_cap_values:
	/* C0 */
	.octa 0xffffffff1203a000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x20008000000100050000000000000000
	/* C12 */
	.octa 0x8eb
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x100030000000000000000
	/* C28 */
	.octa 0x100030000000000000000
	/* C29 */
	.octa 0x1fff
initial_csp_value:
	.octa 0xc00000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c99b93 // ALIGND-C.CI-C Cd:19 Cn:28 0110:0110 U:0 imm6:010011 11000010110:11000010110
	.inst 0xc2c19041 // CLRTAG-C.C-C Cd:1 Cn:2 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c403e2 // SCBNDS-C.CR-C Cd:2 Cn:31 000:000 opc:00 0:0 Rm:4 11000010110:11000010110
	.inst 0x7a1d0001 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:0 000000:000000 Rm:29 11010000:11010000 S:1 op:1 sf:0
	.inst 0xc2c1513b // CFHI-R.C-C Rd:27 Cn:9 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c5b022 // CVTP-C.R-C Cd:2 Rn:1 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x2d36b402 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:2 Rn:0 Rt2:01101 imm7:1101101 L:0 1011010:1011010 opc:00
	.inst 0x3937d58e // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:14 Rn:12 imm12:110111110101 opc:00 111001:111001 size:00
	.inst 0xc2de0fd0 // CSEL-C.CI-C Cd:16 Cn:30 11:11 cond:0000 Cm:30 11000010110:11000010110
	.inst 0xd088e1c0 // ADRP-C.I-C Rd:0 immhi:000100011100001110 P:1 10000:10000 immlo:10 op:1
	.inst 0xc2c21320
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc240056c // ldr c12, [x11, #1]
	.inst 0xc240096e // ldr c14, [x11, #2]
	.inst 0xc2400d7c // ldr c28, [x11, #3]
	.inst 0xc240117d // ldr c29, [x11, #4]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q2, =0x0
	ldr q13, =0x0
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_csp_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x8
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260332b // ldr c11, [c25, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x8260132b // ldr c11, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x25, #0xf
	and x11, x11, x25
	cmp x11, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400179 // ldr c25, [x11, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400579 // ldr c25, [x11, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400979 // ldr c25, [x11, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400d79 // ldr c25, [x11, #3]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2401179 // ldr c25, [x11, #4]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc2401579 // ldr c25, [x11, #5]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc2401979 // ldr c25, [x11, #6]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc2401d79 // ldr c25, [x11, #7]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x25, v2.d[0]
	cmp x11, x25
	b.ne comparison_fail
	ldr x11, =0x0
	mov x25, v2.d[1]
	cmp x11, x25
	b.ne comparison_fail
	ldr x11, =0x0
	mov x25, v13.d[0]
	cmp x11, x25
	b.ne comparison_fail
	ldr x11, =0x0
	mov x25, v13.d[1]
	cmp x11, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000016e0
	ldr x1, =check_data0
	ldr x2, =0x000016e1
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fb4
	ldr x1, =check_data1
	ldr x2, =0x00001fbc
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
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
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
