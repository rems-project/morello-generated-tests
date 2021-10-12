.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x3e, 0xf5, 0x40, 0x35
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 4
.data
check_data8:
	.byte 0x62, 0x69, 0xbf, 0x9b, 0xc1, 0xfb, 0x19, 0xe2, 0x55, 0x2e, 0x4f, 0xa9, 0x41, 0x49, 0x7e, 0xbc
	.byte 0x02, 0x94, 0xb9, 0x3d, 0x36, 0x08, 0xc1, 0x1a, 0xce, 0xe7, 0x92, 0x38, 0x1f, 0xd8, 0xd8, 0x1c
	.byte 0x40, 0x51, 0x78, 0x29, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000010005ffffffffffff3030
	/* C10 */
	.octa 0x80000000000100050000000000400054
	/* C18 */
	.octa 0x800000000101c0050000000000001020
	/* C30 */
	.octa 0x80000000000100070000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C10 */
	.octa 0x80000000000100050000000000400054
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x800000000101c0050000000000001020
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000100070000000000000f2e
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000400230000000000000400000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3540f53e // cbnz:aarch64/instrs/branch/conditional/compare Rt:30 imm19:0100000011110101001 op:1 011010:011010 sf:0
	.zero 532128
	.inst 0x9bbf6962 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:11 Ra:26 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0xe219fbc1 // ALDURSB-R.RI-64 Rt:1 Rn:30 op2:10 imm9:110011111 V:0 op1:00 11100010:11100010
	.inst 0xa94f2e55 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:21 Rn:18 Rt2:01011 imm7:0011110 L:1 1010010:1010010 opc:10
	.inst 0xbc7e4941 // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:1 Rn:10 10:10 S:0 option:010 Rm:30 1:1 opc:01 111100:111100 size:10
	.inst 0x3db99402 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:2 Rn:0 imm12:111001100101 opc:10 111101:111101 size:00
	.inst 0x1ac10836 // udiv:aarch64/instrs/integer/arithmetic/div Rd:22 Rn:1 o1:0 00001:00001 Rm:1 0011010110:0011010110 sf:0
	.inst 0x3892e7ce // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:14 Rn:30 01:01 imm9:100101110 0:0 opc:10 111000:111000 size:00
	.inst 0x1cd8d81f // ldr_lit_fpsimd:aarch64/instrs/memory/literal/simdfp Rt:31 imm19:1101100011011000000 011100:011100 opc:00
	.inst 0x29785140 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:10 Rt2:10100 imm7:1110000 L:1 1010010:1010010 opc:00
	.inst 0xc2c21120
	.zero 516404
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004ca // ldr c10, [x6, #1]
	.inst 0xc24008d2 // ldr c18, [x6, #2]
	.inst 0xc2400cde // ldr c30, [x6, #3]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603126 // ldr c6, [c9, #3]
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	.inst 0x82601126 // ldr c6, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c9 // ldr c9, [x6, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24004c9 // ldr c9, [x6, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24008c9 // ldr c9, [x6, #2]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2400cc9 // ldr c9, [x6, #3]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc24010c9 // ldr c9, [x6, #4]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc24014c9 // ldr c9, [x6, #5]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc24018c9 // ldr c9, [x6, #6]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2401cc9 // ldr c9, [x6, #7]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc24020c9 // ldr c9, [x6, #8]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc24024c9 // ldr c9, [x6, #9]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x9, v1.d[0]
	cmp x6, x9
	b.ne comparison_fail
	ldr x6, =0x0
	mov x9, v1.d[1]
	cmp x6, x9
	b.ne comparison_fail
	ldr x6, =0x0
	mov x9, v2.d[0]
	cmp x6, x9
	b.ne comparison_fail
	ldr x6, =0x0
	mov x9, v2.d[1]
	cmp x6, x9
	b.ne comparison_fail
	ldr x6, =0x0
	mov x9, v31.d[0]
	cmp x6, x9
	b.ne comparison_fail
	ldr x6, =0x0
	mov x9, v31.d[1]
	cmp x6, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001110
	ldr x1, =check_data1
	ldr x2, =0x00001120
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001680
	ldr x1, =check_data2
	ldr x2, =0x00001690
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400014
	ldr x1, =check_data4
	ldr x2, =0x0040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00401054
	ldr x1, =check_data5
	ldr x2, =0x00401058
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00403f9f
	ldr x1, =check_data6
	ldr x2, =0x00403fa0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004339c0
	ldr x1, =check_data7
	ldr x2, =0x004339c4
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00481ea4
	ldr x1, =check_data8
	ldr x2, =0x00481ecc
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
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
