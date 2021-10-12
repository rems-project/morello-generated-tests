.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xcb, 0x73, 0x4a, 0xe2, 0x0e, 0x5c, 0x5c, 0x7c, 0x2a, 0x71, 0xc0, 0xc2, 0x0d, 0xb0, 0xc5, 0xc2
	.byte 0xff, 0x23, 0xbf, 0xf8, 0x00, 0x20, 0xbc, 0xb8, 0xdd, 0xeb, 0x8f, 0x38, 0x74, 0x92, 0xc5, 0xc2
	.byte 0x1f, 0x20, 0x3d, 0x9b, 0xe2, 0x10, 0xc2, 0xc2
.data
check_data5:
	.byte 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2003
	/* C7 */
	.octa 0x200080000017810300000000004e0000
	/* C9 */
	.octa 0x600000000000000000000
	/* C11 */
	.octa 0x0
	/* C19 */
	.octa 0x80000000ffe000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000601400c10000000000001001
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C7 */
	.octa 0x200080000017810300000000004e0000
	/* C9 */
	.octa 0x600000000000000000000
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x20008000000b00070000000000001fc8
	/* C19 */
	.octa 0x80000000ffe000
	/* C20 */
	.octa 0xc00000000007000f0080000000ffe000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000601400c10000000000001001
initial_SP_EL3_value:
	.octa 0x1008
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000b00070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000f000000000000c001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe24a73cb // ASTURH-R.RI-32 Rt:11 Rn:30 op2:00 imm9:010100111 V:0 op1:01 11100010:11100010
	.inst 0x7c5c5c0e // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:14 Rn:0 11:11 imm9:111000101 0:0 opc:01 111100:111100 size:01
	.inst 0xc2c0712a // GCOFF-R.C-C Rd:10 Cn:9 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c5b00d // CVTP-C.R-C Cd:13 Rn:0 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xf8bf23ff // ldeor:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:31 00:00 opc:010 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xb8bc2000 // ldeor:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:0 00:00 opc:010 0:0 Rs:28 1:1 R:0 A:1 111000:111000 size:10
	.inst 0x388febdd // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:29 Rn:30 10:10 imm9:011111110 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c59274 // CVTD-C.R-C Cd:20 Rn:19 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x9b3d201f // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:0 Ra:8 o0:0 Rm:29 01:01 U:0 10011011:10011011
	.inst 0xc2c210e2 // BRS-C-C 00010:00010 Cn:7 100:100 opc:00 11000010110000100:11000010110000100
	.zero 917464
	.inst 0xc2c21340
	.zero 131068
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400647 // ldr c7, [x18, #1]
	.inst 0xc2400a49 // ldr c9, [x18, #2]
	.inst 0xc2400e4b // ldr c11, [x18, #3]
	.inst 0xc2401253 // ldr c19, [x18, #4]
	.inst 0xc240165c // ldr c28, [x18, #5]
	.inst 0xc2401a5e // ldr c30, [x18, #6]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851037
	msr SCTLR_EL3, x18
	ldr x18, =0x8
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603352 // ldr c18, [c26, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601352 // ldr c18, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240025a // ldr c26, [x18, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240065a // ldr c26, [x18, #1]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc2400a5a // ldr c26, [x18, #2]
	.inst 0xc2daa521 // chkeq c9, c26
	b.ne comparison_fail
	.inst 0xc2400e5a // ldr c26, [x18, #3]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc240125a // ldr c26, [x18, #4]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc240165a // ldr c26, [x18, #5]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc2401a5a // ldr c26, [x18, #6]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc2401e5a // ldr c26, [x18, #7]
	.inst 0xc2daa681 // chkeq c20, c26
	b.ne comparison_fail
	.inst 0xc240225a // ldr c26, [x18, #8]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc240265a // ldr c26, [x18, #9]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2402a5a // ldr c26, [x18, #10]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x26, v14.d[0]
	cmp x18, x26
	b.ne comparison_fail
	ldr x18, =0x0
	mov x26, v14.d[1]
	cmp x18, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010a8
	ldr x1, =check_data1
	ldr x2, =0x000010aa
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010ff
	ldr x1, =check_data2
	ldr x2, =0x00001100
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fc8
	ldr x1, =check_data3
	ldr x2, =0x00001fcc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004e0000
	ldr x1, =check_data5
	ldr x2, =0x004e0004
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
