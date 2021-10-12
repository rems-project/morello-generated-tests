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
	.zero 8
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0xff, 0x63, 0xc1, 0xc2, 0x59, 0x10, 0x4c, 0xe2, 0x45, 0xb3, 0x5e, 0xba, 0xc2, 0x53, 0xc3, 0xc2
	.byte 0xe1, 0x67, 0xde, 0xc2, 0xc7, 0xfb, 0x00, 0xf9, 0xd7, 0xd9, 0xfd, 0x68, 0x42, 0xed, 0x9f, 0xa9
	.byte 0xe1, 0x30, 0xc7, 0xc2, 0x3f, 0x88, 0x1e, 0x1b, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000600000010000000000000f3f
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x1228
	/* C14 */
	.octa 0x1004
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x20000000000000000000001000
final_cap_values:
	/* C1 */
	.octa 0xffffffffffffffff
	/* C2 */
	.octa 0x1000000000000000000001000
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x1420
	/* C14 */
	.octa 0xff0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x20000000000000000000001000
initial_SP_EL3_value:
	.octa 0x40000160040000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040790070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000002007008600ffffffffffc001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c163ff // SCOFF-C.CR-C Cd:31 Cn:31 000:000 opc:11 0:0 Rm:1 11000010110:11000010110
	.inst 0xe24c1059 // ASTURH-R.RI-32 Rt:25 Rn:2 op2:00 imm9:011000001 V:0 op1:01 11100010:11100010
	.inst 0xba5eb345 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0101 0:0 Rn:26 00:00 cond:1011 Rm:30 111010010:111010010 op:0 sf:1
	.inst 0xc2c353c2 // SEAL-C.CI-C Cd:2 Cn:30 100:100 form:10 11000010110000110:11000010110000110
	.inst 0xc2de67e1 // CPYVALUE-C.C-C Cd:1 Cn:31 001:001 opc:11 0:0 Cm:30 11000010110:11000010110
	.inst 0xf900fbc7 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:7 Rn:30 imm12:000000111110 opc:00 111001:111001 size:11
	.inst 0x68fdd9d7 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:23 Rn:14 Rt2:10110 imm7:1111011 L:1 1010001:1010001 opc:01
	.inst 0xa99fed42 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:2 Rn:10 Rt2:11011 imm7:0111111 L:0 1010011:1010011 opc:10
	.inst 0xc2c730e1 // RRMASK-R.R-C Rd:1 Rn:7 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x1b1e883f // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:1 Ra:2 o0:1 Rm:30 0011011000:0011011000 sf:0
	.inst 0xc2c21060
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa7 // ldr c7, [x21, #2]
	.inst 0xc2400eaa // ldr c10, [x21, #3]
	.inst 0xc24012ae // ldr c14, [x21, #4]
	.inst 0xc24016b9 // ldr c25, [x21, #5]
	.inst 0xc2401abb // ldr c27, [x21, #6]
	.inst 0xc2401ebe // ldr c30, [x21, #7]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603075 // ldr c21, [c3, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601075 // ldr c21, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x3, #0xf
	and x21, x21, x3
	cmp x21, #0x5
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a3 // ldr c3, [x21, #0]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24006a3 // ldr c3, [x21, #1]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400aa3 // ldr c3, [x21, #2]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc2400ea3 // ldr c3, [x21, #3]
	.inst 0xc2c3a541 // chkeq c10, c3
	b.ne comparison_fail
	.inst 0xc24012a3 // ldr c3, [x21, #4]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc24016a3 // ldr c3, [x21, #5]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc2401aa3 // ldr c3, [x21, #6]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2401ea3 // ldr c3, [x21, #7]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc24022a3 // ldr c3, [x21, #8]
	.inst 0xc2c3a761 // chkeq c27, c3
	b.ne comparison_fail
	.inst 0xc24026a3 // ldr c3, [x21, #9]
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
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011f0
	ldr x1, =check_data2
	ldr x2, =0x000011f8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001420
	ldr x1, =check_data3
	ldr x2, =0x00001430
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
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
