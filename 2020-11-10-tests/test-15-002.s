.section data0, #alloc, #write
	.zero 80
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x20, 0x04, 0x00, 0x00
	.zero 976
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00
	.zero 2816
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 176
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x20, 0x04, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x40, 0x10
.data
check_data5:
	.zero 10
.data
check_data6:
	.zero 8
.data
check_data7:
	.byte 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data8:
	.byte 0xbf, 0x22, 0x62, 0x78, 0x6b, 0x7f, 0x5f, 0xc8, 0x35, 0x34, 0x7f, 0x22, 0x3e, 0x14, 0x3f, 0xe2
	.byte 0xc2, 0xfa, 0xff, 0x82, 0x1f, 0x70, 0x67, 0xb8, 0xa2, 0xc0, 0x3f, 0xa2, 0x10, 0x10, 0xfc, 0xe2
	.byte 0x7f, 0x53, 0x2a, 0x38, 0xc1, 0x88, 0x15, 0x78, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc000000000050003000000000000143c
	/* C1 */
	.octa 0x90000000000000000000000000001040
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x90100000400000010000000000001000
	/* C6 */
	.octa 0x40000000000100050000000000001840
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x20
	/* C21 */
	.octa 0xc0000000000700030000000000001800
	/* C22 */
	.octa 0x1395
	/* C27 */
	.octa 0xc00000007dfe0fd80000000000001f48
final_cap_values:
	/* C0 */
	.octa 0xc000000000050003000000000000143c
	/* C1 */
	.octa 0x90000000000000000000000000001040
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x90100000400000010000000000001000
	/* C6 */
	.octa 0x40000000000100050000000000001840
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x20
	/* C11 */
	.octa 0x10
	/* C13 */
	.octa 0x420800000000000000000000000
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x1395
	/* C27 */
	.octa 0xc00000007dfe0fd80000000000001f48
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080006002f0040000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000400004630000000000002001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001050
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x786222bf // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:010 o3:0 Rs:2 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc85f7f6b // ldxr:aarch64/instrs/memory/exclusive/single Rt:11 Rn:27 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0x227f3435 // LDXP-C.R-C Ct:21 Rn:1 Ct2:01101 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xe23f143e // ALDUR-V.RI-B Rt:30 Rn:1 op2:01 imm9:111110001 V:1 op1:00 11100010:11100010
	.inst 0x82fffac2 // ALDR-V.RRB-D Rt:2 Rn:22 opc:10 S:1 option:111 Rm:31 1:1 L:1 100000101:100000101
	.inst 0xb867701f // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:111 o3:0 Rs:7 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xa23fc0a2 // LDAPR-C.R-C Ct:2 Rn:5 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0xe2fc1010 // ASTUR-V.RI-D Rt:16 Rn:0 op2:00 imm9:111000001 V:1 op1:11 11100010:11100010
	.inst 0x382a537f // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:27 00:00 opc:101 o3:0 Rs:10 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x781588c1 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:6 10:10 imm9:101011000 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21340
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
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400902 // ldr c2, [x8, #2]
	.inst 0xc2400d05 // ldr c5, [x8, #3]
	.inst 0xc2401106 // ldr c6, [x8, #4]
	.inst 0xc2401507 // ldr c7, [x8, #5]
	.inst 0xc240190a // ldr c10, [x8, #6]
	.inst 0xc2401d15 // ldr c21, [x8, #7]
	.inst 0xc2402116 // ldr c22, [x8, #8]
	.inst 0xc240251b // ldr c27, [x8, #9]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q16, =0x0
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603348 // ldr c8, [c26, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601348 // ldr c8, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
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
	.inst 0xc240011a // ldr c26, [x8, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240051a // ldr c26, [x8, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240091a // ldr c26, [x8, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400d1a // ldr c26, [x8, #3]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc240111a // ldr c26, [x8, #4]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc240151a // ldr c26, [x8, #5]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc240191a // ldr c26, [x8, #6]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc2401d1a // ldr c26, [x8, #7]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc240211a // ldr c26, [x8, #8]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc240251a // ldr c26, [x8, #9]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc240291a // ldr c26, [x8, #10]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc2402d1a // ldr c26, [x8, #11]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x26, v2.d[0]
	cmp x8, x26
	b.ne comparison_fail
	ldr x8, =0x0
	mov x26, v2.d[1]
	cmp x8, x26
	b.ne comparison_fail
	ldr x8, =0x0
	mov x26, v16.d[0]
	cmp x8, x26
	b.ne comparison_fail
	ldr x8, =0x0
	mov x26, v16.d[1]
	cmp x8, x26
	b.ne comparison_fail
	ldr x8, =0x0
	mov x26, v30.d[0]
	cmp x8, x26
	b.ne comparison_fail
	ldr x8, =0x0
	mov x26, v30.d[1]
	cmp x8, x26
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001060
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000143c
	ldr x1, =check_data2
	ldr x2, =0x00001440
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001494
	ldr x1, =check_data3
	ldr x2, =0x00001495
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001798
	ldr x1, =check_data4
	ldr x2, =0x0000179a
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000017f8
	ldr x1, =check_data5
	ldr x2, =0x00001802
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001860
	ldr x1, =check_data6
	ldr x2, =0x00001868
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00001f48
	ldr x1, =check_data7
	ldr x2, =0x00001f50
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400000
	ldr x1, =check_data8
	ldr x2, =0x0040002c
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
