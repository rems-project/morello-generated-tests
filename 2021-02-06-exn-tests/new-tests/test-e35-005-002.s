.section text0, #alloc, #execinstr
test_start:
	.inst 0x7860013f // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:9 00:00 opc:000 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xdac00040 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:0 Rn:2 101101011000000000000:101101011000000000000 sf:1
	.inst 0xc2c0e9e0 // CTHI-C.CR-C Cd:0 Cn:15 1010:1010 opc:11 Rm:0 11000010110:11000010110
	.inst 0x7861d95d // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:29 Rn:10 10:10 S:1 option:110 Rm:1 1:1 opc:01 111000:111000 size:01
	.inst 0x694a17bf // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:29 Rt2:00101 imm7:0010100 L:1 1010010:1010010 opc:01
	.zero 1004
	.inst 0x3860101f // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:001 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x0265323a // ADD-C.CIS-C Cd:26 Cn:17 imm12:100101001100 sh:1 A:0 00000010:00000010
	.inst 0xb860703f // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:111 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x3c566f5e // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:30 Rn:26 11:11 imm9:101100110 0:0 opc:01 111100:111100 size:00
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a9 // ldr c9, [x5, #2]
	.inst 0xc2400caa // ldr c10, [x5, #3]
	.inst 0xc24010af // ldr c15, [x5, #4]
	.inst 0xc24014b1 // ldr c17, [x5, #5]
	/* Set up flags and system registers */
	ldr x5, =0x0
	msr SPSR_EL3, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0x1c0000
	msr CPACR_EL1, x5
	ldr x5, =0x4
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x0
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =initial_DDC_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4125 // msr DDC_EL1, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011a5 // ldr c5, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
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
	.inst 0xc24000ad // ldr c13, [x5, #0]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc24004ad // ldr c13, [x5, #1]
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	.inst 0xc24008ad // ldr c13, [x5, #2]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc2400cad // ldr c13, [x5, #3]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc24010ad // ldr c13, [x5, #4]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc24014ad // ldr c13, [x5, #5]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc24018ad // ldr c13, [x5, #6]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x13, v30.d[0]
	cmp x5, x13
	b.ne comparison_fail
	ldr x5, =0x0
	mov x13, v30.d[1]
	cmp x5, x13
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x13, 0x80
	orr x5, x5, x13
	ldr x13, =0x920000a1
	cmp x13, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x0000100a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000107e
	ldr x1, =check_data2
	ldr x2, =0x0000107f
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001320
	ldr x1, =check_data3
	ldr x2, =0x00001322
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
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
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

.section data0, #alloc, #write
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x02, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x3f, 0x01, 0x60, 0x78, 0x40, 0x00, 0xc0, 0xda, 0xe0, 0xe9, 0xc0, 0xc2, 0x5d, 0xd9, 0x61, 0x78
	.byte 0xbf, 0x17, 0x4a, 0x69
.data
check_data5:
	.byte 0x1f, 0x10, 0x60, 0x38, 0x3a, 0x32, 0x65, 0x02, 0x3f, 0x70, 0x60, 0xb8, 0x5e, 0x6f, 0x56, 0x3c
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C9 */
	.octa 0x1320
	/* C10 */
	.octa 0xfffffffffffff008
	/* C15 */
	.octa 0x1000
	/* C17 */
	.octa 0x1000006a005ffffffffff6b5118
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1000
	/* C9 */
	.octa 0x1320
	/* C10 */
	.octa 0xfffffffffffff008
	/* C15 */
	.octa 0x1000
	/* C17 */
	.octa 0x1000006a005ffffffffff6b5118
	/* C26 */
	.octa 0x107e
	/* C29 */
	.octa 0x2
initial_DDC_EL0_value:
	.octa 0xc00000000007000d0000000000000000
initial_DDC_EL1_value:
	.octa 0xc00000000007000600ffffffffffc001
initial_VBAR_EL1_value:
	.octa 0x200080005800001d0000000040400000
final_PCC_value:
	.octa 0x200080005800001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
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
	.dword 0x0000000000001000
	.dword 0x0000000000001320
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x82600da5 // ldr x5, [c13, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400da5 // str x5, [c13, #0]
	ldr x5, =0x40400414
	mrs x13, ELR_EL1
	sub x5, x5, x13
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ad // cvtp c13, x5
	.inst 0xc2c541ad // scvalue c13, c13, x5
	.inst 0x826001a5 // ldr c5, [c13, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
