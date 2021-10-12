.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xae, 0xe3, 0xfa, 0xf2, 0x00, 0x6c, 0xcb, 0xe2, 0x3e, 0x16, 0x55, 0x38, 0x9f, 0xfe, 0x01, 0xc8
	.byte 0x10, 0x39, 0x7f, 0x22, 0x5d, 0x84, 0xa0, 0x9b, 0x12, 0xe4, 0x13, 0xe2, 0x01, 0xd0, 0xc0, 0xc2
	.byte 0x82, 0x50, 0xc2, 0xc2
.data
check_data5:
	.byte 0x00, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0x03, 0xdc, 0x0a, 0x2c, 0x40, 0x11, 0xc2, 0xc2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000a
	/* C4 */
	.octa 0x200080000001000500000000004ffff4
	/* C8 */
	.octa 0x90000000400000020000000000001000
	/* C17 */
	.octa 0x800000000001000500000000004ffffe
	/* C20 */
	.octa 0x40000000000100050000000000001430
final_cap_values:
	/* C0 */
	.octa 0x1200
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x200080000001000500000000004ffff4
	/* C8 */
	.octa 0x90000000400000020000000000001000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x800000000001000500000000004fff4f
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x40000000000100050000000000001430
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000002200070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000000300060000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf2fae3ae // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:14 imm16:1101011100011101 hw:11 100101:100101 opc:11 sf:1
	.inst 0xe2cb6c00 // ALDUR-C.RI-C Ct:0 Rn:0 op2:11 imm9:010110110 V:0 op1:11 11100010:11100010
	.inst 0x3855163e // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:17 01:01 imm9:101010001 0:0 opc:01 111000:111000 size:00
	.inst 0xc801fe9f // stlxr:aarch64/instrs/memory/exclusive/single Rt:31 Rn:20 Rt2:11111 o0:1 Rs:1 0:0 L:0 0010000:0010000 size:11
	.inst 0x227f3910 // LDXP-C.R-C Ct:16 Rn:8 Ct2:01110 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0x9ba0845d // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:2 Ra:1 o0:1 Rm:0 01:01 U:1 10011011:10011011
	.inst 0xe213e412 // ALDURB-R.RI-32 Rt:18 Rn:0 op2:01 imm9:100111110 V:0 op1:00 11100010:11100010
	.inst 0xc2c0d001 // GCPERM-R.C-C Rd:1 Cn:0 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2c25082 // RETS-C-C 00010:00010 Cn:4 100:100 opc:10 11000010110000100:11000010110000100
	.zero 156
	.inst 0x00001200
	.zero 1048368
	.inst 0x2c0adc03 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:3 Rn:0 Rt2:10111 imm7:0010101 L:0 1011000:1011000 opc:00
	.inst 0xc2c21140
	.zero 4
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400524 // ldr c4, [x9, #1]
	.inst 0xc2400928 // ldr c8, [x9, #2]
	.inst 0xc2400d31 // ldr c17, [x9, #3]
	.inst 0xc2401134 // ldr c20, [x9, #4]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q3, =0x0
	ldr q23, =0x0
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30851037
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603149 // ldr c9, [c10, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601149 // ldr c9, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240012a // ldr c10, [x9, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240052a // ldr c10, [x9, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240092a // ldr c10, [x9, #2]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc2400d2a // ldr c10, [x9, #3]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc240112a // ldr c10, [x9, #4]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc240152a // ldr c10, [x9, #5]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc240192a // ldr c10, [x9, #6]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc2401d2a // ldr c10, [x9, #7]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc240212a // ldr c10, [x9, #8]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc240252a // ldr c10, [x9, #9]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x10, v3.d[0]
	cmp x9, x10
	b.ne comparison_fail
	ldr x9, =0x0
	mov x10, v3.d[1]
	cmp x9, x10
	b.ne comparison_fail
	ldr x9, =0x0
	mov x10, v23.d[0]
	cmp x9, x10
	b.ne comparison_fail
	ldr x9, =0x0
	mov x10, v23.d[1]
	cmp x9, x10
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
	ldr x0, =0x0000113e
	ldr x1, =check_data1
	ldr x2, =0x0000113f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001254
	ldr x1, =check_data2
	ldr x2, =0x0000125c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001430
	ldr x1, =check_data3
	ldr x2, =0x00001438
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400024
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004000c0
	ldr x1, =check_data5
	ldr x2, =0x004000d0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff4
	ldr x1, =check_data6
	ldr x2, =0x004ffffc
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffffe
	ldr x1, =check_data7
	ldr x2, =0x004fffff
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
