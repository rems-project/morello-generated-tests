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
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x22, 0x0c, 0xc0, 0x1a, 0x62, 0xc7, 0x46, 0x38, 0x1d, 0x8a, 0x07, 0x29, 0x34, 0x60, 0xd8, 0xc2
	.byte 0xc4, 0xc3, 0x44, 0xfa, 0xe0, 0x48, 0xea, 0xc2, 0xc2, 0x11, 0x4d, 0x38, 0x4b, 0xc0, 0xdf, 0xc2
	.byte 0xe1, 0x54, 0xdb, 0xe2, 0xae, 0x7a, 0x5f, 0xcb, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4001c8150080000000000000
	/* C7 */
	.octa 0x10a3
	/* C14 */
	.octa 0x80000000000100050000000000001f2d
	/* C16 */
	.octa 0x4000000040020003000000000000100c
	/* C24 */
	.octa 0x80000000000007c0
	/* C27 */
	.octa 0x800000000001000700000000000012ac
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x52000000000010a3
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x10a3
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x4000000040020003000000000000100c
	/* C20 */
	.octa 0x4001c8157f7fffffffffcfd5
	/* C24 */
	.octa 0x80000000000007c0
	/* C27 */
	.octa 0x80000000000100070000000000001318
	/* C29 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000610070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1ac00c22 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:2 Rn:1 o1:1 00001:00001 Rm:0 0011010110:0011010110 sf:0
	.inst 0x3846c762 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:27 01:01 imm9:001101100 0:0 opc:01 111000:111000 size:00
	.inst 0x29078a1d // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:29 Rn:16 Rt2:00010 imm7:0001111 L:0 1010010:1010010 opc:00
	.inst 0xc2d86034 // SCOFF-C.CR-C Cd:20 Cn:1 000:000 opc:11 0:0 Rm:24 11000010110:11000010110
	.inst 0xfa44c3c4 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0100 0:0 Rn:30 00:00 cond:1100 Rm:4 111010010:111010010 op:1 sf:1
	.inst 0xc2ea48e0 // ORRFLGS-C.CI-C Cd:0 Cn:7 0:0 01:01 imm8:01010010 11000010111:11000010111
	.inst 0x384d11c2 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:14 00:00 imm9:011010001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2dfc04b // CVT-R.CC-C Rd:11 Cn:2 110000:110000 Cm:31 11000010110:11000010110
	.inst 0xe2db54e1 // ALDUR-R.RI-64 Rt:1 Rn:7 op2:01 imm9:110110101 V:0 op1:11 11100010:11100010
	.inst 0xcb5f7aae // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:14 Rn:21 imm6:011110 Rm:31 0:0 shift:01 01011:01011 S:0 op:1 sf:1
	.inst 0xc2c212e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a27 // ldr c7, [x17, #2]
	.inst 0xc2400e2e // ldr c14, [x17, #3]
	.inst 0xc2401230 // ldr c16, [x17, #4]
	.inst 0xc2401638 // ldr c24, [x17, #5]
	.inst 0xc2401a3b // ldr c27, [x17, #6]
	.inst 0xc2401e3d // ldr c29, [x17, #7]
	/* Set up flags and system registers */
	mov x17, #0x80000000
	msr nzcv, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850032
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f1 // ldr c17, [c23, #3]
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	.inst 0x826012f1 // ldr c17, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x23, #0xf
	and x17, x17, x23
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400237 // ldr c23, [x17, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400637 // ldr c23, [x17, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a37 // ldr c23, [x17, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400e37 // ldr c23, [x17, #3]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2401237 // ldr c23, [x17, #4]
	.inst 0xc2d7a561 // chkeq c11, c23
	b.ne comparison_fail
	.inst 0xc2401637 // ldr c23, [x17, #5]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2401a37 // ldr c23, [x17, #6]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2401e37 // ldr c23, [x17, #7]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc2402237 // ldr c23, [x17, #8]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2402637 // ldr c23, [x17, #9]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001048
	ldr x1, =check_data0
	ldr x2, =0x00001050
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001058
	ldr x1, =check_data1
	ldr x2, =0x00001060
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012ac
	ldr x1, =check_data2
	ldr x2, =0x000012ad
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
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
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
