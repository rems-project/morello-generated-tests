.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0xe0, 0x3f, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xdc, 0x79
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xdf, 0x2f, 0x66, 0xbd, 0x3f, 0x40, 0x3e, 0xf8, 0x80, 0x90, 0x82, 0x38, 0xff, 0x43, 0x9c, 0x78
	.byte 0x60, 0xce, 0x43, 0x10, 0xe8, 0xfd, 0x7f, 0x42, 0x40, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x5f, 0x58, 0x95, 0xb8, 0x0b, 0x82, 0x60, 0x78, 0x62, 0x93, 0xc5, 0xc2, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data7:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000400100030000000000001000
	/* C2 */
	.octa 0x800000000001000500000000005000a3
	/* C4 */
	.octa 0x80000000000100050000000000001fd5
	/* C10 */
	.octa 0x20008000800180060000000000408001
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0xc0000000000100050000000000001010
	/* C27 */
	.octa 0xfffffffffe3701
	/* C30 */
	.octa 0x800000004002000300000000003fe000
final_cap_values:
	/* C0 */
	.octa 0x200080000601000700000000004879dc
	/* C1 */
	.octa 0xc0000000400100030000000000001000
	/* C2 */
	.octa 0x800000000006000700fffffffffe3701
	/* C4 */
	.octa 0x80000000000100050000000000001fd5
	/* C8 */
	.octa 0x3fe000
	/* C10 */
	.octa 0x20008000800180060000000000408001
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0xc0000000000100050000000000001010
	/* C27 */
	.octa 0xfffffffffe3701
	/* C30 */
	.octa 0x800000004002000300000000003fe000
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000002000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000060100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000006000700fffffffffb3f01
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xbd662fdf // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:31 Rn:30 imm12:100110001011 opc:01 111101:111101 size:10
	.inst 0xf83e403f // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:100 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x38829080 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:4 00:00 imm9:000101001 0:0 opc:10 111000:111000 size:00
	.inst 0x789c43ff // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:31 00:00 imm9:111000100 0:0 opc:10 111000:111000 size:01
	.inst 0x1043ce60 // ADR-C.I-C Rd:0 immhi:100001111001110011 P:0 10000:10000 immlo:00 op:0
	.inst 0x427ffde8 // ALDAR-R.R-32 Rt:8 Rn:15 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c21140 // BR-C-C 00000:00000 Cn:10 100:100 opc:00 11000010110000100:11000010110000100
	.zero 32740
	.inst 0xb895585f // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:2 10:10 imm9:101010101 0:0 opc:10 111000:111000 size:10
	.inst 0x7860820b // swph:aarch64/instrs/memory/atomicops/swp Rt:11 Rn:16 100000:100000 Rs:0 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc2c59362 // CVTD-C.R-C Cd:2 Rn:27 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c213a0
	.zero 1015792
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e1 // ldr c1, [x7, #0]
	.inst 0xc24004e2 // ldr c2, [x7, #1]
	.inst 0xc24008e4 // ldr c4, [x7, #2]
	.inst 0xc2400cea // ldr c10, [x7, #3]
	.inst 0xc24010ef // ldr c15, [x7, #4]
	.inst 0xc24014f0 // ldr c16, [x7, #5]
	.inst 0xc24018fb // ldr c27, [x7, #6]
	.inst 0xc2401cfe // ldr c30, [x7, #7]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033a7 // ldr c7, [c29, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x826013a7 // ldr c7, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000fd // ldr c29, [x7, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc24004fd // ldr c29, [x7, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc24008fd // ldr c29, [x7, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400cfd // ldr c29, [x7, #3]
	.inst 0xc2dda481 // chkeq c4, c29
	b.ne comparison_fail
	.inst 0xc24010fd // ldr c29, [x7, #4]
	.inst 0xc2dda501 // chkeq c8, c29
	b.ne comparison_fail
	.inst 0xc24014fd // ldr c29, [x7, #5]
	.inst 0xc2dda541 // chkeq c10, c29
	b.ne comparison_fail
	.inst 0xc24018fd // ldr c29, [x7, #6]
	.inst 0xc2dda561 // chkeq c11, c29
	b.ne comparison_fail
	.inst 0xc2401cfd // ldr c29, [x7, #7]
	.inst 0xc2dda5e1 // chkeq c15, c29
	b.ne comparison_fail
	.inst 0xc24020fd // ldr c29, [x7, #8]
	.inst 0xc2dda601 // chkeq c16, c29
	b.ne comparison_fail
	.inst 0xc24024fd // ldr c29, [x7, #9]
	.inst 0xc2dda761 // chkeq c27, c29
	b.ne comparison_fail
	.inst 0xc24028fd // ldr c29, [x7, #10]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x29, v31.d[0]
	cmp x7, x29
	b.ne comparison_fail
	ldr x7, =0x0
	mov x29, v31.d[1]
	cmp x7, x29
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001012
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc4
	ldr x1, =check_data2
	ldr x2, =0x00001fc6
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040062c
	ldr x1, =check_data5
	ldr x2, =0x00400630
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00408000
	ldr x1, =check_data6
	ldr x2, =0x00408010
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffff8
	ldr x1, =check_data7
	ldr x2, =0x004ffffc
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
