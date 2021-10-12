.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xa8, 0x43, 0xb3, 0xf2, 0x64, 0x08, 0x1f, 0x1b, 0xdd, 0x23, 0xdf, 0x4a, 0x09, 0x7d, 0xa9, 0x82
	.byte 0x0a, 0x00, 0xb5, 0x38, 0xe2, 0xdb, 0x1b, 0xa2, 0xe1, 0x13, 0xc7, 0xc2, 0x60, 0xe6, 0x55, 0x38
	.byte 0xa1, 0x93, 0xc1, 0xc2, 0xc2, 0x2f, 0xd3, 0x9a, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001000
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0xe21f3aff00009002
	/* C9 */
	.octa 0x77831401978a000
	/* C19 */
	.octa 0x800000004001c002000000000040df62
	/* C21 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0xe21f3aff9a1d9002
	/* C9 */
	.octa 0x77831401978a000
	/* C10 */
	.octa 0x0
	/* C19 */
	.octa 0x800000004001c002000000000040dec0
	/* C21 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000000100050000000000002010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000510200020000000000000023
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf2b343a8 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:8 imm16:1001101000011101 hw:01 100101:100101 opc:11 sf:1
	.inst 0x1b1f0864 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:4 Rn:3 Ra:2 o0:0 Rm:31 0011011000:0011011000 sf:0
	.inst 0x4adf23dd // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:29 Rn:30 imm6:001000 Rm:31 N:0 shift:11 01010:01010 opc:10 sf:0
	.inst 0x82a97d09 // ASTR-V.RRB-S Rt:9 Rn:8 opc:11 S:1 option:011 Rm:9 1:1 L:0 100000101:100000101
	.inst 0x38b5000a // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:10 Rn:0 00:00 opc:000 0:0 Rs:21 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xa21bdbe2 // STTR-C.RIB-C Ct:2 Rn:31 10:10 imm9:110111101 0:0 opc:00 10100010:10100010
	.inst 0xc2c713e1 // RRLEN-R.R-C Rd:1 Rn:31 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x3855e660 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:19 01:01 imm9:101011110 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c193a1 // CLRTAG-C.C-C Cd:1 Cn:29 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x9ad32fc2 // rorv:aarch64/instrs/integer/shift/variable Rd:2 Rn:30 op2:11 0010:0010 Rm:19 0011010110:0011010110 sf:1
	.inst 0xc2c210a0
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e8 // ldr c8, [x15, #2]
	.inst 0xc2400de9 // ldr c9, [x15, #3]
	.inst 0xc24011f3 // ldr c19, [x15, #4]
	.inst 0xc24015f5 // ldr c21, [x15, #5]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q9, =0x0
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x3085103d
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030af // ldr c15, [c5, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x826010af // ldr c15, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e5 // ldr c5, [x15, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24005e5 // ldr c5, [x15, #1]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc24009e5 // ldr c5, [x15, #2]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2400de5 // ldr c5, [x15, #3]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc24011e5 // ldr c5, [x15, #4]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc24015e5 // ldr c5, [x15, #5]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc24019e5 // ldr c5, [x15, #6]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x5, v9.d[0]
	cmp x15, x5
	b.ne comparison_fail
	ldr x15, =0x0
	mov x5, v9.d[1]
	cmp x15, x5
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
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001be0
	ldr x1, =check_data2
	ldr x2, =0x00001bf0
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
	ldr x0, =0x0040df62
	ldr x1, =check_data4
	ldr x2, =0x0040df63
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
