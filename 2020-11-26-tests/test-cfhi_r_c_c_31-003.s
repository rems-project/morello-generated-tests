.section data0, #alloc, #write
	.byte 0x01, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x02, 0xac, 0x00, 0x00, 0x00, 0x00, 0xb1, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfa, 0x00, 0x20, 0x78, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xbd, 0x0f
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x27, 0x08, 0x43, 0x82, 0xa0, 0x13, 0x57, 0xe2, 0x41, 0xe0, 0xcf, 0x42, 0x19, 0x7c, 0x1f, 0x42
	.byte 0xb3, 0x4b, 0xf1, 0x2c, 0xf0, 0x53, 0xc1, 0xc2, 0xe5, 0x9b, 0xe2, 0xc2, 0x3e, 0xcc, 0x8c, 0xe2
	.byte 0x0f, 0x48, 0x50, 0x7a, 0x70, 0x44, 0x9f, 0x82, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfbd
	/* C1 */
	.octa 0xf3d
	/* C2 */
	.octa 0x90000000000100070000000000000e10
	/* C3 */
	.octa 0x183c
	/* C7 */
	.octa 0x0
	/* C25 */
	.octa 0x400000b100000000ac0200000000
	/* C29 */
	.octa 0x8000000000010007000000000000180c
	/* C30 */
	.octa 0x782000fa0000000000007000000000
final_cap_values:
	/* C0 */
	.octa 0xfbd
	/* C1 */
	.octa 0x10000000000000000000000f01
	/* C2 */
	.octa 0x90000000000100070000000000000e10
	/* C3 */
	.octa 0x183c
	/* C5 */
	.octa 0x3
	/* C7 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x400000b100000000ac0200000000
	/* C29 */
	.octa 0x80000000000100070000000000001794
	/* C30 */
	.octa 0x782000fa0000000000007000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080100000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000007842004300ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82430827 // ASTR-R.RI-32 Rt:7 Rn:1 op:10 imm9:000110000 L:0 1000001001:1000001001
	.inst 0xe25713a0 // ASTURH-R.RI-32 Rt:0 Rn:29 op2:00 imm9:101110001 V:0 op1:01 11100010:11100010
	.inst 0x42cfe041 // LDP-C.RIB-C Ct:1 Rn:2 Ct2:11000 imm7:0011111 L:1 010000101:010000101
	.inst 0x421f7c19 // ASTLR-C.R-C Ct:25 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x2cf14bb3 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:19 Rn:29 Rt2:10010 imm7:1100010 L:1 1011001:1011001 opc:00
	.inst 0xc2c153f0 // 0xc2c153f0
	.inst 0xc2e29be5 // SUBS-R.CC-C Rd:5 Cn:31 100110:100110 Cm:2 11000010111:11000010111
	.inst 0xe28ccc3e // ASTUR-C.RI-C Ct:30 Rn:1 op2:11 imm9:011001100 V:0 op1:10 11100010:11100010
	.inst 0x7a50480f // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1111 0:0 Rn:0 10:10 cond:0100 imm5:10000 111010010:111010010 op:1 sf:0
	.inst 0x829f4470 // ALDRSB-R.RRB-64 Rt:16 Rn:3 opc:01 S:0 option:010 Rm:31 0:0 L:0 100000101:100000101
	.inst 0xc2c21140
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac2 // ldr c2, [x22, #2]
	.inst 0xc2400ec3 // ldr c3, [x22, #3]
	.inst 0xc24012c7 // ldr c7, [x22, #4]
	.inst 0xc24016d9 // ldr c25, [x22, #5]
	.inst 0xc2401add // ldr c29, [x22, #6]
	.inst 0xc2401ede // ldr c30, [x22, #7]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603156 // ldr c22, [c10, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601156 // ldr c22, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x10, #0xf
	and x22, x22, x10
	cmp x22, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002ca // ldr c10, [x22, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24006ca // ldr c10, [x22, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400aca // ldr c10, [x22, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400eca // ldr c10, [x22, #3]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc24012ca // ldr c10, [x22, #4]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc24016ca // ldr c10, [x22, #5]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc2401aca // ldr c10, [x22, #6]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc2401eca // ldr c10, [x22, #7]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc24022ca // ldr c10, [x22, #8]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc24026ca // ldr c10, [x22, #9]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2402aca // ldr c10, [x22, #10]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x10, v18.d[0]
	cmp x22, x10
	b.ne comparison_fail
	ldr x22, =0x0
	mov x10, v18.d[1]
	cmp x22, x10
	b.ne comparison_fail
	ldr x22, =0x0
	mov x10, v19.d[0]
	cmp x22, x10
	b.ne comparison_fail
	ldr x22, =0x0
	mov x10, v19.d[1]
	cmp x22, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017c0
	ldr x1, =check_data2
	ldr x2, =0x000017c2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000180c
	ldr x1, =check_data3
	ldr x2, =0x00001814
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0000187f
	ldr x1, =check_data4
	ldr x2, =0x00001880
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
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
