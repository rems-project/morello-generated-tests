.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
	.byte 0x11, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x11, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0xaf, 0xfe, 0x7f, 0x42, 0x42, 0xed, 0x58, 0x82, 0xc0, 0x5a, 0x4c, 0xb8, 0xe1, 0x62, 0x7f, 0x88
	.byte 0xff, 0xcb, 0x51, 0xac, 0x1f, 0x71, 0x22, 0x38, 0xf0, 0xf3, 0xc0, 0xc2, 0xb4, 0xfc, 0xdf, 0xc8
	.byte 0x59, 0x70, 0xb8, 0xe2, 0x9e, 0x07, 0x07, 0x62, 0x40, 0x13, 0xc2, 0xc2
.data
check_data7:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1811
	/* C5 */
	.octa 0x80000000100640170000000000401008
	/* C8 */
	.octa 0xc00000000201c00500000000000017e2
	/* C10 */
	.octa 0x1000
	/* C21 */
	.octa 0x1000
	/* C22 */
	.octa 0x800000004802000000000000003fff3b
	/* C23 */
	.octa 0x8000000029b300070000000000001c70
	/* C28 */
	.octa 0x40000000000200070000000000000f80
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x427ffeaf
	/* C1 */
	.octa 0x1811
	/* C2 */
	.octa 0x1811
	/* C5 */
	.octa 0x80000000100640170000000000401008
	/* C8 */
	.octa 0xc00000000201c00500000000000017e2
	/* C10 */
	.octa 0x1000
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x1000
	/* C22 */
	.octa 0x800000004802000000000000003fff3b
	/* C23 */
	.octa 0x8000000029b300070000000000001c70
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x40000000000200070000000000000f80
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800000000002000100000000000010e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080003000e0080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004004000c00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword final_cap_values + 208
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x427ffeaf // ALDAR-R.R-32 Rt:15 Rn:21 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x8258ed42 // ASTR-R.RI-64 Rt:2 Rn:10 op:11 imm9:110001110 L:0 1000001001:1000001001
	.inst 0xb84c5ac0 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:22 10:10 imm9:011000101 0:0 opc:01 111000:111000 size:10
	.inst 0x887f62e1 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:23 Rt2:11000 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0xac51cbff // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:31 Rn:31 Rt2:10010 imm7:0100011 L:1 1011000:1011000 opc:10
	.inst 0x3822711f // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:8 00:00 opc:111 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c0f3f0 // GCTYPE-R.C-C Rd:16 Cn:31 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc8dffcb4 // ldar:aarch64/instrs/memory/ordered Rt:20 Rn:5 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xe2b87059 // ASTUR-V.RI-S Rt:25 Rn:2 op2:00 imm9:110000111 V:1 op1:10 11100010:11100010
	.inst 0x6207079e // STNP-C.RIB-C Ct:30 Rn:28 Ct2:00001 imm7:0001110 L:0 011000100:011000100
	.inst 0xc2c21340
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c2 // ldr c2, [x14, #0]
	.inst 0xc24005c5 // ldr c5, [x14, #1]
	.inst 0xc24009c8 // ldr c8, [x14, #2]
	.inst 0xc2400dca // ldr c10, [x14, #3]
	.inst 0xc24011d5 // ldr c21, [x14, #4]
	.inst 0xc24015d6 // ldr c22, [x14, #5]
	.inst 0xc24019d7 // ldr c23, [x14, #6]
	.inst 0xc2401ddc // ldr c28, [x14, #7]
	.inst 0xc24021de // ldr c30, [x14, #8]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q25, =0x0
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260334e // ldr c14, [c26, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260134e // ldr c14, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001da // ldr c26, [x14, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24005da // ldr c26, [x14, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc24009da // ldr c26, [x14, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400dda // ldr c26, [x14, #3]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc24011da // ldr c26, [x14, #4]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc24015da // ldr c26, [x14, #5]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc24019da // ldr c26, [x14, #6]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc2401dda // ldr c26, [x14, #7]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc24021da // ldr c26, [x14, #8]
	.inst 0xc2daa681 // chkeq c20, c26
	b.ne comparison_fail
	.inst 0xc24025da // ldr c26, [x14, #9]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc24029da // ldr c26, [x14, #10]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc2402dda // ldr c26, [x14, #11]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc24031da // ldr c26, [x14, #12]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc24035da // ldr c26, [x14, #13]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc24039da // ldr c26, [x14, #14]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x26, v18.d[0]
	cmp x14, x26
	b.ne comparison_fail
	ldr x14, =0x0
	mov x26, v18.d[1]
	cmp x14, x26
	b.ne comparison_fail
	ldr x14, =0x0
	mov x26, v25.d[0]
	cmp x14, x26
	b.ne comparison_fail
	ldr x14, =0x0
	mov x26, v25.d[1]
	cmp x14, x26
	b.ne comparison_fail
	ldr x14, =0x0
	mov x26, v31.d[0]
	cmp x14, x26
	b.ne comparison_fail
	ldr x14, =0x0
	mov x26, v31.d[1]
	cmp x14, x26
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
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001080
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001310
	ldr x1, =check_data2
	ldr x2, =0x00001330
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001798
	ldr x1, =check_data3
	ldr x2, =0x0000179c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000017e2
	ldr x1, =check_data4
	ldr x2, =0x000017e3
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001c70
	ldr x1, =check_data5
	ldr x2, =0x00001c78
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
	ldr x0, =0x00401008
	ldr x1, =check_data7
	ldr x2, =0x00401010
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
