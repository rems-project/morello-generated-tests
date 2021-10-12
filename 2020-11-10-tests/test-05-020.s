.section data0, #alloc, #write
	.zero 256
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x00, 0x37, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xf6, 0x09, 0x45, 0xe2, 0xc0, 0x80, 0xa1, 0xa2, 0xc1, 0xe7, 0x8a, 0xb8, 0x3f, 0x70, 0x6d, 0x38
	.byte 0x94, 0x61, 0xbe, 0xc2, 0x5f, 0x30, 0x27, 0x78, 0x5f, 0x32, 0x03, 0xd5, 0xa3, 0x53, 0xc2, 0xc2
.data
check_data5:
	.byte 0xe2, 0xff, 0x5f, 0xc8, 0x46, 0x86, 0xf3, 0xb7, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000000000370000110000000001
	/* C2 */
	.octa 0x1200
	/* C6 */
	.octa 0x1000
	/* C7 */
	.octa 0x0
	/* C12 */
	.octa 0x10000006800700ffffffffffef80
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x80000000000e00020000000000001084
	/* C29 */
	.octa 0x200080008001000500000000004003f9
	/* C30 */
	.octa 0x1004
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1100
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x1000
	/* C7 */
	.octa 0x0
	/* C12 */
	.octa 0x10000006800700ffffffffffef80
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x80000000000e00020000000000001084
	/* C20 */
	.octa 0x1000000680070100000000000032
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x200080008001000500000000004003f9
	/* C30 */
	.octa 0x10b2
initial_SP_EL3_value:
	.octa 0x800000000001000500000000004ffff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600040000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd01000000226000300fffffffe00ffed
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe24509f6 // ALDURSH-R.RI-64 Rt:22 Rn:15 op2:10 imm9:001010000 V:0 op1:01 11100010:11100010
	.inst 0xa2a180c0 // SWPA-CC.R-C Ct:0 Rn:6 100000:100000 Cs:1 1:1 R:0 A:1 10100010:10100010
	.inst 0xb88ae7c1 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:30 01:01 imm9:010101110 0:0 opc:10 111000:111000 size:10
	.inst 0x386d703f // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:111 o3:0 Rs:13 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2be6194 // ADD-C.CRI-C Cd:20 Cn:12 imm3:000 option:011 Rm:30 11000010101:11000010101
	.inst 0x7827305f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:011 o3:0 Rs:7 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xd503325f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0010 11010101000000110011:11010101000000110011
	.inst 0xc2c253a3 // RETR-C-C 00011:00011 Cn:29 100:100 opc:10 11000010110000100:11000010110000100
	.zero 984
	.inst 0xc85fffe2 // ldaxr:aarch64/instrs/memory/exclusive/single Rt:2 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xb7f38646 // tbnz:aarch64/instrs/branch/conditional/test Rt:6 imm14:01110000110010 b40:11110 op:1 011011:011011 b5:1
	.inst 0xc2c210a0
	.zero 1047548
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
	.inst 0xc2400906 // ldr c6, [x8, #2]
	.inst 0xc2400d07 // ldr c7, [x8, #3]
	.inst 0xc240110c // ldr c12, [x8, #4]
	.inst 0xc240150d // ldr c13, [x8, #5]
	.inst 0xc240190f // ldr c15, [x8, #6]
	.inst 0xc2401d1d // ldr c29, [x8, #7]
	.inst 0xc240211e // ldr c30, [x8, #8]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851037
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030a8 // ldr c8, [c5, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826010a8 // ldr c8, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	.inst 0xc2400105 // ldr c5, [x8, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400505 // ldr c5, [x8, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400905 // ldr c5, [x8, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400d05 // ldr c5, [x8, #3]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2401105 // ldr c5, [x8, #4]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2401505 // ldr c5, [x8, #5]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc2401905 // ldr c5, [x8, #6]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2401d05 // ldr c5, [x8, #7]
	.inst 0xc2c5a5e1 // chkeq c15, c5
	b.ne comparison_fail
	.inst 0xc2402105 // ldr c5, [x8, #8]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc2402505 // ldr c5, [x8, #9]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc2402905 // ldr c5, [x8, #10]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402d05 // ldr c5, [x8, #11]
	.inst 0xc2c5a7c1 // chkeq c30, c5
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
	ldr x0, =0x000010d4
	ldr x1, =check_data1
	ldr x2, =0x000010d6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001101
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001200
	ldr x1, =check_data3
	ldr x2, =0x00001202
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004003f8
	ldr x1, =check_data5
	ldr x2, =0x00400404
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff0
	ldr x1, =check_data6
	ldr x2, =0x004ffff8
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
