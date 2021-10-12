.section data0, #alloc, #write
	.zero 1520
	.byte 0x18, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 2560
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x18, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x20, 0x10, 0x43, 0x82, 0x00, 0xd2, 0xd6, 0xc2
.data
check_data5:
	.byte 0xa1, 0xce, 0xff, 0x82, 0x35, 0x50, 0x00, 0x9b, 0xe0, 0x73, 0xc2, 0xc2, 0x62, 0x28, 0xfa, 0xc2
	.byte 0x43, 0x71, 0x59, 0x38, 0x9f, 0x24, 0xc1, 0xc2, 0xe1, 0xa1, 0xc7, 0xc2, 0x02, 0x42, 0xd0, 0xc2
	.byte 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x8000000000000000000014e0
	/* C3 */
	.octa 0x3fff800000000000000000000000
	/* C4 */
	.octa 0x24802000a00ffffffffffe001
	/* C10 */
	.octa 0x8000000058070787000000000000180a
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x90000000000600060000000000001290
	/* C21 */
	.octa 0x800000001007008f0000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x90000000000600060000000000001290
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x24802000a00ffffffffffe001
	/* C10 */
	.octa 0x8000000058070787000000000000180a
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x90000000000600060000000000001290
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000003000700ffffffffefe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000015f0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82431020 // ASTR-C.RI-C Ct:0 Rn:1 op:00 imm9:000110001 L:0 1000001001:1000001001
	.inst 0xc2d6d200 // BR-CI-C 0:0 0000:0000 Cn:16 100:100 imm7:0110110 110000101101:110000101101
	.zero 16
	.inst 0x82ffcea1 // ALDR-V.RRB-S Rt:1 Rn:21 opc:11 S:0 option:110 Rm:31 1:1 L:1 100000101:100000101
	.inst 0x9b005035 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:21 Rn:1 Ra:20 o0:0 Rm:0 0011011000:0011011000 sf:1
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2fa2862 // ORRFLGS-C.CI-C Cd:2 Cn:3 0:0 01:01 imm8:11010001 11000010111:11000010111
	.inst 0x38597143 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:3 Rn:10 00:00 imm9:110010111 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c1249f // CPYTYPE-C.C-C Cd:31 Cn:4 001:001 opc:01 0:0 Cm:1 11000010110:11000010110
	.inst 0xc2c7a1e1 // CLRPERM-C.CR-C Cd:1 Cn:15 000:000 1:1 10:10 Rm:7 11000010110:11000010110
	.inst 0xc2d04202 // SCVALUE-C.CR-C Cd:2 Cn:16 000:000 opc:10 0:0 Rm:16 11000010110:11000010110
	.inst 0xc2c21100
	.zero 1048516
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
	.inst 0xc2400b03 // ldr c3, [x24, #2]
	.inst 0xc2400f04 // ldr c4, [x24, #3]
	.inst 0xc240130a // ldr c10, [x24, #4]
	.inst 0xc240170f // ldr c15, [x24, #5]
	.inst 0xc2401b10 // ldr c16, [x24, #6]
	.inst 0xc2401f15 // ldr c21, [x24, #7]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850032
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603118 // ldr c24, [c8, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601118 // ldr c24, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	.inst 0xc2400308 // ldr c8, [x24, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400708 // ldr c8, [x24, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400b08 // ldr c8, [x24, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400f08 // ldr c8, [x24, #3]
	.inst 0xc2c8a461 // chkeq c3, c8
	b.ne comparison_fail
	.inst 0xc2401308 // ldr c8, [x24, #4]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc2401708 // ldr c8, [x24, #5]
	.inst 0xc2c8a541 // chkeq c10, c8
	b.ne comparison_fail
	.inst 0xc2401b08 // ldr c8, [x24, #6]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc2401f08 // ldr c8, [x24, #7]
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x8, v1.d[0]
	cmp x24, x8
	b.ne comparison_fail
	ldr x24, =0x0
	mov x8, v1.d[1]
	cmp x24, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000015f0
	ldr x1, =check_data1
	ldr x2, =0x00001600
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017a1
	ldr x1, =check_data2
	ldr x2, =0x000017a2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017f0
	ldr x1, =check_data3
	ldr x2, =0x00001800
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400018
	ldr x1, =check_data5
	ldr x2, =0x0040003c
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
