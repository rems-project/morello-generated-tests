.section text0, #alloc, #execinstr
test_start:
	.inst 0xe24872ff // ASTURH-R.RI-32 Rt:31 Rn:23 op2:00 imm9:010000111 V:0 op1:01 11100010:11100010
	.inst 0x783251de // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:14 00:00 opc:101 0:0 Rs:18 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x3a5e5bcc // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1100 0:0 Rn:30 10:10 cond:0101 imm5:11110 111010010:111010010 op:0 sf:0
	.inst 0x5ac003e8 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:8 Rn:31 101101011000000000000:101101011000000000000 sf:0
	.inst 0xb97a50be // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:5 imm12:111010010100 opc:01 111001:111001 size:10
	.inst 0xcad8bec0 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:22 imm6:101111 Rm:24 N:0 shift:11 01010:01010 opc:10 sf:1
	.inst 0x627d442a // LDNP-C.RIB-C Ct:10 Rn:1 Ct2:10001 imm7:1111010 L:1 011000100:011000100
	.inst 0xc2dea7c1 // CHKEQ-_.CC-C 00001:00001 Cn:30 001:001 opc:01 1:1 Cm:30 11000010110:11000010110
	.inst 0x089f7fbe // stllrb:aarch64/instrs/memory/ordered Rt:30 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xd4000001
	.zero 65496
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c5 // ldr c5, [x6, #1]
	.inst 0xc24008ce // ldr c14, [x6, #2]
	.inst 0xc2400cd2 // ldr c18, [x6, #3]
	.inst 0xc24010d7 // ldr c23, [x6, #4]
	.inst 0xc24014dd // ldr c29, [x6, #5]
	/* Set up flags and system registers */
	ldr x6, =0x80000000
	msr SPSR_EL3, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x0
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601206 // ldr c6, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x16, #0xf
	and x6, x6, x16
	cmp x6, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d0 // ldr c16, [x6, #0]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24004d0 // ldr c16, [x6, #1]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc24008d0 // ldr c16, [x6, #2]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc2400cd0 // ldr c16, [x6, #3]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc24010d0 // ldr c16, [x6, #4]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc24014d0 // ldr c16, [x6, #5]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc24018d0 // ldr c16, [x6, #6]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc2401cd0 // ldr c16, [x6, #7]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc24020d0 // ldr c16, [x6, #8]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc24024d0 // ldr c16, [x6, #9]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a4c1 // chkeq c6, c16
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
	ldr x0, =0x0000190c
	ldr x1, =check_data1
	ldr x2, =0x0000190e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x404001a0
	ldr x1, =check_data4
	ldr x2, =0x404001c0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040fff8
	ldr x1, =check_data5
	ldr x2, =0x4040fffc
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
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xff, 0x72, 0x48, 0xe2, 0xde, 0x51, 0x32, 0x78, 0xcc, 0x5b, 0x5e, 0x3a, 0xe8, 0x03, 0xc0, 0x5a
	.byte 0xbe, 0x50, 0x7a, 0xb9, 0xc0, 0xbe, 0xd8, 0xca, 0x2a, 0x44, 0x7d, 0x62, 0xc1, 0xa7, 0xde, 0xc2
	.byte 0xbe, 0x7f, 0x9f, 0x08, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 32
.data
check_data5:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40400200
	/* C5 */
	.octa 0x4040c5a8
	/* C14 */
	.octa 0x1000
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000000100050000000000001885
	/* C29 */
	.octa 0x1ffe
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x40400200
	/* C5 */
	.octa 0x4040c5a8
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C14 */
	.octa 0x1000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000000100050000000000001885
	/* C29 */
	.octa 0x1ffe
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc0100000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080000000c0000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001900
	.dword 0x0000000000001ff0
	.dword 0x00000000404001a0
	.dword 0x00000000404001b0
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400028
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
