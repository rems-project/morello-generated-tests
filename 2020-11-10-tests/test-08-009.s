.section data0, #alloc, #write
	.zero 336
	.byte 0x00, 0x00, 0x00, 0x00, 0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3744
.data
check_data0:
	.byte 0x04, 0x04, 0x00, 0x00, 0x32, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x82
.data
check_data4:
	.byte 0xd7, 0x27, 0xbd, 0xe2, 0x48, 0x82, 0xa1, 0xa2, 0x78, 0x13, 0xe1, 0xc2, 0x5f, 0x32, 0xc1, 0xc2
	.byte 0xf7, 0x5b, 0x7f, 0xa2, 0xde, 0x43, 0x72, 0x3d, 0xf2, 0x76, 0xf9, 0x2a, 0x9f, 0x52, 0x22, 0x38
	.byte 0xdf, 0xf3, 0x9f, 0x82, 0x3e, 0xfc, 0x3f, 0x42, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000000000000000000000404
	/* C2 */
	.octa 0x0
	/* C18 */
	.octa 0xd0000000602100020000000000001000
	/* C20 */
	.octa 0xc0000000520400040000000000001154
	/* C27 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x80000000400100020000000000000432
final_cap_values:
	/* C1 */
	.octa 0x40000000000000000000000000404
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000520400040000000000001154
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x3fff800000000800000000000000
	/* C27 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x80000000400100020000000000000432
initial_SP_EL3_value:
	.octa 0x80000000700420050000000000402ff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004040c0440000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007003100fffffffff80000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2bd27d7 // ALDUR-V.RI-S Rt:23 Rn:30 op2:01 imm9:111010010 V:1 op1:10 11100010:11100010
	.inst 0xa2a18248 // SWPA-CC.R-C Ct:8 Rn:18 100000:100000 Cs:1 1:1 R:0 A:1 10100010:10100010
	.inst 0xc2e11378 // EORFLGS-C.CI-C Cd:24 Cn:27 0:0 10:10 imm8:00001000 11000010111:11000010111
	.inst 0xc2c1325f // GCFLGS-R.C-C Rd:31 Cn:18 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xa27f5bf7 // LDR-C.RRB-C Ct:23 Rn:31 10:10 S:1 option:010 Rm:31 1:1 opc:01 10100010:10100010
	.inst 0x3d7243de // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:30 Rn:30 imm12:110010010000 opc:01 111101:111101 size:00
	.inst 0x2af976f2 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:18 Rn:23 imm6:011101 Rm:25 N:1 shift:11 01010:01010 opc:01 sf:0
	.inst 0x3822529f // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:101 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x829ff3df // ASTRB-R.RRB-B Rt:31 Rn:30 opc:00 S:1 option:111 Rm:31 0:0 L:0 100000101:100000101
	.inst 0x423ffc3e // ASTLR-R.R-32 Rt:30 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
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
	ldr x12, =initial_cap_values
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc2400992 // ldr c18, [x12, #2]
	.inst 0xc2400d94 // ldr c20, [x12, #3]
	.inst 0xc240119b // ldr c27, [x12, #4]
	.inst 0xc240159e // ldr c30, [x12, #5]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x3085103d
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032cc // ldr c12, [c22, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826012cc // ldr c12, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400196 // ldr c22, [x12, #0]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400596 // ldr c22, [x12, #1]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400996 // ldr c22, [x12, #2]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2400d96 // ldr c22, [x12, #3]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2401196 // ldr c22, [x12, #4]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2401596 // ldr c22, [x12, #5]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2401996 // ldr c22, [x12, #6]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2401d96 // ldr c22, [x12, #7]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x22, v23.d[0]
	cmp x12, x22
	b.ne comparison_fail
	ldr x12, =0x0
	mov x22, v23.d[1]
	cmp x12, x22
	b.ne comparison_fail
	ldr x12, =0x0
	mov x22, v30.d[0]
	cmp x12, x22
	b.ne comparison_fail
	ldr x12, =0x0
	mov x22, v30.d[1]
	cmp x12, x22
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
	ldr x0, =0x00001032
	ldr x1, =check_data1
	ldr x2, =0x00001033
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c2
	ldr x1, =check_data2
	ldr x2, =0x000010c3
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001154
	ldr x1, =check_data3
	ldr x2, =0x00001155
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
	ldr x0, =0x00402ff0
	ldr x1, =check_data5
	ldr x2, =0x00403000
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
