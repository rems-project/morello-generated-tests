.section data0, #alloc, #write
	.zero 16
	.byte 0x01, 0x04, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 640
	.byte 0x88, 0x00, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 3408
.data
check_data0:
	.byte 0x01, 0x04, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x88, 0x00, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x01, 0x01, 0x00, 0x04, 0x01, 0x01, 0x01, 0x02
.data
check_data4:
	.zero 12
.data
check_data5:
	.byte 0x02, 0xa4, 0x40, 0xc2, 0x3d, 0x14, 0x88, 0x72, 0xde, 0x33, 0xc5, 0xc2, 0xbf, 0x89, 0x19, 0xb8
	.byte 0x48, 0x48, 0x73, 0x69, 0xe1, 0x73, 0xd8, 0xc2
.data
check_data6:
	.byte 0x17, 0x8c, 0x05, 0x38, 0x7f, 0xd2, 0xd5, 0xe2, 0xc0, 0xeb, 0x25, 0x2b, 0x74, 0x3f, 0x92, 0x6d
	.byte 0x00, 0x12, 0xc2, 0xc2
.data
check_data7:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001010
	/* C13 */
	.octa 0x2060
	/* C19 */
	.octa 0x2093
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000000100050000000000001e08
	/* C30 */
	.octa 0x400
final_cap_values:
	/* C2 */
	.octa 0x101800000000000000000440088
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x2060
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x2093
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000000100050000000000001f28
	/* C30 */
	.octa 0x20008000800100060000000000400018
initial_SP_EL3_value:
	.octa 0x900000000001000500000000000013e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x00000000000012a0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc240a402 // LDR-C.RIB-C Ct:2 Rn:0 imm12:000000101001 L:1 110000100:110000100
	.inst 0x7288143d // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:29 imm16:0100000010100001 hw:00 100101:100101 opc:11 sf:0
	.inst 0xc2c533de // CVTP-R.C-C Rd:30 Cn:30 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xb81989bf // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:13 10:10 imm9:110011000 0:0 opc:00 111000:111000 size:10
	.inst 0x69734848 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:8 Rn:2 Rt2:10010 imm7:1100110 L:1 1010010:1010010 opc:01
	.inst 0xc2d873e1 // BLR-CI-C 1:1 0000:0000 Cn:31 100:100 imm7:1000011 110000101101:110000101101
	.zero 1000
	.inst 0x38058c17 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:23 Rn:0 11:11 imm9:001011000 0:0 opc:00 111000:111000 size:00
	.inst 0xe2d5d27f // ASTUR-R.RI-64 Rt:31 Rn:19 op2:00 imm9:101011101 V:0 op1:11 11100010:11100010
	.inst 0x2b25ebc0 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:30 imm3:010 option:111 Rm:5 01011001:01011001 S:1 op:0 sf:0
	.inst 0x6d923f74 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:20 Rn:27 Rt2:01111 imm7:0100100 L:0 1011011:1011011 opc:01
	.inst 0xc2c21200
	.zero 1047532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc240052d // ldr c13, [x9, #1]
	.inst 0xc2400933 // ldr c19, [x9, #2]
	.inst 0xc2400d37 // ldr c23, [x9, #3]
	.inst 0xc240113b // ldr c27, [x9, #4]
	.inst 0xc240153e // ldr c30, [x9, #5]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q15, =0x201010104000101
	ldr q20, =0x1010101010000
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0x80
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603209 // ldr c9, [c16, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601209 // ldr c9, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400130 // ldr c16, [x9, #0]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400530 // ldr c16, [x9, #1]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc2400930 // ldr c16, [x9, #2]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc2400d30 // ldr c16, [x9, #3]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc2401130 // ldr c16, [x9, #4]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc2401530 // ldr c16, [x9, #5]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc2401930 // ldr c16, [x9, #6]
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	.inst 0xc2401d30 // ldr c16, [x9, #7]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x201010104000101
	mov x16, v15.d[0]
	cmp x9, x16
	b.ne comparison_fail
	ldr x9, =0x0
	mov x16, v15.d[1]
	cmp x9, x16
	b.ne comparison_fail
	ldr x9, =0x1010101010000
	mov x16, v20.d[0]
	cmp x9, x16
	b.ne comparison_fail
	ldr x9, =0x0
	mov x16, v20.d[1]
	cmp x9, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001068
	ldr x1, =check_data1
	ldr x2, =0x00001069
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012a0
	ldr x1, =check_data2
	ldr x2, =0x000012b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f28
	ldr x1, =check_data3
	ldr x2, =0x00001f38
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff0
	ldr x1, =check_data4
	ldr x2, =0x00001ffc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400400
	ldr x1, =check_data6
	ldr x2, =0x00400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00440020
	ldr x1, =check_data7
	ldr x2, =0x00440028
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
