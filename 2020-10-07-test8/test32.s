.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x08, 0x10
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xf7, 0x47, 0xcc, 0xc2, 0x5e, 0xff, 0x06, 0x78, 0xdd, 0xb7, 0x03, 0x6d, 0x7f, 0xfb, 0x0f, 0x79
	.byte 0x5f, 0x04, 0xc0, 0xda, 0xe2, 0xb3, 0xc0, 0xc2, 0x7e, 0x37, 0x51, 0x34, 0x21, 0x7e, 0xf6, 0x28
	.byte 0xff, 0x6f, 0x17, 0x35, 0x25, 0x50, 0xc1, 0xc2, 0x60, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C12 */
	.octa 0x800000000000000000000000
	/* C17 */
	.octa 0x80000000110744070000000000409000
	/* C26 */
	.octa 0x40000000200000200000000000000f91
	/* C27 */
	.octa 0x40000000580013320000000000001000
	/* C30 */
	.octa 0x400000004004030c0000000000001008
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x800000000000000000000000
	/* C17 */
	.octa 0x80000000110744070000000000408fb0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x40000000200000200000000000001000
	/* C27 */
	.octa 0x40000000580013320000000000001000
	/* C30 */
	.octa 0x400000004004030c0000000000001008
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000400070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2cc47f7 // CSEAL-C.C-C Cd:23 Cn:31 001:001 opc:10 0:0 Cm:12 11000010110:11000010110
	.inst 0x7806ff5e // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:26 11:11 imm9:001101111 0:0 opc:00 111000:111000 size:01
	.inst 0x6d03b7dd // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:29 Rn:30 Rt2:01101 imm7:0000111 L:0 1011010:1011010 opc:01
	.inst 0x790ffb7f // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:27 imm12:001111111110 opc:00 111001:111001 size:01
	.inst 0xdac0045f // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:2 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c0b3e2 // GCSEAL-R.C-C Rd:2 Cn:31 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x3451377e // cbz:aarch64/instrs/branch/conditional/compare Rt:30 imm19:0101000100110111011 op:0 011010:011010 sf:0
	.inst 0x28f67e21 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:1 Rn:17 Rt2:11111 imm7:1101100 L:1 1010001:1010001 opc:00
	.inst 0x35176fff // cbnz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:0001011101101111111 op:1 011010:011010 sf:0
	.inst 0xc2c15025 // CFHI-R.C-C Rd:5 Cn:1 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c21260
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc240024c // ldr c12, [x18, #0]
	.inst 0xc2400651 // ldr c17, [x18, #1]
	.inst 0xc2400a5a // ldr c26, [x18, #2]
	.inst 0xc2400e5b // ldr c27, [x18, #3]
	.inst 0xc240125e // ldr c30, [x18, #4]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q13, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82601272 // ldr c18, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x19, #0xf
	and x18, x18, x19
	cmp x18, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400253 // ldr c19, [x18, #0]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400653 // ldr c19, [x18, #1]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400a53 // ldr c19, [x18, #2]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc2400e53 // ldr c19, [x18, #3]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc2401253 // ldr c19, [x18, #4]
	.inst 0xc2d3a621 // chkeq c17, c19
	b.ne comparison_fail
	.inst 0xc2401653 // ldr c19, [x18, #5]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc2401a53 // ldr c19, [x18, #6]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2401e53 // ldr c19, [x18, #7]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc2402253 // ldr c19, [x18, #8]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x19, v13.d[0]
	cmp x18, x19
	b.ne comparison_fail
	ldr x18, =0x0
	mov x19, v13.d[1]
	cmp x18, x19
	b.ne comparison_fail
	ldr x18, =0x0
	mov x19, v29.d[0]
	cmp x18, x19
	b.ne comparison_fail
	ldr x18, =0x0
	mov x19, v29.d[1]
	cmp x18, x19
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017fc
	ldr x1, =check_data2
	ldr x2, =0x000017fe
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
	ldr x0, =0x00409000
	ldr x1, =check_data4
	ldr x2, =0x00409008
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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
