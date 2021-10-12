.section data0, #alloc, #write
	.zero 256
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x01
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x60, 0x83, 0x3e, 0xb8, 0x61, 0xc9, 0xde, 0xca, 0x21, 0xa1, 0xc2, 0xc2, 0xe0, 0xf3, 0xbf, 0x82
	.byte 0x44, 0xfc, 0x5f, 0x08, 0x9e, 0xb2, 0xc0, 0xc2, 0x47, 0xcc, 0x55, 0xe2, 0xce, 0x18, 0x29, 0x2c
	.byte 0xa2, 0x7d, 0xc4, 0x82, 0x3f, 0x08, 0xc2, 0xc2, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000000100050000000000001106
	/* C6 */
	.octa 0x1100
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x80000000000700070000000000001080
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x107c
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x1
	/* C6 */
	.octa 0x1100
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x80000000000700070000000000001080
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x107c
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000000080080000000000001400
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000410000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004001000400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb83e8360 // swp:aarch64/instrs/memory/atomicops/swp Rt:0 Rn:27 100000:100000 Rs:30 1:1 R:0 A:0 111000:111000 size:10
	.inst 0xcadec961 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:11 imm6:110010 Rm:30 N:0 shift:11 01010:01010 opc:10 sf:1
	.inst 0xc2c2a121 // CLRPERM-C.CR-C Cd:1 Cn:9 000:000 1:1 10:10 Rm:2 11000010110:11000010110
	.inst 0x82bff3e0 // ASTR-R.RRB-32 Rt:0 Rn:31 opc:00 S:1 option:111 Rm:31 1:1 L:0 100000101:100000101
	.inst 0x085ffc44 // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:4 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xc2c0b29e // GCSEAL-R.C-C Rd:30 Cn:20 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xe255cc47 // ALDURSH-R.RI-32 Rt:7 Rn:2 op2:11 imm9:101011100 V:0 op1:01 11100010:11100010
	.inst 0x2c2918ce // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:14 Rn:6 Rt2:00110 imm7:1010010 L:0 1011000:1011000 opc:00
	.inst 0x82c47da2 // ALDRH-R.RRB-32 Rt:2 Rn:13 opc:11 S:1 option:011 Rm:4 0:0 L:1 100000101:100000101
	.inst 0xc2c2083f // SEAL-C.CC-C Cd:31 Cn:1 0010:0010 opc:00 Cm:2 11000010110:11000010110
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
	ldr x12, =initial_cap_values
	.inst 0xc2400182 // ldr c2, [x12, #0]
	.inst 0xc2400586 // ldr c6, [x12, #1]
	.inst 0xc2400989 // ldr c9, [x12, #2]
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc2401194 // ldr c20, [x12, #4]
	.inst 0xc240159b // ldr c27, [x12, #5]
	.inst 0xc240199e // ldr c30, [x12, #6]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q6, =0x0
	ldr q14, =0x0
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x3085103d
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260326c // ldr c12, [c19, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260126c // ldr c12, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400193 // ldr c19, [x12, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400593 // ldr c19, [x12, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400993 // ldr c19, [x12, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400d93 // ldr c19, [x12, #3]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc2401193 // ldr c19, [x12, #4]
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	.inst 0xc2401593 // ldr c19, [x12, #5]
	.inst 0xc2d3a4e1 // chkeq c7, c19
	b.ne comparison_fail
	.inst 0xc2401993 // ldr c19, [x12, #6]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc2401d93 // ldr c19, [x12, #7]
	.inst 0xc2d3a5a1 // chkeq c13, c19
	b.ne comparison_fail
	.inst 0xc2402193 // ldr c19, [x12, #8]
	.inst 0xc2d3a681 // chkeq c20, c19
	b.ne comparison_fail
	.inst 0xc2402593 // ldr c19, [x12, #9]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc2402993 // ldr c19, [x12, #10]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x19, v6.d[0]
	cmp x12, x19
	b.ne comparison_fail
	ldr x12, =0x0
	mov x19, v6.d[1]
	cmp x12, x19
	b.ne comparison_fail
	ldr x12, =0x0
	mov x19, v14.d[0]
	cmp x12, x19
	b.ne comparison_fail
	ldr x12, =0x0
	mov x19, v14.d[1]
	cmp x12, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000104c
	ldr x1, =check_data0
	ldr x2, =0x00001054
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001062
	ldr x1, =check_data1
	ldr x2, =0x00001064
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001084
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000110a
	ldr x1, =check_data3
	ldr x2, =0x0000110b
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001400
	ldr x1, =check_data4
	ldr x2, =0x00001404
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
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
