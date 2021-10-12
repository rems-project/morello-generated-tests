.section data0, #alloc, #write
	.zero 96
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00
	.zero 3984
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2
.data
check_data2:
	.byte 0xbd, 0xff, 0x45, 0xe2, 0x6a, 0x0f, 0xdb, 0x1a, 0x9d, 0x00, 0x0c, 0x7a, 0x3d, 0x7a, 0x9f, 0x8a
	.byte 0xb3, 0x10, 0xb0, 0xb9, 0x1e, 0x30, 0xc1, 0xc2, 0xc0, 0xb7, 0x26, 0xe2, 0x80, 0x32, 0xc2, 0xc2
	.byte 0xf0, 0xc3, 0x9a, 0xf8, 0x5f, 0x51, 0xc1, 0xc2, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C5 */
	.octa 0x8000000040020402000000000040e3f0
	/* C20 */
	.octa 0x200080008007000f0000000000400021
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x9
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C5 */
	.octa 0x8000000040020402000000000040e3f0
	/* C10 */
	.octa 0x0
	/* C19 */
	.octa 0xffffffffc2c2c2c2
	/* C20 */
	.octa 0x200080008007000f0000000000400021
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000100070000000000400021
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000600210000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe245ffbd // ALDURSH-R.RI-32 Rt:29 Rn:29 op2:11 imm9:001011111 V:0 op1:01 11100010:11100010
	.inst 0x1adb0f6a // sdiv:aarch64/instrs/integer/arithmetic/div Rd:10 Rn:27 o1:1 00001:00001 Rm:27 0011010110:0011010110 sf:0
	.inst 0x7a0c009d // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:29 Rn:4 000000:000000 Rm:12 11010000:11010000 S:1 op:1 sf:0
	.inst 0x8a9f7a3d // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:29 Rn:17 imm6:011110 Rm:31 N:0 shift:10 01010:01010 opc:00 sf:1
	.inst 0xb9b010b3 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:19 Rn:5 imm12:110000000100 opc:10 111001:111001 size:10
	.inst 0xc2c1301e // GCFLGS-R.C-C Rd:30 Cn:0 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xe226b7c0 // ALDUR-V.RI-B Rt:0 Rn:30 op2:01 imm9:001101011 V:1 op1:00 11100010:11100010
	.inst 0xc2c23280 // BLR-C-C 00000:00000 Cn:20 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xf89ac3f0 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:31 00:00 imm9:110101100 0:0 opc:10 111000:111000 size:11
	.inst 0xc2c1515f // CFHI-R.C-C Rd:31 Cn:10 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c210c0
	.zero 70612
	.inst 0xc2c2c2c2
	.zero 977916
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
	.inst 0xc24006a5 // ldr c5, [x21, #1]
	.inst 0xc2400ab4 // ldr c20, [x21, #2]
	.inst 0xc2400ebb // ldr c27, [x21, #3]
	.inst 0xc24012bd // ldr c29, [x21, #4]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d5 // ldr c21, [c6, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826010d5 // ldr c21, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a6 // ldr c6, [x21, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24006a6 // ldr c6, [x21, #1]
	.inst 0xc2c6a4a1 // chkeq c5, c6
	b.ne comparison_fail
	.inst 0xc2400aa6 // ldr c6, [x21, #2]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2400ea6 // ldr c6, [x21, #3]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc24012a6 // ldr c6, [x21, #4]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc24016a6 // ldr c6, [x21, #5]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2401aa6 // ldr c6, [x21, #6]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2401ea6 // ldr c6, [x21, #7]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0xc2
	mov x6, v0.d[0]
	cmp x21, x6
	b.ne comparison_fail
	ldr x21, =0x0
	mov x6, v0.d[1]
	cmp x21, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001068
	ldr x1, =check_data0
	ldr x2, =0x0000106a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000106b
	ldr x1, =check_data1
	ldr x2, =0x0000106c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00411400
	ldr x1, =check_data3
	ldr x2, =0x00411404
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
