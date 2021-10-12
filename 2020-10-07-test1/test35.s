.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xdf, 0x16, 0x6d, 0xd0, 0x21, 0x10, 0xc0, 0x5a, 0xbe, 0x36, 0x5a, 0x3c, 0xe6, 0x37, 0x19, 0x78
	.byte 0xc2, 0xfb, 0x44, 0xa9, 0x30, 0x20, 0xd8, 0x92, 0x87, 0x0f, 0x02, 0xb8, 0x14, 0xd2, 0xc1, 0xc2
	.byte 0xbd, 0xfb, 0xd6, 0xc2, 0x12, 0x44, 0xc5, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C21 */
	.octa 0x800000000007800f000000000040ffff
	/* C28 */
	.octa 0x40000000000000080000000000001440
	/* C29 */
	.octa 0x600070000000000000000
	/* C30 */
	.octa 0x800000000401c0050000000000001008
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C16 */
	.octa 0xffff3efeffffffff
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0xffff3efeffffffff
	/* C21 */
	.octa 0x800000000007800f000000000040ffa2
	/* C28 */
	.octa 0x40000000000000080000000000001460
	/* C29 */
	.octa 0x42d000000000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000014100070000000000001050
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002800e0080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x100000014006001ce1e300000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd06d16df // ADRP-C.I-C Rd:31 immhi:110110100010110110 P:0 10000:10000 immlo:10 op:1
	.inst 0x5ac01021 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:1 Rn:1 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x3c5a36be // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:30 Rn:21 01:01 imm9:110100011 0:0 opc:01 111100:111100 size:00
	.inst 0x781937e6 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:6 Rn:31 01:01 imm9:110010011 0:0 opc:00 111000:111000 size:01
	.inst 0xa944fbc2 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:2 Rn:30 Rt2:11110 imm7:0001001 L:1 1010010:1010010 opc:10
	.inst 0x92d82030 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:16 imm16:1100000100000001 hw:10 100101:100101 opc:00 sf:1
	.inst 0xb8020f87 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:7 Rn:28 11:11 imm9:000100000 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c1d214 // CPY-C.C-C Cd:20 Cn:16 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xc2d6fbbd // SCBNDS-C.CI-S Cd:29 Cn:29 1110:1110 S:1 imm6:101101 11000010110:11000010110
	.inst 0xc2c54412 // CSEAL-C.C-C Cd:18 Cn:0 001:001 opc:10 0:0 Cm:5 11000010110:11000010110
	.inst 0xc2c21120
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400765 // ldr c5, [x27, #1]
	.inst 0xc2400b66 // ldr c6, [x27, #2]
	.inst 0xc2400f67 // ldr c7, [x27, #3]
	.inst 0xc2401375 // ldr c21, [x27, #4]
	.inst 0xc240177c // ldr c28, [x27, #5]
	.inst 0xc2401b7d // ldr c29, [x27, #6]
	.inst 0xc2401f7e // ldr c30, [x27, #7]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
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
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260313b // ldr c27, [c9, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260113b // ldr c27, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x9, #0xf
	and x27, x27, x9
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400369 // ldr c9, [x27, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400769 // ldr c9, [x27, #1]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400b69 // ldr c9, [x27, #2]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2400f69 // ldr c9, [x27, #3]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401369 // ldr c9, [x27, #4]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2401769 // ldr c9, [x27, #5]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401b69 // ldr c9, [x27, #6]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2401f69 // ldr c9, [x27, #7]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2402369 // ldr c9, [x27, #8]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2402769 // ldr c9, [x27, #9]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402b69 // ldr c9, [x27, #10]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402f69 // ldr c9, [x27, #11]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x9, v30.d[0]
	cmp x27, x9
	b.ne comparison_fail
	ldr x27, =0x0
	mov x9, v30.d[1]
	cmp x27, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001050
	ldr x1, =check_data0
	ldr x2, =0x00001060
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001460
	ldr x1, =check_data1
	ldr x2, =0x00001464
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040ffff
	ldr x1, =check_data3
	ldr x2, =0x00410000
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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
