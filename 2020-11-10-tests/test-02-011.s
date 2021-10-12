.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x01
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x38, 0x90, 0x22, 0x22, 0xe1, 0x32, 0x53, 0x78, 0x57, 0xa0, 0xde, 0xc2, 0xa2, 0xea, 0xf2, 0x38
	.byte 0x42, 0xac, 0x79, 0x82, 0x40, 0xd8, 0xd9, 0xc2, 0xc0, 0xd7, 0x9f, 0x9a, 0xc1, 0xb0, 0xc5, 0xc2
	.byte 0xc2, 0xab, 0x06, 0xf8, 0xc1, 0x7d, 0x9f, 0x08, 0x60, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x10
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x48000000000300070000000000001e40
	/* C4 */
	.octa 0x4000000000000000000000000000
	/* C6 */
	.octa 0x1
	/* C14 */
	.octa 0x40000000500200020000000000001000
	/* C18 */
	.octa 0x4ffffd
	/* C21 */
	.octa 0x80000000000100050000000000000001
	/* C23 */
	.octa 0x80000000000700070000000000001801
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000001000500000000000010c6
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x20008000001100070000000000000001
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x4000000000000000000000000000
	/* C6 */
	.octa 0x1
	/* C14 */
	.octa 0x40000000500200020000000000001000
	/* C18 */
	.octa 0x4ffffd
	/* C21 */
	.octa 0x80000000000100050000000000000001
	/* C23 */
	.octa 0x1
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000001000500000000000010c6
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000001100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000147000500000000003f8001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x22229038 // STLXP-R.CR-C Ct:24 Rn:1 Ct2:00100 1:1 Rs:2 1:1 L:0 001000100:001000100
	.inst 0x785332e1 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:23 00:00 imm9:100110011 0:0 opc:01 111000:111000 size:01
	.inst 0xc2dea057 // CLRPERM-C.CR-C Cd:23 Cn:2 000:000 1:1 10:10 Rm:30 11000010110:11000010110
	.inst 0x38f2eaa2 // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:21 10:10 S:0 option:111 Rm:18 1:1 opc:11 111000:111000 size:00
	.inst 0x8279ac42 // ALDR-R.RI-64 Rt:2 Rn:2 op:11 imm9:110011010 L:1 1000001001:1000001001
	.inst 0xc2d9d840 // ALIGNU-C.CI-C Cd:0 Cn:2 0110:0110 U:1 imm6:110011 11000010110:11000010110
	.inst 0x9a9fd7c0 // csinc:aarch64/instrs/integer/conditional/select Rd:0 Rn:30 o2:1 0:0 cond:1101 Rm:31 011010100:011010100 op:0 sf:1
	.inst 0xc2c5b0c1 // CVTP-C.R-C Cd:1 Rn:6 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xf806abc2 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:30 10:10 imm9:001101010 0:0 opc:00 111000:111000 size:11
	.inst 0x089f7dc1 // stllrb:aarch64/instrs/memory/ordered Rt:1 Rn:14 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c21360
	.zero 1048528
	.inst 0x00100000
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400604 // ldr c4, [x16, #1]
	.inst 0xc2400a06 // ldr c6, [x16, #2]
	.inst 0xc2400e0e // ldr c14, [x16, #3]
	.inst 0xc2401212 // ldr c18, [x16, #4]
	.inst 0xc2401615 // ldr c21, [x16, #5]
	.inst 0xc2401a17 // ldr c23, [x16, #6]
	.inst 0xc2401e18 // ldr c24, [x16, #7]
	.inst 0xc240221e // ldr c30, [x16, #8]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603370 // ldr c16, [c27, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601370 // ldr c16, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x27, #0xd
	and x16, x16, x27
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240021b // ldr c27, [x16, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240061b // ldr c27, [x16, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400a1b // ldr c27, [x16, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400e1b // ldr c27, [x16, #3]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc240121b // ldr c27, [x16, #4]
	.inst 0xc2dba4c1 // chkeq c6, c27
	b.ne comparison_fail
	.inst 0xc240161b // ldr c27, [x16, #5]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc2401a1b // ldr c27, [x16, #6]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc2401e1b // ldr c27, [x16, #7]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc240221b // ldr c27, [x16, #8]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc240261b // ldr c27, [x16, #9]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc2402a1b // ldr c27, [x16, #10]
	.inst 0xc2dba7c1 // chkeq c30, c27
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
	ldr x0, =0x00001130
	ldr x1, =check_data1
	ldr x2, =0x00001138
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001734
	ldr x1, =check_data2
	ldr x2, =0x00001736
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
	ldr x0, =0x00400ce0
	ldr x1, =check_data4
	ldr x2, =0x00400ce8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffe
	ldr x1, =check_data5
	ldr x2, =0x004fffff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
