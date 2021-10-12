.section data0, #alloc, #write
	.zero 256
	.byte 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.byte 0xf4, 0x0f, 0xf4, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xff, 0xff, 0xff, 0xff
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xff, 0xb7, 0x12, 0xc2, 0xde, 0x13, 0xe9, 0xb8, 0x71, 0xa7, 0x81, 0xda, 0x05, 0xfc, 0x01, 0x22
	.byte 0x1f, 0x20, 0x7d, 0x78, 0x7e, 0xaf, 0x50, 0x11, 0xe1, 0x5d, 0xff, 0x6a, 0x1e, 0x18, 0xfe, 0xc2
	.byte 0x13, 0x7d, 0xdf, 0x08, 0xbd, 0xeb, 0x00, 0x78, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x700070000000000001000
	/* C5 */
	.octa 0x4000000000000000000000000000
	/* C8 */
	.octa 0x1380
	/* C9 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C27 */
	.octa 0x1fbd3000
	/* C29 */
	.octa 0xff4
	/* C30 */
	.octa 0x1100
final_cap_values:
	/* C0 */
	.octa 0x700070000000000001000
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x4000000000000000000000000000
	/* C8 */
	.octa 0x1380
	/* C9 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x1fbd3000
	/* C29 */
	.octa 0xff4
	/* C30 */
	.octa 0x70007000000001fffe000
initial_SP_EL3_value:
	.octa 0xffffffffffffd130
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004406c8040000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000000704a600ffffffffffc001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc212b7ff // STR-C.RIB-C Ct:31 Rn:31 imm12:010010101101 L:0 110000100:110000100
	.inst 0xb8e913de // ldclr:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:30 00:00 opc:001 0:0 Rs:9 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xda81a771 // csneg:aarch64/instrs/integer/conditional/select Rd:17 Rn:27 o2:1 0:0 cond:1010 Rm:1 011010100:011010100 op:1 sf:1
	.inst 0x2201fc05 // STLXR-R.CR-C Ct:5 Rn:0 (1)(1)(1)(1)(1):11111 1:1 Rs:1 0:0 L:0 001000100:001000100
	.inst 0x787d201f // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:010 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x1150af7e // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:27 imm12:010000101011 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0x6aff5de1 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:15 imm6:010111 Rm:31 N:1 shift:11 01010:01010 opc:11 sf:0
	.inst 0xc2fe181e // CVT-C.CR-C Cd:30 Cn:0 0110:0110 0:0 0:0 Rm:30 11000010111:11000010111
	.inst 0x08df7d13 // ldlarb:aarch64/instrs/memory/ordered Rt:19 Rn:8 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x7800ebbd // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:29 Rn:29 10:10 imm9:000001110 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c210e0
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400705 // ldr c5, [x24, #1]
	.inst 0xc2400b08 // ldr c8, [x24, #2]
	.inst 0xc2400f09 // ldr c9, [x24, #3]
	.inst 0xc240130f // ldr c15, [x24, #4]
	.inst 0xc240171b // ldr c27, [x24, #5]
	.inst 0xc2401b1d // ldr c29, [x24, #6]
	.inst 0xc2401f1e // ldr c30, [x24, #7]
	/* Set up flags and system registers */
	mov x24, #0x80000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x3085103d
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f8 // ldr c24, [c7, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x826010f8 // ldr c24, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x7, #0xf
	and x24, x24, x7
	cmp x24, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400307 // ldr c7, [x24, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400707 // ldr c7, [x24, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400b07 // ldr c7, [x24, #2]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc2400f07 // ldr c7, [x24, #3]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc2401307 // ldr c7, [x24, #4]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401707 // ldr c7, [x24, #5]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401b07 // ldr c7, [x24, #6]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2401f07 // ldr c7, [x24, #7]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402307 // ldr c7, [x24, #8]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402707 // ldr c7, [x24, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001104
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001380
	ldr x1, =check_data2
	ldr x2, =0x00001381
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c00
	ldr x1, =check_data3
	ldr x2, =0x00001c10
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
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
