.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x51, 0xd8, 0xc9, 0xc2, 0xe0, 0x93, 0xc0, 0xc2, 0xd8, 0xb4, 0x56, 0xb8, 0x40, 0xd9, 0x39, 0xe2
	.byte 0xe2, 0x53, 0x9e, 0xda, 0x4c, 0x5a, 0xdf, 0xc2, 0x21, 0xf9, 0xb6, 0x9b, 0xa0, 0xda, 0x36, 0xb8
	.byte 0x7f, 0x2e, 0x82, 0x38, 0x2b, 0x9a, 0xd5, 0xc2, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x204000c004007ffffffff80001
	/* C6 */
	.octa 0x400400
	/* C10 */
	.octa 0x40000000540000020000000000001063
	/* C18 */
	.octa 0x100040000000000000000
	/* C19 */
	.octa 0x1fdc
	/* C21 */
	.octa 0x1000
	/* C22 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x40036b
	/* C10 */
	.octa 0x40000000540000020000000000001063
	/* C11 */
	.octa 0x204000c0040080000000000000
	/* C12 */
	.octa 0x100040000000000000000
	/* C17 */
	.octa 0x204000c0040080000000000000
	/* C18 */
	.octa 0x100040000000000000000
	/* C19 */
	.octa 0x1ffe
	/* C21 */
	.octa 0x1000
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c9d851 // ALIGNU-C.CI-C Cd:17 Cn:2 0110:0110 U:1 imm6:010011 11000010110:11000010110
	.inst 0xc2c093e0 // GCTAG-R.C-C Rd:0 Cn:31 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xb856b4d8 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:24 Rn:6 01:01 imm9:101101011 0:0 opc:01 111000:111000 size:10
	.inst 0xe239d940 // ASTUR-V.RI-Q Rt:0 Rn:10 op2:10 imm9:110011101 V:1 op1:00 11100010:11100010
	.inst 0xda9e53e2 // csinv:aarch64/instrs/integer/conditional/select Rd:2 Rn:31 o2:0 0:0 cond:0101 Rm:30 011010100:011010100 op:1 sf:1
	.inst 0xc2df5a4c // ALIGNU-C.CI-C Cd:12 Cn:18 0110:0110 U:1 imm6:111110 11000010110:11000010110
	.inst 0x9bb6f921 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:9 Ra:30 o0:1 Rm:22 01:01 U:1 10011011:10011011
	.inst 0xb836daa0 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:0 Rn:21 10:10 S:1 option:110 Rm:22 1:1 opc:00 111000:111000 size:10
	.inst 0x38822e7f // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:19 11:11 imm9:000100010 0:0 opc:10 111000:111000 size:00
	.inst 0xc2d59a2b // ALIGND-C.CI-C Cd:11 Cn:17 0110:0110 U:0 imm6:101011 11000010110:11000010110
	.inst 0xc2c212e0
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
	.inst 0xc2400382 // ldr c2, [x28, #0]
	.inst 0xc2400786 // ldr c6, [x28, #1]
	.inst 0xc2400b8a // ldr c10, [x28, #2]
	.inst 0xc2400f92 // ldr c18, [x28, #3]
	.inst 0xc2401393 // ldr c19, [x28, #4]
	.inst 0xc2401795 // ldr c21, [x28, #5]
	.inst 0xc2401b96 // ldr c22, [x28, #6]
	/* Vector registers */
	mrs x28, cptr_el3
	bfc x28, #10, #1
	msr cptr_el3, x28
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850032
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032fc // ldr c28, [c23, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x826012fc // ldr c28, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x23, #0x8
	and x28, x28, x23
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400397 // ldr c23, [x28, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400797 // ldr c23, [x28, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400b97 // ldr c23, [x28, #2]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc2400f97 // ldr c23, [x28, #3]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2401397 // ldr c23, [x28, #4]
	.inst 0xc2d7a561 // chkeq c11, c23
	b.ne comparison_fail
	.inst 0xc2401797 // ldr c23, [x28, #5]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401b97 // ldr c23, [x28, #6]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401f97 // ldr c23, [x28, #7]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2402397 // ldr c23, [x28, #8]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc2402797 // ldr c23, [x28, #9]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc2402b97 // ldr c23, [x28, #10]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2402f97 // ldr c23, [x28, #11]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x23, v0.d[0]
	cmp x28, x23
	b.ne comparison_fail
	ldr x28, =0x0
	mov x23, v0.d[1]
	cmp x28, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400400
	ldr x1, =check_data3
	ldr x2, =0x00400404
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
