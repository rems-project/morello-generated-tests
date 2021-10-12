.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x5f, 0x82, 0xf6, 0xe2, 0x07, 0xac, 0x59, 0x38, 0xf4, 0x7e, 0x7f, 0x42, 0xf2, 0x7f, 0x5f, 0x48
	.byte 0x20, 0xc7, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0x80, 0x0a, 0xe2, 0x1e, 0x0d, 0x05, 0xe2, 0x01, 0x81, 0xe1, 0xa2, 0xe1, 0x97, 0x5c, 0x38
	.byte 0x3e, 0x30, 0x8d, 0xf8, 0x60, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000500100020000000000001066
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400002000000000000000000000000
	/* C6 */
	.octa 0x40000000000000000000000000001000
	/* C8 */
	.octa 0x80000000000100050000000000001000
	/* C18 */
	.octa 0x1408
	/* C23 */
	.octa 0x4ffffe
	/* C25 */
	.octa 0x20408002000100050000000000410000
final_cap_values:
	/* C0 */
	.octa 0x80000000500100020000000000001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400002000000000000000000000000
	/* C6 */
	.octa 0x40000000000000000000000000001000
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x80000000000100050000000000001000
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x4ffffe
	/* C25 */
	.octa 0x20408002000100050000000000410000
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000466036
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2f6825f // ASTUR-V.RI-D Rt:31 Rn:18 op2:00 imm9:101101000 V:1 op1:11 11100010:11100010
	.inst 0x3859ac07 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:7 Rn:0 11:11 imm9:110011010 0:0 opc:01 111000:111000 size:00
	.inst 0x427f7ef4 // ALDARB-R.R-B Rt:20 Rn:23 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x485f7ff2 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:18 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xc2c2c720 // RETS-C.C-C 00000:00000 Cn:25 001:001 opc:10 1:1 Cm:2 11000010110:11000010110
	.zero 65516
	.inst 0xe20a80c2 // ASTURB-R.RI-32 Rt:2 Rn:6 op2:00 imm9:010101000 V:0 op1:00 11100010:11100010
	.inst 0xe2050d1e // ALDURSB-R.RI-32 Rt:30 Rn:8 op2:11 imm9:001010000 V:0 op1:00 11100010:11100010
	.inst 0xa2e18101 // SWPAL-CC.R-C Ct:1 Rn:8 100000:100000 Cs:1 1:1 R:1 A:1 10100010:10100010
	.inst 0x385c97e1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:31 01:01 imm9:111001001 0:0 opc:01 111000:111000 size:00
	.inst 0xf88d303e // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:1 00:00 imm9:011010011 0:0 opc:10 111000:111000 size:11
	.inst 0xc2c21060
	.zero 983016
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
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e06 // ldr c6, [x16, #3]
	.inst 0xc2401208 // ldr c8, [x16, #4]
	.inst 0xc2401612 // ldr c18, [x16, #5]
	.inst 0xc2401a17 // ldr c23, [x16, #6]
	.inst 0xc2401e19 // ldr c25, [x16, #7]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603070 // ldr c16, [c3, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601070 // ldr c16, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400203 // ldr c3, [x16, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400603 // ldr c3, [x16, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400e03 // ldr c3, [x16, #3]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc2401203 // ldr c3, [x16, #4]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc2401603 // ldr c3, [x16, #5]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc2401a03 // ldr c3, [x16, #6]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2401e03 // ldr c3, [x16, #7]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc2402203 // ldr c3, [x16, #8]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2402603 // ldr c3, [x16, #9]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc2402a03 // ldr c3, [x16, #10]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402e03 // ldr c3, [x16, #11]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x3, v31.d[0]
	cmp x16, x3
	b.ne comparison_fail
	ldr x16, =0x0
	mov x3, v31.d[1]
	cmp x16, x3
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
	ldr x0, =0x00001050
	ldr x1, =check_data1
	ldr x2, =0x00001051
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a8
	ldr x1, =check_data2
	ldr x2, =0x000010a9
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001370
	ldr x1, =check_data3
	ldr x2, =0x00001378
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00410000
	ldr x1, =check_data5
	ldr x2, =0x00410018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00466036
	ldr x1, =check_data6
	ldr x2, =0x00466038
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffffe
	ldr x1, =check_data7
	ldr x2, =0x004fffff
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
