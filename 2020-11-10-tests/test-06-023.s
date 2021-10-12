.section data0, #alloc, #write
	.byte 0x60, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xe6, 0xaf, 0x2d, 0x39, 0x1b, 0xd8, 0x6c, 0x92, 0x3f, 0x6f, 0x16, 0x7c, 0x1f, 0xcc, 0x5f, 0xe2
	.byte 0x3e, 0x80, 0xf7, 0xa2, 0x18, 0x94, 0x27, 0xe2, 0xc1, 0xb7, 0x51, 0xf2, 0x21, 0x84, 0x6a, 0x82
	.byte 0x4e, 0x98, 0xcc, 0xc2, 0x6c, 0x5b, 0x73, 0x82, 0x80, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x401000
	/* C1 */
	.octa 0xd8000000502100010000000000001000
	/* C2 */
	.octa 0x100010000000000000000
	/* C6 */
	.octa 0x0
	/* C23 */
	.octa 0x4000000000000000000000000000
	/* C25 */
	.octa 0x40000000000100070000000000002002
final_cap_values:
	/* C0 */
	.octa 0x401000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x100010000000000000000
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x100010000000000000000
	/* C23 */
	.octa 0x4000000000000000000000000000
	/* C25 */
	.octa 0x40000000000100070000000000001f68
	/* C27 */
	.octa 0x400000
	/* C30 */
	.octa 0x1000000000000000000000400060
initial_SP_EL3_value:
	.octa 0x40000000400000200000000000001001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000448100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000007000700000000003fe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x392dafe6 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:6 Rn:31 imm12:101101101011 opc:00 111001:111001 size:00
	.inst 0x926cd81b // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:27 Rn:0 imms:110110 immr:101100 N:1 100100:100100 opc:00 sf:1
	.inst 0x7c166f3f // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:31 Rn:25 11:11 imm9:101100110 0:0 opc:00 111100:111100 size:01
	.inst 0xe25fcc1f // ALDURSH-R.RI-32 Rt:31 Rn:0 op2:11 imm9:111111100 V:0 op1:01 11100010:11100010
	.inst 0xa2f7803e // SWPAL-CC.R-C Ct:30 Rn:1 100000:100000 Cs:23 1:1 R:1 A:1 10100010:10100010
	.inst 0xe2279418 // ALDUR-V.RI-B Rt:24 Rn:0 op2:01 imm9:001111001 V:1 op1:00 11100010:11100010
	.inst 0xf251b7c1 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:30 imms:101101 immr:010001 N:1 100100:100100 opc:11 sf:1
	.inst 0x826a8421 // ALDRB-R.RI-B Rt:1 Rn:1 op:01 imm9:010101000 L:1 1000001001:1000001001
	.inst 0xc2cc984e // ALIGND-C.CI-C Cd:14 Cn:2 0110:0110 U:0 imm6:011001 11000010110:11000010110
	.inst 0x82735b6c // ALDR-R.RI-32 Rt:12 Rn:27 op:10 imm9:100110101 L:1 1000001001:1000001001
	.inst 0xc2c21080
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa2 // ldr c2, [x21, #2]
	.inst 0xc2400ea6 // ldr c6, [x21, #3]
	.inst 0xc24012b7 // ldr c23, [x21, #4]
	.inst 0xc24016b9 // ldr c25, [x21, #5]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851037
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603095 // ldr c21, [c4, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601095 // ldr c21, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x4, #0xf
	and x21, x21, x4
	cmp x21, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a4 // ldr c4, [x21, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24006a4 // ldr c4, [x21, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400aa4 // ldr c4, [x21, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400ea4 // ldr c4, [x21, #3]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc24012a4 // ldr c4, [x21, #4]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc24016a4 // ldr c4, [x21, #5]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc2401aa4 // ldr c4, [x21, #6]
	.inst 0xc2c4a6e1 // chkeq c23, c4
	b.ne comparison_fail
	.inst 0xc2401ea4 // ldr c4, [x21, #7]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc24022a4 // ldr c4, [x21, #8]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc24026a4 // ldr c4, [x21, #9]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x4, v24.d[0]
	cmp x21, x4
	b.ne comparison_fail
	ldr x21, =0x0
	mov x4, v24.d[1]
	cmp x21, x4
	b.ne comparison_fail
	ldr x21, =0x0
	mov x4, v31.d[0]
	cmp x21, x4
	b.ne comparison_fail
	ldr x21, =0x0
	mov x4, v31.d[1]
	cmp x21, x4
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
	ldr x0, =0x00001b6c
	ldr x1, =check_data1
	ldr x2, =0x00001b6d
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f68
	ldr x1, =check_data2
	ldr x2, =0x00001f6a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400108
	ldr x1, =check_data4
	ldr x2, =0x00400109
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004004d4
	ldr x1, =check_data5
	ldr x2, =0x004004d8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400ffc
	ldr x1, =check_data6
	ldr x2, =0x00400ffe
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00401079
	ldr x1, =check_data7
	ldr x2, =0x0040107a
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
