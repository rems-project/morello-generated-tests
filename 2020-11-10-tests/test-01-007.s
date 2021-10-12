.section data0, #alloc, #write
	.byte 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0x3d, 0x8c, 0x36, 0xe2, 0x1f, 0xbe, 0xc8, 0x02, 0x8a, 0x93, 0x77, 0x79, 0x41, 0x84, 0x10, 0x9b
	.byte 0x3f, 0x71, 0x3f, 0x78, 0x6a, 0x04, 0xc0, 0xda, 0x1f, 0x30, 0xc7, 0xc2, 0x42, 0x40, 0x9d, 0xf9
	.byte 0x5f, 0x3c, 0x03, 0xd5, 0x9e, 0xfc, 0x1f, 0x42, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x480028
	/* C4 */
	.octa 0x48000000000100050000000000001000
	/* C9 */
	.octa 0xc0000000100100050000000000001000
	/* C16 */
	.octa 0x80000720070200000000010100
	/* C28 */
	.octa 0x800000005e0940040000000000404000
	/* C30 */
	.octa 0x4000000000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C4 */
	.octa 0x48000000000100050000000000001000
	/* C9 */
	.octa 0xc0000000100100050000000000001000
	/* C16 */
	.octa 0x80000720070200000000010100
	/* C28 */
	.octa 0x800000005e0940040000000000404000
	/* C30 */
	.octa 0x4000000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000e00070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000cfb000700ffe00000008001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2368c3d // ALDUR-V.RI-Q Rt:29 Rn:1 op2:11 imm9:101101000 V:1 op1:00 11100010:11100010
	.inst 0x02c8be1f // SUB-C.CIS-C Cd:31 Cn:16 imm12:001000101111 sh:1 A:1 00000010:00000010
	.inst 0x7977938a // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:10 Rn:28 imm12:110111100100 opc:01 111001:111001 size:01
	.inst 0x9b108441 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:1 Rn:2 Ra:1 o0:1 Rm:16 0011011000:0011011000 sf:1
	.inst 0x783f713f // lduminh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:9 00:00 opc:111 0:0 Rs:31 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xdac0046a // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:10 Rn:3 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c7301f // RRMASK-R.R-C Rd:31 Rn:0 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xf99d4042 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:2 imm12:011101010000 opc:10 111001:111001 size:11
	.inst 0xd5033c5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1100 11010101000000110011:11010101000000110011
	.inst 0x421ffc9e // STLR-C.R-C Ct:30 Rn:4 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2c211a0
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b24 // ldr c4, [x25, #2]
	.inst 0xc2400f29 // ldr c9, [x25, #3]
	.inst 0xc2401330 // ldr c16, [x25, #4]
	.inst 0xc240173c // ldr c28, [x25, #5]
	.inst 0xc2401b3e // ldr c30, [x25, #6]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	ldr x25, =0x4
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b9 // ldr c25, [c13, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x826011b9 // ldr c25, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc240032d // ldr c13, [x25, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240072d // ldr c13, [x25, #1]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc2400b2d // ldr c13, [x25, #2]
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	.inst 0xc2400f2d // ldr c13, [x25, #3]
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	.inst 0xc240132d // ldr c13, [x25, #4]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc240172d // ldr c13, [x25, #5]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x13, v29.d[0]
	cmp x25, x13
	b.ne comparison_fail
	ldr x25, =0x0
	mov x13, v29.d[1]
	cmp x25, x13
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
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00405bc8
	ldr x1, =check_data2
	ldr x2, =0x00405bca
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0047ff90
	ldr x1, =check_data3
	ldr x2, =0x0047ffa0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
