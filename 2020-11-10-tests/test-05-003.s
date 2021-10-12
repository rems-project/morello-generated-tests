.section data0, #alloc, #write
	.byte 0x0d, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 3152
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 912
.data
check_data0:
	.byte 0x0d, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0xb7, 0x0f
.data
check_data2:
	.byte 0x10, 0xf8
.data
check_data3:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data4:
	.byte 0x41, 0x14, 0x58, 0xa2, 0xe4, 0xaf, 0x54, 0xb8, 0xa0, 0x32, 0xdc, 0xc2, 0x1e, 0x90, 0xc4, 0x78
	.byte 0x60, 0x78, 0x21, 0x78, 0x7e, 0x29, 0xe4, 0x42, 0xff, 0x3f, 0x42, 0x79, 0xfa, 0x7f, 0x0f, 0x48
	.byte 0x22, 0xa1, 0x48, 0xe2, 0xb2, 0xca, 0x22, 0x9b, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0x8a, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000000fb7
	/* C2 */
	.octa 0x80100000000300060000000000440000
	/* C3 */
	.octa 0x40000000000100050000000000000180
	/* C9 */
	.octa 0x1668
	/* C11 */
	.octa 0x90000000000100050000000000001fd0
	/* C21 */
	.octa 0x901000000003000700000000000011f0
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000000fb7
	/* C1 */
	.octa 0x78a
	/* C2 */
	.octa 0x8010000000030006000000000043f810
	/* C3 */
	.octa 0x40000000000100050000000000000180
	/* C4 */
	.octa 0x0
	/* C9 */
	.octa 0x1668
	/* C10 */
	.octa 0x101800000000000000000000000
	/* C11 */
	.octa 0x90000000000100050000000000001fd0
	/* C15 */
	.octa 0x1
	/* C21 */
	.octa 0x901000000003000700000000000011f0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc000000000010007000000000040013a
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001c60
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2581441 // LDR-C.RIAW-C Ct:1 Rn:2 01:01 imm9:110000001 0:0 opc:01 10100010:10100010
	.inst 0xb854afe4 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:4 Rn:31 11:11 imm9:101001010 0:0 opc:01 111000:111000 size:10
	.inst 0xc2dc32a0 // BR-CI-C 0:0 0000:0000 Cn:21 100:100 imm7:1100001 110000101101:110000101101
	.inst 0x78c4901e // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:0 00:00 imm9:001001001 0:0 opc:11 111000:111000 size:01
	.inst 0x78217860 // strh_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:3 10:10 S:1 option:011 Rm:1 1:1 opc:00 111000:111000 size:01
	.inst 0x42e4297e // LDP-C.RIB-C Ct:30 Rn:11 Ct2:01010 imm7:1001000 L:1 010000101:010000101
	.inst 0x79423fff // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:31 imm12:000010001111 opc:01 111001:111001 size:01
	.inst 0x480f7ffa // stxrh:aarch64/instrs/memory/exclusive/single Rt:26 Rn:31 Rt2:11111 o0:0 Rs:15 0:0 L:0 0010000:0010000 size:01
	.inst 0xe248a122 // ASTURH-R.RI-32 Rt:2 Rn:9 op2:00 imm9:010001010 V:0 op1:01 11100010:11100010
	.inst 0x9b22cab2 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:18 Rn:21 Ra:18 o0:1 Rm:2 01:01 U:0 10011011:10011011
	.inst 0xc2c210c0
	.zero 262100
	.inst 0x0000078a
	.zero 786428
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
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc24008a3 // ldr c3, [x5, #2]
	.inst 0xc2400ca9 // ldr c9, [x5, #3]
	.inst 0xc24010ab // ldr c11, [x5, #4]
	.inst 0xc24014b5 // ldr c21, [x5, #5]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851037
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030c5 // ldr c5, [c6, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x826010c5 // ldr c5, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a6 // ldr c6, [x5, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24004a6 // ldr c6, [x5, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc24008a6 // ldr c6, [x5, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400ca6 // ldr c6, [x5, #3]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc24010a6 // ldr c6, [x5, #4]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc24014a6 // ldr c6, [x5, #5]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc24018a6 // ldr c6, [x5, #6]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401ca6 // ldr c6, [x5, #7]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc24020a6 // ldr c6, [x5, #8]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc24024a6 // ldr c6, [x5, #9]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc24028a6 // ldr c6, [x5, #10]
	.inst 0xc2c6a7c1 // chkeq c30, c6
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
	ldr x0, =0x00001094
	ldr x1, =check_data1
	ldr x2, =0x00001096
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000016f2
	ldr x1, =check_data2
	ldr x2, =0x000016f4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c50
	ldr x1, =check_data3
	ldr x2, =0x00001c70
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
	ldr x0, =0x00400084
	ldr x1, =check_data5
	ldr x2, =0x00400088
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004001a2
	ldr x1, =check_data6
	ldr x2, =0x004001a4
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00440000
	ldr x1, =check_data7
	ldr x2, =0x00440010
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
