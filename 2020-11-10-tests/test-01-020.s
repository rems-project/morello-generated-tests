.section data0, #alloc, #write
	.zero 1088
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2992
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x08, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x1e, 0xb0, 0xc0, 0xc2, 0x40, 0x10, 0x0d, 0x51, 0xe5, 0x7f, 0xdf, 0x48, 0x42, 0x61, 0xdb, 0x39
	.byte 0xc1, 0x6b, 0x2a, 0x78, 0x60, 0x20, 0x0d, 0xe2, 0xa2, 0x31, 0xc2, 0xc2, 0x73, 0x23, 0xe7, 0x38
	.byte 0x60, 0x11, 0xc2, 0xc2
.data
check_data6:
	.byte 0xff, 0x53, 0x3c, 0x38, 0xc3, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x8
	/* C2 */
	.octa 0x44
	/* C3 */
	.octa 0x40000000400000210000000000001f10
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x1924
	/* C13 */
	.octa 0x20008000800100070000000000400381
	/* C27 */
	.octa 0x1ffe
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xfffffd00
	/* C1 */
	.octa 0x8
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x40000000400000210000000000001f10
	/* C5 */
	.octa 0x1
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x1924
	/* C13 */
	.octa 0x20008000800100070000000000400381
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x1ffe
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000a0000008000000000040001c
initial_SP_EL3_value:
	.octa 0xc0000000000100050000000000001440
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200000080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 176
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0b01e // GCSEAL-R.C-C Rd:30 Cn:0 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x510d1040 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:2 imm12:001101000100 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0x48df7fe5 // ldlarh:aarch64/instrs/memory/ordered Rt:5 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x39db6142 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:10 imm12:011011011000 opc:11 111001:111001 size:00
	.inst 0x782a6bc1 // strh_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:30 10:10 S:0 option:011 Rm:10 1:1 opc:00 111000:111000 size:01
	.inst 0xe20d2060 // ASTURB-R.RI-32 Rt:0 Rn:3 op2:00 imm9:011010010 V:0 op1:00 11100010:11100010
	.inst 0xc2c231a2 // BLRS-C-C 00010:00010 Cn:13 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x38e72373 // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:19 Rn:27 00:00 opc:010 0:0 Rs:7 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xc2c21160
	.zero 860
	.inst 0x383c53ff // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:101 o3:0 Rs:28 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c213c3 // BRR-C-C 00011:00011 Cn:30 100:100 opc:00 11000010110000100:11000010110000100
	.zero 1047672
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba2 // ldr c2, [x29, #2]
	.inst 0xc2400fa3 // ldr c3, [x29, #3]
	.inst 0xc24013a7 // ldr c7, [x29, #4]
	.inst 0xc24017aa // ldr c10, [x29, #5]
	.inst 0xc2401bad // ldr c13, [x29, #6]
	.inst 0xc2401fbb // ldr c27, [x29, #7]
	.inst 0xc24023bc // ldr c28, [x29, #8]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x3085103f
	msr SCTLR_EL3, x29
	ldr x29, =0x80
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260317d // ldr c29, [c11, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260117d // ldr c29, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003ab // ldr c11, [x29, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24007ab // ldr c11, [x29, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400bab // ldr c11, [x29, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400fab // ldr c11, [x29, #3]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc24013ab // ldr c11, [x29, #4]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc24017ab // ldr c11, [x29, #5]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc2401bab // ldr c11, [x29, #6]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc2401fab // ldr c11, [x29, #7]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc24023ab // ldr c11, [x29, #8]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc24027ab // ldr c11, [x29, #9]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc2402bab // ldr c11, [x29, #10]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc2402fab // ldr c11, [x29, #11]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001440
	ldr x1, =check_data0
	ldr x2, =0x00001442
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001924
	ldr x1, =check_data1
	ldr x2, =0x00001926
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe2
	ldr x1, =check_data2
	ldr x2, =0x00001fe3
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
	ldr x2, =0x00400024
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400380
	ldr x1, =check_data6
	ldr x2, =0x00400388
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
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
