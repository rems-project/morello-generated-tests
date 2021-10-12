.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x4c, 0xa0, 0x5d, 0xd2, 0x2f, 0x7c, 0x71, 0x91, 0x05, 0x54, 0x59, 0x78, 0xa0, 0xe8, 0x77, 0x18
	.byte 0x01, 0x53, 0xae, 0xe2, 0x39, 0xf8, 0xe9, 0x82, 0xc2, 0x07, 0xcf, 0xc2, 0xb0, 0x18, 0xd8, 0xc2
	.byte 0xff, 0xae, 0x60, 0xaa, 0xb0, 0x83, 0x60, 0x82, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000010005000000000040200c
	/* C1 */
	.octa 0x4ffff0
	/* C9 */
	.octa 0x0
	/* C24 */
	.octa 0x1f13
	/* C29 */
	.octa 0x1f60
	/* C30 */
	.octa 0x3fff800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4ffff0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C15 */
	.octa 0x115eff0
	/* C16 */
	.octa 0x0
	/* C24 */
	.octa 0x1f13
	/* C29 */
	.octa 0x1f60
	/* C30 */
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd25da04c // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:12 Rn:2 imms:101000 immr:011101 N:1 100100:100100 opc:10 sf:1
	.inst 0x91717c2f // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:15 Rn:1 imm12:110001011111 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x78595405 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:5 Rn:0 01:01 imm9:110010101 0:0 opc:01 111000:111000 size:01
	.inst 0x1877e8a0 // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:0 imm19:0111011111101000101 011000:011000 opc:00
	.inst 0xe2ae5301 // ASTUR-V.RI-S Rt:1 Rn:24 op2:00 imm9:011100101 V:1 op1:10 11100010:11100010
	.inst 0x82e9f839 // ALDR-V.RRB-D Rt:25 Rn:1 opc:10 S:1 option:111 Rm:9 1:1 L:1 100000101:100000101
	.inst 0xc2cf07c2 // BUILD-C.C-C Cd:2 Cn:30 001:001 opc:00 0:0 Cm:15 11000010110:11000010110
	.inst 0xc2d818b0 // ALIGND-C.CI-C Cd:16 Cn:5 0110:0110 U:0 imm6:110000 11000010110:11000010110
	.inst 0xaa60aeff // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:23 imm6:101011 Rm:0 N:1 shift:01 01010:01010 opc:01 sf:1
	.inst 0x826083b0 // ALDR-C.RI-C Ct:16 Rn:29 op:00 imm9:000001000 L:1 1000001001:1000001001
	.inst 0xc2c211c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e9 // ldr c9, [x7, #2]
	.inst 0xc2400cf8 // ldr c24, [x7, #3]
	.inst 0xc24010fd // ldr c29, [x7, #4]
	.inst 0xc24014fe // ldr c30, [x7, #5]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850032
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c7 // ldr c7, [c14, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x826011c7 // ldr c7, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000ee // ldr c14, [x7, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24004ee // ldr c14, [x7, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24008ee // ldr c14, [x7, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400cee // ldr c14, [x7, #3]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc24010ee // ldr c14, [x7, #4]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc24014ee // ldr c14, [x7, #5]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc24018ee // ldr c14, [x7, #6]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc2401cee // ldr c14, [x7, #7]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc24020ee // ldr c14, [x7, #8]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc24024ee // ldr c14, [x7, #9]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x14, v1.d[0]
	cmp x7, x14
	b.ne comparison_fail
	ldr x7, =0x0
	mov x14, v1.d[1]
	cmp x7, x14
	b.ne comparison_fail
	ldr x7, =0x0
	mov x14, v25.d[0]
	cmp x7, x14
	b.ne comparison_fail
	ldr x7, =0x0
	mov x14, v25.d[1]
	cmp x7, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fe0
	ldr x1, =check_data0
	ldr x2, =0x00001ff0
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
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040200c
	ldr x1, =check_data3
	ldr x2, =0x0040200e
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004efd20
	ldr x1, =check_data4
	ldr x2, =0x004efd24
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffff0
	ldr x1, =check_data5
	ldr x2, =0x004ffff8
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
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
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
