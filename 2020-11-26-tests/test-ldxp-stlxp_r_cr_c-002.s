.section data0, #alloc, #write
	.byte 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x04, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0xa3, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x80, 0x01, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x01, 0xfc, 0x9f, 0xc8, 0x02, 0xfc, 0x5f, 0x42, 0x69, 0x73, 0x7f, 0x22, 0xe1, 0x6f, 0x21, 0x8b
	.byte 0xf6, 0x2f, 0xc1, 0x9a, 0x83, 0x84, 0x20, 0x22, 0xe0, 0xdf, 0x55, 0x78, 0x1d, 0x94, 0x6f, 0x28
	.byte 0xe8, 0x6f, 0x2a, 0x39, 0x9e, 0x4f, 0xee, 0x50, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1800
	/* C1 */
	.octa 0x400000000180
	/* C3 */
	.octa 0x1804
	/* C4 */
	.octa 0x1000
	/* C8 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x1804
	/* C1 */
	.octa 0x2000000001ca3
	/* C2 */
	.octa 0x400000000180
	/* C3 */
	.octa 0x1804
	/* C4 */
	.octa 0x1000
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x1800
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x3dca16
initial_SP_EL3_value:
	.octa 0x10a3
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc100000080700f30000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc89ffc01 // stlr:aarch64/instrs/memory/ordered Rt:1 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x425ffc02 // LDAR-C.R-C Ct:2 Rn:0 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x227f7369 // 0x227f7369
	.inst 0x8b216fe1 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:31 imm3:011 option:011 Rm:1 01011001:01011001 S:0 op:0 sf:1
	.inst 0x9ac12ff6 // rorv:aarch64/instrs/integer/shift/variable Rd:22 Rn:31 op2:11 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0x22208483 // 0x22208483
	.inst 0x7855dfe0 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:31 11:11 imm9:101011101 0:0 opc:01 111000:111000 size:01
	.inst 0x286f941d // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:29 Rn:0 Rt2:00101 imm7:1011111 L:1 1010000:1010000 opc:00
	.inst 0x392a6fe8 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:8 Rn:31 imm12:101010011011 opc:00 111001:111001 size:00
	.inst 0x50ee4f9e // ADR-C.I-C Rd:30 immhi:110111001001111100 P:1 10000:10000 immlo:10 op:0
	.inst 0xc2c210e0
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa3 // ldr c3, [x21, #2]
	.inst 0xc2400ea4 // ldr c4, [x21, #3]
	.inst 0xc24012a8 // ldr c8, [x21, #4]
	.inst 0xc24016bb // ldr c27, [x21, #5]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851037
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f5 // ldr c21, [c7, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826010f5 // ldr c21, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a7 // ldr c7, [x21, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24006a7 // ldr c7, [x21, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400aa7 // ldr c7, [x21, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400ea7 // ldr c7, [x21, #3]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc24012a7 // ldr c7, [x21, #4]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc24016a7 // ldr c7, [x21, #5]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc2401aa7 // ldr c7, [x21, #6]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc2401ea7 // ldr c7, [x21, #7]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc24022a7 // ldr c7, [x21, #8]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc24026a7 // ldr c7, [x21, #9]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402aa7 // ldr c7, [x21, #10]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402ea7 // ldr c7, [x21, #11]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc24032a7 // ldr c7, [x21, #12]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001780
	ldr x1, =check_data1
	ldr x2, =0x00001788
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001810
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a9b
	ldr x1, =check_data3
	ldr x2, =0x00001a9c
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
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
