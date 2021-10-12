.section text0, #alloc, #execinstr
test_start:
	.inst 0x82c1543f // ALDRSB-R.RRB-32 Rt:31 Rn:1 opc:01 S:1 option:010 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x387e83fc // swpb:aarch64/instrs/memory/atomicops/swp Rt:28 Rn:31 100000:100000 Rs:30 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x79654021 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:1 imm12:100101010000 opc:01 111001:111001 size:01
	.inst 0x383e53ff // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:101 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2538fc0 // LDR-C.RIB-C Ct:0 Rn:30 imm12:010011100011 L:1 110000100:110000100
	.zero 1004
	.inst 0xc2c133fc // GCFLGS-R.C-C Rd:28 Cn:31 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x8254282b // ASTR-R.RI-32 Rt:11 Rn:1 op:10 imm9:101000010 L:0 1000001001:1000001001
	.inst 0x7821119f // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:12 00:00 opc:001 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x425f7d7e // ALDAR-C.R-C Ct:30 Rn:11 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xd4000001
	.zero 64492
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
	ldr x17, =initial_cap_values
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc240062b // ldr c11, [x17, #1]
	.inst 0xc2400a2c // ldr c12, [x17, #2]
	.inst 0xc2400e3e // ldr c30, [x17, #3]
	/* Set up flags and system registers */
	ldr x17, =0x0
	msr SPSR_EL3, x17
	ldr x17, =initial_SP_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884111 // msr CSP_EL0, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30d5d99f
	msr SCTLR_EL1, x17
	ldr x17, =0xc0000
	msr CPACR_EL1, x17
	ldr x17, =0x4
	msr S3_0_C1_C2_2, x17 // CCTLR_EL1
	ldr x17, =0x4
	msr S3_3_C1_C2_2, x17 // CCTLR_EL0
	ldr x17, =initial_DDC_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884131 // msr DDC_EL0, c17
	ldr x17, =initial_DDC_EL1_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc28c4131 // msr DDC_EL1, c17
	ldr x17, =0x80000000
	msr HCR_EL2, x17
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601091 // ldr c17, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc28e4031 // msr CELR_EL3, c17
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400224 // ldr c4, [x17, #0]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400624 // ldr c4, [x17, #1]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc2400a24 // ldr c4, [x17, #2]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc2400e24 // ldr c4, [x17, #3]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check system registers */
	ldr x17, =final_SP_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984104 // mrs c4, CSP_EL0
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	ldr x17, =final_PCC_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	ldr x17, =esr_el1_dump_address
	ldr x17, [x17]
	mov x4, 0x80
	orr x17, x17, x4
	ldr x4, =0x920000a1
	cmp x4, x17
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001102
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000015b8
	ldr x1, =check_data2
	ldr x2, =0x000015bc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001aa0
	ldr x1, =check_data3
	ldr x2, =0x00001aa2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f10
	ldr x1, =check_data4
	ldr x2, =0x00001f20
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
	.zero 256
	.byte 0x31, 0xef, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2448
	.byte 0xb0, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1360
.data
check_data0:
	.byte 0xe1
.data
check_data1:
	.byte 0x01, 0xef
.data
check_data2:
	.byte 0x10, 0x1f, 0x00, 0x00
.data
check_data3:
	.byte 0xb0, 0x10
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x3f, 0x54, 0xc1, 0x82, 0xfc, 0x83, 0x7e, 0x38, 0x21, 0x40, 0x65, 0x79, 0xff, 0x53, 0x3e, 0x38
	.byte 0xc0, 0x8f, 0x53, 0xc2
.data
check_data6:
	.byte 0xfc, 0x33, 0xc1, 0xc2, 0x2b, 0x28, 0x54, 0x82, 0x9f, 0x11, 0x21, 0x78, 0x7e, 0x7d, 0x5f, 0x42
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000400010000000000000800
	/* C11 */
	.octa 0x1f10
	/* C12 */
	.octa 0xc0000000400402240000000000001100
	/* C30 */
	.octa 0x57fffffffffb1e1
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x10b0
	/* C11 */
	.octa 0x1f10
	/* C12 */
	.octa 0xc0000000400402240000000000001100
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc000000027c200030000000000000001
initial_DDC_EL1_value:
	.octa 0xd01000002003000700007fffffff0003
initial_VBAR_EL1_value:
	.octa 0x200080005000d01d0000000040400001
final_SP_EL0_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080005000d01d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001f10
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001f10
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001100
	.dword 0x00000000000015b0
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
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x02000231 // add c17, c17, #0
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x02020231 // add c17, c17, #128
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x02040231 // add c17, c17, #256
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x02060231 // add c17, c17, #384
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x02080231 // add c17, c17, #512
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x020a0231 // add c17, c17, #640
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x020c0231 // add c17, c17, #768
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x020e0231 // add c17, c17, #896
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x02100231 // add c17, c17, #1024
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x02120231 // add c17, c17, #1152
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x02140231 // add c17, c17, #1280
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x02160231 // add c17, c17, #1408
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x02180231 // add c17, c17, #1536
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x021a0231 // add c17, c17, #1664
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x021c0231 // add c17, c17, #1792
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600c91 // ldr x17, [c4, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c91 // str x17, [c4, #0]
	ldr x17, =0x40400414
	mrs x4, ELR_EL1
	sub x17, x17, x4
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b224 // cvtp c4, x17
	.inst 0xc2d14084 // scvalue c4, c4, x17
	.inst 0x82600091 // ldr c17, [c4, #0]
	.inst 0x021e0231 // add c17, c17, #1920
	.inst 0xc2c21220 // br c17

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
