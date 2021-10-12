.section data0, #alloc, #write
	.zero 1152
	.byte 0x1f, 0xff, 0xfb, 0xff, 0xf7, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2928
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x1f, 0xff, 0xfb, 0xff, 0xf7, 0xff, 0xff, 0xff
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x22, 0xfc, 0xa0, 0xc8, 0xfe, 0x67, 0x2e, 0x39, 0x9e, 0xfe, 0xdf, 0x88, 0x42, 0x7c, 0x1e, 0x48
	.byte 0xe9, 0x43, 0xc6, 0xc2, 0x1f, 0x00, 0x00, 0xfa, 0x1e, 0x94, 0x9f, 0x1a, 0x12, 0x08, 0xc2, 0xc2
	.byte 0xfe, 0x23, 0xc2, 0x9a, 0x82, 0x3b, 0x82, 0x38, 0x80, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000400e0
	/* C1 */
	.octa 0xc0000000000600020000000000001480
	/* C2 */
	.octa 0x400000007ffd10000000000000001002
	/* C6 */
	.octa 0x0
	/* C20 */
	.octa 0x800000000000800800000000004e0120
	/* C28 */
	.octa 0x80000000000100050000000000001fdb
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xfffffff7fffbff1f
	/* C1 */
	.octa 0xc0000000000600020000000000001480
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x40000000000500050000000000000000
	/* C18 */
	.octa 0x80100000000fffffff7fffbff1f
	/* C20 */
	.octa 0x800000000000800800000000004e0120
	/* C28 */
	.octa 0x80000000000100050000000000001fdb
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000000500050000000000000800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc8a0fc22 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:2 Rn:1 11111:11111 o0:1 Rs:0 1:1 L:0 0010001:0010001 size:11
	.inst 0x392e67fe // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:31 imm12:101110011001 opc:00 111001:111001 size:00
	.inst 0x88dffe9e // ldar:aarch64/instrs/memory/ordered Rt:30 Rn:20 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x481e7c42 // stxrh:aarch64/instrs/memory/exclusive/single Rt:2 Rn:2 Rt2:11111 o0:0 Rs:30 0:0 L:0 0010000:0010000 size:01
	.inst 0xc2c643e9 // SCVALUE-C.CR-C Cd:9 Cn:31 000:000 opc:10 0:0 Rm:6 11000010110:11000010110
	.inst 0xfa00001f // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:0 000000:000000 Rm:0 11010000:11010000 S:1 op:1 sf:1
	.inst 0x1a9f941e // csinc:aarch64/instrs/integer/conditional/select Rd:30 Rn:0 o2:1 0:0 cond:1001 Rm:31 011010100:011010100 op:0 sf:0
	.inst 0xc2c20812 // SEAL-C.CC-C Cd:18 Cn:0 0010:0010 opc:00 Cm:2 11000010110:11000010110
	.inst 0x9ac223fe // lslv:aarch64/instrs/integer/shift/variable Rd:30 Rn:31 op2:00 0010:0010 Rm:2 0011010110:0011010110 sf:1
	.inst 0x38823b82 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:28 10:10 imm9:000100011 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c21180
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a2 // ldr c2, [x5, #2]
	.inst 0xc2400ca6 // ldr c6, [x5, #3]
	.inst 0xc24010b4 // ldr c20, [x5, #4]
	.inst 0xc24014bc // ldr c28, [x5, #5]
	.inst 0xc24018be // ldr c30, [x5, #6]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x3085103d
	msr SCTLR_EL3, x5
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601185 // ldr c5, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x12, #0xf
	and x5, x5, x12
	cmp x5, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000ac // ldr c12, [x5, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24004ac // ldr c12, [x5, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24008ac // ldr c12, [x5, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400cac // ldr c12, [x5, #3]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc24010ac // ldr c12, [x5, #4]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc24014ac // ldr c12, [x5, #5]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc24018ac // ldr c12, [x5, #6]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc2401cac // ldr c12, [x5, #7]
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	.inst 0xc24020ac // ldr c12, [x5, #8]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001399
	ldr x1, =check_data1
	ldr x2, =0x0000139a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001480
	ldr x1, =check_data2
	ldr x2, =0x00001488
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004e0120
	ldr x1, =check_data5
	ldr x2, =0x004e0124
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
