.section data0, #alloc, #write
	.zero 2048
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2016
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00
.data
check_data0:
	.byte 0x01, 0x80
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xd3
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xd0, 0x37, 0x80, 0x78, 0x91, 0xc2, 0xc1, 0xc2, 0x69, 0x73, 0x7f, 0x22, 0x3f, 0x50, 0x33, 0x78
	.byte 0x00, 0xb8, 0xcb, 0xc2, 0x83, 0x04, 0x20, 0x22, 0xe1, 0x22, 0xca, 0x9a, 0xde, 0xa7, 0x52, 0x82
	.byte 0xe0, 0x9b, 0xf7, 0xc2, 0x5f, 0x43, 0x3f, 0x38, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x700060000000000000000
	/* C1 */
	.octa 0xc0000000000100050000000000001808
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x4c0000000001000500000000004fffc0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0xc0000000000100050000000000001ffe
	/* C27 */
	.octa 0x80100000400000020000000000001960
	/* C30 */
	.octa 0x80000000000100060000000000001ad0
final_cap_values:
	/* C0 */
	.octa 0x3
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x4c0000000001000500000000004fffc0
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0xc0000000000100050000000000001ffe
	/* C27 */
	.octa 0x80100000400000020000000000001960
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000100060000000000001ad3
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001960
	.dword 0x0000000000001970
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x788037d0 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:16 Rn:30 01:01 imm9:000000011 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c1c291 // CVT-R.CC-C Rd:17 Cn:20 110000:110000 Cm:1 11000010110:11000010110
	.inst 0x227f7369 // 0x227f7369
	.inst 0x7833503f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:101 o3:0 Rs:19 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2cbb800 // SCBNDS-C.CI-C Cd:0 Cn:0 1110:1110 S:0 imm6:010111 11000010110:11000010110
	.inst 0x22200483 // 0x22200483
	.inst 0x9aca22e1 // lslv:aarch64/instrs/integer/shift/variable Rd:1 Rn:23 op2:00 0010:0010 Rm:10 0011010110:0011010110 sf:1
	.inst 0x8252a7de // ASTRB-R.RI-B Rt:30 Rn:30 op:01 imm9:100101010 L:0 1000001001:1000001001
	.inst 0xc2f79be0 // SUBS-R.CC-C Rd:0 Cn:31 100110:100110 Cm:23 11000010111:11000010111
	.inst 0x383f435f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:26 00:00 opc:100 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c21180
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc2400843 // ldr c3, [x2, #2]
	.inst 0xc2400c44 // ldr c4, [x2, #3]
	.inst 0xc2401053 // ldr c19, [x2, #4]
	.inst 0xc2401454 // ldr c20, [x2, #5]
	.inst 0xc2401857 // ldr c23, [x2, #6]
	.inst 0xc2401c5a // ldr c26, [x2, #7]
	.inst 0xc240205b // ldr c27, [x2, #8]
	.inst 0xc240245e // ldr c30, [x2, #9]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	ldr x2, =0x0
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603182 // ldr c2, [c12, #3]
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	.inst 0x82601182 // ldr c2, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x12, #0xf
	and x2, x2, x12
	cmp x2, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc240004c // ldr c12, [x2, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240044c // ldr c12, [x2, #1]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc240084c // ldr c12, [x2, #2]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc2400c4c // ldr c12, [x2, #3]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc240104c // ldr c12, [x2, #4]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240144c // ldr c12, [x2, #5]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc240184c // ldr c12, [x2, #6]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2401c4c // ldr c12, [x2, #7]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc240204c // ldr c12, [x2, #8]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc240244c // ldr c12, [x2, #9]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc240284c // ldr c12, [x2, #10]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc2402c4c // ldr c12, [x2, #11]
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	.inst 0xc240304c // ldr c12, [x2, #12]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001808
	ldr x1, =check_data0
	ldr x2, =0x0000180a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001960
	ldr x1, =check_data1
	ldr x2, =0x00001980
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ad0
	ldr x1, =check_data2
	ldr x2, =0x00001ad2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001bfd
	ldr x1, =check_data3
	ldr x2, =0x00001bfe
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
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
