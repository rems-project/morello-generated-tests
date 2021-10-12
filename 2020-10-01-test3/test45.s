.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xf9, 0x63, 0x50, 0xe2, 0xc1, 0xa8, 0xdf, 0xc2, 0x1e, 0x10, 0x4b, 0xf8, 0x9d, 0x03, 0x1f, 0xda
	.byte 0x6a, 0x48, 0xfe, 0x82, 0xa2, 0x06, 0x6d, 0x82, 0x1a, 0xa0, 0x70, 0xf1, 0x09, 0x0b, 0xce, 0xc2
	.byte 0x21, 0x24, 0xd3, 0xc2, 0x82, 0xd9, 0x7d, 0xb7, 0x00, 0x12, 0xc2, 0xc2
.data
check_data4:
	.byte 0x24, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000c0000000000000400007
	/* C3 */
	.octa 0xbdc
	/* C6 */
	.octa 0x80079eff0080000000006001
	/* C14 */
	.octa 0x2000000000100040000000000000000
	/* C19 */
	.octa 0x3000800000000000000000000000
	/* C21 */
	.octa 0x1006
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x800000000000c0000000000000400007
	/* C1 */
	.octa 0x80079eff0000000000006001
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xbdc
	/* C6 */
	.octa 0x80079eff0080000000006001
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x2000000000100040000000000000000
	/* C19 */
	.octa 0x3000800000000000000000000000
	/* C21 */
	.octa 0x1006
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0xffffffffff7d8007
	/* C30 */
	.octa 0x424
initial_csp_value:
	.octa 0x1400
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000580400ea00ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe25063f9 // ASTURH-R.RI-32 Rt:25 Rn:31 op2:00 imm9:100000110 V:0 op1:01 11100010:11100010
	.inst 0xc2dfa8c1 // EORFLGS-C.CR-C Cd:1 Cn:6 1010:1010 opc:10 Rm:31 11000010110:11000010110
	.inst 0xf84b101e // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:0 00:00 imm9:010110001 0:0 opc:01 111000:111000 size:11
	.inst 0xda1f039d // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:29 Rn:28 000000:000000 Rm:31 11010000:11010000 S:0 op:1 sf:1
	.inst 0x82fe486a // ALDR-V.RRB-D Rt:10 Rn:3 opc:10 S:0 option:010 Rm:30 1:1 L:1 100000101:100000101
	.inst 0x826d06a2 // ALDRB-R.RI-B Rt:2 Rn:21 op:01 imm9:011010000 L:1 1000001001:1000001001
	.inst 0xf170a01a // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:26 Rn:0 imm12:110000101000 sh:1 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0xc2ce0b09 // SEAL-C.CC-C Cd:9 Cn:24 0010:0010 opc:00 Cm:14 11000010110:11000010110
	.inst 0xc2d32421 // CPYTYPE-C.C-C Cd:1 Cn:1 001:001 opc:01 0:0 Cm:19 11000010110:11000010110
	.inst 0xb77dd982 // tbnz:aarch64/instrs/branch/conditional/test Rt:2 imm14:10111011001100 b40:01111 op:1 011011:011011 b5:1
	.inst 0xc2c21200
	.zero 140
	.inst 0x00000424
	.zero 1048388
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400683 // ldr c3, [x20, #1]
	.inst 0xc2400a86 // ldr c6, [x20, #2]
	.inst 0xc2400e8e // ldr c14, [x20, #3]
	.inst 0xc2401293 // ldr c19, [x20, #4]
	.inst 0xc2401695 // ldr c21, [x20, #5]
	.inst 0xc2401a98 // ldr c24, [x20, #6]
	.inst 0xc2401e99 // ldr c25, [x20, #7]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_csp_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	ldr x20, =0x0
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603214 // ldr c20, [c16, #3]
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	.inst 0x82601214 // ldr c20, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x16, #0xf
	and x20, x20, x16
	cmp x20, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400290 // ldr c16, [x20, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400690 // ldr c16, [x20, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400a90 // ldr c16, [x20, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400e90 // ldr c16, [x20, #3]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2401290 // ldr c16, [x20, #4]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2401690 // ldr c16, [x20, #5]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc2401a90 // ldr c16, [x20, #6]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2401e90 // ldr c16, [x20, #7]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc2402290 // ldr c16, [x20, #8]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc2402690 // ldr c16, [x20, #9]
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	.inst 0xc2402a90 // ldr c16, [x20, #10]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2402e90 // ldr c16, [x20, #11]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc2403290 // ldr c16, [x20, #12]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x16, v10.d[0]
	cmp x20, x16
	b.ne comparison_fail
	ldr x20, =0x0
	mov x16, v10.d[1]
	cmp x20, x16
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
	ldr x0, =0x000010d6
	ldr x1, =check_data1
	ldr x2, =0x000010d7
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001306
	ldr x1, =check_data2
	ldr x2, =0x00001308
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
	ldr x0, =0x004000b8
	ldr x1, =check_data4
	ldr x2, =0x004000c0
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr ddc_el3, c20
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
