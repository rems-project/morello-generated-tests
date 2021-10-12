.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0x40, 0x34, 0x73, 0xe2, 0xc2, 0xb3, 0x48, 0x38, 0x41, 0xa8, 0xd2, 0xc2, 0x62, 0x48, 0x7f, 0x78
	.byte 0x1f, 0x98, 0x2c, 0x12, 0x23, 0x48, 0xf1, 0xc2, 0x70, 0x07, 0xc8, 0xc2, 0x1e, 0x40, 0x33, 0x2b
	.byte 0x29, 0x90, 0xc0, 0xc2, 0x08, 0x7c, 0x5f, 0x42, 0x20, 0x12, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004fffe0
	/* C2 */
	.octa 0x80000000400020240000000000402401
	/* C3 */
	.octa 0x4ffffc
	/* C8 */
	.octa 0x3000f00ffe00000000001
	/* C27 */
	.octa 0x720060000000000000000
	/* C30 */
	.octa 0x1f73
final_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004fffe0
	/* C2 */
	.octa 0xc2c2
	/* C8 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x720060000000000000000
	/* C27 */
	.octa 0x720060000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004600170000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2733440 // ALDUR-V.RI-H Rt:0 Rn:2 op2:01 imm9:100110011 V:1 op1:01 11100010:11100010
	.inst 0x3848b3c2 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:30 00:00 imm9:010001011 0:0 opc:01 111000:111000 size:00
	.inst 0xc2d2a841 // EORFLGS-C.CR-C Cd:1 Cn:2 1010:1010 opc:10 Rm:18 11000010110:11000010110
	.inst 0x787f4862 // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:3 10:10 S:0 option:010 Rm:31 1:1 opc:01 111000:111000 size:01
	.inst 0x122c981f // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:0 imms:100110 immr:101100 N:0 100100:100100 opc:00 sf:0
	.inst 0xc2f14823 // ORRFLGS-C.CI-C Cd:3 Cn:1 0:0 01:01 imm8:10001010 11000010111:11000010111
	.inst 0xc2c80770 // BUILD-C.C-C Cd:16 Cn:27 001:001 opc:00 0:0 Cm:8 11000010110:11000010110
	.inst 0x2b33401e // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:0 imm3:000 option:010 Rm:19 01011001:01011001 S:1 op:0 sf:0
	.inst 0xc2c09029 // GCTAG-R.C-C Rd:9 Cn:1 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x425f7c08 // ALDAR-C.R-C Ct:8 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c21220
	.zero 8968
	.inst 0x0000c2c2
	.zero 1039528
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 12
	.inst 0x0000c2c2
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400702 // ldr c2, [x24, #1]
	.inst 0xc2400b03 // ldr c3, [x24, #2]
	.inst 0xc2400f08 // ldr c8, [x24, #3]
	.inst 0xc240131b // ldr c27, [x24, #4]
	.inst 0xc240171e // ldr c30, [x24, #5]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850032
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603238 // ldr c24, [c17, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601238 // ldr c24, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400311 // ldr c17, [x24, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400711 // ldr c17, [x24, #1]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400b11 // ldr c17, [x24, #2]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc2400f11 // ldr c17, [x24, #3]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc2401311 // ldr c17, [x24, #4]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc2401711 // ldr c17, [x24, #5]
	.inst 0xc2d1a761 // chkeq c27, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0xc2c2
	mov x17, v0.d[0]
	cmp x24, x17
	b.ne comparison_fail
	ldr x24, =0x0
	mov x17, v0.d[1]
	cmp x24, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ffe
	ldr x1, =check_data0
	ldr x2, =0x00001fff
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00402334
	ldr x1, =check_data2
	ldr x2, =0x00402336
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004fffe0
	ldr x1, =check_data3
	ldr x2, =0x004ffff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffc
	ldr x1, =check_data4
	ldr x2, =0x004ffffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
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
