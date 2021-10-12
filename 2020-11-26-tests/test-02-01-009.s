.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x04, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0x30, 0xec, 0xc1, 0x82, 0x3d, 0xe0, 0x92, 0x2d, 0x33, 0xf6, 0xec, 0xe2, 0xdd, 0xcf, 0x25, 0x8b
	.byte 0xdd, 0xaf, 0x42, 0x38, 0xdf, 0x17, 0x0b, 0xb9, 0xbf, 0x61, 0x3e, 0xb8, 0x02, 0xe8, 0x5f, 0x82
	.byte 0xdf, 0xa3, 0xd3, 0xc2, 0x00, 0xa5, 0xc0, 0xc2
.data
check_data8:
	.byte 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400002000000000000000000000c00
	/* C1 */
	.octa 0x400000005041005a0000000000000f84
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x20408002000100070000000000402000
	/* C13 */
	.octa 0xc0000000400000040000000000001000
	/* C17 */
	.octa 0xfe9
	/* C30 */
	.octa 0xc00000002000e0000000000000001042
final_cap_values:
	/* C0 */
	.octa 0x400002000000000000000000000c00
	/* C1 */
	.octa 0x400000005041005a0000000000001018
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x20408002000100070000000000402000
	/* C13 */
	.octa 0xc0000000400000040000000000001000
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0xfe9
	/* C29 */
	.octa 0x400000000000000000000000000c00
	/* C30 */
	.octa 0x20008000900100060000000000400029
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000600200010000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82c1ec30 // ALDRH-R.RRB-32 Rt:16 Rn:1 opc:11 S:0 option:111 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x2d92e03d // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:29 Rn:1 Rt2:11000 imm7:0100101 L:0 1011011:1011011 opc:00
	.inst 0xe2ecf633 // ALDUR-V.RI-D Rt:19 Rn:17 op2:01 imm9:011001111 V:1 op1:11 11100010:11100010
	.inst 0x8b25cfdd // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:29 Rn:30 imm3:011 option:110 Rm:5 01011001:01011001 S:0 op:0 sf:1
	.inst 0x3842afdd // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:29 Rn:30 11:11 imm9:000101010 0:0 opc:01 111000:111000 size:00
	.inst 0xb90b17df // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:30 imm12:001011000101 opc:00 111001:111001 size:10
	.inst 0xb83e61bf // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:13 00:00 opc:110 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x825fe802 // ASTR-R.RI-32 Rt:2 Rn:0 op:10 imm9:111111110 L:0 1000001001:1000001001
	.inst 0xc2d3a3df // CLRPERM-C.CR-C Cd:31 Cn:30 000:000 1:1 10:10 Rm:19 11000010110:11000010110
	.inst 0xc2c0a500 // BLRS-C.C-C 00000:00000 Cn:8 001:001 opc:01 1:1 Cm:0 11000010110:11000010110
	.zero 8152
	.inst 0xc2c21380
	.zero 1040380
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b62 // ldr c2, [x27, #2]
	.inst 0xc2400f68 // ldr c8, [x27, #3]
	.inst 0xc240136d // ldr c13, [x27, #4]
	.inst 0xc2401771 // ldr c17, [x27, #5]
	.inst 0xc2401b7e // ldr c30, [x27, #6]
	/* Vector registers */
	mrs x27, cptr_el3
	bfc x27, #10, #1
	msr cptr_el3, x27
	isb
	ldr q24, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30851037
	msr SCTLR_EL3, x27
	ldr x27, =0x80
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260339b // ldr c27, [c28, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260139b // ldr c27, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240037c // ldr c28, [x27, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240077c // ldr c28, [x27, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400b7c // ldr c28, [x27, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400f7c // ldr c28, [x27, #3]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc240137c // ldr c28, [x27, #4]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc240177c // ldr c28, [x27, #5]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc2401b7c // ldr c28, [x27, #6]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc2401f7c // ldr c28, [x27, #7]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc240237c // ldr c28, [x27, #8]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x28, v19.d[0]
	cmp x27, x28
	b.ne comparison_fail
	ldr x27, =0x0
	mov x28, v19.d[1]
	cmp x27, x28
	b.ne comparison_fail
	ldr x27, =0x0
	mov x28, v24.d[0]
	cmp x27, x28
	b.ne comparison_fail
	ldr x27, =0x0
	mov x28, v24.d[1]
	cmp x27, x28
	b.ne comparison_fail
	ldr x27, =0x0
	mov x28, v29.d[0]
	cmp x27, x28
	b.ne comparison_fail
	ldr x27, =0x0
	mov x28, v29.d[1]
	cmp x27, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000106c
	ldr x1, =check_data2
	ldr x2, =0x0000106d
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010b8
	ldr x1, =check_data3
	ldr x2, =0x000010c0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000013f8
	ldr x1, =check_data4
	ldr x2, =0x000013fc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001b80
	ldr x1, =check_data5
	ldr x2, =0x00001b84
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001f08
	ldr x1, =check_data6
	ldr x2, =0x00001f0a
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x00400028
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00402000
	ldr x1, =check_data8
	ldr x2, =0x00402004
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
