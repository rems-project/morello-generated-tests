.section data0, #alloc, #write
	.zero 2048
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x01
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x55, 0x2c, 0x02, 0xb8, 0xfd, 0x07, 0x93, 0x38, 0x69, 0x73, 0x7f, 0x22, 0x20, 0x6c, 0xbf, 0x9b
	.byte 0xd0, 0xf0, 0x5b, 0xa2, 0x83, 0x04, 0x20, 0x22, 0x1e, 0x14, 0x69, 0xe2, 0xe0, 0xab, 0x7f, 0x22
	.byte 0xe1, 0x5b, 0xe7, 0xc2, 0xbf, 0x61, 0x79, 0xb8, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000000100070000000000001002
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x48000000000700130000000000001000
	/* C6 */
	.octa 0x900000001007cfc70000000000400041
	/* C7 */
	.octa 0x0
	/* C13 */
	.octa 0xc0000000000700930000000000001800
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x1000000
	/* C27 */
	.octa 0x90000000041300070000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000000100070000000000001024
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x48000000000700130000000000001000
	/* C6 */
	.octa 0x900000001007cfc70000000000400041
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0xc0000000000700930000000000001800
	/* C16 */
	.octa 0x9bbf6c20227f7369389307fdb8022c55
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x1000000
	/* C27 */
	.octa 0x90000000041300070000000000001000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x90100000000062000000000000001850
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600040000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000060001b8100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001790
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 144
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 208
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb8022c55 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:21 Rn:2 11:11 imm9:000100010 0:0 opc:00 111000:111000 size:10
	.inst 0x389307fd // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:31 01:01 imm9:100110000 0:0 opc:10 111000:111000 size:00
	.inst 0x227f7369 // 0x227f7369
	.inst 0x9bbf6c20 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:1 Ra:27 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0xa25bf0d0 // LDUR-C.RI-C Ct:16 Rn:6 00:00 imm9:110111111 0:0 opc:01 10100010:10100010
	.inst 0x22200483 // 0x22200483
	.inst 0xe269141e // ALDUR-V.RI-H Rt:30 Rn:0 op2:01 imm9:010010001 V:1 op1:01 11100010:11100010
	.inst 0x227fabe0 // LDAXP-C.R-C Ct:0 Rn:31 Ct2:01010 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xc2e75be1 // CVTZ-C.CR-C Cd:1 Cn:31 0110:0110 1:1 0:0 Rm:7 11000010111:11000010111
	.inst 0xb87961bf // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:13 00:00 opc:110 o3:0 Rs:25 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2c21280
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
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400903 // ldr c3, [x8, #2]
	.inst 0xc2400d04 // ldr c4, [x8, #3]
	.inst 0xc2401106 // ldr c6, [x8, #4]
	.inst 0xc2401507 // ldr c7, [x8, #5]
	.inst 0xc240190d // ldr c13, [x8, #6]
	.inst 0xc2401d15 // ldr c21, [x8, #7]
	.inst 0xc2402119 // ldr c25, [x8, #8]
	.inst 0xc240251b // ldr c27, [x8, #9]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x3085103f
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603288 // ldr c8, [c20, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601288 // ldr c8, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400114 // ldr c20, [x8, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400514 // ldr c20, [x8, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400914 // ldr c20, [x8, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400d14 // ldr c20, [x8, #3]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2401114 // ldr c20, [x8, #4]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc2401514 // ldr c20, [x8, #5]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2401914 // ldr c20, [x8, #6]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2401d14 // ldr c20, [x8, #7]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2402114 // ldr c20, [x8, #8]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc2402514 // ldr c20, [x8, #9]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2402914 // ldr c20, [x8, #10]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2402d14 // ldr c20, [x8, #11]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc2403114 // ldr c20, [x8, #12]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc2403514 // ldr c20, [x8, #13]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc2403914 // ldr c20, [x8, #14]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2403d14 // ldr c20, [x8, #15]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x20, v30.d[0]
	cmp x8, x20
	b.ne comparison_fail
	ldr x8, =0x0
	mov x20, v30.d[1]
	cmp x8, x20
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
	ldr x0, =0x00001024
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001780
	ldr x1, =check_data2
	ldr x2, =0x000017a0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001804
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001850
	ldr x1, =check_data4
	ldr x2, =0x00001851
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001c12
	ldr x1, =check_data5
	ldr x2, =0x00001c14
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
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
