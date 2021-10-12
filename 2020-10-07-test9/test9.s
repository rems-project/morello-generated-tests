.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xfe, 0x07, 0x73, 0x82, 0x21, 0xa4, 0xdf, 0xc2, 0x20, 0x84, 0xa1, 0x9b, 0x00, 0x05, 0xd2, 0xc2
	.byte 0x2d, 0x70, 0x1b, 0x38, 0x00, 0x80, 0x03, 0x1b, 0x3e, 0x74, 0xdb, 0x2d, 0x5f, 0x24, 0xc9, 0x38
	.byte 0xef, 0x43, 0x88, 0x1a, 0x9f, 0xf9, 0xc6, 0xc2, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc00000000007001b0000000000001100
	/* C2 */
	.octa 0x800000000001000500000000004ffffe
	/* C8 */
	.octa 0x70006000040000003c001
	/* C12 */
	.octa 0x10000300070000000000000000
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x400121040001000000040001
final_cap_values:
	/* C1 */
	.octa 0xc00000000007001b00000000000011d8
	/* C2 */
	.octa 0x80000000000100050000000000500090
	/* C8 */
	.octa 0x70006000040000003c001
	/* C12 */
	.octa 0x10000300070000000000000000
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x3c001
	/* C18 */
	.octa 0x400121040001000000040001
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x430000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004181f002000000000042c001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x827307fe // ALDRB-R.RI-B Rt:30 Rn:31 op:01 imm9:100110000 L:1 1000001001:1000001001
	.inst 0xc2dfa421 // CHKEQ-_.CC-C 00001:00001 Cn:1 001:001 opc:01 1:1 Cm:31 11000010110:11000010110
	.inst 0x9ba18420 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:1 Ra:1 o0:1 Rm:1 01:01 U:1 10011011:10011011
	.inst 0xc2d20500 // BUILD-C.C-C Cd:0 Cn:8 001:001 opc:00 0:0 Cm:18 11000010110:11000010110
	.inst 0x381b702d // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:13 Rn:1 00:00 imm9:110110111 0:0 opc:00 111000:111000 size:00
	.inst 0x1b038000 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:0 Rn:0 Ra:0 o0:1 Rm:3 0011011000:0011011000 sf:0
	.inst 0x2ddb743e // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:30 Rn:1 Rt2:11101 imm7:0110110 L:1 1011011:1011011 opc:00
	.inst 0x38c9245f // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:2 01:01 imm9:010010010 0:0 opc:11 111000:111000 size:00
	.inst 0x1a8843ef // csel:aarch64/instrs/integer/conditional/select Rd:15 Rn:31 o2:0 0:0 cond:0100 Rm:8 011010100:011010100 op:0 sf:0
	.inst 0xc2c6f99f // SCBNDS-C.CI-S Cd:31 Cn:12 1110:1110 S:1 imm6:001101 11000010110:11000010110
	.inst 0xc2c210c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a08 // ldr c8, [x16, #2]
	.inst 0xc2400e0c // ldr c12, [x16, #3]
	.inst 0xc240120d // ldr c13, [x16, #4]
	.inst 0xc2401612 // ldr c18, [x16, #5]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x3085003a
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d0 // ldr c16, [c6, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x826010d0 // ldr c16, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x6, #0xf
	and x16, x16, x6
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400206 // ldr c6, [x16, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400606 // ldr c6, [x16, #1]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400a06 // ldr c6, [x16, #2]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2400e06 // ldr c6, [x16, #3]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc2401206 // ldr c6, [x16, #4]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2401606 // ldr c6, [x16, #5]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401a06 // ldr c6, [x16, #6]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2401e06 // ldr c6, [x16, #7]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x6, v29.d[0]
	cmp x16, x6
	b.ne comparison_fail
	ldr x16, =0x0
	mov x6, v29.d[1]
	cmp x16, x6
	b.ne comparison_fail
	ldr x16, =0x0
	mov x6, v30.d[0]
	cmp x16, x6
	b.ne comparison_fail
	ldr x16, =0x0
	mov x6, v30.d[1]
	cmp x16, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010b7
	ldr x1, =check_data0
	ldr x2, =0x000010b8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011d8
	ldr x1, =check_data1
	ldr x2, =0x000011e0
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
	ldr x0, =0x00430130
	ldr x1, =check_data3
	ldr x2, =0x00430131
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
