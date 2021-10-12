.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xed, 0x0b, 0xcb, 0x1a, 0x3e, 0x4c, 0xb2, 0xf9, 0x7f, 0xc6, 0x94, 0xda, 0x42, 0x7d, 0x3f, 0x42
	.byte 0x24, 0xed, 0x3e, 0x4b, 0xc1, 0xa2, 0xaa, 0xe2, 0xff, 0x13, 0x46, 0xac, 0x41, 0x20, 0x7d, 0x51
	.byte 0x00, 0x24, 0x84, 0x1a, 0x02, 0xfc, 0x9f, 0x08, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 32
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x1ffd
	/* C10 */
	.octa 0x40000000000600040000000000001ffa
	/* C11 */
	.octa 0x0
	/* C22 */
	.octa 0x4000000040010002000000000000161a
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1ffe
	/* C1 */
	.octa 0xff0b8000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x1ffd
	/* C9 */
	.octa 0x1ffd
	/* C10 */
	.octa 0x40000000000600040000000000001ffa
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C22 */
	.octa 0x4000000040010002000000000000161a
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x3fff70
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000180060080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1acb0bed // udiv:aarch64/instrs/integer/arithmetic/div Rd:13 Rn:31 o1:0 00001:00001 Rm:11 0011010110:0011010110 sf:0
	.inst 0xf9b24c3e // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:1 imm12:110010010011 opc:10 111001:111001 size:11
	.inst 0xda94c67f // csneg:aarch64/instrs/integer/conditional/select Rd:31 Rn:19 o2:1 0:0 cond:1100 Rm:20 011010100:011010100 op:1 sf:1
	.inst 0x423f7d42 // ASTLRB-R.R-B Rt:2 Rn:10 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x4b3eed24 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:4 Rn:9 imm3:011 option:111 Rm:30 01011001:01011001 S:0 op:1 sf:0
	.inst 0xe2aaa2c1 // ASTUR-V.RI-S Rt:1 Rn:22 op2:00 imm9:010101010 V:1 op1:10 11100010:11100010
	.inst 0xac4613ff // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:31 Rn:31 Rt2:00100 imm7:0001100 L:1 1011000:1011000 opc:10
	.inst 0x517d2041 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:2 imm12:111101001000 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0x1a842400 // csinc:aarch64/instrs/integer/conditional/select Rd:0 Rn:0 o2:1 0:0 cond:0010 Rm:4 011010100:011010100 op:0 sf:0
	.inst 0x089ffc02 // stlrb:aarch64/instrs/memory/ordered Rt:2 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c210c0
	.zero 1048532
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a2 // ldr c2, [x29, #0]
	.inst 0xc24007a9 // ldr c9, [x29, #1]
	.inst 0xc2400baa // ldr c10, [x29, #2]
	.inst 0xc2400fab // ldr c11, [x29, #3]
	.inst 0xc24013b6 // ldr c22, [x29, #4]
	.inst 0xc24017be // ldr c30, [x29, #5]
	/* Vector registers */
	mrs x29, cptr_el3
	bfc x29, #10, #1
	msr cptr_el3, x29
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_csp_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850032
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030dd // ldr c29, [c6, #3]
	.inst 0xc28b413d // msr ddc_el3, c29
	isb
	.inst 0x826010dd // ldr c29, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr ddc_el3, c29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x6, #0xf
	and x29, x29, x6
	cmp x29, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003a6 // ldr c6, [x29, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24007a6 // ldr c6, [x29, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400ba6 // ldr c6, [x29, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400fa6 // ldr c6, [x29, #3]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc24013a6 // ldr c6, [x29, #4]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc24017a6 // ldr c6, [x29, #5]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401ba6 // ldr c6, [x29, #6]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2401fa6 // ldr c6, [x29, #7]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc24023a6 // ldr c6, [x29, #8]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc24027a6 // ldr c6, [x29, #9]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x6, v1.d[0]
	cmp x29, x6
	b.ne comparison_fail
	ldr x29, =0x0
	mov x6, v1.d[1]
	cmp x29, x6
	b.ne comparison_fail
	ldr x29, =0x0
	mov x6, v4.d[0]
	cmp x29, x6
	b.ne comparison_fail
	ldr x29, =0x0
	mov x6, v4.d[1]
	cmp x29, x6
	b.ne comparison_fail
	ldr x29, =0x0
	mov x6, v31.d[0]
	cmp x29, x6
	b.ne comparison_fail
	ldr x29, =0x0
	mov x6, v31.d[1]
	cmp x29, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000016c4
	ldr x1, =check_data0
	ldr x2, =0x000016c8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffa
	ldr x1, =check_data1
	ldr x2, =0x00001ffb
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x00400030
	ldr x1, =check_data4
	ldr x2, =0x00400050
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr ddc_el3, c29
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
