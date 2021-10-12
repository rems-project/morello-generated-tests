.section data0, #alloc, #write
	.zero 3952
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2e, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 128
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x2e, 0x10, 0x00, 0x00
.data
check_data3:
	.byte 0x22, 0x4c, 0xc0, 0x78, 0xa2, 0xdb, 0xd2, 0xc2, 0xc2, 0x19, 0xcc, 0xc2, 0x60, 0x2d, 0xb8, 0x02
	.byte 0xa0, 0x38, 0x88, 0xe2, 0x09, 0x9c, 0x07, 0x79, 0xde, 0x8b, 0x50, 0x02, 0x32, 0x50, 0xfd, 0x69
	.byte 0x0f, 0x12, 0xc0, 0x5a, 0xc0, 0x95, 0xa6, 0xe2, 0x60, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x424000
	/* C5 */
	.octa 0x80000000000500060000000000001ef5
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x40002000000000001000003d
	/* C14 */
	.octa 0x80000000000700030000000000001003
	/* C29 */
	.octa 0x1009c01f007fffe000000001
	/* C30 */
	.octa 0x80062007007fffffffc90000
final_cap_values:
	/* C0 */
	.octa 0x102e
	/* C1 */
	.octa 0x423fec
	/* C2 */
	.octa 0x80000000000700030000000000000000
	/* C5 */
	.octa 0x80000000000500060000000000001ef5
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x40002000000000001000003d
	/* C14 */
	.octa 0x80000000000700030000000000001003
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0x1009c01f007fffe000000001
	/* C30 */
	.octa 0x8006200700800000000b2000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000200600070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78c04c22 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:1 11:11 imm9:000000100 0:0 opc:11 111000:111000 size:01
	.inst 0xc2d2dba2 // ALIGNU-C.CI-C Cd:2 Cn:29 0110:0110 U:1 imm6:100101 11000010110:11000010110
	.inst 0xc2cc19c2 // ALIGND-C.CI-C Cd:2 Cn:14 0110:0110 U:0 imm6:011000 11000010110:11000010110
	.inst 0x02b82d60 // SUB-C.CIS-C Cd:0 Cn:11 imm12:111000001011 sh:0 A:1 00000010:00000010
	.inst 0xe28838a0 // ALDURSW-R.RI-64 Rt:0 Rn:5 op2:10 imm9:010000011 V:0 op1:10 11100010:11100010
	.inst 0x79079c09 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:9 Rn:0 imm12:000111100111 opc:00 111001:111001 size:01
	.inst 0x02508bde // ADD-C.CIS-C Cd:30 Cn:30 imm12:010000100010 sh:1 A:0 00000010:00000010
	.inst 0x69fd5032 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:18 Rn:1 Rt2:10100 imm7:1111010 L:1 1010011:1010011 opc:01
	.inst 0x5ac0120f // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:15 Rn:16 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0xe2a695c0 // ALDUR-V.RI-S Rt:0 Rn:14 op2:01 imm9:001101001 V:1 op1:10 11100010:11100010
	.inst 0xc2c21260
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400785 // ldr c5, [x28, #1]
	.inst 0xc2400b89 // ldr c9, [x28, #2]
	.inst 0xc2400f8b // ldr c11, [x28, #3]
	.inst 0xc240138e // ldr c14, [x28, #4]
	.inst 0xc240179d // ldr c29, [x28, #5]
	.inst 0xc2401b9e // ldr c30, [x28, #6]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	ldr x28, =0x4
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260327c // ldr c28, [c19, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260127c // ldr c28, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400393 // ldr c19, [x28, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400793 // ldr c19, [x28, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400b93 // ldr c19, [x28, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400f93 // ldr c19, [x28, #3]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc2401393 // ldr c19, [x28, #4]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc2401793 // ldr c19, [x28, #5]
	.inst 0xc2d3a561 // chkeq c11, c19
	b.ne comparison_fail
	.inst 0xc2401b93 // ldr c19, [x28, #6]
	.inst 0xc2d3a5c1 // chkeq c14, c19
	b.ne comparison_fail
	.inst 0xc2401f93 // ldr c19, [x28, #7]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2402393 // ldr c19, [x28, #8]
	.inst 0xc2d3a681 // chkeq c20, c19
	b.ne comparison_fail
	.inst 0xc2402793 // ldr c19, [x28, #9]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2402b93 // ldr c19, [x28, #10]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x19, v0.d[0]
	cmp x28, x19
	b.ne comparison_fail
	ldr x28, =0x0
	mov x19, v0.d[1]
	cmp x28, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000106c
	ldr x1, =check_data0
	ldr x2, =0x00001070
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013fc
	ldr x1, =check_data1
	ldr x2, =0x000013fe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f78
	ldr x1, =check_data2
	ldr x2, =0x00001f7c
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
	ldr x0, =0x00423fec
	ldr x1, =check_data4
	ldr x2, =0x00423ff4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00424004
	ldr x1, =check_data5
	ldr x2, =0x00424006
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
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
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
