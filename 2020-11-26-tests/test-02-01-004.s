.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x11, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x3f, 0x7c, 0xdf, 0x88, 0x60, 0x03, 0x1f, 0xd6
.data
check_data5:
	.byte 0xfe, 0xa2, 0x30, 0x22, 0xa2, 0xe8, 0xc5, 0xc2, 0x9f, 0xe9, 0xeb, 0x79, 0xab, 0x03, 0xbe, 0xb8
	.byte 0x22, 0x53, 0xc2, 0xc2
.data
check_data6:
	.byte 0xb7, 0x73, 0xc4, 0xe2, 0x36, 0x00, 0x1f, 0x3a, 0x92, 0xc8, 0x16, 0x02, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x110d
	/* C4 */
	.octa 0x220000000000000000000
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0xfffffffffffffc91
	/* C23 */
	.octa 0x1011
	/* C25 */
	.octa 0x20008000506142220000000000444400
	/* C27 */
	.octa 0xe020
	/* C29 */
	.octa 0x40000000580008020000000000000fc1
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x110d
	/* C4 */
	.octa 0x220000000000000000000
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0xfffffffffffffc91
	/* C16 */
	.octa 0x1
	/* C18 */
	.octa 0x2200000000000000005b2
	/* C23 */
	.octa 0x1011
	/* C25 */
	.octa 0x20008000506142220000000000444400
	/* C27 */
	.octa 0xe020
	/* C29 */
	.octa 0x40000000580008020000000000000fc1
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002007c8050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000401c010f0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x88df7c3f // ldlar:aarch64/instrs/memory/ordered Rt:31 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xd61f0360 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:27 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 24
	.inst 0x2230a2fe // STLXP-R.CR-C Ct:30 Rn:23 Ct2:01000 1:1 Rs:16 1:1 L:0 001000100:001000100
	.inst 0xc2c5e8a2 // CTHI-C.CR-C Cd:2 Cn:5 1010:1010 opc:11 Rm:5 11000010110:11000010110
	.inst 0x79ebe99f // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:12 imm12:101011111010 opc:11 111001:111001 size:01
	.inst 0xb8be03ab // ldadd:aarch64/instrs/memory/atomicops/ld Rt:11 Rn:29 00:00 opc:000 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:10
	.inst 0xc2c25322 // RETS-C-C 00010:00010 Cn:25 100:100 opc:10 11000010110000100:11000010110000100
	.zero 279500
	.inst 0xe2c473b7 // ASTUR-R.RI-64 Rt:23 Rn:29 op2:00 imm9:001000111 V:0 op1:11 11100010:11100010
	.inst 0x3a1f0036 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:22 Rn:1 000000:000000 Rm:31 11010000:11010000 S:1 op:0 sf:0
	.inst 0x0216c892 // ADD-C.CIS-C Cd:18 Cn:4 imm12:010110110010 sh:0 A:0 00000010:00000010
	.inst 0xc2c21120
	.zero 769008
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc2400868 // ldr c8, [x3, #2]
	.inst 0xc2400c6c // ldr c12, [x3, #3]
	.inst 0xc2401077 // ldr c23, [x3, #4]
	.inst 0xc2401479 // ldr c25, [x3, #5]
	.inst 0xc240187b // ldr c27, [x3, #6]
	.inst 0xc2401c7d // ldr c29, [x3, #7]
	.inst 0xc240207e // ldr c30, [x3, #8]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851037
	msr SCTLR_EL3, x3
	ldr x3, =0xc
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603123 // ldr c3, [c9, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601123 // ldr c3, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x9, #0x4
	and x3, x3, x9
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400069 // ldr c9, [x3, #0]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400469 // ldr c9, [x3, #1]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2400869 // ldr c9, [x3, #2]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc2400c69 // ldr c9, [x3, #3]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc2401069 // ldr c9, [x3, #4]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401469 // ldr c9, [x3, #5]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401869 // ldr c9, [x3, #6]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2401c69 // ldr c9, [x3, #7]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2402069 // ldr c9, [x3, #8]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2402469 // ldr c9, [x3, #9]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2402869 // ldr c9, [x3, #10]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402c69 // ldr c9, [x3, #11]
	.inst 0xc2c9a7c1 // chkeq c30, c9
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
	ldr x0, =0x000010d0
	ldr x1, =check_data1
	ldr x2, =0x000010d4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000121c
	ldr x1, =check_data2
	ldr x2, =0x00001220
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001394
	ldr x1, =check_data3
	ldr x2, =0x00001396
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400020
	ldr x1, =check_data5
	ldr x2, =0x00400034
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00444400
	ldr x1, =check_data6
	ldr x2, =0x00444410
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
