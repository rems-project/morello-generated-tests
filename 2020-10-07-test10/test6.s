.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x32
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x00, 0x14
.data
check_data7:
	.byte 0xfe, 0xb3, 0x30, 0xe2, 0x9f, 0x5d, 0x06, 0x38, 0x5e, 0xef, 0xe5, 0x69, 0x49, 0xa0, 0x15, 0x38
	.byte 0x16, 0x08, 0x18, 0x38, 0x5e, 0xd0, 0xba, 0xe2, 0x6f, 0xa3, 0x7e, 0x30, 0x02, 0xfc, 0x9f, 0x48
	.byte 0xfd, 0x40, 0xf8, 0x82, 0x3f, 0x30, 0xef, 0xc2, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000400200040000000000001800
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C2 */
	.octa 0x400000002007000d0000000000001400
	/* C7 */
	.octa 0xffffffff80000805
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x40000000000700040000000000001040
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x80000c10
	/* C26 */
	.octa 0x800000000001000700000000004000d4
final_cap_values:
	/* C0 */
	.octa 0x40000000400200040000000000001800
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C2 */
	.octa 0x400000002007000d0000000000001400
	/* C7 */
	.octa 0xffffffff80000805
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x400000000007000400000000000010a5
	/* C15 */
	.octa 0x200080004404000000000000004fd485
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x80000c10
	/* C26 */
	.octa 0x80000000000100070000000000400000
	/* C27 */
	.octa 0x38065d9f
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xffffffffe230b3fe
initial_SP_EL3_value:
	.octa 0x1830
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440400000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004000001300ffffffffffeb83
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe230b3fe // ASTUR-V.RI-B Rt:30 Rn:31 op2:00 imm9:100001011 V:1 op1:00 11100010:11100010
	.inst 0x38065d9f // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:12 11:11 imm9:001100101 0:0 opc:00 111000:111000 size:00
	.inst 0x69e5ef5e // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:30 Rn:26 Rt2:11011 imm7:1001011 L:1 1010011:1010011 opc:01
	.inst 0x3815a049 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:9 Rn:2 00:00 imm9:101011010 0:0 opc:00 111000:111000 size:00
	.inst 0x38180816 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:22 Rn:0 10:10 imm9:110000000 0:0 opc:00 111000:111000 size:00
	.inst 0xe2bad05e // ASTUR-V.RI-S Rt:30 Rn:2 op2:00 imm9:110101101 V:1 op1:10 11100010:11100010
	.inst 0x307ea36f // ADR-C.I-C Rd:15 immhi:111111010100011011 P:0 10000:10000 immlo:01 op:0
	.inst 0x489ffc02 // stlrh:aarch64/instrs/memory/ordered Rt:2 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x82f840fd // ALDR-R.RRB-32 Rt:29 Rn:7 opc:00 S:0 option:010 Rm:24 1:1 L:1 100000101:100000101
	.inst 0xc2ef303f // EORFLGS-C.CI-C Cd:31 Cn:1 0:0 10:10 imm8:01111001 11000010111:11000010111
	.inst 0xc2c21060
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2400cc7 // ldr c7, [x6, #3]
	.inst 0xc24010c9 // ldr c9, [x6, #4]
	.inst 0xc24014cc // ldr c12, [x6, #5]
	.inst 0xc24018d6 // ldr c22, [x6, #6]
	.inst 0xc2401cd8 // ldr c24, [x6, #7]
	.inst 0xc24020da // ldr c26, [x6, #8]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q30, =0x32000000
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x3085003a
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603066 // ldr c6, [c3, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601066 // ldr c6, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c3 // ldr c3, [x6, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24004c3 // ldr c3, [x6, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24008c3 // ldr c3, [x6, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400cc3 // ldr c3, [x6, #3]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc24010c3 // ldr c3, [x6, #4]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc24014c3 // ldr c3, [x6, #5]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc24018c3 // ldr c3, [x6, #6]
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	.inst 0xc2401cc3 // ldr c3, [x6, #7]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc24020c3 // ldr c3, [x6, #8]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc24024c3 // ldr c3, [x6, #9]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc24028c3 // ldr c3, [x6, #10]
	.inst 0xc2c3a761 // chkeq c27, c3
	b.ne comparison_fail
	.inst 0xc2402cc3 // ldr c3, [x6, #11]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc24030c3 // ldr c3, [x6, #12]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x32000000
	mov x3, v30.d[0]
	cmp x6, x3
	b.ne comparison_fail
	ldr x6, =0x0
	mov x3, v30.d[1]
	cmp x6, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010a5
	ldr x1, =check_data0
	ldr x2, =0x000010a6
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000135a
	ldr x1, =check_data1
	ldr x2, =0x0000135b
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013c0
	ldr x1, =check_data2
	ldr x2, =0x000013c4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001428
	ldr x1, =check_data3
	ldr x2, =0x0000142c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0000174e
	ldr x1, =check_data4
	ldr x2, =0x0000174f
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001780
	ldr x1, =check_data5
	ldr x2, =0x00001781
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001800
	ldr x1, =check_data6
	ldr x2, =0x00001802
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
