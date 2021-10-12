.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
	.byte 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4016
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x20, 0x00
.data
check_data1:
	.byte 0x20
.data
check_data2:
	.byte 0x70, 0x00, 0x40, 0x00
.data
check_data3:
	.byte 0xdd, 0x5b, 0x0b, 0xb9, 0xa6, 0x08, 0x4c, 0x7a, 0xa2, 0x53, 0xc2, 0xc2
.data
check_data4:
	.byte 0xb9, 0x8f, 0x4b, 0xa2, 0x59, 0x48, 0xfc, 0xc2, 0xdf, 0x63, 0x3f, 0xb8, 0x48, 0xe3, 0xd7, 0xc2
	.byte 0x2f, 0x14, 0xc0, 0xda, 0x3f, 0x60, 0x3f, 0x38, 0xfa, 0x83, 0xf4, 0xa2, 0x60, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1040
	/* C2 */
	.octa 0x3fff800000000000000000000000
	/* C20 */
	.octa 0x0
	/* C26 */
	.octa 0x3fff800000000000000000000000
	/* C29 */
	.octa 0x20008000c200c2010000000000400070
	/* C30 */
	.octa 0x1010
final_cap_values:
	/* C1 */
	.octa 0x1040
	/* C2 */
	.octa 0x3fff800000000000000000000000
	/* C15 */
	.octa 0x32
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x3fff80000000e200000000000000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x400bf0
	/* C30 */
	.octa 0x1010
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004011c0240000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc1000003ff900050080ffffffb00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb90b5bdd // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:30 imm12:001011010110 opc:00 111001:111001 size:10
	.inst 0x7a4c08a6 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0110 0:0 Rn:5 10:10 cond:0000 imm5:01100 111010010:111010010 op:1 sf:0
	.inst 0xc2c253a2 // RETS-C-C 00010:00010 Cn:29 100:100 opc:10 11000010110000100:11000010110000100
	.zero 100
	.inst 0xa24b8fb9 // LDR-C.RIBW-C Ct:25 Rn:29 11:11 imm9:010111000 0:0 opc:01 10100010:10100010
	.inst 0xc2fc4859 // ORRFLGS-C.CI-C Cd:25 Cn:2 0:0 01:01 imm8:11100010 11000010111:11000010111
	.inst 0xb83f63df // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:110 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2d7e348 // SCFLGS-C.CR-C Cd:8 Cn:26 111000:111000 Rm:23 11000010110:11000010110
	.inst 0xdac0142f // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:15 Rn:1 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x383f603f // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:110 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa2f483fa // SWPAL-CC.R-C Ct:26 Rn:31 100000:100000 Cs:20 1:1 R:1 A:1 10100010:10100010
	.inst 0xc2c21060
	.zero 1048432
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400954 // ldr c20, [x10, #2]
	.inst 0xc2400d5a // ldr c26, [x10, #3]
	.inst 0xc240115d // ldr c29, [x10, #4]
	.inst 0xc240155e // ldr c30, [x10, #5]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851037
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306a // ldr c10, [c3, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260106a // ldr c10, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x3, #0xf
	and x10, x10, x3
	cmp x10, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400143 // ldr c3, [x10, #0]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400543 // ldr c3, [x10, #1]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400943 // ldr c3, [x10, #2]
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	.inst 0xc2400d43 // ldr c3, [x10, #3]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc2401143 // ldr c3, [x10, #4]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc2401543 // ldr c3, [x10, #5]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc2401943 // ldr c3, [x10, #6]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2401d43 // ldr c3, [x10, #7]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001041
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b68
	ldr x1, =check_data2
	ldr x2, =0x00001b6c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040000c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400070
	ldr x1, =check_data4
	ldr x2, =0x00400090
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400bf0
	ldr x1, =check_data5
	ldr x2, =0x00400c00
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
