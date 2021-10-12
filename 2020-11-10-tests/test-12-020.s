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
	.byte 0xd6, 0x10, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x41, 0xa4, 0xde, 0xc2, 0x3f, 0x6c, 0x55, 0x39, 0x01, 0x84, 0x2f, 0xb9, 0xbf, 0xb8, 0x3a, 0xc2
	.byte 0x3e, 0x94, 0x42, 0x82, 0x5f, 0x50, 0x34, 0x78, 0xff, 0x83, 0xbf, 0xa2, 0x82, 0xc5, 0xfc, 0x82
	.byte 0x4c, 0x3f, 0x16, 0x38, 0x1f, 0xf5, 0x01, 0xf8, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffffffe580
	/* C1 */
	.octa 0x400000000005000300000000000010d6
	/* C2 */
	.octa 0x1000
	/* C5 */
	.octa 0xffffffffffff2520
	/* C8 */
	.octa 0x1000
	/* C12 */
	.octa 0x8000000050800081fffffffffffffc00
	/* C20 */
	.octa 0x8000
	/* C26 */
	.octa 0x10c0
	/* C28 */
	.octa 0x1400
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffe580
	/* C1 */
	.octa 0x400000000005000300000000000010d6
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0xffffffffffff2520
	/* C8 */
	.octa 0x101f
	/* C12 */
	.octa 0x8000000050800081fffffffffffffc00
	/* C20 */
	.octa 0x8000
	/* C26 */
	.octa 0x1023
	/* C28 */
	.octa 0x1400
	/* C30 */
	.octa 0x1000
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000005000500ffffff80000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dea441 // CHKEQ-_.CC-C 00001:00001 Cn:2 001:001 opc:01 1:1 Cm:30 11000010110:11000010110
	.inst 0x39556c3f // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:1 imm12:010101011011 opc:01 111001:111001 size:00
	.inst 0xb92f8401 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:0 imm12:101111100001 opc:00 111001:111001 size:10
	.inst 0xc23ab8bf // STR-C.RIB-C Ct:31 Rn:5 imm12:111010101110 L:0 110000100:110000100
	.inst 0x8242943e // ASTRB-R.RI-B Rt:30 Rn:1 op:01 imm9:000101001 L:0 1000001001:1000001001
	.inst 0x7834505f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:101 o3:0 Rs:20 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xa2bf83ff // SWPA-CC.R-C Ct:31 Rn:31 100000:100000 Cs:31 1:1 R:0 A:1 10100010:10100010
	.inst 0x82fcc582 // ALDR-R.RRB-64 Rt:2 Rn:12 opc:01 S:0 option:110 Rm:28 1:1 L:1 100000101:100000101
	.inst 0x38163f4c // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:12 Rn:26 11:11 imm9:101100011 0:0 opc:00 111000:111000 size:00
	.inst 0xf801f51f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:8 01:01 imm9:000011111 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c21240
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a2 // ldr c2, [x13, #2]
	.inst 0xc2400da5 // ldr c5, [x13, #3]
	.inst 0xc24011a8 // ldr c8, [x13, #4]
	.inst 0xc24015ac // ldr c12, [x13, #5]
	.inst 0xc24019b4 // ldr c20, [x13, #6]
	.inst 0xc2401dba // ldr c26, [x13, #7]
	.inst 0xc24021bc // ldr c28, [x13, #8]
	.inst 0xc24025be // ldr c30, [x13, #9]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x3085103f
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260324d // ldr c13, [c18, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260124d // ldr c13, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x18, #0xf
	and x13, x13, x18
	cmp x13, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b2 // ldr c18, [x13, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24005b2 // ldr c18, [x13, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24009b2 // ldr c18, [x13, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400db2 // ldr c18, [x13, #3]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc24011b2 // ldr c18, [x13, #4]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc24015b2 // ldr c18, [x13, #5]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc24019b2 // ldr c18, [x13, #6]
	.inst 0xc2d2a681 // chkeq c20, c18
	b.ne comparison_fail
	.inst 0xc2401db2 // ldr c18, [x13, #7]
	.inst 0xc2d2a741 // chkeq c26, c18
	b.ne comparison_fail
	.inst 0xc24021b2 // ldr c18, [x13, #8]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc24025b2 // ldr c18, [x13, #9]
	.inst 0xc2d2a7c1 // chkeq c30, c18
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
	ldr x0, =0x00001023
	ldr x1, =check_data1
	ldr x2, =0x00001024
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
	ldr x0, =0x00001504
	ldr x1, =check_data3
	ldr x2, =0x00001508
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001631
	ldr x1, =check_data4
	ldr x2, =0x00001632
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
