.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xe9, 0x20, 0x23, 0xe2, 0xe2, 0xa2, 0x06, 0xb8, 0x24, 0xfd, 0xdf, 0x88, 0x74, 0x2b, 0xdd, 0x1a
	.byte 0x80, 0xda, 0xeb, 0x36
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x20, 0x00, 0xc2, 0xc2, 0x96, 0x2b, 0xc3, 0xc2, 0xaa, 0xf4, 0x8a, 0x82, 0xc0, 0x51, 0x60, 0x38
	.byte 0x73, 0x16, 0xc0, 0xda, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400000300030000000000000000
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x200001
	/* C7 */
	.octa 0xfe0
	/* C9 */
	.octa 0x80000000600000040000000000001000
	/* C10 */
	.octa 0x20008f
	/* C14 */
	.octa 0xc0000000000100050000000000001ffc
	/* C23 */
	.octa 0x4000000000070003000000000000102e
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x400000300030000000000000000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x200001
	/* C7 */
	.octa 0xfe0
	/* C9 */
	.octa 0x80000000600000040000000000001000
	/* C10 */
	.octa 0x0
	/* C14 */
	.octa 0xc0000000000100050000000000001ffc
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x4000000000070003000000000000102e
	/* C28 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000000000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe22320e9 // ASTUR-V.RI-B Rt:9 Rn:7 op2:00 imm9:000110010 V:1 op1:00 11100010:11100010
	.inst 0xb806a2e2 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:23 00:00 imm9:001101010 0:0 opc:00 111000:111000 size:10
	.inst 0x88dffd24 // ldar:aarch64/instrs/memory/ordered Rt:4 Rn:9 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x1add2b74 // asrv:aarch64/instrs/integer/shift/variable Rd:20 Rn:27 op2:10 0010:0010 Rm:29 0011010110:0011010110 sf:0
	.inst 0x36ebda80 // tbz:aarch64/instrs/branch/conditional/test Rt:0 imm14:01111011010100 b40:11101 op:0 011011:011011 b5:0
	.zero 31564
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0xc2c32b96 // BICFLGS-C.CR-C Cd:22 Cn:28 1010:1010 opc:00 Rm:3 11000010110:11000010110
	.inst 0x828af4aa // ALDRSB-R.RRB-64 Rt:10 Rn:5 opc:01 S:1 option:111 Rm:10 0:0 L:0 100000101:100000101
	.inst 0x386051c0 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:14 00:00 opc:101 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xdac01673 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:19 Rn:19 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0xc2c21300
	.zero 1016968
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
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2400cc5 // ldr c5, [x6, #3]
	.inst 0xc24010c7 // ldr c7, [x6, #4]
	.inst 0xc24014c9 // ldr c9, [x6, #5]
	.inst 0xc24018ca // ldr c10, [x6, #6]
	.inst 0xc2401cce // ldr c14, [x6, #7]
	.inst 0xc24020d7 // ldr c23, [x6, #8]
	.inst 0xc24024dc // ldr c28, [x6, #9]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q9, =0x0
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
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603306 // ldr c6, [c24, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601306 // ldr c6, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d8 // ldr c24, [x6, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24004d8 // ldr c24, [x6, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24008d8 // ldr c24, [x6, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400cd8 // ldr c24, [x6, #3]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc24010d8 // ldr c24, [x6, #4]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc24014d8 // ldr c24, [x6, #5]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc24018d8 // ldr c24, [x6, #6]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2401cd8 // ldr c24, [x6, #7]
	.inst 0xc2d8a541 // chkeq c10, c24
	b.ne comparison_fail
	.inst 0xc24020d8 // ldr c24, [x6, #8]
	.inst 0xc2d8a5c1 // chkeq c14, c24
	b.ne comparison_fail
	.inst 0xc24024d8 // ldr c24, [x6, #9]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc24028d8 // ldr c24, [x6, #10]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc2402cd8 // ldr c24, [x6, #11]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x24, v9.d[0]
	cmp x6, x24
	b.ne comparison_fail
	ldr x6, =0x0
	mov x24, v9.d[1]
	cmp x6, x24
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
	ldr x0, =0x00001012
	ldr x1, =check_data1
	ldr x2, =0x00001013
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001098
	ldr x1, =check_data2
	ldr x2, =0x0000109c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffd
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400090
	ldr x1, =check_data5
	ldr x2, =0x00400091
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00407b60
	ldr x1, =check_data6
	ldr x2, =0x00407b78
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
