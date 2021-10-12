.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x40, 0x58, 0xfc, 0xc2, 0x41, 0x22, 0x67, 0xe2, 0x7f, 0xb3, 0x80, 0x8a, 0x41, 0x10, 0xc2, 0xc2
	.byte 0xc0, 0xe3, 0xa4, 0xe2, 0x46, 0xb5, 0x89, 0xb8, 0x3e, 0xd8, 0x5c, 0xb8, 0x41, 0x98, 0xdd, 0xc2
	.byte 0x01, 0xa2, 0x49, 0xa9, 0xcd, 0xd3, 0x80, 0x9a, 0x20, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000003d00000000000000001203
	/* C2 */
	.octa 0x200720070000000000000001
	/* C10 */
	.octa 0x800000000005000e0000000000400000
	/* C16 */
	.octa 0x80000000000100050000000000400010
	/* C18 */
	.octa 0x1730
	/* C28 */
	.octa 0x80000000080000
	/* C30 */
	.octa 0x1052
final_cap_values:
	/* C0 */
	.octa 0x200720070080000000080000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x200720070000000000000001
	/* C6 */
	.octa 0xffffffffc2fc5840
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x800000000005000e000000000040009b
	/* C13 */
	.octa 0x80000000080000
	/* C16 */
	.octa 0x80000000000100050000000000400010
	/* C18 */
	.octa 0x1730
	/* C28 */
	.octa 0x80000000080000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000601000c500ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2fc5840 // CVTZ-C.CR-C Cd:0 Cn:2 0110:0110 1:1 0:0 Rm:28 11000010111:11000010111
	.inst 0xe2672241 // ASTUR-V.RI-H Rt:1 Rn:18 op2:00 imm9:001110010 V:1 op1:01 11100010:11100010
	.inst 0x8a80b37f // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:27 imm6:101100 Rm:0 N:0 shift:10 01010:01010 opc:00 sf:1
	.inst 0xc2c21041 // CHKSLD-C-C 00001:00001 Cn:2 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xe2a4e3c0 // ASTUR-V.RI-S Rt:0 Rn:30 op2:00 imm9:001001110 V:1 op1:10 11100010:11100010
	.inst 0xb889b546 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:6 Rn:10 01:01 imm9:010011011 0:0 opc:10 111000:111000 size:10
	.inst 0xb85cd83e // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:1 10:10 imm9:111001101 0:0 opc:01 111000:111000 size:10
	.inst 0xc2dd9841 // ALIGND-C.CI-C Cd:1 Cn:2 0110:0110 U:0 imm6:111011 11000010110:11000010110
	.inst 0xa949a201 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:1 Rn:16 Rt2:01000 imm7:0010011 L:1 1010010:1010010 opc:10
	.inst 0x9a80d3cd // csel:aarch64/instrs/integer/conditional/select Rd:13 Rn:30 o2:0 0:0 cond:1101 Rm:0 011010100:011010100 op:0 sf:1
	.inst 0xc2c21120
	.zero 1048532
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
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400702 // ldr c2, [x24, #1]
	.inst 0xc2400b0a // ldr c10, [x24, #2]
	.inst 0xc2400f10 // ldr c16, [x24, #3]
	.inst 0xc2401312 // ldr c18, [x24, #4]
	.inst 0xc240171c // ldr c28, [x24, #5]
	.inst 0xc2401b1e // ldr c30, [x24, #6]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q0, =0x0
	ldr q1, =0x0
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
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603138 // ldr c24, [c9, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601138 // ldr c24, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x9, #0xf
	and x24, x24, x9
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400309 // ldr c9, [x24, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400709 // ldr c9, [x24, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400b09 // ldr c9, [x24, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400f09 // ldr c9, [x24, #3]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401309 // ldr c9, [x24, #4]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc2401709 // ldr c9, [x24, #5]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2401b09 // ldr c9, [x24, #6]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc2401f09 // ldr c9, [x24, #7]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2402309 // ldr c9, [x24, #8]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2402709 // ldr c9, [x24, #9]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402b09 // ldr c9, [x24, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x9, v0.d[0]
	cmp x24, x9
	b.ne comparison_fail
	ldr x24, =0x0
	mov x9, v0.d[1]
	cmp x24, x9
	b.ne comparison_fail
	ldr x24, =0x0
	mov x9, v1.d[0]
	cmp x24, x9
	b.ne comparison_fail
	ldr x24, =0x0
	mov x9, v1.d[1]
	cmp x24, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010a0
	ldr x1, =check_data0
	ldr x2, =0x000010a4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011d0
	ldr x1, =check_data1
	ldr x2, =0x000011d4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017a2
	ldr x1, =check_data2
	ldr x2, =0x000017a4
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
	ldr x0, =0x004000a8
	ldr x1, =check_data4
	ldr x2, =0x004000b8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
