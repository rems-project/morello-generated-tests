.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xe0, 0x47, 0xa0, 0xe2, 0x37, 0xdc, 0x98, 0x8b, 0xf5, 0x2a, 0xca, 0x1a, 0x20, 0x00, 0x1f, 0xd6
.data
check_data4:
	.byte 0x8a, 0x13, 0xc1, 0xc2, 0x10, 0xf4, 0xb6, 0xe2, 0x2e, 0x3a, 0x2c, 0xd0, 0x04, 0x83, 0x53, 0xe2
	.byte 0x22, 0x16, 0x65, 0xb5, 0x25, 0x93, 0x35, 0xc2, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000400000020000000000002009
	/* C1 */
	.octa 0x400100
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x80000000000000000000000000000
	/* C24 */
	.octa 0x400000000001000500000000000010cc
	/* C25 */
	.octa 0xffffffffffff400f
	/* C28 */
	.octa 0x400080000000000000008001
final_cap_values:
	/* C0 */
	.octa 0x80000000400000020000000000002009
	/* C1 */
	.octa 0x400100
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x80000000000000000000000000000
	/* C10 */
	.octa 0x8000
	/* C14 */
	.octa 0x58b46000
	/* C23 */
	.octa 0x400100
	/* C24 */
	.octa 0x400000000001000500000000000010cc
	/* C25 */
	.octa 0xffffffffffff400f
	/* C28 */
	.octa 0x400080000000000000008001
initial_SP_EL3_value:
	.octa 0x800000000007c0060000000000417ffc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500200000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005b01000100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2a047e0 // ALDUR-V.RI-S Rt:0 Rn:31 op2:01 imm9:000000100 V:1 op1:10 11100010:11100010
	.inst 0x8b98dc37 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:23 Rn:1 imm6:110111 Rm:24 0:0 shift:10 01011:01011 S:0 op:0 sf:1
	.inst 0x1aca2af5 // asrv:aarch64/instrs/integer/shift/variable Rd:21 Rn:23 op2:10 0010:0010 Rm:10 0011010110:0011010110 sf:0
	.inst 0xd61f0020 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 240
	.inst 0xc2c1138a // GCLIM-R.C-C Rd:10 Cn:28 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xe2b6f410 // ALDUR-V.RI-S Rt:16 Rn:0 op2:01 imm9:101101111 V:1 op1:10 11100010:11100010
	.inst 0xd02c3a2e // ADRDP-C.ID-C Rd:14 immhi:010110000111010001 P:0 10000:10000 immlo:10 op:1
	.inst 0xe2538304 // ASTURH-R.RI-32 Rt:4 Rn:24 op2:00 imm9:100111000 V:0 op1:01 11100010:11100010
	.inst 0xb5651622 // cbnz:aarch64/instrs/branch/conditional/compare Rt:2 imm19:0110010100010110001 op:1 011010:011010 sf:1
	.inst 0xc2359325 // STR-C.RIB-C Ct:5 Rn:25 imm12:110101100100 L:0 110000100:110000100
	.inst 0xc2c211a0
	.zero 1048292
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a62 // ldr c2, [x19, #2]
	.inst 0xc2400e64 // ldr c4, [x19, #3]
	.inst 0xc2401265 // ldr c5, [x19, #4]
	.inst 0xc2401678 // ldr c24, [x19, #5]
	.inst 0xc2401a79 // ldr c25, [x19, #6]
	.inst 0xc2401e7c // ldr c28, [x19, #7]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851037
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b3 // ldr c19, [c13, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826011b3 // ldr c19, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026d // ldr c13, [x19, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240066d // ldr c13, [x19, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400a6d // ldr c13, [x19, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400e6d // ldr c13, [x19, #3]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc240126d // ldr c13, [x19, #4]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc240166d // ldr c13, [x19, #5]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc2401a6d // ldr c13, [x19, #6]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc2401e6d // ldr c13, [x19, #7]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc240226d // ldr c13, [x19, #8]
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	.inst 0xc240266d // ldr c13, [x19, #9]
	.inst 0xc2cda721 // chkeq c25, c13
	b.ne comparison_fail
	.inst 0xc2402a6d // ldr c13, [x19, #10]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x13, v0.d[0]
	cmp x19, x13
	b.ne comparison_fail
	ldr x19, =0x0
	mov x13, v0.d[1]
	cmp x19, x13
	b.ne comparison_fail
	ldr x19, =0x0
	mov x13, v16.d[0]
	cmp x19, x13
	b.ne comparison_fail
	ldr x19, =0x0
	mov x13, v16.d[1]
	cmp x19, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001006
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001650
	ldr x1, =check_data1
	ldr x2, =0x00001660
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f78
	ldr x1, =check_data2
	ldr x2, =0x00001f7c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400100
	ldr x1, =check_data4
	ldr x2, =0x0040011c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00418000
	ldr x1, =check_data5
	ldr x2, =0x00418004
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
