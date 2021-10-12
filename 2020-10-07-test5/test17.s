.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xbe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x42
.data
check_data5:
	.byte 0x41, 0x1a, 0xff, 0xc2, 0x5f, 0x38, 0x5f, 0xe2, 0x29, 0x60, 0x4a, 0xf8, 0x1f, 0x7c, 0x9f, 0x08
	.byte 0xdf, 0x13, 0x3f, 0x8b, 0xff, 0x87, 0x55, 0xa2, 0xde, 0xd4, 0x89, 0xa8, 0x81, 0x63, 0xc0, 0xc2
	.byte 0x50, 0xf0, 0xc0, 0xc2, 0xfe, 0x07, 0xc0, 0xda, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xd87
	/* C2 */
	.octa 0x8000000000010005000000000000100d
	/* C6 */
	.octa 0x1036
	/* C18 */
	.octa 0x800100070081df0dbe078e01
	/* C21 */
	.octa 0x420000000000c000
	/* C28 */
	.octa 0x2000007fffffffffe0a0
	/* C30 */
	.octa 0xbe
final_cap_values:
	/* C0 */
	.octa 0xd87
	/* C1 */
	.octa 0x20000000000000000d87
	/* C2 */
	.octa 0x8000000000010005000000000000100d
	/* C6 */
	.octa 0x10ce
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x800100070081df0dbe078e01
	/* C21 */
	.octa 0x420000000000c000
	/* C28 */
	.octa 0x2000007fffffffffe0a0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480400000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000005fc10f620000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2ff1a41 // CVT-C.CR-C Cd:1 Cn:18 0110:0110 0:0 0:0 Rm:31 11000010111:11000010111
	.inst 0xe25f385f // ALDURSH-R.RI-64 Rt:31 Rn:2 op2:10 imm9:111110011 V:0 op1:01 11100010:11100010
	.inst 0xf84a6029 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:9 Rn:1 00:00 imm9:010100110 0:0 opc:01 111000:111000 size:11
	.inst 0x089f7c1f // stllrb:aarch64/instrs/memory/ordered Rt:31 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x8b3f13df // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:30 imm3:100 option:000 Rm:31 01011001:01011001 S:0 op:0 sf:1
	.inst 0xa25587ff // LDR-C.RIAW-C Ct:31 Rn:31 01:01 imm9:101011000 0:0 opc:01 10100010:10100010
	.inst 0xa889d4de // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:30 Rn:6 Rt2:10101 imm7:0010011 L:0 1010001:1010001 opc:10
	.inst 0xc2c06381 // SCOFF-C.CR-C Cd:1 Cn:28 000:000 opc:11 0:0 Rm:0 11000010110:11000010110
	.inst 0xc2c0f050 // GCTYPE-R.C-C Rd:16 Cn:2 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xdac007fe // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:31 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c21060
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc2400886 // ldr c6, [x4, #2]
	.inst 0xc2400c92 // ldr c18, [x4, #3]
	.inst 0xc2401095 // ldr c21, [x4, #4]
	.inst 0xc240149c // ldr c28, [x4, #5]
	.inst 0xc240189e // ldr c30, [x4, #6]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603064 // ldr c4, [c3, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601064 // ldr c4, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400083 // ldr c3, [x4, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400483 // ldr c3, [x4, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400883 // ldr c3, [x4, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400c83 // ldr c3, [x4, #3]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc2401083 // ldr c3, [x4, #4]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2401483 // ldr c3, [x4, #5]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2401883 // ldr c3, [x4, #6]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2401c83 // ldr c3, [x4, #7]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc2402083 // ldr c3, [x4, #8]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2402483 // ldr c3, [x4, #9]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001020
	ldr x1, =check_data2
	ldr x2, =0x00001030
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ce9
	ldr x1, =check_data3
	ldr x2, =0x00001cea
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f98
	ldr x1, =check_data4
	ldr x2, =0x00001fa8
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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
