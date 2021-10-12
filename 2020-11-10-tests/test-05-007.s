.section data0, #alloc, #write
	.zero 2560
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1520
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0xb8
.data
check_data3:
	.byte 0x0c, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x0c, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0xcd, 0x03, 0x30, 0xbd, 0xff, 0x83, 0xc3, 0xc2, 0x3f, 0xa3, 0x55, 0x78, 0x21, 0x40, 0xcf, 0xe2
	.byte 0xdc, 0x07, 0x9a, 0xf9, 0x63, 0x13, 0x61, 0x38, 0x9f, 0x41, 0x21, 0xf8, 0xaa, 0x65, 0xbe, 0x82
	.byte 0x01, 0x50, 0xa2, 0x38, 0x0a, 0xd0, 0xf8, 0xe2, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc00000001007000e000000000000180b
	/* C1 */
	.octa 0x180c
	/* C2 */
	.octa 0x80
	/* C3 */
	.octa 0x0
	/* C10 */
	.octa 0xb800000082000000
	/* C12 */
	.octa 0xc0000000400410220000000000001a08
	/* C13 */
	.octa 0x3808
	/* C25 */
	.octa 0x80000000438150040000000000408400
	/* C27 */
	.octa 0xc0000000500400010000000000001000
	/* C30 */
	.octa 0x4000000058010004ffffffffffffe000
final_cap_values:
	/* C0 */
	.octa 0xc00000001007000e000000000000180b
	/* C1 */
	.octa 0x82
	/* C2 */
	.octa 0x80
	/* C3 */
	.octa 0x0
	/* C10 */
	.octa 0xb800000082000000
	/* C12 */
	.octa 0xc0000000400410220000000000001a08
	/* C13 */
	.octa 0x3808
	/* C25 */
	.octa 0x80000000438150040000000000408400
	/* C27 */
	.octa 0xc0000000500400010000000000001000
	/* C30 */
	.octa 0x4000000058010004ffffffffffffe000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200000800000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000407002700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xbd3003cd // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:13 Rn:30 imm12:110000000000 opc:00 111101:111101 size:10
	.inst 0xc2c383ff // SCTAG-C.CR-C Cd:31 Cn:31 000:000 0:0 10:10 Rm:3 11000010110:11000010110
	.inst 0x7855a33f // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:25 00:00 imm9:101011010 0:0 opc:01 111000:111000 size:01
	.inst 0xe2cf4021 // ASTUR-R.RI-64 Rt:1 Rn:1 op2:00 imm9:011110100 V:0 op1:11 11100010:11100010
	.inst 0xf99a07dc // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:30 imm12:011010000001 opc:10 111001:111001 size:11
	.inst 0x38611363 // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:27 00:00 opc:001 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xf821419f // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:12 00:00 opc:100 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x82be65aa // ASTR-R.RRB-64 Rt:10 Rn:13 opc:01 S:0 option:011 Rm:30 1:1 L:0 100000101:100000101
	.inst 0x38a25001 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:0 00:00 opc:101 0:0 Rs:2 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xe2f8d00a // ASTUR-V.RI-D Rt:10 Rn:0 op2:00 imm9:110001101 V:1 op1:11 11100010:11100010
	.inst 0xc2c212c0
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba2 // ldr c2, [x29, #2]
	.inst 0xc2400fa3 // ldr c3, [x29, #3]
	.inst 0xc24013aa // ldr c10, [x29, #4]
	.inst 0xc24017ac // ldr c12, [x29, #5]
	.inst 0xc2401bad // ldr c13, [x29, #6]
	.inst 0xc2401fb9 // ldr c25, [x29, #7]
	.inst 0xc24023bb // ldr c27, [x29, #8]
	.inst 0xc24027be // ldr c30, [x29, #9]
	/* Vector registers */
	mrs x29, cptr_el3
	bfc x29, #10, #1
	msr cptr_el3, x29
	isb
	ldr q10, =0x0
	ldr q13, =0x0
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30851037
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032dd // ldr c29, [c22, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x826012dd // ldr c29, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	.inst 0xc24003b6 // ldr c22, [x29, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24007b6 // ldr c22, [x29, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400bb6 // ldr c22, [x29, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400fb6 // ldr c22, [x29, #3]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc24013b6 // ldr c22, [x29, #4]
	.inst 0xc2d6a541 // chkeq c10, c22
	b.ne comparison_fail
	.inst 0xc24017b6 // ldr c22, [x29, #5]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2401bb6 // ldr c22, [x29, #6]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401fb6 // ldr c22, [x29, #7]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc24023b6 // ldr c22, [x29, #8]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc24027b6 // ldr c22, [x29, #9]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x22, v10.d[0]
	cmp x29, x22
	b.ne comparison_fail
	ldr x29, =0x0
	mov x22, v10.d[1]
	cmp x29, x22
	b.ne comparison_fail
	ldr x29, =0x0
	mov x22, v13.d[0]
	cmp x29, x22
	b.ne comparison_fail
	ldr x29, =0x0
	mov x22, v13.d[1]
	cmp x29, x22
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
	ldr x0, =0x00001798
	ldr x1, =check_data1
	ldr x2, =0x000017a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001808
	ldr x1, =check_data2
	ldr x2, =0x00001810
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001900
	ldr x1, =check_data3
	ldr x2, =0x00001908
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001a08
	ldr x1, =check_data4
	ldr x2, =0x00001a10
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
	ldr x0, =0x0040835a
	ldr x1, =check_data6
	ldr x2, =0x0040835c
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
