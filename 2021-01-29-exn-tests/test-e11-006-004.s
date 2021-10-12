.section text0, #alloc, #execinstr
test_start:
	.inst 0x387e321a // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:16 00:00 opc:011 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x3d2e4a1e // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:30 Rn:16 imm12:101110010010 opc:00 111101:111101 size:00
	.inst 0xa2a1ffab // CASL-C.R-C Ct:11 Rn:29 11111:11111 R:1 Cs:1 1:1 L:0 1:1 10100010:10100010
	.inst 0xb88d243d // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:1 01:01 imm9:011010010 0:0 opc:10 111000:111000 size:10
	.inst 0xb8e18126 // swp:aarch64/instrs/memory/atomicops/swp Rt:6 Rn:9 100000:100000 Rs:1 1:1 R:1 A:1 111000:111000 size:10
	.zero 1004
	.inst 0xc2d1da5d // 0xc2d1da5d
	.inst 0x2cc59df4 // 0x2cc59df4
	.inst 0xc2c1c2de // 0xc2c1c2de
	.inst 0xc2da831b // 0xc2da831b
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c9 // ldr c9, [x6, #1]
	.inst 0xc24008cb // ldr c11, [x6, #2]
	.inst 0xc2400ccf // ldr c15, [x6, #3]
	.inst 0xc24010d0 // ldr c16, [x6, #4]
	.inst 0xc24014d2 // ldr c18, [x6, #5]
	.inst 0xc24018d6 // ldr c22, [x6, #6]
	.inst 0xc2401cdd // ldr c29, [x6, #7]
	.inst 0xc24020de // ldr c30, [x6, #8]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x6, =0x0
	msr SPSR_EL3, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0x3c0000
	msr CPACR_EL1, x6
	ldr x6, =0x4
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
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012e6 // ldr c6, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	mov x23, #0xf
	and x6, x6, x23
	cmp x6, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d7 // ldr c23, [x6, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24004d7 // ldr c23, [x6, #1]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc24008d7 // ldr c23, [x6, #2]
	.inst 0xc2d7a561 // chkeq c11, c23
	b.ne comparison_fail
	.inst 0xc2400cd7 // ldr c23, [x6, #3]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc24010d7 // ldr c23, [x6, #4]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc24014d7 // ldr c23, [x6, #5]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc24018d7 // ldr c23, [x6, #6]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2401cd7 // ldr c23, [x6, #7]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc24020d7 // ldr c23, [x6, #8]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc24024d7 // ldr c23, [x6, #9]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0xa2a1ffab
	mov x23, v7.d[0]
	cmp x6, x23
	b.ne comparison_fail
	ldr x6, =0x0
	mov x23, v7.d[1]
	cmp x6, x23
	b.ne comparison_fail
	ldr x6, =0x3d2e4a1e
	mov x23, v20.d[0]
	cmp x6, x23
	b.ne comparison_fail
	ldr x6, =0x0
	mov x23, v20.d[1]
	cmp x6, x23
	b.ne comparison_fail
	ldr x6, =0x0
	mov x23, v30.d[0]
	cmp x6, x23
	b.ne comparison_fail
	ldr x6, =0x0
	mov x23, v30.d[1]
	cmp x6, x23
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x6, 0x83
	orr x23, x23, x6
	ldr x6, =0x920000ab
	cmp x6, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001011
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001170
	ldr x1, =check_data1
	ldr x2, =0x00001174
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ba2
	ldr x1, =check_data2
	ldr x2, =0x00001ba3
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.byte 0x70, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 16
	.byte 0x01
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x1a, 0x32, 0x7e, 0x38, 0x1e, 0x4a, 0x2e, 0x3d, 0xab, 0xff, 0xa1, 0xa2, 0x3d, 0x24, 0x8d, 0xb8
	.byte 0x26, 0x81, 0xe1, 0xb8
.data
check_data4:
	.byte 0x5d, 0xda, 0xd1, 0xc2, 0xf4, 0x9d, 0xc5, 0x2c, 0xde, 0xc2, 0xc1, 0xc2, 0x1b, 0x83, 0xda, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1170
	/* C9 */
	.octa 0xbc40000000000001
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x80000000040604030000000040400004
	/* C16 */
	.octa 0x1010
	/* C18 */
	.octa 0x800100040000000000000000
	/* C22 */
	.octa 0x1
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1242
	/* C9 */
	.octa 0xbc40000000000001
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x80000000040604030000000040400030
	/* C16 */
	.octa 0x1010
	/* C18 */
	.octa 0x800100040000000000000000
	/* C22 */
	.octa 0x1
	/* C26 */
	.octa 0x1
	/* C29 */
	.octa 0x800100040000000000000000
	/* C30 */
	.octa 0x1
initial_DDC_EL0_value:
	.octa 0xc00000000206000000fffffff0000000
initial_VBAR_EL1_value:
	.octa 0x208080005000d41e0000000040400001
final_PCC_value:
	.octa 0x208080005000d41e0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008040080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
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
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x40400414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
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
