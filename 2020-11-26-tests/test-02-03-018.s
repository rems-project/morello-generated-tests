.section data0, #alloc, #write
	.zero 160
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 80
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0x02, 0x00
.data
check_data2:
	.byte 0xff, 0x38, 0x0a, 0xe2, 0xbf, 0x63, 0x3a, 0x78, 0xd5, 0x03, 0x1e, 0x1a, 0xbe, 0x70, 0x82, 0xf8
	.byte 0xc0, 0xa3, 0xca, 0xc2, 0xb4, 0x92, 0x08, 0x18, 0x1f, 0x60, 0xf2, 0xc2, 0x23, 0x30, 0xc2, 0xc2
.data
check_data3:
	.byte 0x41, 0x05, 0x12, 0xb1, 0xe1, 0xda, 0xd4, 0xc2, 0x00, 0x11, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x200000000017bfff0000000000410000
	/* C7 */
	.octa 0x1002
	/* C23 */
	.octa 0x803003e00e00ffff0000000000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000100050000000000001100
	/* C30 */
	.octa 0x3fff800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C1 */
	.octa 0x803003e00e0100000000000000
	/* C7 */
	.octa 0x1002
	/* C20 */
	.octa 0xc2c2c2c2
	/* C23 */
	.octa 0x803003e00e00ffff0000000000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000100050000000000001100
	/* C30 */
	.octa 0xa0008000000100070000000000400021
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000050b110080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe20a38ff // ALDURSB-R.RI-64 Rt:31 Rn:7 op2:10 imm9:010100011 V:0 op1:00 11100010:11100010
	.inst 0x783a63bf // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:110 o3:0 Rs:26 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x1a1e03d5 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:21 Rn:30 000000:000000 Rm:30 11010000:11010000 S:0 op:0 sf:0
	.inst 0xf88270be // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:5 00:00 imm9:000100111 0:0 opc:10 111000:111000 size:11
	.inst 0xc2caa3c0 // CLRPERM-C.CR-C Cd:0 Cn:30 000:000 1:1 10:10 Rm:10 11000010110:11000010110
	.inst 0x180892b4 // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:20 imm19:0000100010010010101 011000:011000 opc:00
	.inst 0xc2f2601f // BICFLGS-C.CI-C Cd:31 Cn:0 0:0 00:00 imm8:10010011 11000010111:11000010111
	.inst 0xc2c23023 // BLRR-C-C 00011:00011 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.zero 65504
	.inst 0xb1120541 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:10 imm12:010010000001 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2d4dae1 // ALIGNU-C.CI-C Cd:1 Cn:23 0110:0110 U:1 imm6:101001 11000010110:11000010110
	.inst 0xc2c21100
	.zero 4700
	.inst 0xc2c2c2c2
	.zero 978324
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
	ldr x11, =initial_cap_values
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400567 // ldr c7, [x11, #1]
	.inst 0xc2400977 // ldr c23, [x11, #2]
	.inst 0xc2400d7a // ldr c26, [x11, #3]
	.inst 0xc240117d // ldr c29, [x11, #4]
	.inst 0xc240157e // ldr c30, [x11, #5]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30851037
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260310b // ldr c11, [c8, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260110b // ldr c11, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400168 // ldr c8, [x11, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400568 // ldr c8, [x11, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400968 // ldr c8, [x11, #2]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2400d68 // ldr c8, [x11, #3]
	.inst 0xc2c8a681 // chkeq c20, c8
	b.ne comparison_fail
	.inst 0xc2401168 // ldr c8, [x11, #4]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2401568 // ldr c8, [x11, #5]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2401968 // ldr c8, [x11, #6]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2401d68 // ldr c8, [x11, #7]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010a5
	ldr x1, =check_data0
	ldr x2, =0x000010a6
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001102
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400020
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00410000
	ldr x1, =check_data3
	ldr x2, =0x0041000c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00411268
	ldr x1, =check_data4
	ldr x2, =0x0041126c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
