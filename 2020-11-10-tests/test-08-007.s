.section data0, #alloc, #write
	.byte 0xff, 0xfe, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x80
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x7b, 0x10, 0x01, 0x80
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x54
.data
check_data6:
	.byte 0xd8, 0x23, 0x30, 0x38, 0x28, 0x10, 0xa2, 0x78, 0xff, 0x11, 0x61, 0x78, 0xd1, 0xdf, 0xc5, 0xc2
	.byte 0xc2, 0xff, 0x7f, 0x42, 0xc1, 0x12, 0xa7, 0x2c, 0x7f, 0x63, 0x32, 0xb8, 0x36, 0xbd, 0x07, 0x38
	.byte 0x9e, 0x20, 0xff, 0x78, 0x02, 0x19, 0xe2, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800
	/* C2 */
	.octa 0xfe00
	/* C4 */
	.octa 0x1000
	/* C9 */
	.octa 0x100d
	/* C15 */
	.octa 0x800
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000
	/* C22 */
	.octa 0x81c
	/* C27 */
	.octa 0x800
	/* C30 */
	.octa 0x80000000000700060000000000001010
final_cap_values:
	/* C1 */
	.octa 0x800
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x1000
	/* C8 */
	.octa 0xfeff
	/* C9 */
	.octa 0x1088
	/* C15 */
	.octa 0x800
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000
	/* C22 */
	.octa 0x754
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x800
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000086000f00ffffffffffb800
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x383023d8 // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:24 Rn:30 00:00 opc:010 0:0 Rs:16 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x78a21028 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:8 Rn:1 00:00 opc:001 0:0 Rs:2 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x786111ff // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:15 00:00 opc:001 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c5dfd1 // CSEL-C.CI-C Cd:17 Cn:30 11:11 cond:1101 Cm:5 11000010110:11000010110
	.inst 0x427fffc2 // ALDAR-R.R-32 Rt:2 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x2ca712c1 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:1 Rn:22 Rt2:00100 imm7:1001110 L:0 1011001:1011001 opc:00
	.inst 0xb832637f // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:27 00:00 opc:110 o3:0 Rs:18 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x3807bd36 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:22 Rn:9 11:11 imm9:001111011 0:0 opc:00 111000:111000 size:00
	.inst 0x78ff209e // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:4 00:00 opc:010 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xc2e21902 // CVT-C.CR-C Cd:2 Cn:8 0110:0110 0:0 0:0 Rm:2 11000010111:11000010111
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c4 // ldr c4, [x6, #2]
	.inst 0xc2400cc9 // ldr c9, [x6, #3]
	.inst 0xc24010cf // ldr c15, [x6, #4]
	.inst 0xc24014d0 // ldr c16, [x6, #5]
	.inst 0xc24018d2 // ldr c18, [x6, #6]
	.inst 0xc2401cd6 // ldr c22, [x6, #7]
	.inst 0xc24020db // ldr c27, [x6, #8]
	.inst 0xc24024de // ldr c30, [x6, #9]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q1, =0x0
	ldr q4, =0x8001107b
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e6 // ldr c6, [c7, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826010e6 // ldr c6, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	mov x7, #0xd
	and x6, x6, x7
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c7 // ldr c7, [x6, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24004c7 // ldr c7, [x6, #1]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc24008c7 // ldr c7, [x6, #2]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400cc7 // ldr c7, [x6, #3]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc24010c7 // ldr c7, [x6, #4]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc24014c7 // ldr c7, [x6, #5]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc24018c7 // ldr c7, [x6, #6]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc2401cc7 // ldr c7, [x6, #7]
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	.inst 0xc24020c7 // ldr c7, [x6, #8]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc24024c7 // ldr c7, [x6, #9]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc24028c7 // ldr c7, [x6, #10]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402cc7 // ldr c7, [x6, #11]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x7, v1.d[0]
	cmp x6, x7
	b.ne comparison_fail
	ldr x6, =0x0
	mov x7, v1.d[1]
	cmp x6, x7
	b.ne comparison_fail
	ldr x6, =0x8001107b
	mov x7, v4.d[0]
	cmp x6, x7
	b.ne comparison_fail
	ldr x6, =0x0
	mov x7, v4.d[1]
	cmp x6, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000101c
	ldr x1, =check_data2
	ldr x2, =0x00001024
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001802
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001810
	ldr x1, =check_data4
	ldr x2, =0x00001811
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001888
	ldr x1, =check_data5
	ldr x2, =0x00001889
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
