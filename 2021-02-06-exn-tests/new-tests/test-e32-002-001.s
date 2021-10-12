.section text0, #alloc, #execinstr
test_start:
	.inst 0x78d27a61 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:19 10:10 imm9:100100111 0:0 opc:11 111000:111000 size:01
	.inst 0x7a1d0041 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:2 000000:000000 Rm:29 11010000:11010000 S:1 op:1 sf:0
	.inst 0xc2c0b03e // GCSEAL-R.C-C Rd:30 Cn:1 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2e01bfe // CVT-C.CR-C Cd:30 Cn:31 0110:0110 0:0 0:0 Rm:0 11000010111:11000010111
	.inst 0x380c6ba0 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:29 10:10 imm9:011000110 0:0 opc:00 111000:111000 size:00
	.zero 180
	.inst 0xc2c2c2c2
	.zero 33588
	.inst 0xb89c5fd8 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:24 Rn:30 11:11 imm9:111000101 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c151a1 // CFHI-R.C-C Rd:1 Cn:13 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2dd27ff // CPYTYPE-C.C-C Cd:31 Cn:31 001:001 opc:01 0:0 Cm:29 11000010110:11000010110
	.inst 0x784f0081 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:4 00:00 imm9:011110000 0:0 opc:01 111000:111000 size:01
	.inst 0xd4000001
	.zero 31724
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc2400873 // ldr c19, [x3, #2]
	.inst 0xc2400c7d // ldr c29, [x3, #3]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =initial_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884103 // msr CSP_EL0, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0xc0000
	msr CPACR_EL1, x3
	ldr x3, =0x0
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x4
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =initial_DDC_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4123 // msr DDC_EL1, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010e3 // ldr c3, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400067 // ldr c7, [x3, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400467 // ldr c7, [x3, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400867 // ldr c7, [x3, #2]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400c67 // ldr c7, [x3, #3]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2401067 // ldr c7, [x3, #4]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2401467 // ldr c7, [x3, #5]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2401867 // ldr c7, [x3, #6]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984107 // mrs c7, CSP_EL0
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x7, 0x80
	orr x3, x3, x7
	ldr x7, =0x920000eb
	cmp x7, x3
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
	ldr x0, =0x00001ffc
	ldr x1, =check_data1
	ldr x2, =0x00001ffe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x404000c8
	ldr x1, =check_data3
	ldr x2, =0x404000cc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40408400
	ldr x1, =check_data4
	ldr x2, =0x40408414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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

.section data0, #alloc, #write
	.byte 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0x61, 0x7a, 0xd2, 0x78, 0x41, 0x00, 0x1d, 0x7a, 0x3e, 0xb0, 0xc0, 0xc2, 0xfe, 0x1b, 0xe0, 0xc2
	.byte 0xa0, 0x6b, 0x0c, 0x38
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xd8, 0x5f, 0x9c, 0xb8, 0xa1, 0x51, 0xc1, 0xc2, 0xff, 0x27, 0xdd, 0xc2, 0x81, 0x00, 0x4f, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1dce240400102
	/* C4 */
	.octa 0x1f0c
	/* C19 */
	.octa 0xd9
	/* C29 */
	.octa 0x80000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1dce240400102
	/* C1 */
	.octa 0xc2c2
	/* C4 */
	.octa 0x1f0c
	/* C19 */
	.octa 0xd9
	/* C24 */
	.octa 0xffffffffc2c2c2c2
	/* C29 */
	.octa 0x80000000001000
	/* C30 */
	.octa 0x404000c8
initial_SP_EL0_value:
	.octa 0xc001000100fe231e00000000
initial_DDC_EL0_value:
	.octa 0x800000005f82100000ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000801d0000000040408000
final_SP_EL0_value:
	.octa 0xc001000100fe231e00000000
final_PCC_value:
	.octa 0x200080005000801d0000000040408414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x82600ce3 // ldr x3, [c7, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ce3 // str x3, [c7, #0]
	ldr x3, =0x40408414
	mrs x7, ELR_EL1
	sub x3, x3, x7
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b067 // cvtp c7, x3
	.inst 0xc2c340e7 // scvalue c7, c7, x3
	.inst 0x826000e3 // ldr c3, [c7, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
