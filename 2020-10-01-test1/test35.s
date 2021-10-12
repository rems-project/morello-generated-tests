.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 3
.data
check_data3:
	.byte 0x30, 0x7c, 0x3f, 0x42, 0x06, 0x69, 0xde, 0xc2, 0x5f, 0xd8, 0x65, 0x62, 0xcd, 0x87, 0x9e, 0x34
	.byte 0x3e, 0xf0, 0xc5, 0xc2, 0x22, 0x44, 0xc1, 0xc2, 0xc3, 0xd5, 0x09, 0x78, 0x0a, 0x68, 0xa1, 0x78
	.byte 0xe1, 0x77, 0x7a, 0x82, 0x4a, 0x7c, 0x33, 0x9b, 0x20, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000400000040000000000401000
	/* C1 */
	.octa 0x2000000000000070000000000001000
	/* C2 */
	.octa 0x80100000400000040000000000001750
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0xffffffff
	/* C14 */
	.octa 0x40000000000100050000000000001ffc
	/* C16 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x80000000400000040000000000401000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x2000000000000070000000000001000
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0xffffffff
	/* C14 */
	.octa 0x40000000000100050000000000002099
	/* C16 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000f80830000000000001000
initial_csp_value:
	.octa 0x1e57
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000f80830000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000040000c2100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001400
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x423f7c30 // ASTLRB-R.R-B Rt:16 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2de6906 // ORRFLGS-C.CR-C Cd:6 Cn:8 1010:1010 opc:01 Rm:30 11000010110:11000010110
	.inst 0x6265d85f // LDNP-C.RIB-C Ct:31 Rn:2 Ct2:10110 imm7:1001011 L:1 011000100:011000100
	.inst 0x349e87cd // cbz:aarch64/instrs/branch/conditional/compare Rt:13 imm19:1001111010000111110 op:0 011010:011010 sf:0
	.inst 0xc2c5f03e // CVTPZ-C.R-C Cd:30 Rn:1 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xc2c14422 // CSEAL-C.C-C Cd:2 Cn:1 001:001 opc:10 0:0 Cm:1 11000010110:11000010110
	.inst 0x7809d5c3 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:3 Rn:14 01:01 imm9:010011101 0:0 opc:00 111000:111000 size:01
	.inst 0x78a1680a // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:10 Rn:0 10:10 S:0 option:011 Rm:1 1:1 opc:10 111000:111000 size:01
	.inst 0x827a77e1 // ALDRB-R.RI-B Rt:1 Rn:31 op:01 imm9:110100111 L:1 1000001001:1000001001
	.inst 0x9b337c4a // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:10 Rn:2 Ra:31 o0:0 Rm:19 01:01 U:0 10011011:10011011
	.inst 0xc2c21220
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a2 // ldr c2, [x5, #2]
	.inst 0xc2400ca3 // ldr c3, [x5, #3]
	.inst 0xc24010a8 // ldr c8, [x5, #4]
	.inst 0xc24014ad // ldr c13, [x5, #5]
	.inst 0xc24018ae // ldr c14, [x5, #6]
	.inst 0xc2401cb0 // ldr c16, [x5, #7]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_csp_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603225 // ldr c5, [c17, #3]
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	.inst 0x82601225 // ldr c5, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x17, #0xf
	and x5, x5, x17
	cmp x5, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b1 // ldr c17, [x5, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24004b1 // ldr c17, [x5, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24008b1 // ldr c17, [x5, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400cb1 // ldr c17, [x5, #3]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc24010b1 // ldr c17, [x5, #4]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc24014b1 // ldr c17, [x5, #5]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc24018b1 // ldr c17, [x5, #6]
	.inst 0xc2d1a5c1 // chkeq c14, c17
	b.ne comparison_fail
	.inst 0xc2401cb1 // ldr c17, [x5, #7]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc24020b1 // ldr c17, [x5, #8]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc24024b1 // ldr c17, [x5, #9]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
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
	ldr x0, =0x00402000
	ldr x1, =check_data4
	ldr x2, =0x00402002
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
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
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
