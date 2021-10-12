.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x00, 0x18, 0x00, 0x00
.data
check_data5:
	.zero 32
.data
check_data6:
	.byte 0x7e, 0x7e, 0x9f, 0x88, 0xfc, 0xcf, 0xcc, 0x22, 0xde, 0x03, 0xd7, 0x38, 0x0b, 0x8c, 0x87, 0xe2
	.byte 0x26, 0xdd, 0x80, 0xf9, 0x1f, 0x14, 0x10, 0x79, 0x01, 0x10, 0x42, 0x38, 0x22, 0xd0, 0xc1, 0xc2
	.byte 0x21, 0xd8, 0x20, 0xea, 0xff, 0x63, 0xcd, 0xc2, 0xa0, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc00000005fc00fd40000000000000fe8
	/* C11 */
	.octa 0x4000000000000000000000000000
	/* C13 */
	.octa 0x80000000000000
	/* C19 */
	.octa 0x40000000400100020000000000001800
	/* C30 */
	.octa 0x80000000600000040000000000001800
final_cap_values:
	/* C0 */
	.octa 0xc00000005fc00fd40000000000000fe8
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0x4000000000000000000000000000
	/* C13 */
	.octa 0x80000000000000
	/* C19 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000028100060000000000001fc0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004100c1010000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x48000000210600070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fd0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x889f7e7e // stllr:aarch64/instrs/memory/ordered Rt:30 Rn:19 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x22cccffc // LDP-CC.RIAW-C Ct:28 Rn:31 Ct2:10011 imm7:0011001 L:1 001000101:001000101
	.inst 0x38d703de // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:30 00:00 imm9:101110000 0:0 opc:11 111000:111000 size:00
	.inst 0xe2878c0b // ASTUR-C.RI-C Ct:11 Rn:0 op2:11 imm9:001111000 V:0 op1:10 11100010:11100010
	.inst 0xf980dd26 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:6 Rn:9 imm12:000000110111 opc:10 111001:111001 size:11
	.inst 0x7910141f // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:0 imm12:010000000101 opc:00 111001:111001 size:01
	.inst 0x38421001 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:0 00:00 imm9:000100001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c1d022 // CPY-C.C-C Cd:2 Cn:1 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xea20d821 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:1 imm6:110110 Rm:0 N:1 shift:00 01010:01010 opc:11 sf:1
	.inst 0xc2cd63ff // SCOFF-C.CR-C Cd:31 Cn:31 000:000 opc:11 0:0 Rm:13 11000010110:11000010110
	.inst 0xc2c213a0
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
	.inst 0xc240072b // ldr c11, [x25, #1]
	.inst 0xc2400b2d // ldr c13, [x25, #2]
	.inst 0xc2400f33 // ldr c19, [x25, #3]
	.inst 0xc240133e // ldr c30, [x25, #4]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x3085103f
	msr SCTLR_EL3, x25
	ldr x25, =0x4
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033b9 // ldr c25, [c29, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x826013b9 // ldr c25, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x29, #0xf
	and x25, x25, x29
	cmp x25, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc240033d // ldr c29, [x25, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240073d // ldr c29, [x25, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc2400b3d // ldr c29, [x25, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400f3d // ldr c29, [x25, #3]
	.inst 0xc2dda561 // chkeq c11, c29
	b.ne comparison_fail
	.inst 0xc240133d // ldr c29, [x25, #4]
	.inst 0xc2dda5a1 // chkeq c13, c29
	b.ne comparison_fail
	.inst 0xc240173d // ldr c29, [x25, #5]
	.inst 0xc2dda661 // chkeq c19, c29
	b.ne comparison_fail
	.inst 0xc2401b3d // ldr c29, [x25, #6]
	.inst 0xc2dda781 // chkeq c28, c29
	b.ne comparison_fail
	.inst 0xc2401f3d // ldr c29, [x25, #7]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001009
	ldr x1, =check_data0
	ldr x2, =0x0000100a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001070
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001770
	ldr x1, =check_data2
	ldr x2, =0x00001771
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017f2
	ldr x1, =check_data3
	ldr x2, =0x000017f4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001804
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fc0
	ldr x1, =check_data5
	ldr x2, =0x00001fe0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
