.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x7c, 0x7b, 0xf2, 0x38, 0xc2, 0x0f, 0xc0, 0x9a, 0x42, 0x7b, 0x5a, 0xe2, 0x2e, 0xfc, 0x9f, 0x08
	.byte 0x3e, 0xa3, 0xc6, 0xc2, 0x40, 0x55, 0xd9, 0x69, 0xe0, 0xff, 0xdf, 0x88, 0x20, 0x28, 0x3e, 0x6a
	.byte 0x5f, 0xa1, 0xc8, 0xc2, 0x80, 0xd2, 0x42, 0x82, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1c00
	/* C10 */
	.octa 0x1338
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x1000
	/* C20 */
	.octa 0x40000000000100050000000000001000
	/* C25 */
	.octa 0x7
	/* C26 */
	.octa 0x80000000000100050000000000002005
	/* C27 */
	.octa 0xc00
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1c00
	/* C2 */
	.octa 0x0
	/* C10 */
	.octa 0x1400
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x1000
	/* C20 */
	.octa 0x40000000000100050000000000001000
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x7
	/* C26 */
	.octa 0x80000000000100050000000000002005
	/* C27 */
	.octa 0xc00
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x7
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004004000800ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38f27b7c // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:28 Rn:27 10:10 S:1 option:011 Rm:18 1:1 opc:11 111000:111000 size:00
	.inst 0x9ac00fc2 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:2 Rn:30 o1:1 00001:00001 Rm:0 0011010110:0011010110 sf:1
	.inst 0xe25a7b42 // ALDURSH-R.RI-64 Rt:2 Rn:26 op2:10 imm9:110100111 V:0 op1:01 11100010:11100010
	.inst 0x089ffc2e // stlrb:aarch64/instrs/memory/ordered Rt:14 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c6a33e // CLRPERM-C.CR-C Cd:30 Cn:25 000:000 1:1 10:10 Rm:6 11000010110:11000010110
	.inst 0x69d95540 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:10 Rt2:10101 imm7:0110010 L:1 1010011:1010011 opc:01
	.inst 0x88dfffe0 // ldar:aarch64/instrs/memory/ordered Rt:0 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x6a3e2820 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:1 imm6:001010 Rm:30 N:1 shift:00 01010:01010 opc:11 sf:0
	.inst 0xc2c8a15f // CLRPERM-C.CR-C Cd:31 Cn:10 000:000 1:1 10:10 Rm:8 11000010110:11000010110
	.inst 0x8242d280 // ASTR-C.RI-C Ct:0 Rn:20 op:00 imm9:000101101 L:0 1000001001:1000001001
	.inst 0xc2c210a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400aca // ldr c10, [x22, #2]
	.inst 0xc2400ece // ldr c14, [x22, #3]
	.inst 0xc24012d2 // ldr c18, [x22, #4]
	.inst 0xc24016d4 // ldr c20, [x22, #5]
	.inst 0xc2401ad9 // ldr c25, [x22, #6]
	.inst 0xc2401eda // ldr c26, [x22, #7]
	.inst 0xc24022db // ldr c27, [x22, #8]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_SP_EL3_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b6 // ldr c22, [c5, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x826010b6 // ldr c22, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x5, #0xf
	and x22, x22, x5
	cmp x22, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002c5 // ldr c5, [x22, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24006c5 // ldr c5, [x22, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400ac5 // ldr c5, [x22, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400ec5 // ldr c5, [x22, #3]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc24012c5 // ldr c5, [x22, #4]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc24016c5 // ldr c5, [x22, #5]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2401ac5 // ldr c5, [x22, #6]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc2401ec5 // ldr c5, [x22, #7]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc24022c5 // ldr c5, [x22, #8]
	.inst 0xc2c5a721 // chkeq c25, c5
	b.ne comparison_fail
	.inst 0xc24026c5 // ldr c5, [x22, #9]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2402ac5 // ldr c5, [x22, #10]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc2402ec5 // ldr c5, [x22, #11]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc24032c5 // ldr c5, [x22, #12]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000012d0
	ldr x1, =check_data1
	ldr x2, =0x000012e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001408
	ldr x1, =check_data2
	ldr x2, =0x00001410
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c08
	ldr x1, =check_data3
	ldr x2, =0x00001c09
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fac
	ldr x1, =check_data4
	ldr x2, =0x00001fae
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
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
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
