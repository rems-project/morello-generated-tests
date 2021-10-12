.section text0, #alloc, #execinstr
test_start:
	.inst 0x78d27a61 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:19 10:10 imm9:100100111 0:0 opc:11 111000:111000 size:01
	.inst 0x7a1d0041 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:2 000000:000000 Rm:29 11010000:11010000 S:1 op:1 sf:0
	.inst 0xc2c0b03e // GCSEAL-R.C-C Rd:30 Cn:1 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2e01bfe // CVT-C.CR-C Cd:30 Cn:31 0110:0110 0:0 0:0 Rm:0 11000010111:11000010111
	.inst 0x380c6ba0 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:29 10:10 imm9:011000110 0:0 opc:00 111000:111000 size:00
	.zero 948
	.inst 0xc2c2c2c2
	.zero 16436
	.inst 0xb89c5fd8 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:24 Rn:30 11:11 imm9:111000101 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c151a1 // CFHI-R.C-C Rd:1 Cn:13 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2dd27ff // CPYTYPE-C.C-C Cd:31 Cn:31 001:001 opc:01 0:0 Cm:29 11000010110:11000010110
	.inst 0x784f0081 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:4 00:00 imm9:011110000 0:0 opc:01 111000:111000 size:01
	.inst 0xd4000001
	.zero 48108
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400564 // ldr c4, [x11, #1]
	.inst 0xc2400973 // ldr c19, [x11, #2]
	.inst 0xc2400d7d // ldr c29, [x11, #3]
	/* Set up flags and system registers */
	ldr x11, =0x0
	msr SPSR_EL3, x11
	ldr x11, =initial_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288410b // msr CSP_EL0, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0xc0000
	msr CPACR_EL1, x11
	ldr x11, =0x4
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x4
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =initial_DDC_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c412b // msr DDC_EL1, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260122b // ldr c11, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc28e402b // msr CELR_EL3, c11
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400171 // ldr c17, [x11, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400571 // ldr c17, [x11, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400971 // ldr c17, [x11, #2]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc2400d71 // ldr c17, [x11, #3]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc2401171 // ldr c17, [x11, #4]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc2401571 // ldr c17, [x11, #5]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2401971 // ldr c17, [x11, #6]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984111 // mrs c17, CSP_EL0
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984031 // mrs c17, CELR_EL1
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	ldr x11, =esr_el1_dump_address
	ldr x11, [x11]
	mov x17, 0x80
	orr x11, x11, x17
	ldr x17, =0x920000eb
	cmp x17, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010f0
	ldr x1, =check_data0
	ldr x2, =0x000010f2
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f80
	ldr x1, =check_data1
	ldr x2, =0x00001f82
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
	ldr x0, =0x404003c8
	ldr x1, =check_data3
	ldr x2, =0x404003cc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40404400
	ldr x1, =check_data4
	ldr x2, =0x40404414
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
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
	.zero 240
	.byte 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3712
	.byte 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 112
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
	.octa 0x40400403
	/* C4 */
	.octa 0x1000
	/* C19 */
	.octa 0x2059
	/* C29 */
	.octa 0x2000000000000000000000000400
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40400403
	/* C1 */
	.octa 0xc2c2
	/* C4 */
	.octa 0x1000
	/* C19 */
	.octa 0x2059
	/* C24 */
	.octa 0xffffffffc2c2c2c2
	/* C29 */
	.octa 0x2000000000000000000000000400
	/* C30 */
	.octa 0x404003c8
initial_SP_EL0_value:
	.octa 0x200007000700ffffffffffe229
initial_DDC_EL0_value:
	.octa 0x80000000200700040000000000018001
initial_DDC_EL1_value:
	.octa 0x8000000020014005000000000000c001
initial_VBAR_EL1_value:
	.octa 0x2000800060002d020000000040404000
final_SP_EL0_value:
	.octa 0x200007000700ffffffffffe229
final_PCC_value:
	.octa 0x2000800060002d020000000040404414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180050000000040400000
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40404414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x021e016b // add c11, c11, #1920
	.inst 0xc2c21160 // br c11

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
