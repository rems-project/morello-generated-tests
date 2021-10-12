.section data0, #alloc, #write
	.byte 0x00, 0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 208
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3856
.data
check_data0:
	.byte 0x00, 0x82
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x4e, 0x78, 0x88, 0xf9, 0x40, 0xec, 0x8b, 0xb8, 0x02, 0x41, 0xea, 0x0a, 0x3f, 0x80, 0x79, 0x82
	.byte 0x4d, 0x13, 0xed, 0xe2, 0x0a, 0x7c, 0x0c, 0x48, 0x35, 0x30, 0xc7, 0xc2, 0xff, 0x13, 0xc0, 0xc2
	.byte 0x1f, 0x50, 0x6d, 0x78, 0xba, 0x20, 0x62, 0x38, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x801000007ffc1c7c0000000000000300
	/* C2 */
	.octa 0x1022
	/* C5 */
	.octa 0x1ffe
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C26 */
	.octa 0x400000000001000500000000000017a7
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x801000007ffc1c7c0000000000000300
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x1ffe
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x1
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0xffffffffffffffff
	/* C26 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x300070000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf988784e // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:14 Rn:2 imm12:001000011110 opc:10 111001:111001 size:11
	.inst 0xb88bec40 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:2 11:11 imm9:010111110 0:0 opc:10 111000:111000 size:10
	.inst 0x0aea4102 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:8 imm6:010000 Rm:10 N:1 shift:11 01010:01010 opc:00 sf:0
	.inst 0x8279803f // ALDR-C.RI-C Ct:31 Rn:1 op:00 imm9:110011000 L:1 1000001001:1000001001
	.inst 0xe2ed134d // ASTUR-V.RI-D Rt:13 Rn:26 op2:00 imm9:011010001 V:1 op1:11 11100010:11100010
	.inst 0x480c7c0a // stxrh:aarch64/instrs/memory/exclusive/single Rt:10 Rn:0 Rt2:11111 o0:0 Rs:12 0:0 L:0 0010000:0010000 size:01
	.inst 0xc2c73035 // RRMASK-R.R-C Rd:21 Rn:1 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c013ff // GCBASE-R.C-C Rd:31 Cn:31 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x786d501f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:101 o3:0 Rs:13 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x386220ba // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:5 00:00 opc:010 0:0 Rs:2 1:1 R:1 A:0 111000:111000 size:00
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc2400925 // ldr c5, [x9, #2]
	.inst 0xc2400d28 // ldr c8, [x9, #3]
	.inst 0xc240112a // ldr c10, [x9, #4]
	.inst 0xc240152d // ldr c13, [x9, #5]
	.inst 0xc240193a // ldr c26, [x9, #6]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q13, =0x0
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603249 // ldr c9, [c18, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601249 // ldr c9, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	.inst 0xc2400132 // ldr c18, [x9, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400532 // ldr c18, [x9, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400932 // ldr c18, [x9, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400d32 // ldr c18, [x9, #3]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2401132 // ldr c18, [x9, #4]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc2401532 // ldr c18, [x9, #5]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401932 // ldr c18, [x9, #6]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2401d32 // ldr c18, [x9, #7]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2402132 // ldr c18, [x9, #8]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2402532 // ldr c18, [x9, #9]
	.inst 0xc2d2a741 // chkeq c26, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x18, v13.d[0]
	cmp x9, x18
	b.ne comparison_fail
	ldr x9, =0x0
	mov x18, v13.d[1]
	cmp x9, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x000010e4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001878
	ldr x1, =check_data2
	ldr x2, =0x00001880
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c80
	ldr x1, =check_data3
	ldr x2, =0x00001c90
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
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
