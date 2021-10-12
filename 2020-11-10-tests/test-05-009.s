.section data0, #alloc, #write
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 816
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1888
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1344
.data
check_data0:
	.byte 0x4a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0x1a, 0x00
.data
check_data2:
	.byte 0x01
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data4:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0xe2, 0xb8, 0x4a, 0xa2, 0xdf, 0x63, 0x3f, 0x38, 0xc1, 0x63, 0x21, 0xeb, 0x51, 0xfc, 0xe2, 0xa2
	.byte 0x42, 0xd1, 0xbe, 0x82, 0xe1, 0x7f, 0x9f, 0x48, 0x50, 0xe8, 0xc8, 0xc2, 0xdf, 0x33, 0x3f, 0x38
	.byte 0x20, 0x6c, 0x5c, 0x78, 0x5f, 0x40, 0x3e, 0x38, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xffffffffffbf1330
	/* C7 */
	.octa 0x1000
	/* C10 */
	.octa 0x4000000000070004ffffffffffffc800
	/* C17 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x134a
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40ffe0
	/* C2 */
	.octa 0x1000
	/* C7 */
	.octa 0x1000
	/* C10 */
	.octa 0x4000000000070004ffffffffffffc800
	/* C17 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x134a
initial_SP_EL3_value:
	.octa 0x1020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8100000000180060080000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001ab0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa24ab8e2 // LDTR-C.RIB-C Ct:2 Rn:7 10:10 imm9:010101011 0:0 opc:01 10100010:10100010
	.inst 0x383f63df // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:110 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xeb2163c1 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:30 imm3:000 option:011 Rm:1 01011001:01011001 S:1 op:1 sf:1
	.inst 0xa2e2fc51 // CASAL-C.R-C Ct:17 Rn:2 11111:11111 R:1 Cs:2 1:1 L:1 1:1 10100010:10100010
	.inst 0x82bed142 // ASTR-R.RRB-32 Rt:2 Rn:10 opc:00 S:1 option:110 Rm:30 1:1 L:0 100000101:100000101
	.inst 0x489f7fe1 // stllrh:aarch64/instrs/memory/ordered Rt:1 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c8e850 // CTHI-C.CR-C Cd:16 Cn:2 1010:1010 opc:11 Rm:8 11000010110:11000010110
	.inst 0x383f33df // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:011 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x785c6c20 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:1 11:11 imm9:111000110 0:0 opc:01 111000:111000 size:01
	.inst 0x383e405f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:100 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c210a0
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
	ldr x25, =initial_cap_values
	.inst 0xc2400321 // ldr c1, [x25, #0]
	.inst 0xc2400727 // ldr c7, [x25, #1]
	.inst 0xc2400b2a // ldr c10, [x25, #2]
	.inst 0xc2400f31 // ldr c17, [x25, #3]
	.inst 0xc240133e // ldr c30, [x25, #4]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	ldr x25, =0x0
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b9 // ldr c25, [c5, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x826010b9 // ldr c25, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x5, #0xf
	and x25, x25, x5
	cmp x25, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400325 // ldr c5, [x25, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400725 // ldr c5, [x25, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400b25 // ldr c5, [x25, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400f25 // ldr c5, [x25, #3]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2401325 // ldr c5, [x25, #4]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2401725 // ldr c5, [x25, #5]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2401b25 // ldr c5, [x25, #6]
	.inst 0xc2c5a7c1 // chkeq c30, c5
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001022
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000134a
	ldr x1, =check_data2
	ldr x2, =0x0000134b
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001528
	ldr x1, =check_data3
	ldr x2, =0x0000152c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ab0
	ldr x1, =check_data4
	ldr x2, =0x00001ac0
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
	ldr x0, =0x0040ffe0
	ldr x1, =check_data6
	ldr x2, =0x0040ffe2
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
