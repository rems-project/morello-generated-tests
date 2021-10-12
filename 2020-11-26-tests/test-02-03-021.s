.section data0, #alloc, #write
	.byte 0xe4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 368
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3664
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
.data
check_data0:
	.byte 0xe4
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0x2a, 0x08, 0xc0, 0xda, 0x4b, 0x60, 0x3e, 0x38, 0xa0, 0x93, 0xc1, 0xc2, 0xfb, 0xf3, 0x89, 0xf8
	.byte 0xd3, 0x9b, 0x41, 0x78, 0x38, 0x20, 0xc9, 0xc2, 0xbe, 0x07, 0xc0, 0xda, 0xfe, 0x46, 0xd1, 0xc2
	.byte 0xa8, 0x07, 0x57, 0xa8, 0xce, 0x2b, 0x45, 0xba, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x2000000070000000000000000
	/* C2 */
	.octa 0x1000
	/* C17 */
	.octa 0x100000000000000000000000000
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x1018
	/* C30 */
	.octa 0x1fe3
final_cap_values:
	/* C0 */
	.octa 0x1018
	/* C1 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C2 */
	.octa 0x1000
	/* C8 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0xe4
	/* C17 */
	.octa 0x100000000000000000000000000
	/* C19 */
	.octa 0xc2c2
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x1018
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac0082a // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:10 Rn:1 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x383e604b // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:11 Rn:2 00:00 opc:110 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xc2c193a0 // CLRTAG-C.C-C Cd:0 Cn:29 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xf889f3fb // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:27 Rn:31 00:00 imm9:010011111 0:0 opc:10 111000:111000 size:11
	.inst 0x78419bd3 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:19 Rn:30 10:10 imm9:000011001 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c92038 // SCBNDSE-C.CR-C Cd:24 Cn:1 000:000 opc:01 0:0 Rm:9 11000010110:11000010110
	.inst 0xdac007be // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:29 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2d146fe // CSEAL-C.C-C Cd:30 Cn:23 001:001 opc:10 0:0 Cm:17 11000010110:11000010110
	.inst 0xa85707a8 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:8 Rn:29 Rt2:00001 imm7:0101110 L:1 1010000:1010000 opc:10
	.inst 0xba452bce // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1110 0:0 Rn:30 10:10 cond:0010 imm5:00101 111010010:111010010 op:0 sf:1
	.inst 0xc2c212c0
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400871 // ldr c17, [x3, #2]
	.inst 0xc2400c77 // ldr c23, [x3, #3]
	.inst 0xc240107d // ldr c29, [x3, #4]
	.inst 0xc240147e // ldr c30, [x3, #5]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851037
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032c3 // ldr c3, [c22, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x826012c3 // ldr c3, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	mov x22, #0xf
	and x3, x3, x22
	cmp x3, #0xe
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400076 // ldr c22, [x3, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400476 // ldr c22, [x3, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400876 // ldr c22, [x3, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400c76 // ldr c22, [x3, #3]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2401076 // ldr c22, [x3, #4]
	.inst 0xc2d6a541 // chkeq c10, c22
	b.ne comparison_fail
	.inst 0xc2401476 // ldr c22, [x3, #5]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc2401876 // ldr c22, [x3, #6]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2401c76 // ldr c22, [x3, #7]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc2402076 // ldr c22, [x3, #8]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2402476 // ldr c22, [x3, #9]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402876 // ldr c22, [x3, #10]
	.inst 0xc2d6a7c1 // chkeq c30, c22
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
	ldr x0, =0x00001188
	ldr x1, =check_data1
	ldr x2, =0x00001198
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
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
