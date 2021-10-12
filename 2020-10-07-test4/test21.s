.section data0, #alloc, #write
	.byte 0x12, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc9, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x61, 0x5b, 0x67, 0xea, 0x00, 0x7d, 0xdf, 0x88, 0xe2, 0x13, 0xc1, 0xc2, 0x3b, 0xd0, 0x5f, 0x79
	.byte 0x42, 0x59, 0x82, 0x82, 0x31, 0x94, 0x1a, 0xa2, 0xf3, 0xd1, 0xe8, 0xc2, 0x02, 0xe0, 0x93, 0x3c
	.byte 0xc1, 0x73, 0xc0, 0xc2, 0xc0, 0x13, 0xc2, 0xc2
.data
check_data5:
	.byte 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x8000000000030007fffffffe00001900
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x4000000000000000000000000000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000a000e0000000000000440010
final_cap_values:
	/* C0 */
	.octa 0x1012
	/* C1 */
	.octa 0x440010
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x8000000000030007fffffffe00001900
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x4000000000000000000000000000
	/* C19 */
	.octa 0x4600000000000000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000a000e0000000000000440010
initial_SP_EL3_value:
	.octa 0x1001f02300ffffffffffdd1c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000087808f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000207020400ffffffffff0000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xea675b61 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:27 imm6:010110 Rm:7 N:1 shift:01 01010:01010 opc:11 sf:1
	.inst 0x88df7d00 // ldlar:aarch64/instrs/memory/ordered Rt:0 Rn:8 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xc2c113e2 // GCLIM-R.C-C Rd:2 Cn:31 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x795fd03b // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:27 Rn:1 imm12:011111110100 opc:01 111001:111001 size:01
	.inst 0x82825942 // ALDRSH-R.RRB-64 Rt:2 Rn:10 opc:10 S:1 option:010 Rm:2 0:0 L:0 100000101:100000101
	.inst 0xa21a9431 // STR-C.RIAW-C Ct:17 Rn:1 01:01 imm9:110101001 0:0 opc:00 10100010:10100010
	.inst 0xc2e8d1f3 // EORFLGS-C.CI-C Cd:19 Cn:15 0:0 10:10 imm8:01000110 11000010111:11000010111
	.inst 0x3c93e002 // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:2 Rn:0 00:00 imm9:100111110 0:0 opc:10 111100:111100 size:00
	.inst 0xc2c073c1 // GCOFF-R.C-C Rd:1 Cn:30 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c213c0 // BR-C-C 00000:00000 Cn:30 100:100 opc:00 11000010110000100:11000010110000100
	.zero 262120
	.inst 0xc2c21200
	.zero 786412
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a7 // ldr c7, [x29, #0]
	.inst 0xc24007a8 // ldr c8, [x29, #1]
	.inst 0xc2400baa // ldr c10, [x29, #2]
	.inst 0xc2400faf // ldr c15, [x29, #3]
	.inst 0xc24013b1 // ldr c17, [x29, #4]
	.inst 0xc24017bb // ldr c27, [x29, #5]
	.inst 0xc2401bbe // ldr c30, [x29, #6]
	/* Vector registers */
	mrs x29, cptr_el3
	bfc x29, #10, #1
	msr cptr_el3, x29
	isb
	ldr q2, =0xc90000000000000000000000000000
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	ldr x29, =0x4
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260321d // ldr c29, [c16, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260121d // ldr c29, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x16, #0xf
	and x29, x29, x16
	cmp x29, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003b0 // ldr c16, [x29, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24007b0 // ldr c16, [x29, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400bb0 // ldr c16, [x29, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400fb0 // ldr c16, [x29, #3]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc24013b0 // ldr c16, [x29, #4]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc24017b0 // ldr c16, [x29, #5]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc2401bb0 // ldr c16, [x29, #6]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2401fb0 // ldr c16, [x29, #7]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc24023b0 // ldr c16, [x29, #8]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc24027b0 // ldr c16, [x29, #9]
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	.inst 0xc2402bb0 // ldr c16, [x29, #10]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x16, v2.d[0]
	cmp x29, x16
	b.ne comparison_fail
	ldr x29, =0xc9000000000000
	mov x16, v2.d[1]
	cmp x29, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000018fe
	ldr x1, =check_data1
	ldr x2, =0x00001900
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f50
	ldr x1, =check_data2
	ldr x2, =0x00001f60
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe8
	ldr x1, =check_data3
	ldr x2, =0x00001fea
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00440010
	ldr x1, =check_data5
	ldr x2, =0x00440014
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
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
