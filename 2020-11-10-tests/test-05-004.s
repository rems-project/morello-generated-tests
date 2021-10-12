.section data0, #alloc, #write
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x21, 0xd8, 0xa1, 0x82, 0xde, 0xdb, 0xae, 0xf9, 0x7e, 0x2b, 0x71, 0x28, 0xa0, 0xea, 0xcd, 0xc2
	.byte 0x60, 0xa2, 0xfe, 0xc2, 0x01, 0x1b, 0x33, 0x2d, 0x8b, 0x99, 0xd8, 0x69, 0x7d, 0x19, 0xf6, 0x28
	.byte 0x4d, 0x94, 0x03, 0x38, 0xe0, 0x93, 0x04, 0x3d, 0x40, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x400000005801080200000000000001d0
	/* C2 */
	.octa 0x1004
	/* C12 */
	.octa 0xf64
	/* C13 */
	.octa 0x0
	/* C19 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0x2000
	/* C27 */
	.octa 0x404000
final_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C1 */
	.octa 0x400000005801080200000000000001d0
	/* C2 */
	.octa 0x103d
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0xfb0
	/* C12 */
	.octa 0x1028
	/* C13 */
	.octa 0x0
	/* C19 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0x2000
	/* C27 */
	.octa 0x404000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xf00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800048c400000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000200140050080000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82a1d821 // ASTR-V.RRB-D Rt:1 Rn:1 opc:10 S:1 option:110 Rm:1 1:1 L:0 100000101:100000101
	.inst 0xf9aedbde // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:30 imm12:101110110110 opc:10 111001:111001 size:11
	.inst 0x28712b7e // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:30 Rn:27 Rt2:01010 imm7:1100010 L:1 1010000:1010000 opc:00
	.inst 0xc2cdeaa0 // CTHI-C.CR-C Cd:0 Cn:21 1010:1010 opc:11 Rm:13 11000010110:11000010110
	.inst 0xc2fea260 // BICFLGS-C.CI-C Cd:0 Cn:19 0:0 00:00 imm8:11110101 11000010111:11000010111
	.inst 0x2d331b01 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:1 Rn:24 Rt2:00110 imm7:1100110 L:0 1011010:1011010 opc:00
	.inst 0x69d8998b // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:11 Rn:12 Rt2:00110 imm7:0110001 L:1 1010011:1010011 opc:01
	.inst 0x28f6197d // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:29 Rn:11 Rt2:00110 imm7:1101100 L:1 1010001:1010001 opc:00
	.inst 0x3803944d // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:13 Rn:2 01:01 imm9:000111001 0:0 opc:00 111000:111000 size:00
	.inst 0x3d0493e0 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:0 Rn:31 imm12:000100100100 opc:00 111101:111101 size:00
	.inst 0xc2c21240
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc24008ac // ldr c12, [x5, #2]
	.inst 0xc2400cad // ldr c13, [x5, #3]
	.inst 0xc24010b3 // ldr c19, [x5, #4]
	.inst 0xc24014b8 // ldr c24, [x5, #5]
	.inst 0xc24018bb // ldr c27, [x5, #6]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q0, =0x0
	ldr q1, =0x0
	ldr q6, =0x0
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x3085103d
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603245 // ldr c5, [c18, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601245 // ldr c5, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b2 // ldr c18, [x5, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24004b2 // ldr c18, [x5, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24008b2 // ldr c18, [x5, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400cb2 // ldr c18, [x5, #3]
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	.inst 0xc24010b2 // ldr c18, [x5, #4]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc24014b2 // ldr c18, [x5, #5]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc24018b2 // ldr c18, [x5, #6]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2401cb2 // ldr c18, [x5, #7]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc24020b2 // ldr c18, [x5, #8]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc24024b2 // ldr c18, [x5, #9]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc24028b2 // ldr c18, [x5, #10]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc2402cb2 // ldr c18, [x5, #11]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc24030b2 // ldr c18, [x5, #12]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x18, v0.d[0]
	cmp x5, x18
	b.ne comparison_fail
	ldr x5, =0x0
	mov x18, v0.d[1]
	cmp x5, x18
	b.ne comparison_fail
	ldr x5, =0x0
	mov x18, v1.d[0]
	cmp x5, x18
	b.ne comparison_fail
	ldr x5, =0x0
	mov x18, v1.d[1]
	cmp x5, x18
	b.ne comparison_fail
	ldr x5, =0x0
	mov x18, v6.d[0]
	cmp x5, x18
	b.ne comparison_fail
	ldr x5, =0x0
	mov x18, v6.d[1]
	cmp x5, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001024
	ldr x1, =check_data1
	ldr x2, =0x00001025
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001028
	ldr x1, =check_data2
	ldr x2, =0x00001030
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001050
	ldr x1, =check_data3
	ldr x2, =0x00001058
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f98
	ldr x1, =check_data4
	ldr x2, =0x00001fa0
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
	ldr x0, =0x00403f88
	ldr x1, =check_data6
	ldr x2, =0x00403f90
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
