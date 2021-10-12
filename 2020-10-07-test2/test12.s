.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x5a, 0x08, 0x2c, 0x9b, 0xfe, 0x87, 0x1a, 0x38, 0x2b, 0x7c, 0x7f, 0x42, 0xdf, 0x0a, 0xc2, 0xc2
	.byte 0x50, 0xf7, 0x3e, 0xe2, 0x9e, 0x50, 0x6c, 0x69, 0x82, 0x18, 0xf1, 0xc2, 0x94, 0x0e, 0xde, 0x1a
	.byte 0x21, 0x6a, 0xde, 0xc2, 0x5e, 0x24, 0x94, 0x9a, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1ff6
	/* C2 */
	.octa 0x2000000000100040000000000002000
	/* C4 */
	.octa 0x800000000003000700000000004080a0
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x8000000000fffff79ff40000
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x8000000000fffff79ff40000
	/* C2 */
	.octa 0x800000000003000700fffff79ff40000
	/* C4 */
	.octa 0x800000000003000700000000004080a0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x8000000000fffff79ff40000
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x2000
	/* C30 */
	.octa 0xfffff79ff40000
initial_SP_EL3_value:
	.octa 0x40000000000100050000000000001374
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b2c085a // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:26 Rn:2 Ra:2 o0:0 Rm:12 01:01 U:0 10011011:10011011
	.inst 0x381a87fe // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:31 01:01 imm9:110101000 0:0 opc:00 111000:111000 size:00
	.inst 0x427f7c2b // ALDARB-R.R-B Rt:11 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c20adf // SEAL-C.CC-C Cd:31 Cn:22 0010:0010 opc:00 Cm:2 11000010110:11000010110
	.inst 0xe23ef750 // ALDUR-V.RI-B Rt:16 Rn:26 op2:01 imm9:111101111 V:1 op1:00 11100010:11100010
	.inst 0x696c509e // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:30 Rn:4 Rt2:10100 imm7:1011000 L:1 1010010:1010010 opc:01
	.inst 0xc2f11882 // CVT-C.CR-C Cd:2 Cn:4 0110:0110 0:0 0:0 Rm:17 11000010111:11000010111
	.inst 0x1ade0e94 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:20 Rn:20 o1:1 00001:00001 Rm:30 0011010110:0011010110 sf:0
	.inst 0xc2de6a21 // ORRFLGS-C.CR-C Cd:1 Cn:17 1010:1010 opc:01 Rm:30 11000010110:11000010110
	.inst 0x9a94245e // csinc:aarch64/instrs/integer/conditional/select Rd:30 Rn:2 o2:1 0:0 cond:0010 Rm:20 011010100:011010100 op:0 sf:1
	.inst 0xc2c212e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a64 // ldr c4, [x19, #2]
	.inst 0xc2400e6c // ldr c12, [x19, #3]
	.inst 0xc2401271 // ldr c17, [x19, #4]
	.inst 0xc2401676 // ldr c22, [x19, #5]
	.inst 0xc2401a7e // ldr c30, [x19, #6]
	/* Set up flags and system registers */
	mov x19, #0x20000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850032
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f3 // ldr c19, [c23, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826012f3 // ldr c19, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x23, #0x2
	and x19, x19, x23
	cmp x19, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400277 // ldr c23, [x19, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400677 // ldr c23, [x19, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400a77 // ldr c23, [x19, #2]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2400e77 // ldr c23, [x19, #3]
	.inst 0xc2d7a561 // chkeq c11, c23
	b.ne comparison_fail
	.inst 0xc2401277 // ldr c23, [x19, #4]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401677 // ldr c23, [x19, #5]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401a77 // ldr c23, [x19, #6]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2401e77 // ldr c23, [x19, #7]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2402277 // ldr c23, [x19, #8]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc2402677 // ldr c23, [x19, #9]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x23, v16.d[0]
	cmp x19, x23
	b.ne comparison_fail
	ldr x19, =0x0
	mov x23, v16.d[1]
	cmp x19, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001374
	ldr x1, =check_data0
	ldr x2, =0x00001375
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fef
	ldr x1, =check_data1
	ldr x2, =0x00001ff0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff6
	ldr x1, =check_data2
	ldr x2, =0x00001ff7
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
	ldr x0, =0x00408000
	ldr x1, =check_data4
	ldr x2, =0x00408008
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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
