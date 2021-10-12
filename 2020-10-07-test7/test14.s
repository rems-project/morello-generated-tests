.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xbe, 0x7e, 0x3f, 0x42, 0xe0, 0x23, 0x5b, 0xbc, 0x00, 0x00, 0x1f, 0xd6
.data
check_data5:
	.byte 0x3f, 0x98, 0x4c, 0x69, 0xff, 0xcb, 0x44, 0x38, 0xb6, 0xfa, 0xc5, 0xc2, 0x60, 0x02, 0x1e, 0x5a
	.byte 0x42, 0x90, 0xc5, 0xc2, 0xdf, 0x4e, 0xe0, 0x82, 0x37, 0x4a, 0x22, 0xf8, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x480000
	/* C1 */
	.octa 0x80000000000100050000000000001830
	/* C2 */
	.octa 0x1000
	/* C17 */
	.octa 0x40000000000100050000000000000000
	/* C19 */
	.octa 0x4fdfcb
	/* C21 */
	.octa 0x600030000000000001ffe
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x4fdfca
	/* C1 */
	.octa 0x80000000000100050000000000001830
	/* C2 */
	.octa 0xc0000000000100050000000000001000
	/* C6 */
	.octa 0x0
	/* C17 */
	.octa 0x40000000000100050000000000000000
	/* C19 */
	.octa 0x4fdfcb
	/* C21 */
	.octa 0x600030000000000001ffe
	/* C22 */
	.octa 0x60ae1ffe0000000000001ffe
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000200010000000000001fb2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x423f7ebe // ASTLRB-R.R-B Rt:30 Rn:21 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xbc5b23e0 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:0 Rn:31 00:00 imm9:110110010 0:0 opc:01 111100:111100 size:10
	.inst 0xd61f0000 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 524276
	.inst 0x694c983f // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:1 Rt2:00110 imm7:0011001 L:1 1010010:1010010 opc:01
	.inst 0x3844cbff // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:31 10:10 imm9:001001100 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c5fab6 // SCBNDS-C.CI-S Cd:22 Cn:21 1110:1110 S:1 imm6:001011 11000010110:11000010110
	.inst 0x5a1e0260 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:19 000000:000000 Rm:30 11010000:11010000 S:0 op:1 sf:0
	.inst 0xc2c59042 // CVTD-C.R-C Cd:2 Rn:2 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x82e04edf // ALDR-V.RRB-S Rt:31 Rn:22 opc:11 S:0 option:010 Rm:0 1:1 L:1 100000101:100000101
	.inst 0xf8224a37 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:23 Rn:17 10:10 S:0 option:010 Rm:2 1:1 opc:00 111000:111000 size:11
	.inst 0xc2c210a0
	.zero 524256
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400862 // ldr c2, [x3, #2]
	.inst 0xc2400c71 // ldr c17, [x3, #3]
	.inst 0xc2401073 // ldr c19, [x3, #4]
	.inst 0xc2401475 // ldr c21, [x3, #5]
	.inst 0xc2401877 // ldr c23, [x3, #6]
	.inst 0xc2401c7e // ldr c30, [x3, #7]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0x8
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030a3 // ldr c3, [c5, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x826010a3 // ldr c3, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x5, #0x2
	and x3, x3, x5
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400065 // ldr c5, [x3, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400465 // ldr c5, [x3, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400865 // ldr c5, [x3, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400c65 // ldr c5, [x3, #3]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2401065 // ldr c5, [x3, #4]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2401465 // ldr c5, [x3, #5]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2401865 // ldr c5, [x3, #6]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2401c65 // ldr c5, [x3, #7]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc2402065 // ldr c5, [x3, #8]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2402465 // ldr c5, [x3, #9]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x5, v0.d[0]
	cmp x3, x5
	b.ne comparison_fail
	ldr x3, =0x0
	mov x5, v0.d[1]
	cmp x3, x5
	b.ne comparison_fail
	ldr x3, =0x0
	mov x5, v31.d[0]
	cmp x3, x5
	b.ne comparison_fail
	ldr x3, =0x0
	mov x5, v31.d[1]
	cmp x3, x5
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
	ldr x0, =0x00001894
	ldr x1, =check_data1
	ldr x2, =0x0000189c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f64
	ldr x1, =check_data2
	ldr x2, =0x00001f68
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040000c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00480000
	ldr x1, =check_data5
	ldr x2, =0x00480020
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004fffc8
	ldr x1, =check_data6
	ldr x2, =0x004fffcc
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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
