.section data0, #alloc, #write
	.zero 1040
	.byte 0x01, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 3040
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 16
	.byte 0x01, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0x61, 0x52, 0xc1, 0xc2, 0xa2, 0xfb, 0xd3, 0xc2, 0x9f, 0x7e, 0x1f, 0x42, 0x9e, 0x7b, 0xbf, 0xf8
	.byte 0x82, 0x4d, 0x3e, 0x0b, 0x6d, 0x12, 0xc1, 0xc2, 0xef, 0x67, 0xcb, 0x38, 0xc7, 0x83, 0x89, 0xe2
	.byte 0x02, 0x10, 0xc4, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xa3, 0x7e, 0xdf, 0xc8, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90100000000100070000000000001400
	/* C7 */
	.octa 0x0
	/* C19 */
	.octa 0x790070000000000000001
	/* C20 */
	.octa 0x1000
	/* C21 */
	.octa 0x80000000500000000000000000400000
	/* C29 */
	.octa 0x400000000000000000000000
	/* C30 */
	.octa 0x1370
final_cap_values:
	/* C0 */
	.octa 0x90100000000100070000000000001400
	/* C1 */
	.octa 0x79007
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xc2d3fba2c2c15261
	/* C7 */
	.octa 0x0
	/* C13 */
	.octa 0xffffffffffffffff
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x790070000000000000001
	/* C20 */
	.octa 0x1000
	/* C21 */
	.octa 0x80000000500000000000000000400000
	/* C29 */
	.octa 0x400000000000000000000000
	/* C30 */
	.octa 0x1370
initial_SP_EL3_value:
	.octa 0x800000002001c00500000000004106b9
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005c000002000000000000000b
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001410
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c15261 // CFHI-R.C-C Rd:1 Cn:19 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2d3fba2 // SCBNDS-C.CI-S Cd:2 Cn:29 1110:1110 S:1 imm6:100111 11000010110:11000010110
	.inst 0x421f7e9f // ASTLR-C.R-C Ct:31 Rn:20 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xf8bf7b9e // prfm_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:28 10:10 S:1 option:011 Rm:31 1:1 opc:10 111000:111000 size:11
	.inst 0x0b3e4d82 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:2 Rn:12 imm3:011 option:010 Rm:30 01011001:01011001 S:0 op:0 sf:0
	.inst 0xc2c1126d // GCLIM-R.C-C Rd:13 Cn:19 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x38cb67ef // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:15 Rn:31 01:01 imm9:010110110 0:0 opc:11 111000:111000 size:00
	.inst 0xe28983c7 // ASTUR-R.RI-32 Rt:7 Rn:30 op2:00 imm9:010011000 V:0 op1:10 11100010:11100010
	.inst 0xc2c41002 // LDPBR-C.C-C Ct:2 Cn:0 100:100 opc:00 11000010110001000:11000010110001000
	.zero 524252
	.inst 0xc8df7ea3 // ldlar:aarch64/instrs/memory/ordered Rt:3 Rn:21 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xc2c21160
	.zero 524280
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400507 // ldr c7, [x8, #1]
	.inst 0xc2400913 // ldr c19, [x8, #2]
	.inst 0xc2400d14 // ldr c20, [x8, #3]
	.inst 0xc2401115 // ldr c21, [x8, #4]
	.inst 0xc240151d // ldr c29, [x8, #5]
	.inst 0xc240191e // ldr c30, [x8, #6]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603168 // ldr c8, [c11, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601168 // ldr c8, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010b // ldr c11, [x8, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240050b // ldr c11, [x8, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240090b // ldr c11, [x8, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400d0b // ldr c11, [x8, #3]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc240110b // ldr c11, [x8, #4]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc240150b // ldr c11, [x8, #5]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240190b // ldr c11, [x8, #6]
	.inst 0xc2cba5e1 // chkeq c15, c11
	b.ne comparison_fail
	.inst 0xc2401d0b // ldr c11, [x8, #7]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc240210b // ldr c11, [x8, #8]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc240250b // ldr c11, [x8, #9]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc240290b // ldr c11, [x8, #10]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc2402d0b // ldr c11, [x8, #11]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001420
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400024
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004106b9
	ldr x1, =check_data3
	ldr x2, =0x004106ba
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00480000
	ldr x1, =check_data4
	ldr x2, =0x00480008
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
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
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
