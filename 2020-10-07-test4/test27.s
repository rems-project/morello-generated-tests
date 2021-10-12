.section data0, #alloc, #write
	.zero 160
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3920
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0x53, 0x08, 0xdb, 0xc2, 0x81, 0x79, 0x9f, 0x6a, 0xdf, 0x1b, 0xeb, 0xc2, 0xa0, 0x02, 0x3f, 0xd6
.data
check_data2:
	.byte 0xe1, 0x08, 0xc0, 0xda, 0x86, 0x7a, 0x6f, 0x38, 0xc0, 0x17, 0xc0, 0x5a, 0xc1, 0x4a, 0xe9, 0xc2
	.byte 0x96, 0x70, 0xc0, 0xc2, 0xbf, 0x5b, 0xdf, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x400000000000000000000000
	/* C11 */
	.octa 0x200000000000
	/* C15 */
	.octa 0x32002000000010a6
	/* C20 */
	.octa 0x8000000024030007cdffe00000000000
	/* C21 */
	.octa 0x100
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x2000000000000040000000000000000
	/* C29 */
	.octa 0x72007000822061402e000
	/* C30 */
	.octa 0x1400720010000607820002002
final_cap_values:
	/* C0 */
	.octa 0x8
	/* C1 */
	.octa 0x4a00000000000000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x400000000000000000000000
	/* C6 */
	.octa 0xc2
	/* C11 */
	.octa 0x200000000000
	/* C15 */
	.octa 0x32002000000010a6
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x8000000024030007cdffe00000000000
	/* C21 */
	.octa 0x100
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x2000000000000040000000000000000
	/* C29 */
	.octa 0x72007000822061402e000
	/* C30 */
	.octa 0x20008000800700070000000000400011
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword final_cap_values + 208
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2db0853 // SEAL-C.CC-C Cd:19 Cn:2 0010:0010 opc:00 Cm:27 11000010110:11000010110
	.inst 0x6a9f7981 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:12 imm6:011110 Rm:31 N:0 shift:10 01010:01010 opc:11 sf:0
	.inst 0xc2eb1bdf // CVT-C.CR-C Cd:31 Cn:30 0110:0110 0:0 0:0 Rm:11 11000010111:11000010111
	.inst 0xd63f02a0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:21 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 240
	.inst 0xdac008e1 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:7 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x386f7a86 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:6 Rn:20 10:10 S:1 option:011 Rm:15 1:1 opc:01 111000:111000 size:00
	.inst 0x5ac017c0 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:0 Rn:30 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2e94ac1 // ORRFLGS-C.CI-C Cd:1 Cn:22 0:0 01:01 imm8:01001010 11000010111:11000010111
	.inst 0xc2c07096 // GCOFF-R.C-C Rd:22 Cn:4 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2df5bbf // ALIGNU-C.CI-C Cd:31 Cn:29 0110:0110 U:1 imm6:111110 11000010110:11000010110
	.inst 0xc2c21220
	.zero 1048292
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
	.inst 0xc2400122 // ldr c2, [x9, #0]
	.inst 0xc2400524 // ldr c4, [x9, #1]
	.inst 0xc240092b // ldr c11, [x9, #2]
	.inst 0xc2400d2f // ldr c15, [x9, #3]
	.inst 0xc2401134 // ldr c20, [x9, #4]
	.inst 0xc2401535 // ldr c21, [x9, #5]
	.inst 0xc2401936 // ldr c22, [x9, #6]
	.inst 0xc2401d3b // ldr c27, [x9, #7]
	.inst 0xc240213d // ldr c29, [x9, #8]
	.inst 0xc240253e // ldr c30, [x9, #9]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850032
	msr SCTLR_EL3, x9
	ldr x9, =0x8c
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82601229 // ldr c9, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x17, #0xf
	and x9, x9, x17
	cmp x9, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400131 // ldr c17, [x9, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400531 // ldr c17, [x9, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400931 // ldr c17, [x9, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400d31 // ldr c17, [x9, #3]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc2401131 // ldr c17, [x9, #4]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc2401531 // ldr c17, [x9, #5]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc2401931 // ldr c17, [x9, #6]
	.inst 0xc2d1a5e1 // chkeq c15, c17
	b.ne comparison_fail
	.inst 0xc2401d31 // ldr c17, [x9, #7]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc2402131 // ldr c17, [x9, #8]
	.inst 0xc2d1a681 // chkeq c20, c17
	b.ne comparison_fail
	.inst 0xc2402531 // ldr c17, [x9, #9]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2402931 // ldr c17, [x9, #10]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc2402d31 // ldr c17, [x9, #11]
	.inst 0xc2d1a761 // chkeq c27, c17
	b.ne comparison_fail
	.inst 0xc2403131 // ldr c17, [x9, #12]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2403531 // ldr c17, [x9, #13]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010a6
	ldr x1, =check_data0
	ldr x2, =0x000010a7
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400100
	ldr x1, =check_data2
	ldr x2, =0x0040011c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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
