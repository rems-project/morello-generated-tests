.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c213a1 // CHKSLD-C-C 00001:00001 Cn:29 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xf85ee80b // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:11 Rn:0 10:10 imm9:111101110 0:0 opc:01 111000:111000 size:11
	.inst 0x089ffc18 // stlrb:aarch64/instrs/memory/ordered Rt:24 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c07001 // GCOFF-R.C-C Rd:1 Cn:0 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x826573d3 // ALDR-C.RI-C Ct:19 Rn:30 op:00 imm9:001010111 L:1 1000001001:1000001001
	.zero 50156
	.inst 0x9bbd83c7 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:7 Rn:30 Ra:0 o0:1 Rm:29 01:01 U:1 10011011:10011011
	.inst 0x380aacb0 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:16 Rn:5 11:11 imm9:010101010 0:0 opc:00 111000:111000 size:00
	.inst 0x88dffc1f // ldar:aarch64/instrs/memory/ordered Rt:31 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xcb3e2bc5 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:5 Rn:30 imm3:010 option:001 Rm:30 01011001:01011001 S:0 op:1 sf:1
	.inst 0xd4000001
	.zero 15340
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
	ldr x0, =vector_table_el1
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc288c001 // msr CVBAR_EL1, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	msr ttbr0_el1, x0
	mov x0, #0xff
	msr mair_el3, x0
	msr mair_el1, x0
	ldr x0, =0x0d003519
	msr tcr_el3, x0
	ldr x0, =0x0000320000803519 // No cap effects, inner shareable, normal, outer write-back read-allocate write-allocate cacheable
	msr tcr_el1, x0
	isb
	tlbi alle3
	tlbi alle1
	dsb sy
	ldr x0, =0x30851035
	msr sctlr_el3, x0
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400505 // ldr c5, [x8, #1]
	.inst 0xc2400910 // ldr c16, [x8, #2]
	.inst 0xc2400d18 // ldr c24, [x8, #3]
	.inst 0xc240111d // ldr c29, [x8, #4]
	.inst 0xc240151e // ldr c30, [x8, #5]
	/* Set up flags and system registers */
	ldr x8, =0x4000000
	msr SPSR_EL3, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0xc0000
	msr CPACR_EL1, x8
	ldr x8, =0x4
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x0
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601328 // ldr c8, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x25, #0xf
	and x8, x8, x25
	cmp x8, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400119 // ldr c25, [x8, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400519 // ldr c25, [x8, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400919 // ldr c25, [x8, #2]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2400d19 // ldr c25, [x8, #3]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc2401119 // ldr c25, [x8, #4]
	.inst 0xc2d9a561 // chkeq c11, c25
	b.ne comparison_fail
	.inst 0xc2401519 // ldr c25, [x8, #5]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401919 // ldr c25, [x8, #6]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc2401d19 // ldr c25, [x8, #7]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402119 // ldr c25, [x8, #8]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x25, 0x80
	orr x8, x8, x25
	ldr x25, =0x920000a9
	cmp x25, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000013f0
	ldr x1, =check_data0
	ldr x2, =0x000013f8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001402
	ldr x1, =check_data1
	ldr x2, =0x00001403
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001860
	ldr x1, =check_data2
	ldr x2, =0x00001864
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001908
	ldr x1, =check_data3
	ldr x2, =0x00001909
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040c400
	ldr x1, =check_data5
	ldr x2, =0x4040c414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xa1, 0x13, 0xc2, 0xc2, 0x0b, 0xe8, 0x5e, 0xf8, 0x18, 0xfc, 0x9f, 0x08, 0x01, 0x70, 0xc0, 0xc2
	.byte 0xd3, 0x73, 0x65, 0x82
.data
check_data5:
	.byte 0xc7, 0x83, 0xbd, 0x9b, 0xb0, 0xac, 0x0a, 0x38, 0x1f, 0xfc, 0xdf, 0x88, 0xc5, 0x2b, 0x3e, 0xcb
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000080080000000000001402
	/* C5 */
	.octa 0x1400
	/* C16 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0xfffffffffffffa90
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000000080080000000000001402
	/* C1 */
	.octa 0x1402
	/* C5 */
	.octa 0xfffffffffffc1050
	/* C7 */
	.octa 0x1402
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0xfffffffffffffa90
initial_DDC_EL0_value:
	.octa 0x800000000000000000000000
initial_DDC_EL1_value:
	.octa 0xc00000005a23045e00ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080005000941d000000004040c000
final_PCC_value:
	.octa 0x200080005000941d000000004040c414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000680080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001400
	.dword 0x0000000000001900
	.dword 0
esr_el1_dump_address:
	.dword 0

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
	b finish
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

.section vector_table_el1, #alloc, #execinstr
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600f28 // ldr x8, [c25, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f28 // str x8, [c25, #0]
	ldr x8, =0x4040c414
	mrs x25, ELR_EL1
	sub x8, x8, x25
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b119 // cvtp c25, x8
	.inst 0xc2c84339 // scvalue c25, c25, x8
	.inst 0x82600328 // ldr c8, [c25, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
