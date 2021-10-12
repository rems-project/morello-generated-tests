.section data0, #alloc, #write
	.zero 208
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 160
	.byte 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3696
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x72, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data3:
	.byte 0x04
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x3f, 0x00, 0x00, 0xb2, 0x20, 0x12, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x52, 0x00, 0x40, 0x00, 0xfa
.data
check_data6:
	.byte 0x1f, 0x60, 0x52, 0x38, 0x8d, 0x8f, 0x09, 0xb8, 0x41, 0x7c, 0x58, 0x62, 0x00, 0xfc, 0xdf, 0x08
	.byte 0x3d, 0x48, 0xde, 0xc2, 0xdf, 0x27, 0xdf, 0x9a, 0x82, 0xce, 0x4c, 0xc2, 0x21, 0xc8, 0x20, 0x38
	.byte 0xe9, 0xba, 0x32, 0x62, 0x3f, 0x00, 0x00, 0xba, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1180
	/* C2 */
	.octa 0xdcc
	/* C9 */
	.octa 0x400000001220b200003f00000000
	/* C13 */
	.octa 0x72000000
	/* C14 */
	.octa 0xfa004000522400000000000000000000
	/* C20 */
	.octa 0xffffffffffffe00c
	/* C23 */
	.octa 0x202c
	/* C28 */
	.octa 0xf68
	/* C30 */
	.octa 0x4000000000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x4
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x400000001220b200003f00000000
	/* C13 */
	.octa 0x72000000
	/* C14 */
	.octa 0xfa004000522400000000000000000000
	/* C20 */
	.octa 0xffffffffffffe00c
	/* C23 */
	.octa 0x202c
	/* C28 */
	.octa 0x1000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x4000000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc81000005f22000400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010d0
	.dword 0x00000000000010e0
	.dword 0x0000000000001340
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3852601f // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:0 00:00 imm9:100100110 0:0 opc:01 111000:111000 size:00
	.inst 0xb8098f8d // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:13 Rn:28 11:11 imm9:010011000 0:0 opc:00 111000:111000 size:10
	.inst 0x62587c41 // LDNP-C.RIB-C Ct:1 Rn:2 Ct2:11111 imm7:0110000 L:1 011000100:011000100
	.inst 0x08dffc00 // ldarb:aarch64/instrs/memory/ordered Rt:0 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2de483d // UNSEAL-C.CC-C Cd:29 Cn:1 0010:0010 opc:01 Cm:30 11000010110:11000010110
	.inst 0x9adf27df // lsrv:aarch64/instrs/integer/shift/variable Rd:31 Rn:30 op2:01 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0xc24cce82 // LDR-C.RIB-C Ct:2 Rn:20 imm12:001100110011 L:1 110000100:110000100
	.inst 0x3820c821 // strb_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:1 10:10 S:0 option:110 Rm:0 1:1 opc:00 111000:111000 size:00
	.inst 0x6232bae9 // STNP-C.RIB-C Ct:9 Rn:23 Ct2:01110 imm7:1100101 L:0 011000100:011000100
	.inst 0xba00003f // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:1 000000:000000 Rm:0 11010000:11010000 S:1 op:0 sf:1
	.inst 0xc2c21220
	.zero 1048532
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
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400869 // ldr c9, [x3, #2]
	.inst 0xc2400c6d // ldr c13, [x3, #3]
	.inst 0xc240106e // ldr c14, [x3, #4]
	.inst 0xc2401474 // ldr c20, [x3, #5]
	.inst 0xc2401877 // ldr c23, [x3, #6]
	.inst 0xc2401c7c // ldr c28, [x3, #7]
	.inst 0xc240207e // ldr c30, [x3, #8]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603223 // ldr c3, [c17, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601223 // ldr c3, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
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
	mov x17, #0xf
	and x3, x3, x17
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400071 // ldr c17, [x3, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400471 // ldr c17, [x3, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400871 // ldr c17, [x3, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400c71 // ldr c17, [x3, #3]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc2401071 // ldr c17, [x3, #4]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc2401471 // ldr c17, [x3, #5]
	.inst 0xc2d1a5c1 // chkeq c14, c17
	b.ne comparison_fail
	.inst 0xc2401871 // ldr c17, [x3, #6]
	.inst 0xc2d1a681 // chkeq c20, c17
	b.ne comparison_fail
	.inst 0xc2401c71 // ldr c17, [x3, #7]
	.inst 0xc2d1a6e1 // chkeq c23, c17
	b.ne comparison_fail
	.inst 0xc2402071 // ldr c17, [x3, #8]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	.inst 0xc2402471 // ldr c17, [x3, #9]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402871 // ldr c17, [x3, #10]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001009
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010aa
	ldr x1, =check_data1
	ldr x2, =0x000010ab
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010d0
	ldr x1, =check_data2
	ldr x2, =0x000010f0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001184
	ldr x1, =check_data3
	ldr x2, =0x00001185
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001340
	ldr x1, =check_data4
	ldr x2, =0x00001350
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001e80
	ldr x1, =check_data5
	ldr x2, =0x00001ea0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
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
