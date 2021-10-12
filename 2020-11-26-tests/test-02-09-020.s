.section data0, #alloc, #write
	.zero 48
	.byte 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4032
.data
check_data0:
	.byte 0x80, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x10
.data
check_data3:
	.byte 0x42, 0x08, 0x01, 0x00
.data
check_data4:
	.zero 32
.data
check_data5:
	.zero 8
.data
check_data6:
	.zero 8
.data
check_data7:
	.byte 0x00, 0x10
.data
check_data8:
	.byte 0x0c, 0x02, 0x12, 0xba, 0xfb, 0x7f, 0x9f, 0x48, 0x60, 0x83, 0x2f, 0x78, 0x7e, 0x9e, 0x16, 0x38
	.byte 0x2a, 0xcc, 0x69, 0x62, 0xdf, 0x32, 0x6a, 0xf8, 0xfd, 0xec, 0x02, 0xb8, 0xb6, 0x5b, 0xc3, 0xc2
	.byte 0x3f, 0x72, 0x7a, 0x78, 0x3e, 0xa0, 0x79, 0x69, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1810
	/* C7 */
	.octa 0x1102
	/* C15 */
	.octa 0x80
	/* C17 */
	.octa 0x1032
	/* C19 */
	.octa 0x10c7
	/* C22 */
	.octa 0x17c8
	/* C26 */
	.octa 0x4000
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x100070000000000010842
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1810
	/* C7 */
	.octa 0x1130
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x80
	/* C17 */
	.octa 0x1032
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x100070000000000010880
	/* C26 */
	.octa 0x4000
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x100070000000000010842
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1840
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000464100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000006002000000ffffffffffe003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001540
	.dword 0x0000000000001550
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xba12020c // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:12 Rn:16 000000:000000 Rm:18 11010000:11010000 S:1 op:0 sf:1
	.inst 0x489f7ffb // stllrh:aarch64/instrs/memory/ordered Rt:27 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x782f8360 // swph:aarch64/instrs/memory/atomicops/swp Rt:0 Rn:27 100000:100000 Rs:15 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x38169e7e // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:19 11:11 imm9:101101001 0:0 opc:00 111000:111000 size:00
	.inst 0x6269cc2a // LDNP-C.RIB-C Ct:10 Rn:1 Ct2:10011 imm7:1010011 L:1 011000100:011000100
	.inst 0xf86a32df // stset:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:011 o3:0 Rs:10 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xb802ecfd // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:29 Rn:7 11:11 imm9:000101110 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c35bb6 // ALIGNU-C.CI-C Cd:22 Cn:29 0110:0110 U:1 imm6:000110 11000010110:11000010110
	.inst 0x787a723f // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:111 o3:0 Rs:26 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x6979a03e // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:30 Rn:1 Rt2:01000 imm7:1110011 L:1 1010010:1010010 opc:01
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
	.inst 0xc2400b2f // ldr c15, [x25, #2]
	.inst 0xc2400f31 // ldr c17, [x25, #3]
	.inst 0xc2401333 // ldr c19, [x25, #4]
	.inst 0xc2401736 // ldr c22, [x25, #5]
	.inst 0xc2401b3a // ldr c26, [x25, #6]
	.inst 0xc2401f3b // ldr c27, [x25, #7]
	.inst 0xc240233d // ldr c29, [x25, #8]
	.inst 0xc240273e // ldr c30, [x25, #9]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x3085103f
	msr SCTLR_EL3, x25
	ldr x25, =0x4
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
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400325 // ldr c5, [x25, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400725 // ldr c5, [x25, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400b25 // ldr c5, [x25, #2]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2400f25 // ldr c5, [x25, #3]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2401325 // ldr c5, [x25, #4]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2401725 // ldr c5, [x25, #5]
	.inst 0xc2c5a5e1 // chkeq c15, c5
	b.ne comparison_fail
	.inst 0xc2401b25 // ldr c5, [x25, #6]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2401f25 // ldr c5, [x25, #7]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2402325 // ldr c5, [x25, #8]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc2402725 // ldr c5, [x25, #9]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2402b25 // ldr c5, [x25, #10]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc2402f25 // ldr c5, [x25, #11]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2403325 // ldr c5, [x25, #12]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001031
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001032
	ldr x1, =check_data2
	ldr x2, =0x00001034
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001130
	ldr x1, =check_data3
	ldr x2, =0x00001134
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001540
	ldr x1, =check_data4
	ldr x2, =0x00001560
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000017c8
	ldr x1, =check_data5
	ldr x2, =0x000017d0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x000017dc
	ldr x1, =check_data6
	ldr x2, =0x000017e4
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00001840
	ldr x1, =check_data7
	ldr x2, =0x00001842
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400000
	ldr x1, =check_data8
	ldr x2, =0x0040002c
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
