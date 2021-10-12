.section data0, #alloc, #write
	.zero 80
	.byte 0x00, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x48, 0x00, 0x80, 0x00, 0x20
	.zero 3840
	.byte 0x00, 0x00, 0x00, 0x00, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 144
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
	.byte 0x00, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x48, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.byte 0xf0, 0x00, 0x00, 0x00
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0xbf, 0x79, 0xd8, 0xa8, 0x41, 0x10, 0x38, 0x9b, 0xe1, 0x33, 0x81, 0xb8, 0x89, 0x37, 0xa2, 0x8a
	.byte 0x6d, 0xcc, 0xec, 0x82, 0x41, 0xe8, 0x14, 0x29, 0x3f, 0xa0, 0x5d, 0x38, 0x16, 0x30, 0xc4, 0xc2
.data
check_data7:
	.byte 0x6b, 0xfc, 0x9f, 0x48, 0xf8, 0x93, 0xc5, 0xc2, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x9010000060020b440000000000001040
	/* C2 */
	.octa 0xb
	/* C3 */
	.octa 0x800000005404080c00000000000000af
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0xf61
	/* C13 */
	.octa 0x1067
	/* C26 */
	.octa 0x400000
final_cap_values:
	/* C0 */
	.octa 0x9010000060020b440000000000001040
	/* C1 */
	.octa 0xf0
	/* C2 */
	.octa 0xb
	/* C3 */
	.octa 0x800000005404080c00000000000000af
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0xf61
	/* C13 */
	.octa 0x11e7
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0xc00000005fcc0f510000000000000f51
	/* C26 */
	.octa 0x400000
	/* C30 */
	.octa 0x20008000000100050000000000400020
initial_csp_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005fcc0f510000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001040
	.dword 0x0000000000001050
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa8d879bf // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:31 Rn:13 Rt2:11110 imm7:0110000 L:1 1010001:1010001 opc:10
	.inst 0x9b381041 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:2 Ra:4 o0:0 Rm:24 01:01 U:0 10011011:10011011
	.inst 0xb88133e1 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:31 00:00 imm9:000010011 0:0 opc:10 111000:111000 size:10
	.inst 0x8aa23789 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:9 Rn:28 imm6:001101 Rm:2 N:1 shift:10 01010:01010 opc:00 sf:1
	.inst 0x82eccc6d // ALDR-V.RRB-S Rt:13 Rn:3 opc:11 S:0 option:110 Rm:12 1:1 L:1 100000101:100000101
	.inst 0x2914e841 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:1 Rn:2 Rt2:11010 imm7:0101001 L:0 1010010:1010010 opc:00
	.inst 0x385da03f // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:1 00:00 imm9:111011010 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c43016 // LDPBLR-C.C-C Ct:22 Cn:0 100:100 opc:01 11000010110001000:11000010110001000
	.zero 480
	.inst 0x489ffc6b // stlrh:aarch64/instrs/memory/ordered Rt:11 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c593f8 // CVTD-C.R-C Cd:24 Rn:31 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c21360
	.zero 1048052
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
	.inst 0xc2400682 // ldr c2, [x20, #1]
	.inst 0xc2400a83 // ldr c3, [x20, #2]
	.inst 0xc2400e8b // ldr c11, [x20, #3]
	.inst 0xc240128c // ldr c12, [x20, #4]
	.inst 0xc240168d // ldr c13, [x20, #5]
	.inst 0xc2401a9a // ldr c26, [x20, #6]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_csp_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850038
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603374 // ldr c20, [c27, #3]
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	.inst 0x82601374 // ldr c20, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240029b // ldr c27, [x20, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240069b // ldr c27, [x20, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400a9b // ldr c27, [x20, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400e9b // ldr c27, [x20, #3]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc240129b // ldr c27, [x20, #4]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc240169b // ldr c27, [x20, #5]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc2401a9b // ldr c27, [x20, #6]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc2401e9b // ldr c27, [x20, #7]
	.inst 0xc2dba6c1 // chkeq c22, c27
	b.ne comparison_fail
	.inst 0xc240229b // ldr c27, [x20, #8]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc240269b // ldr c27, [x20, #9]
	.inst 0xc2dba741 // chkeq c26, c27
	b.ne comparison_fail
	.inst 0xc2402a9b // ldr c27, [x20, #10]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x27, v13.d[0]
	cmp x20, x27
	b.ne comparison_fail
	ldr x20, =0x0
	mov x27, v13.d[1]
	cmp x20, x27
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000101b
	ldr x1, =check_data2
	ldr x2, =0x0000101c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001040
	ldr x1, =check_data3
	ldr x2, =0x00001060
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f64
	ldr x1, =check_data4
	ldr x2, =0x00001f68
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fb8
	ldr x1, =check_data5
	ldr x2, =0x00001fc8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400020
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400200
	ldr x1, =check_data7
	ldr x2, =0x0040020c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
