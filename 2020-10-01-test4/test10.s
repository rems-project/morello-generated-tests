.section data0, #alloc, #write
	.zero 1008
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 1968
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1056
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0x9e, 0x82, 0xc0, 0xc2, 0xe1, 0x26, 0x7f, 0x28, 0xee, 0xe7, 0xfe, 0xe2, 0xbf, 0x53, 0xc1, 0xc2
	.byte 0x5e, 0x70, 0xee, 0xc2, 0xbe, 0x9d, 0x5a, 0xb8, 0xe1, 0x8b, 0x53, 0xba, 0xe2, 0x87, 0x01, 0xe2
	.byte 0x05, 0x20, 0x56, 0x3a, 0x43, 0x32, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data5:
	.byte 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1
	/* C2 */
	.octa 0x3fff800000000000000000000000
	/* C13 */
	.octa 0x80000000200020000000000000406023
	/* C18 */
	.octa 0x200000008007800700000000004c8000
	/* C23 */
	.octa 0x800000000007000e0000000000001400
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0xc2c2c2c2
	/* C2 */
	.octa 0xc2
	/* C9 */
	.octa 0xc2c2c2c2
	/* C13 */
	.octa 0x80000000200020000000000000405fcc
	/* C18 */
	.octa 0x200000008007800700000000004c8000
	/* C23 */
	.octa 0x800000000007000e0000000000001400
	/* C30 */
	.octa 0x20808000800700030000000000400029
initial_csp_value:
	.octa 0x1bc2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000000700030000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0829e // SCTAG-C.CR-C Cd:30 Cn:20 000:000 0:0 10:10 Rm:0 11000010110:11000010110
	.inst 0x287f26e1 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:1 Rn:23 Rt2:01001 imm7:1111110 L:1 1010000:1010000 opc:00
	.inst 0xe2fee7ee // ALDUR-V.RI-D Rt:14 Rn:31 op2:01 imm9:111101110 V:1 op1:11 11100010:11100010
	.inst 0xc2c153bf // CFHI-R.C-C Rd:31 Cn:29 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2ee705e // EORFLGS-C.CI-C Cd:30 Cn:2 0:0 10:10 imm8:01110011 11000010111:11000010111
	.inst 0xb85a9dbe // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:13 11:11 imm9:110101001 0:0 opc:01 111000:111000 size:10
	.inst 0xba538be1 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0001 0:0 Rn:31 10:10 cond:1000 imm5:10011 111010010:111010010 op:0 sf:1
	.inst 0xe20187e2 // ALDURB-R.RI-32 Rt:2 Rn:31 op2:01 imm9:000011000 V:0 op1:00 11100010:11100010
	.inst 0x3a562005 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0101 0:0 Rn:0 00:00 cond:0010 Rm:22 111010010:111010010 op:0 sf:0
	.inst 0xc2c23243 // BLRR-C-C 00011:00011 Cn:18 100:100 opc:01 11000010110000100:11000010110000100
	.zero 24484
	.inst 0xc2c2c2c2
	.zero 794672
	.inst 0xc2c210a0
	.zero 229372
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x25, cptr_el3
	orr x25, x25, #0x200
	msr cptr_el3, x25
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400722 // ldr c2, [x25, #1]
	.inst 0xc2400b2d // ldr c13, [x25, #2]
	.inst 0xc2400f32 // ldr c18, [x25, #3]
	.inst 0xc2401337 // ldr c23, [x25, #4]
	/* Set up flags and system registers */
	mov x25, #0x60000000
	msr nzcv, x25
	ldr x25, =initial_csp_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	ldr x25, =0x80
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b9 // ldr c25, [c5, #3]
	.inst 0xc28b4139 // msr ddc_el3, c25
	isb
	.inst 0x826010b9 // ldr c25, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr ddc_el3, c25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x5, #0xf
	and x25, x25, x5
	cmp x25, #0x5
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400325 // ldr c5, [x25, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400725 // ldr c5, [x25, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400b25 // ldr c5, [x25, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400f25 // ldr c5, [x25, #3]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc2401325 // ldr c5, [x25, #4]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2401725 // ldr c5, [x25, #5]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2401b25 // ldr c5, [x25, #6]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2401f25 // ldr c5, [x25, #7]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0xc2c2c2c2c2c2c2c2
	mov x5, v14.d[0]
	cmp x25, x5
	b.ne comparison_fail
	ldr x25, =0x0
	mov x5, v14.d[1]
	cmp x25, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000013f8
	ldr x1, =check_data0
	ldr x2, =0x00001400
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001bb0
	ldr x1, =check_data1
	ldr x2, =0x00001bb8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bda
	ldr x1, =check_data2
	ldr x2, =0x00001bdb
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00405fcc
	ldr x1, =check_data4
	ldr x2, =0x00405fd0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004c8000
	ldr x1, =check_data5
	ldr x2, =0x004c8004
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
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr ddc_el3, c25
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
