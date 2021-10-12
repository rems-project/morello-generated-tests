.section data0, #alloc, #write
	.zero 2096
	.byte 0x40, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1984
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x19, 0x08, 0x00, 0x00
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x60, 0x18
.data
check_data4:
	.byte 0x1e, 0x90, 0xc1, 0xc2, 0xb0, 0x75, 0x3d, 0xe2, 0x34, 0x02, 0x2d, 0x9b, 0x62, 0x12, 0xc2, 0xc2
.data
check_data5:
	.byte 0x5f, 0x00, 0x22, 0x78, 0x05, 0x10, 0xc7, 0xc2, 0x4d, 0xfc, 0x3f, 0x42, 0xe1, 0x07, 0xca, 0xc2
	.byte 0xe0, 0x6b, 0xbe, 0xf8, 0x1f, 0xeb, 0x0e, 0xa2, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000400000010000000000001020
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x819
	/* C19 */
	.octa 0x20008000808140050000000000402000
	/* C24 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000400000010000000000001020
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x819
	/* C19 */
	.octa 0x20008000808140050000000000402000
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000401200000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005c04081000ffffffffffe003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1901e // CLRTAG-C.C-C Cd:30 Cn:0 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xe23d75b0 // ALDUR-V.RI-B Rt:16 Rn:13 op2:01 imm9:111010111 V:1 op1:00 11100010:11100010
	.inst 0x9b2d0234 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:20 Rn:17 Ra:0 o0:0 Rm:13 01:01 U:0 10011011:10011011
	.inst 0xc2c21262 // BRS-C-C 00010:00010 Cn:19 100:100 opc:00 11000010110000100:11000010110000100
	.zero 8176
	.inst 0x7822005f // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:000 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c71005 // RRLEN-R.R-C Rd:5 Rn:0 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x423ffc4d // ASTLR-R.R-32 Rt:13 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2ca07e1 // BUILD-C.C-C Cd:1 Cn:31 001:001 opc:00 0:0 Cm:10 11000010110:11000010110
	.inst 0xf8be6be0 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:31 10:10 S:0 option:011 Rm:30 1:1 opc:10 111000:111000 size:11
	.inst 0xa20eeb1f // STTR-C.RIB-C Ct:31 Rn:24 10:10 imm9:011101110 0:0 opc:00 10100010:10100010
	.inst 0xc2c212c0
	.zero 1040356
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
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e2 // ldr c2, [x7, #1]
	.inst 0xc24008ea // ldr c10, [x7, #2]
	.inst 0xc2400ced // ldr c13, [x7, #3]
	.inst 0xc24010f3 // ldr c19, [x7, #4]
	.inst 0xc24014f8 // ldr c24, [x7, #5]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30851037
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032c7 // ldr c7, [c22, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x826012c7 // ldr c7, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	.inst 0xc24000f6 // ldr c22, [x7, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24004f6 // ldr c22, [x7, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24008f6 // ldr c22, [x7, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400cf6 // ldr c22, [x7, #3]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc24010f6 // ldr c22, [x7, #4]
	.inst 0xc2d6a541 // chkeq c10, c22
	b.ne comparison_fail
	.inst 0xc24014f6 // ldr c22, [x7, #5]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc24018f6 // ldr c22, [x7, #6]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc2401cf6 // ldr c22, [x7, #7]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc24020f6 // ldr c22, [x7, #8]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x22, v16.d[0]
	cmp x7, x22
	b.ne comparison_fail
	ldr x7, =0x0
	mov x22, v16.d[1]
	cmp x7, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000016f0
	ldr x1, =check_data2
	ldr x2, =0x00001700
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001830
	ldr x1, =check_data3
	ldr x2, =0x00001832
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00402000
	ldr x1, =check_data5
	ldr x2, =0x0040201c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
