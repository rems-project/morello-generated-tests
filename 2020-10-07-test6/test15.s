.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x15, 0x00, 0x01, 0x80, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x4b, 0xec, 0xa1, 0x82, 0xc1, 0x04, 0x01, 0x9b, 0xc2, 0x43, 0xc9, 0xc2, 0x4e, 0x67, 0x49, 0x54
.data
check_data4:
	.byte 0x20, 0x13, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc8, 0x2f, 0x51, 0x51, 0x81, 0x92, 0xf5, 0xc2, 0xbe, 0x52, 0x97, 0x62, 0x21, 0x1b, 0xd7, 0x37
.data
check_data6:
	.byte 0x00, 0x87, 0x11, 0xe2, 0x20, 0x00, 0x1f, 0xd6
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xfbffc80000440000
	/* C2 */
	.octa 0x4000000000030007040037ffffbc1000
	/* C6 */
	.octa 0x1e2d2e000000
	/* C9 */
	.octa 0x0
	/* C20 */
	.octa 0x4001000000000000000004000000
	/* C21 */
	.octa 0x10b0
	/* C24 */
	.octa 0x800000006002000400000000000018e6
	/* C30 */
	.octa 0x800100150000000000000001
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400100000000ac00000004000000
	/* C2 */
	.octa 0x800100150000000000000000
	/* C6 */
	.octa 0x1e2d2e000000
	/* C8 */
	.octa 0xffbb5001
	/* C9 */
	.octa 0x0
	/* C20 */
	.octa 0x4001000000000000000004000000
	/* C21 */
	.octa 0x1390
	/* C24 */
	.octa 0x800000006002000400000000000018e6
	/* C30 */
	.octa 0x800100150000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x48000000220600000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82a1ec4b // ASTR-V.RRB-S Rt:11 Rn:2 opc:11 S:0 option:111 Rm:1 1:1 L:0 100000101:100000101
	.inst 0x9b0104c1 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:1 Rn:6 Ra:1 o0:0 Rm:1 0011011000:0011011000 sf:1
	.inst 0xc2c943c2 // SCVALUE-C.CR-C Cd:2 Cn:30 000:000 opc:10 0:0 Rm:9 11000010110:11000010110
	.inst 0x5449674e // b_cond:aarch64/instrs/branch/conditional/cond cond:1110 0:0 imm19:0100100101100111010 01010100:01010100
	.zero 254816
	.inst 0xc2c21320
	.zero 7308
	.inst 0x51512fc8 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:8 Rn:30 imm12:010001001011 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xc2f59281 // EORFLGS-C.CI-C Cd:1 Cn:20 0:0 10:10 imm8:10101100 11000010111:11000010111
	.inst 0x629752be // STP-C.RIBW-C Ct:30 Rn:21 Ct2:10100 imm7:0101110 L:0 011000101:011000101
	.inst 0x37d71b21 // tbnz:aarch64/instrs/branch/conditional/test Rt:1 imm14:11100011011001 b40:11010 op:1 011011:011011 b5:0
	.zero 339172
	.inst 0xe2118700 // ALDURB-R.RI-32 Rt:0 Rn:24 op2:01 imm9:100011000 V:0 op1:00 11100010:11100010
	.inst 0xd61f0020 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 447236
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
	.inst 0xc2400361 // ldr c1, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b66 // ldr c6, [x27, #2]
	.inst 0xc2400f69 // ldr c9, [x27, #3]
	.inst 0xc2401374 // ldr c20, [x27, #4]
	.inst 0xc2401775 // ldr c21, [x27, #5]
	.inst 0xc2401b78 // ldr c24, [x27, #6]
	.inst 0xc2401f7e // ldr c30, [x27, #7]
	/* Vector registers */
	mrs x27, cptr_el3
	bfc x27, #10, #1
	msr cptr_el3, x27
	isb
	ldr q11, =0x0
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	ldr x27, =0xc
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260333b // ldr c27, [c25, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260133b // ldr c27, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400379 // ldr c25, [x27, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400779 // ldr c25, [x27, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400b79 // ldr c25, [x27, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400f79 // ldr c25, [x27, #3]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc2401379 // ldr c25, [x27, #4]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2401779 // ldr c25, [x27, #5]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc2401b79 // ldr c25, [x27, #6]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2401f79 // ldr c25, [x27, #7]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc2402379 // ldr c25, [x27, #8]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc2402779 // ldr c25, [x27, #9]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x25, v11.d[0]
	cmp x27, x25
	b.ne comparison_fail
	ldr x27, =0x0
	mov x25, v11.d[1]
	cmp x27, x25
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
	ldr x0, =0x00001390
	ldr x1, =check_data1
	ldr x2, =0x000013b0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017fe
	ldr x1, =check_data2
	ldr x2, =0x000017ff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0043e370
	ldr x1, =check_data4
	ldr x2, =0x0043e374
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00440000
	ldr x1, =check_data5
	ldr x2, =0x00440010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00492cf4
	ldr x1, =check_data6
	ldr x2, =0x00492cfc
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
