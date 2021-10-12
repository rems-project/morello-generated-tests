.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xc0, 0x2b, 0xda, 0x9a, 0xe9, 0xef, 0x4f, 0xe2, 0x12, 0x13, 0xc5, 0xc2, 0xe0, 0xc7, 0xe0, 0x82
	.byte 0xfe, 0x47, 0xff, 0xe2, 0xb4, 0x89, 0xdf, 0xc2, 0x01, 0x14, 0x40, 0x6a, 0xde, 0x03, 0xd3, 0xc2
	.byte 0xc8, 0x61, 0xdb, 0xc2, 0xe1, 0xf9, 0x3e, 0x78, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C13 */
	.octa 0x4004c0050000000000000001
	/* C14 */
	.octa 0xa0040020000000000000
	/* C15 */
	.octa 0xffb8000000000000
	/* C24 */
	.octa 0x400
	/* C26 */
	.octa 0x30
	/* C27 */
	.octa 0x20000000000000
	/* C30 */
	.octa 0x300070024000000000800
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0xa0040020000000000000
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x4004c0050000000000000001
	/* C14 */
	.octa 0xa0040020000000000000
	/* C15 */
	.octa 0xffb8000000000000
	/* C18 */
	.octa 0x400
	/* C20 */
	.octa 0x4004c0050000000000000001
	/* C24 */
	.octa 0x400
	/* C26 */
	.octa 0x30
	/* C27 */
	.octa 0x20000000000000
initial_csp_value:
	.octa 0x800000003ff90007000000000040400c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000900070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000002000300e9000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 144
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ada2bc0 // asrv:aarch64/instrs/integer/shift/variable Rd:0 Rn:30 op2:10 0010:0010 Rm:26 0011010110:0011010110 sf:1
	.inst 0xe24fefe9 // ALDURSH-R.RI-32 Rt:9 Rn:31 op2:11 imm9:011111110 V:0 op1:01 11100010:11100010
	.inst 0xc2c51312 // CVTD-R.C-C Rd:18 Cn:24 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x82e0c7e0 // ALDR-R.RRB-64 Rt:0 Rn:31 opc:01 S:0 option:110 Rm:0 1:1 L:1 100000101:100000101
	.inst 0xe2ff47fe // ALDUR-V.RI-D Rt:30 Rn:31 op2:01 imm9:111110100 V:1 op1:11 11100010:11100010
	.inst 0xc2df89b4 // CHKSSU-C.CC-C Cd:20 Cn:13 0010:0010 opc:10 Cm:31 11000010110:11000010110
	.inst 0x6a401401 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:0 imm6:000101 Rm:0 N:0 shift:01 01010:01010 opc:11 sf:0
	.inst 0xc2d303de // SCBNDS-C.CR-C Cd:30 Cn:30 000:000 opc:00 0:0 Rm:19 11000010110:11000010110
	.inst 0xc2db61c8 // SCOFF-C.CR-C Cd:8 Cn:14 000:000 opc:11 0:0 Rm:27 11000010110:11000010110
	.inst 0x783ef9e1 // strh_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:15 10:10 S:1 option:111 Rm:30 1:1 opc:00 111000:111000 size:01
	.inst 0xc2c213a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x2, cptr_el3
	orr x2, x2, #0x200
	msr cptr_el3, x2
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
	ldr x2, =initial_cap_values
	.inst 0xc240004d // ldr c13, [x2, #0]
	.inst 0xc240044e // ldr c14, [x2, #1]
	.inst 0xc240084f // ldr c15, [x2, #2]
	.inst 0xc2400c58 // ldr c24, [x2, #3]
	.inst 0xc240105a // ldr c26, [x2, #4]
	.inst 0xc240145b // ldr c27, [x2, #5]
	.inst 0xc240185e // ldr c30, [x2, #6]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =initial_csp_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2c1d05f // cpy c31, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30850032
	msr SCTLR_EL3, x2
	ldr x2, =0x4
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033a2 // ldr c2, [c29, #3]
	.inst 0xc28b4122 // msr ddc_el3, c2
	isb
	.inst 0x826013a2 // ldr c2, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr ddc_el3, c2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x29, #0xf
	and x2, x2, x29
	cmp x2, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc240005d // ldr c29, [x2, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240045d // ldr c29, [x2, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc240085d // ldr c29, [x2, #2]
	.inst 0xc2dda501 // chkeq c8, c29
	b.ne comparison_fail
	.inst 0xc2400c5d // ldr c29, [x2, #3]
	.inst 0xc2dda521 // chkeq c9, c29
	b.ne comparison_fail
	.inst 0xc240105d // ldr c29, [x2, #4]
	.inst 0xc2dda5a1 // chkeq c13, c29
	b.ne comparison_fail
	.inst 0xc240145d // ldr c29, [x2, #5]
	.inst 0xc2dda5c1 // chkeq c14, c29
	b.ne comparison_fail
	.inst 0xc240185d // ldr c29, [x2, #6]
	.inst 0xc2dda5e1 // chkeq c15, c29
	b.ne comparison_fail
	.inst 0xc2401c5d // ldr c29, [x2, #7]
	.inst 0xc2dda641 // chkeq c18, c29
	b.ne comparison_fail
	.inst 0xc240205d // ldr c29, [x2, #8]
	.inst 0xc2dda681 // chkeq c20, c29
	b.ne comparison_fail
	.inst 0xc240245d // ldr c29, [x2, #9]
	.inst 0xc2dda701 // chkeq c24, c29
	b.ne comparison_fail
	.inst 0xc240285d // ldr c29, [x2, #10]
	.inst 0xc2dda741 // chkeq c26, c29
	b.ne comparison_fail
	.inst 0xc2402c5d // ldr c29, [x2, #11]
	.inst 0xc2dda761 // chkeq c27, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x2, =0x0
	mov x29, v30.d[0]
	cmp x2, x29
	b.ne comparison_fail
	ldr x2, =0x0
	mov x29, v30.d[1]
	cmp x2, x29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
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
	ldr x0, =0x00404000
	ldr x1, =check_data2
	ldr x2, =0x00404008
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00404030
	ldr x1, =check_data3
	ldr x2, =0x00404038
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040410a
	ldr x1, =check_data4
	ldr x2, =0x0040410c
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
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr ddc_el3, c2
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
