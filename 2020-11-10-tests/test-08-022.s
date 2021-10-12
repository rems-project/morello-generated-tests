.section data0, #alloc, #write
	.byte 0x94, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2928
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1136
.data
check_data0:
	.byte 0x94, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x01, 0x80
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x3f, 0x51, 0x3e, 0x78, 0xa7, 0x6a, 0x7f, 0x38, 0x5e, 0x7e, 0xa1, 0xa2, 0x42, 0x67, 0x4a, 0xa2
	.byte 0xfe, 0x7f, 0x5f, 0x22, 0x5f, 0xb9, 0xcf, 0x2c, 0x5c, 0xf4, 0xb0, 0x2c, 0xfe, 0x13, 0xc0, 0x5a
	.byte 0x45, 0x7b, 0xe2, 0xca, 0x7e, 0x6b, 0xc1, 0xc2, 0xa0, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C9 */
	.octa 0x1b84
	/* C10 */
	.octa 0x1ff4
	/* C18 */
	.octa 0x1f80
	/* C21 */
	.octa 0x1f95
	/* C26 */
	.octa 0x1000
	/* C27 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x4000000000000000000000000000
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1f18
	/* C5 */
	.octa 0xffff839fffffe59f
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x1b84
	/* C10 */
	.octa 0x2070
	/* C18 */
	.octa 0x1f80
	/* C21 */
	.octa 0x1f95
	/* C26 */
	.octa 0x1a60
	/* C27 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x3fff800000000000000000000000
initial_SP_EL3_value:
	.octa 0x1fe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc800000060000f970000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x783e513f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:9 00:00 opc:101 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x387f6aa7 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:7 Rn:21 10:10 S:0 option:011 Rm:31 1:1 opc:01 111000:111000 size:00
	.inst 0xa2a17e5e // CAS-C.R-C Ct:30 Rn:18 11111:11111 R:0 Cs:1 1:1 L:0 1:1 10100010:10100010
	.inst 0xa24a6742 // LDR-C.RIAW-C Ct:2 Rn:26 01:01 imm9:010100110 0:0 opc:01 10100010:10100010
	.inst 0x225f7ffe // LDXR-C.R-C Ct:30 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x2ccfb95f // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:31 Rn:10 Rt2:01110 imm7:0011111 L:1 1011001:1011001 opc:00
	.inst 0x2cb0f45c // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:28 Rn:2 Rt2:11101 imm7:1100001 L:0 1011001:1011001 opc:00
	.inst 0x5ac013fe // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:31 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0xcae27b45 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:5 Rn:26 imm6:011110 Rm:2 N:1 shift:11 01010:01010 opc:10 sf:1
	.inst 0xc2c16b7e // ORRFLGS-C.CR-C Cd:30 Cn:27 1010:1010 opc:01 Rm:1 11000010110:11000010110
	.inst 0xc2c213a0
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400469 // ldr c9, [x3, #1]
	.inst 0xc240086a // ldr c10, [x3, #2]
	.inst 0xc2400c72 // ldr c18, [x3, #3]
	.inst 0xc2401075 // ldr c21, [x3, #4]
	.inst 0xc240147a // ldr c26, [x3, #5]
	.inst 0xc240187b // ldr c27, [x3, #6]
	.inst 0xc2401c7e // ldr c30, [x3, #7]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q28, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x3085103f
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033a3 // ldr c3, [c29, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x826013a3 // ldr c3, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240007d // ldr c29, [x3, #0]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc240047d // ldr c29, [x3, #1]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc240087d // ldr c29, [x3, #2]
	.inst 0xc2dda4a1 // chkeq c5, c29
	b.ne comparison_fail
	.inst 0xc2400c7d // ldr c29, [x3, #3]
	.inst 0xc2dda4e1 // chkeq c7, c29
	b.ne comparison_fail
	.inst 0xc240107d // ldr c29, [x3, #4]
	.inst 0xc2dda521 // chkeq c9, c29
	b.ne comparison_fail
	.inst 0xc240147d // ldr c29, [x3, #5]
	.inst 0xc2dda541 // chkeq c10, c29
	b.ne comparison_fail
	.inst 0xc240187d // ldr c29, [x3, #6]
	.inst 0xc2dda641 // chkeq c18, c29
	b.ne comparison_fail
	.inst 0xc2401c7d // ldr c29, [x3, #7]
	.inst 0xc2dda6a1 // chkeq c21, c29
	b.ne comparison_fail
	.inst 0xc240207d // ldr c29, [x3, #8]
	.inst 0xc2dda741 // chkeq c26, c29
	b.ne comparison_fail
	.inst 0xc240247d // ldr c29, [x3, #9]
	.inst 0xc2dda761 // chkeq c27, c29
	b.ne comparison_fail
	.inst 0xc240287d // ldr c29, [x3, #10]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x29, v14.d[0]
	cmp x3, x29
	b.ne comparison_fail
	ldr x3, =0x0
	mov x29, v14.d[1]
	cmp x3, x29
	b.ne comparison_fail
	ldr x3, =0x0
	mov x29, v28.d[0]
	cmp x3, x29
	b.ne comparison_fail
	ldr x3, =0x0
	mov x29, v28.d[1]
	cmp x3, x29
	b.ne comparison_fail
	ldr x3, =0x0
	mov x29, v29.d[0]
	cmp x3, x29
	b.ne comparison_fail
	ldr x3, =0x0
	mov x29, v29.d[1]
	cmp x3, x29
	b.ne comparison_fail
	ldr x3, =0x0
	mov x29, v31.d[0]
	cmp x3, x29
	b.ne comparison_fail
	ldr x3, =0x0
	mov x29, v31.d[1]
	cmp x3, x29
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
	ldr x0, =0x00001b84
	ldr x1, =check_data1
	ldr x2, =0x00001b86
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f80
	ldr x1, =check_data2
	ldr x2, =0x00001f90
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f94
	ldr x1, =check_data3
	ldr x2, =0x00001f9c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001ff0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff4
	ldr x1, =check_data5
	ldr x2, =0x00001ffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
