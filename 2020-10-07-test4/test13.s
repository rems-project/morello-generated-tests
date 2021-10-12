.section data0, #alloc, #write
	.zero 2640
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.zero 1408
	.byte 0x05, 0x1a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x05, 0x1a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0x80, 0x62, 0x9c, 0x82, 0x4f, 0x00, 0xc9, 0x78, 0xe8, 0x47, 0x87, 0x29, 0xe1, 0xda, 0x73, 0xa2
	.byte 0xb7, 0x10, 0xc0, 0xc2, 0x18, 0xc8, 0xc2, 0x82, 0x1f, 0x88, 0x03, 0xd1, 0x5e, 0xc0, 0x85, 0x38
	.byte 0x32, 0xbc, 0xc4, 0xe2, 0x56, 0xfc, 0xdf, 0x48, 0x40, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
check_data7:
	.zero 1
.data
check_data8:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffffb7be00
	/* C2 */
	.octa 0x800000005f044f640000000000485e4c
	/* C5 */
	.octa 0x400000000000000000000000
	/* C8 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x1fe
	/* C20 */
	.octa 0x230
	/* C23 */
	.octa 0x800000000201c0050000000000000000
	/* C28 */
	.octa 0x1370
final_cap_values:
	/* C0 */
	.octa 0xffffffffffb7be00
	/* C1 */
	.octa 0x1a05
	/* C2 */
	.octa 0x800000005f044f640000000000485e4c
	/* C5 */
	.octa 0x400000000000000000000000
	/* C8 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x1000000000000000000000000
	/* C19 */
	.octa 0x1fe
	/* C20 */
	.octa 0x230
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x1370
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x400000000007000700000000000019e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000880c0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd000000040040009000000000000a001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001a50
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x829c6280 // ASTRB-R.RRB-B Rt:0 Rn:20 opc:00 S:0 option:011 Rm:28 0:0 L:0 100000101:100000101
	.inst 0x78c9004f // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:15 Rn:2 00:00 imm9:010010000 0:0 opc:11 111000:111000 size:01
	.inst 0x298747e8 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:8 Rn:31 Rt2:10001 imm7:0001110 L:0 1010011:1010011 opc:00
	.inst 0xa273dae1 // LDR-C.RRB-C Ct:1 Rn:23 10:10 S:1 option:110 Rm:19 1:1 opc:01 10100010:10100010
	.inst 0xc2c010b7 // GCBASE-R.C-C Rd:23 Cn:5 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x82c2c818 // ALDRSH-R.RRB-32 Rt:24 Rn:0 opc:10 S:0 option:110 Rm:2 0:0 L:1 100000101:100000101
	.inst 0xd103881f // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:0 imm12:000011100010 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x3885c05e // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:2 00:00 imm9:001011100 0:0 opc:10 111000:111000 size:00
	.inst 0xe2c4bc32 // ALDUR-C.RI-C Ct:18 Rn:1 op2:11 imm9:001001011 V:0 op1:11 11100010:11100010
	.inst 0x48dffc56 // ldarh:aarch64/instrs/memory/ordered Rt:22 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c21340
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
	.inst 0xc2400865 // ldr c5, [x3, #2]
	.inst 0xc2400c68 // ldr c8, [x3, #3]
	.inst 0xc2401071 // ldr c17, [x3, #4]
	.inst 0xc2401473 // ldr c19, [x3, #5]
	.inst 0xc2401874 // ldr c20, [x3, #6]
	.inst 0xc2401c77 // ldr c23, [x3, #7]
	.inst 0xc240207c // ldr c28, [x3, #8]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x3085003a
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603343 // ldr c3, [c26, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601343 // ldr c3, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240007a // ldr c26, [x3, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240047a // ldr c26, [x3, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240087a // ldr c26, [x3, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400c7a // ldr c26, [x3, #3]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc240107a // ldr c26, [x3, #4]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc240147a // ldr c26, [x3, #5]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc240187a // ldr c26, [x3, #6]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc2401c7a // ldr c26, [x3, #7]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc240207a // ldr c26, [x3, #8]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc240247a // ldr c26, [x3, #9]
	.inst 0xc2daa681 // chkeq c20, c26
	b.ne comparison_fail
	.inst 0xc240287a // ldr c26, [x3, #10]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc2402c7a // ldr c26, [x3, #11]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc240307a // ldr c26, [x3, #12]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc240347a // ldr c26, [x3, #13]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc240387a // ldr c26, [x3, #14]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000015a0
	ldr x1, =check_data0
	ldr x2, =0x000015a1
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001a18
	ldr x1, =check_data1
	ldr x2, =0x00001a20
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a50
	ldr x1, =check_data2
	ldr x2, =0x00001a60
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c4c
	ldr x1, =check_data3
	ldr x2, =0x00001c4e
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001ff0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00485e4c
	ldr x1, =check_data6
	ldr x2, =0x00485e4e
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00485ea8
	ldr x1, =check_data7
	ldr x2, =0x00485ea9
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00485edc
	ldr x1, =check_data8
	ldr x2, =0x00485ede
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
