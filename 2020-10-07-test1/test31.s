.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x00, 0x2d, 0x00, 0x00, 0x50, 0x80, 0x00, 0x00, 0x00, 0x00, 0x51, 0x00, 0x48, 0x00, 0x00
.data
check_data5:
	.byte 0xd0, 0x33, 0xc0, 0xc2, 0xcd, 0x64, 0x5a, 0x82, 0x80, 0x51, 0x5b, 0x82, 0x29, 0xc0, 0x0c, 0x51
	.byte 0xa0, 0x86, 0xd2, 0xc2
.data
check_data6:
	.byte 0xfe, 0x0b, 0x6e, 0xa9, 0x5e, 0x23, 0x13, 0x78, 0x25, 0x10, 0x21, 0x8b, 0x23, 0x90, 0xf8, 0x68
	.byte 0x1e, 0x00, 0xde, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x48005100000000805000002d0000
	/* C1 */
	.octa 0x8000000000010005000000000000106c
	/* C6 */
	.octa 0xfd3
	/* C12 */
	.octa 0xfffffffffffff657
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x400002000000000000000000000000
	/* C21 */
	.octa 0x20408002081f8fff00000000004007f1
	/* C26 */
	.octa 0x40000000000100050000000000001100
	/* C30 */
	.octa 0x807400f0020000000008001
final_cap_values:
	/* C0 */
	.octa 0x48005100000000805000002d0000
	/* C1 */
	.octa 0x80000000000100050000000000001030
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x172c
	/* C6 */
	.octa 0xfd3
	/* C9 */
	.octa 0xd3c
	/* C12 */
	.octa 0xfffffffffffff657
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x47f8
	/* C18 */
	.octa 0x400002000000000000000000000000
	/* C21 */
	.octa 0x20408002081f8fff00000000004007f1
	/* C26 */
	.octa 0x40000000000100050000000000001100
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x48004000000000805000002d0000
initial_SP_EL3_value:
	.octa 0x80000000600008220000000000001140
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x48000000560400490000000000002001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword final_cap_values + 224
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c033d0 // GCLEN-R.C-C Rd:16 Cn:30 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x825a64cd // ASTRB-R.RI-B Rt:13 Rn:6 op:01 imm9:110100110 L:0 1000001001:1000001001
	.inst 0x825b5180 // ASTR-C.RI-C Ct:0 Rn:12 op:00 imm9:110110101 L:0 1000001001:1000001001
	.inst 0x510cc029 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:9 Rn:1 imm12:001100110000 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xc2d286a0 // BRS-C.C-C 00000:00000 Cn:21 001:001 opc:00 1:1 Cm:18 11000010110:11000010110
	.zero 2012
	.inst 0xa96e0bfe // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:30 Rn:31 Rt2:00010 imm7:1011100 L:1 1010010:1010010 opc:10
	.inst 0x7813235e // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:26 00:00 imm9:100110010 0:0 opc:00 111000:111000 size:01
	.inst 0x8b211025 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:5 Rn:1 imm3:100 option:000 Rm:1 01011001:01011001 S:0 op:0 sf:1
	.inst 0x68f89023 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:3 Rn:1 Rt2:00100 imm7:1110001 L:1 1010001:1010001 opc:01
	.inst 0xc2de001e // SCBNDS-C.CR-C Cd:30 Cn:0 000:000 opc:00 0:0 Rm:30 11000010110:11000010110
	.inst 0xc2c21220
	.zero 1046520
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b06 // ldr c6, [x24, #2]
	.inst 0xc2400f0c // ldr c12, [x24, #3]
	.inst 0xc240130d // ldr c13, [x24, #4]
	.inst 0xc2401712 // ldr c18, [x24, #5]
	.inst 0xc2401b15 // ldr c21, [x24, #6]
	.inst 0xc2401f1a // ldr c26, [x24, #7]
	.inst 0xc240231e // ldr c30, [x24, #8]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850038
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603238 // ldr c24, [c17, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601238 // ldr c24, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400311 // ldr c17, [x24, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400711 // ldr c17, [x24, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400b11 // ldr c17, [x24, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400f11 // ldr c17, [x24, #3]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2401311 // ldr c17, [x24, #4]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc2401711 // ldr c17, [x24, #5]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc2401b11 // ldr c17, [x24, #6]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc2401f11 // ldr c17, [x24, #7]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc2402311 // ldr c17, [x24, #8]
	.inst 0xc2d1a581 // chkeq c12, c17
	b.ne comparison_fail
	.inst 0xc2402711 // ldr c17, [x24, #9]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc2402b11 // ldr c17, [x24, #10]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc2402f11 // ldr c17, [x24, #11]
	.inst 0xc2d1a641 // chkeq c18, c17
	b.ne comparison_fail
	.inst 0xc2403311 // ldr c17, [x24, #12]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2403711 // ldr c17, [x24, #13]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc2403b11 // ldr c17, [x24, #14]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2403f11 // ldr c17, [x24, #15]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001032
	ldr x1, =check_data1
	ldr x2, =0x00001034
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000106c
	ldr x1, =check_data2
	ldr x2, =0x00001074
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011c2
	ldr x1, =check_data3
	ldr x2, =0x000011c3
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000011f0
	ldr x1, =check_data4
	ldr x2, =0x00001200
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004007f0
	ldr x1, =check_data6
	ldr x2, =0x00400808
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
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
