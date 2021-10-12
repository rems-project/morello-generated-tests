.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0xbe, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x40, 0x70, 0xc0, 0xc2, 0x53, 0x68, 0x87, 0x8b, 0x01, 0x98, 0x16, 0xf8, 0xbf, 0x09, 0x20, 0x9b
	.byte 0xef, 0x33, 0xc7, 0xc2, 0x1c, 0x7f, 0xdf, 0x88, 0xfc, 0x2b, 0xdf, 0xc2, 0x4d, 0x15, 0x35, 0xe2
	.byte 0x3f, 0x8e, 0x0d, 0x82, 0xfd, 0xeb, 0x7c, 0xa2, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xbe00000000
	/* C2 */
	.octa 0xa200000000000001117
	/* C10 */
	.octa 0x80000000580210020000000000001440
	/* C24 */
	.octa 0x1b58
final_cap_values:
	/* C0 */
	.octa 0x1117
	/* C1 */
	.octa 0xbe00000000
	/* C2 */
	.octa 0xa200000000000001117
	/* C10 */
	.octa 0x80000000580210020000000000001440
	/* C15 */
	.octa 0xffffffffffffffff
	/* C24 */
	.octa 0x1b58
	/* C28 */
	.octa 0xfe0
	/* C29 */
	.octa 0x0
initial_csp_value:
	.octa 0xfe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0108000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fc0
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c07040 // GCOFF-R.C-C Rd:0 Cn:2 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x8b876853 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:19 Rn:2 imm6:011010 Rm:7 0:0 shift:10 01011:01011 S:0 op:0 sf:1
	.inst 0xf8169801 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:0 10:10 imm9:101101001 0:0 opc:00 111000:111000 size:11
	.inst 0x9b2009bf // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:13 Ra:2 o0:0 Rm:0 01:01 U:0 10011011:10011011
	.inst 0xc2c733ef // RRMASK-R.R-C Rd:15 Rn:31 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x88df7f1c // ldlar:aarch64/instrs/memory/ordered Rt:28 Rn:24 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xc2df2bfc // BICFLGS-C.CR-C Cd:28 Cn:31 1010:1010 opc:00 Rm:31 11000010110:11000010110
	.inst 0xe235154d // ALDUR-V.RI-B Rt:13 Rn:10 op2:01 imm9:101010001 V:1 op1:00 11100010:11100010
	.inst 0x820d8e3f // LDR-C.I-C Ct:31 imm17:00110110001110001 1000001000:1000001000
	.inst 0xa27cebfd // LDR-C.RRB-C Ct:29 Rn:31 10:10 S:0 option:111 Rm:28 1:1 opc:01 10100010:10100010
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400361 // ldr c1, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b6a // ldr c10, [x27, #2]
	.inst 0xc2400f78 // ldr c24, [x27, #3]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_csp_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x3085003a
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032bb // ldr c27, [c21, #3]
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	.inst 0x826012bb // ldr c27, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400375 // ldr c21, [x27, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400775 // ldr c21, [x27, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400b75 // ldr c21, [x27, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400f75 // ldr c21, [x27, #3]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401375 // ldr c21, [x27, #4]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2401775 // ldr c21, [x27, #5]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc2401b75 // ldr c21, [x27, #6]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc2401f75 // ldr c21, [x27, #7]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x21, v13.d[0]
	cmp x27, x21
	b.ne comparison_fail
	ldr x27, =0x0
	mov x21, v13.d[1]
	cmp x27, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x00001088
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001391
	ldr x1, =check_data1
	ldr x2, =0x00001392
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b58
	ldr x1, =check_data2
	ldr x2, =0x00001b5c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fc0
	ldr x1, =check_data3
	ldr x2, =0x00001fd0
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
	ldr x0, =0x0046c730
	ldr x1, =check_data5
	ldr x2, =0x0046c740
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
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
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
