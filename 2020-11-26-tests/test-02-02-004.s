.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x0b
.data
check_data3:
	.byte 0xf3, 0x2f, 0x33, 0xb1, 0xb5, 0xa3, 0xf1, 0xe2, 0x1f, 0x00, 0x7f, 0x78, 0xde, 0xc3, 0xdc, 0x78
	.byte 0xe2, 0xcb, 0x7d, 0x38, 0xff, 0x30, 0x33, 0x38, 0x3e, 0xc0, 0xdd, 0xc2, 0x4e, 0x0a, 0xc5, 0x1a
	.byte 0xa7, 0xcf, 0x23, 0x0b, 0x36, 0xa8, 0xce, 0xc2, 0x60, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc00000000000c0000000000000001000
	/* C1 */
	.octa 0x800000000000000000000000
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0xc0000000000700070000000000001eff
	/* C29 */
	.octa 0x1106
	/* C30 */
	.octa 0x80000000080600410000000000400408
final_cap_values:
	/* C0 */
	.octa 0xc00000000000c0000000000000001000
	/* C1 */
	.octa 0x800000000000000000000000
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x40150b
	/* C22 */
	.octa 0x800000000000000000000000
	/* C29 */
	.octa 0x1106
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000080080000000000400840
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000004000000200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb1332ff3 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:19 Rn:31 imm12:110011001011 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xe2f1a3b5 // ASTUR-V.RI-D Rt:21 Rn:29 op2:00 imm9:100011010 V:1 op1:11 11100010:11100010
	.inst 0x787f001f // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:000 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x78dcc3de // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:30 00:00 imm9:111001100 0:0 opc:11 111000:111000 size:01
	.inst 0x387dcbe2 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:31 10:10 S:0 option:110 Rm:29 1:1 opc:01 111000:111000 size:00
	.inst 0x383330ff // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:7 00:00 opc:011 o3:0 Rs:19 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2ddc03e // CVT-R.CC-C Rd:30 Cn:1 110000:110000 Cm:29 11000010110:11000010110
	.inst 0x1ac50a4e // udiv:aarch64/instrs/integer/arithmetic/div Rd:14 Rn:18 o1:0 00001:00001 Rm:5 0011010110:0011010110 sf:0
	.inst 0x0b23cfa7 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:7 Rn:29 imm3:011 option:110 Rm:3 01011001:01011001 S:0 op:0 sf:0
	.inst 0xc2cea836 // EORFLGS-C.CR-C Cd:22 Cn:1 1010:1010 opc:10 Rm:14 11000010110:11000010110
	.inst 0xc2c21360
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b85 // ldr c5, [x28, #2]
	.inst 0xc2400f87 // ldr c7, [x28, #3]
	.inst 0xc240139d // ldr c29, [x28, #4]
	.inst 0xc240179e // ldr c30, [x28, #5]
	/* Vector registers */
	mrs x28, cptr_el3
	bfc x28, #10, #1
	msr cptr_el3, x28
	isb
	ldr q21, =0x0
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x3085103f
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260337c // ldr c28, [c27, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260137c // ldr c28, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x27, #0xf
	and x28, x28, x27
	cmp x28, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240039b // ldr c27, [x28, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240079b // ldr c27, [x28, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400b9b // ldr c27, [x28, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400f9b // ldr c27, [x28, #3]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc240139b // ldr c27, [x28, #4]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc240179b // ldr c27, [x28, #5]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc2401b9b // ldr c27, [x28, #6]
	.inst 0xc2dba6c1 // chkeq c22, c27
	b.ne comparison_fail
	.inst 0xc2401f9b // ldr c27, [x28, #7]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240239b // ldr c27, [x28, #8]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x27, v21.d[0]
	cmp x28, x27
	b.ne comparison_fail
	ldr x28, =0x0
	mov x27, v21.d[1]
	cmp x28, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001eff
	ldr x1, =check_data2
	ldr x2, =0x00001f00
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
	ldr x0, =0x004003d4
	ldr x1, =check_data4
	ldr x2, =0x004003d6
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00401946
	ldr x1, =check_data5
	ldr x2, =0x00401947
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
