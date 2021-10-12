.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x4c, 0x13, 0xc0, 0xda, 0xd5, 0x05, 0x4e, 0x2d, 0xa8, 0x9f, 0x15, 0x6d, 0xe4, 0xfc, 0x0d, 0x54
	.byte 0x1c, 0xb0, 0x9d, 0xda, 0xb5, 0x33, 0xc7, 0xc2, 0x2a, 0x80, 0x21, 0x39, 0x41, 0x74, 0xd9, 0xe2
	.byte 0x2a, 0x48, 0x3f, 0xa2, 0x20, 0x7c, 0x9f, 0x08, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1751
	/* C2 */
	.octa 0x800000005fd900000000000000002019
	/* C10 */
	.octa 0x10
	/* C14 */
	.octa 0x1000
	/* C29 */
	.octa 0x1020
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x800000005fd900000000000000002019
	/* C10 */
	.octa 0x10
	/* C14 */
	.octa 0x1000
	/* C21 */
	.octa 0xffffffffffffffff
	/* C28 */
	.octa 0xffffffffffffefdf
	/* C29 */
	.octa 0x1020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000007100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000006f0a0ffe00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac0134c // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:12 Rn:26 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0x2d4e05d5 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:21 Rn:14 Rt2:00001 imm7:0011100 L:1 1011010:1011010 opc:00
	.inst 0x6d159fa8 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:8 Rn:29 Rt2:00111 imm7:0101011 L:0 1011010:1011010 opc:01
	.inst 0x540dfce4 // b_cond:aarch64/instrs/branch/conditional/cond cond:0100 0:0 imm19:0000110111111100111 01010100:01010100
	.inst 0xda9db01c // csinv:aarch64/instrs/integer/conditional/select Rd:28 Rn:0 o2:0 0:0 cond:1011 Rm:29 011010100:011010100 op:1 sf:1
	.inst 0xc2c733b5 // RRMASK-R.R-C Rd:21 Rn:29 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x3921802a // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:10 Rn:1 imm12:100001100000 opc:00 111001:111001 size:00
	.inst 0xe2d97441 // ALDUR-R.RI-64 Rt:1 Rn:2 op2:01 imm9:110010111 V:0 op1:11 11100010:11100010
	.inst 0xa23f482a // STR-C.RRB-C Ct:10 Rn:1 10:10 S:0 option:010 Rm:31 1:1 opc:00 10100010:10100010
	.inst 0x089f7c20 // stllrb:aarch64/instrs/memory/ordered Rt:0 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c21260
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2400cca // ldr c10, [x6, #3]
	.inst 0xc24010ce // ldr c14, [x6, #4]
	.inst 0xc24014dd // ldr c29, [x6, #5]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q7, =0x11000
	ldr q8, =0x0
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851037
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603266 // ldr c6, [c19, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601266 // ldr c6, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x19, #0x9
	and x6, x6, x19
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d3 // ldr c19, [x6, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24004d3 // ldr c19, [x6, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc24008d3 // ldr c19, [x6, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400cd3 // ldr c19, [x6, #3]
	.inst 0xc2d3a541 // chkeq c10, c19
	b.ne comparison_fail
	.inst 0xc24010d3 // ldr c19, [x6, #4]
	.inst 0xc2d3a5c1 // chkeq c14, c19
	b.ne comparison_fail
	.inst 0xc24014d3 // ldr c19, [x6, #5]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc24018d3 // ldr c19, [x6, #6]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc2401cd3 // ldr c19, [x6, #7]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x19, v1.d[0]
	cmp x6, x19
	b.ne comparison_fail
	ldr x6, =0x0
	mov x19, v1.d[1]
	cmp x6, x19
	b.ne comparison_fail
	ldr x6, =0x11000
	mov x19, v7.d[0]
	cmp x6, x19
	b.ne comparison_fail
	ldr x6, =0x0
	mov x19, v7.d[1]
	cmp x6, x19
	b.ne comparison_fail
	ldr x6, =0x0
	mov x19, v8.d[0]
	cmp x6, x19
	b.ne comparison_fail
	ldr x6, =0x0
	mov x19, v8.d[1]
	cmp x6, x19
	b.ne comparison_fail
	ldr x6, =0x0
	mov x19, v21.d[0]
	cmp x6, x19
	b.ne comparison_fail
	ldr x6, =0x0
	mov x19, v21.d[1]
	cmp x6, x19
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
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001078
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001178
	ldr x1, =check_data2
	ldr x2, =0x00001188
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fb0
	ldr x1, =check_data3
	ldr x2, =0x00001fb8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
