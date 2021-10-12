.section data0, #alloc, #write
	.byte 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xc0, 0xff, 0x7f, 0x42, 0xfe, 0x33, 0xc5, 0xc2, 0x00, 0x52, 0xe0, 0x38, 0x2a, 0x6c, 0x3c, 0xa9
	.byte 0xde, 0x8c, 0x82, 0xea, 0x52, 0x8a, 0x38, 0x9b, 0xac, 0xc3, 0xbf, 0xf8, 0x20, 0x51, 0xc2, 0xc2
	.zero 4
.data
check_data5:
	.byte 0x30, 0xfc, 0x02, 0x88, 0xf0, 0xe3, 0x7f, 0x22, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000400404490000000000001408
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0xffffffffffffffff
	/* C9 */
	.octa 0x2000800081079007000000000041fffc
	/* C10 */
	.octa 0x0
	/* C16 */
	.octa 0xc0000000000300070000000000001000
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000700070000000000001000
	/* C30 */
	.octa 0x400020
final_cap_values:
	/* C0 */
	.octa 0x81
	/* C1 */
	.octa 0x40000000400404490000000000001408
	/* C2 */
	.octa 0x1
	/* C6 */
	.octa 0xffffffffffffffff
	/* C9 */
	.octa 0x2000800081079007000000000041fffc
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x81
	/* C16 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000700070000000000001000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000200140050080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x427fffc0 // ALDAR-R.R-32 Rt:0 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c533fe // CVTP-R.C-C Rd:30 Cn:31 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x38e05200 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:16 00:00 opc:101 0:0 Rs:0 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xa93c6c2a // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:10 Rn:1 Rt2:11011 imm7:1111000 L:0 1010010:1010010 opc:10
	.inst 0xea828cde // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:6 imm6:100011 Rm:2 N:0 shift:10 01010:01010 opc:11 sf:1
	.inst 0x9b388a52 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:18 Rn:18 Ra:2 o0:1 Rm:24 01:01 U:0 10011011:10011011
	.inst 0xf8bfc3ac // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:12 Rn:29 110000:110000 Rs:11111 111000101:111000101 size:11
	.inst 0xc2c25120 // RET-C-C 00000:00000 Cn:9 100:100 opc:10 11000010110000100:11000010110000100
	.zero 131036
	.inst 0x8802fc30 // stlxr:aarch64/instrs/memory/exclusive/single Rt:16 Rn:1 Rt2:11111 o0:1 Rs:2 0:0 L:0 0010000:0010000 size:10
	.inst 0x227fe3f0 // LDAXP-C.R-C Ct:16 Rn:31 Ct2:11000 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xc2c212e0
	.zero 917496
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa6 // ldr c6, [x21, #2]
	.inst 0xc2400ea9 // ldr c9, [x21, #3]
	.inst 0xc24012aa // ldr c10, [x21, #4]
	.inst 0xc24016b0 // ldr c16, [x21, #5]
	.inst 0xc2401abb // ldr c27, [x21, #6]
	.inst 0xc2401ebd // ldr c29, [x21, #7]
	.inst 0xc24022be // ldr c30, [x21, #8]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x3085103f
	msr SCTLR_EL3, x21
	ldr x21, =0x8
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f5 // ldr c21, [c23, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826012f5 // ldr c21, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x23, #0xf
	and x21, x21, x23
	cmp x21, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b7 // ldr c23, [x21, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24006b7 // ldr c23, [x21, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400ab7 // ldr c23, [x21, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400eb7 // ldr c23, [x21, #3]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc24012b7 // ldr c23, [x21, #4]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc24016b7 // ldr c23, [x21, #5]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2401ab7 // ldr c23, [x21, #6]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401eb7 // ldr c23, [x21, #7]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc24022b7 // ldr c23, [x21, #8]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc24026b7 // ldr c23, [x21, #9]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2402ab7 // ldr c23, [x21, #10]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2402eb7 // ldr c23, [x21, #11]
	.inst 0xc2d7a7c1 // chkeq c30, c23
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013c8
	ldr x1, =check_data2
	ldr x2, =0x000013d8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001408
	ldr x1, =check_data3
	ldr x2, =0x0000140c
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
	ldr x0, =0x0041fffc
	ldr x1, =check_data5
	ldr x2, =0x00420008
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
