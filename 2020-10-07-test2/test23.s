.section data0, #alloc, #write
	.zero 1840
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2112
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 80
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0x3e, 0x64, 0x6c, 0x6c, 0x41, 0x58, 0xe7, 0xc2, 0x60, 0xb6, 0x55, 0x78, 0xff, 0x41, 0xdc, 0xc2
	.byte 0xe7, 0x2f, 0xc2, 0x1a, 0xc2, 0xe3, 0xde, 0xc2, 0x3e, 0xbe, 0x52, 0xf8, 0x22, 0x10, 0x5d, 0xa2
	.byte 0x06, 0x24, 0xa0, 0xc2, 0x65, 0x08, 0x36, 0xd2, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x18c0
	/* C2 */
	.octa 0x4001180200fffffffffff000
	/* C7 */
	.octa 0xd
	/* C15 */
	.octa 0x80070007000000020004e001
	/* C17 */
	.octa 0x1005
	/* C19 */
	.octa 0x17f0
	/* C28 */
	.octa 0x807e000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc2c2
	/* C1 */
	.octa 0x40011802000000000000180f
	/* C2 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C6 */
	.octa 0x24846
	/* C7 */
	.octa 0x0
	/* C15 */
	.octa 0x80070007000000020004e001
	/* C17 */
	.octa 0xf30
	/* C19 */
	.octa 0x174b
	/* C28 */
	.octa 0x807e000
	/* C30 */
	.octa 0xc2c2c2c2c2c2c2c2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x901000000007020500ffffffffffa001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x6c6c643e // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:30 Rn:1 Rt2:11001 imm7:1011000 L:1 1011000:1011000 opc:01
	.inst 0xc2e75841 // CVTZ-C.CR-C Cd:1 Cn:2 0110:0110 1:1 0:0 Rm:7 11000010111:11000010111
	.inst 0x7855b660 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:19 01:01 imm9:101011011 0:0 opc:01 111000:111000 size:01
	.inst 0xc2dc41ff // SCVALUE-C.CR-C Cd:31 Cn:15 000:000 opc:10 0:0 Rm:28 11000010110:11000010110
	.inst 0x1ac22fe7 // rorv:aarch64/instrs/integer/shift/variable Rd:7 Rn:31 op2:11 0010:0010 Rm:2 0011010110:0011010110 sf:0
	.inst 0xc2dee3c2 // SCFLGS-C.CR-C Cd:2 Cn:30 111000:111000 Rm:30 11000010110:11000010110
	.inst 0xf852be3e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:17 11:11 imm9:100101011 0:0 opc:01 111000:111000 size:11
	.inst 0xa25d1022 // LDUR-C.RI-C Ct:2 Rn:1 00:00 imm9:111010001 0:0 opc:01 10100010:10100010
	.inst 0xc2a02406 // ADD-C.CRI-C Cd:6 Cn:0 imm3:001 option:001 Rm:0 11000010101:11000010101
	.inst 0xd2360865 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:5 Rn:3 imms:000010 immr:110110 N:0 100100:100100 opc:10 sf:1
	.inst 0xc2c21280
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400947 // ldr c7, [x10, #2]
	.inst 0xc2400d4f // ldr c15, [x10, #3]
	.inst 0xc2401151 // ldr c17, [x10, #4]
	.inst 0xc2401553 // ldr c19, [x10, #5]
	.inst 0xc240195c // ldr c28, [x10, #6]
	.inst 0xc2401d5e // ldr c30, [x10, #7]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850032
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260328a // ldr c10, [c20, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260128a // ldr c10, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400154 // ldr c20, [x10, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400554 // ldr c20, [x10, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400954 // ldr c20, [x10, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400d54 // ldr c20, [x10, #3]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2401154 // ldr c20, [x10, #4]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2401554 // ldr c20, [x10, #5]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2401954 // ldr c20, [x10, #6]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2401d54 // ldr c20, [x10, #7]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc2402154 // ldr c20, [x10, #8]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2402554 // ldr c20, [x10, #9]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0xc2c2c2c2c2c2c2c2
	mov x20, v25.d[0]
	cmp x10, x20
	b.ne comparison_fail
	ldr x10, =0x0
	mov x20, v25.d[1]
	cmp x10, x20
	b.ne comparison_fail
	ldr x10, =0xc2c2c2c2c2c2c2c2
	mov x20, v30.d[0]
	cmp x10, x20
	b.ne comparison_fail
	ldr x10, =0x0
	mov x20, v30.d[1]
	cmp x10, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001730
	ldr x1, =check_data0
	ldr x2, =0x00001738
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f80
	ldr x1, =check_data1
	ldr x2, =0x00001f90
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
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
