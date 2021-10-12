.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x43, 0x10, 0xc2, 0xc2, 0xbe, 0xf3, 0xc0, 0xc2, 0x82, 0xfc, 0xdf, 0x48, 0x22, 0x30, 0xc5, 0xc2
	.byte 0x5f, 0x13, 0xfa, 0x2c, 0xc1, 0x5b, 0x0b, 0xd2, 0xd5, 0x8e, 0x29, 0xb5
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xcf, 0x7f, 0x1e, 0x9b, 0xe0, 0x73, 0xc2, 0xc2, 0x32, 0xa8, 0xd3, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x20008000800100060000000000400004
	/* C4 */
	.octa 0x422efc
	/* C21 */
	.octa 0xffffffffffffffff
	/* C26 */
	.octa 0x1ff4
final_cap_values:
	/* C2 */
	.octa 0x1
	/* C4 */
	.octa 0x422efc
	/* C21 */
	.octa 0xffffffffffffffff
	/* C26 */
	.octa 0x1fc4
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100700010000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c21043 // BRR-C-C 00011:00011 Cn:2 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2c0f3be // GCTYPE-R.C-C Rd:30 Cn:29 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x48dffc82 // ldarh:aarch64/instrs/memory/ordered Rt:2 Rn:4 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c53022 // CVTP-R.C-C Rd:2 Cn:1 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x2cfa135f // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:31 Rn:26 Rt2:00100 imm7:1110100 L:1 1011001:1011001 opc:00
	.inst 0xd20b5bc1 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:30 imms:010110 immr:001011 N:0 100100:100100 opc:10 sf:1
	.inst 0xb5298ed5 // cbnz:aarch64/instrs/branch/conditional/compare Rt:21 imm19:0010100110001110110 op:1 011010:011010 sf:1
	.zero 143072
	.inst 0x0000c2c2
	.zero 197360
	.inst 0x9b1e7fcf // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:15 Rn:30 Ra:31 o0:0 Rm:30 0011011000:0011011000 sf:1
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2d3a832 // EORFLGS-C.CR-C Cd:18 Cn:1 1010:1010 opc:10 Rm:19 11000010110:11000010110
	.inst 0xc2c21220
	.zero 708096
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
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc2400924 // ldr c4, [x9, #2]
	.inst 0xc2400d35 // ldr c21, [x9, #3]
	.inst 0xc240113a // ldr c26, [x9, #4]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0x8
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603229 // ldr c9, [c17, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
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
	cmp x9, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400131 // ldr c17, [x9, #0]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400531 // ldr c17, [x9, #1]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc2400931 // ldr c17, [x9, #2]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2400d31 // ldr c17, [x9, #3]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0xc2c2c2c2
	mov x17, v4.d[0]
	cmp x9, x17
	b.ne comparison_fail
	ldr x9, =0x0
	mov x17, v4.d[1]
	cmp x9, x17
	b.ne comparison_fail
	ldr x9, =0xc2c2c2c2
	mov x17, v31.d[0]
	cmp x9, x17
	b.ne comparison_fail
	ldr x9, =0x0
	mov x17, v31.d[1]
	cmp x9, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff4
	ldr x1, =check_data0
	ldr x2, =0x00001ffc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040001c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00422efc
	ldr x1, =check_data2
	ldr x2, =0x00422efe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004531f0
	ldr x1, =check_data3
	ldr x2, =0x00453200
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
