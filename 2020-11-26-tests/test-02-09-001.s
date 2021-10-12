.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xdd, 0xa4, 0x10, 0xa2, 0xb1, 0xc3, 0xde, 0xc2, 0xc1, 0xc9, 0x22, 0x38, 0x45, 0xab, 0x82, 0xe2
	.byte 0x1f, 0x05, 0x1f, 0xe2, 0xe0, 0x73, 0xc2, 0xc2, 0xe1, 0xdb, 0xef, 0x69, 0xdd, 0xd3, 0x9e, 0x02
	.byte 0x81, 0x57, 0x50, 0xe2, 0x41, 0x36, 0x02, 0xf8, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x8c4
	/* C6 */
	.octa 0x818
	/* C8 */
	.octa 0x8000000031ff2fff0000000000404000
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x40000000000100050000000000001000
	/* C26 */
	.octa 0x80000000000f40170000000000403fea
	/* C28 */
	.octa 0x1833
	/* C29 */
	.octa 0xc000000000000000000100000000
	/* C30 */
	.octa 0x220070000000a00000000
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x8c4
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0xfffffffffffff8b8
	/* C8 */
	.octa 0x8000000031ff2fff0000000000404000
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0xffe0000100000000
	/* C18 */
	.octa 0x40000000000100050000000000001023
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x80000000000f40170000000000403fea
	/* C28 */
	.octa 0x1833
	/* C29 */
	.octa 0x2200700000009fffff84c
	/* C30 */
	.octa 0x220070000000a00000000
initial_SP_EL3_value:
	.octa 0x80000000000100070000000000400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000004004080800ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa210a4dd // STR-C.RIAW-C Ct:29 Rn:6 01:01 imm9:100001010 0:0 opc:00 10100010:10100010
	.inst 0xc2dec3b1 // CVT-R.CC-C Rd:17 Cn:29 110000:110000 Cm:30 11000010110:11000010110
	.inst 0x3822c9c1 // strb_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:14 10:10 S:0 option:110 Rm:2 1:1 opc:00 111000:111000 size:00
	.inst 0xe282ab45 // ALDURSW-R.RI-64 Rt:5 Rn:26 op2:10 imm9:000101010 V:0 op1:10 11100010:11100010
	.inst 0xe21f051f // ALDURB-R.RI-32 Rt:31 Rn:8 op2:01 imm9:111110000 V:0 op1:00 11100010:11100010
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x69efdbe1 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:31 Rt2:10110 imm7:1011111 L:1 1010011:1010011 opc:01
	.inst 0x029ed3dd // SUB-C.CIS-C Cd:29 Cn:30 imm12:011110110100 sh:0 A:1 00000010:00000010
	.inst 0xe2505781 // ALDURH-R.RI-32 Rt:1 Rn:28 op2:01 imm9:100000101 V:0 op1:01 11100010:11100010
	.inst 0xf8023641 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:18 01:01 imm9:000100011 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c212e0
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
	ldr x11, =initial_cap_values
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400966 // ldr c6, [x11, #2]
	.inst 0xc2400d68 // ldr c8, [x11, #3]
	.inst 0xc240116e // ldr c14, [x11, #4]
	.inst 0xc2401572 // ldr c18, [x11, #5]
	.inst 0xc240197a // ldr c26, [x11, #6]
	.inst 0xc2401d7c // ldr c28, [x11, #7]
	.inst 0xc240217d // ldr c29, [x11, #8]
	.inst 0xc240257e // ldr c30, [x11, #9]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032eb // ldr c11, [c23, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x826012eb // ldr c11, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x23, #0xf
	and x11, x11, x23
	cmp x11, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400177 // ldr c23, [x11, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400577 // ldr c23, [x11, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400977 // ldr c23, [x11, #2]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc2400d77 // ldr c23, [x11, #3]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc2401177 // ldr c23, [x11, #4]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc2401577 // ldr c23, [x11, #5]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2401977 // ldr c23, [x11, #6]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401d77 // ldr c23, [x11, #7]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2402177 // ldr c23, [x11, #8]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2402577 // ldr c23, [x11, #9]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc2402977 // ldr c23, [x11, #10]
	.inst 0xc2d7a781 // chkeq c28, c23
	b.ne comparison_fail
	.inst 0xc2402d77 // ldr c23, [x11, #11]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2403177 // ldr c23, [x11, #12]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010cc
	ldr x1, =check_data2
	ldr x2, =0x000010cd
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f40
	ldr x1, =check_data3
	ldr x2, =0x00001f42
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
	ldr x0, =0x00400390
	ldr x1, =check_data5
	ldr x2, =0x00400398
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00403ff0
	ldr x1, =check_data6
	ldr x2, =0x00403ff1
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00404014
	ldr x1, =check_data7
	ldr x2, =0x00404018
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
