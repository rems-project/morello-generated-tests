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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a9 // ldr c9, [x21, #1]
	.inst 0xc2400aab // ldr c11, [x21, #2]
	.inst 0xc2400eaf // ldr c15, [x21, #3]
	.inst 0xc24012b0 // ldr c16, [x21, #4]
	.inst 0xc24016b2 // ldr c18, [x21, #5]
	.inst 0xc2401ab6 // ldr c22, [x21, #6]
	.inst 0xc2401ebd // ldr c29, [x21, #7]
	.inst 0xc24022be // ldr c30, [x21, #8]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x21, =0x0
	msr SPSR_EL3, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30d5d99f
	msr SCTLR_EL1, x21
	ldr x21, =0x3c0000
	msr CPACR_EL1, x21
	ldr x21, =0x0
	msr S3_0_C1_C2_2, x21 // CCTLR_EL1
	ldr x21, =0x0
	msr S3_3_C1_C2_2, x21 // CCTLR_EL0
	ldr x21, =initial_DDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884135 // msr DDC_EL0, c21
	ldr x21, =initial_DDC_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc28c4135 // msr DDC_EL1, c21
	ldr x21, =0x80000000
	msr HCR_EL2, x21
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82601055 // ldr c21, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc28e4035 // msr CELR_EL3, c21
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x2, #0xf
	and x21, x21, x2
	cmp x21, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a2 // ldr c2, [x21, #0]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2c2a521 // chkeq c9, c2
	b.ne comparison_fail
	.inst 0xc2400aa2 // ldr c2, [x21, #2]
	.inst 0xc2c2a561 // chkeq c11, c2
	b.ne comparison_fail
	.inst 0xc2400ea2 // ldr c2, [x21, #3]
	.inst 0xc2c2a5e1 // chkeq c15, c2
	b.ne comparison_fail
	.inst 0xc24012a2 // ldr c2, [x21, #4]
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	.inst 0xc24016a2 // ldr c2, [x21, #5]
	.inst 0xc2c2a641 // chkeq c18, c2
	b.ne comparison_fail
	.inst 0xc2401aa2 // ldr c2, [x21, #6]
	.inst 0xc2c2a6c1 // chkeq c22, c2
	b.ne comparison_fail
	.inst 0xc2401ea2 // ldr c2, [x21, #7]
	.inst 0xc2c2a741 // chkeq c26, c2
	b.ne comparison_fail
	.inst 0xc24022a2 // ldr c2, [x21, #8]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc24026a2 // ldr c2, [x21, #9]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x2, v7.d[0]
	cmp x21, x2
	b.ne comparison_fail
	ldr x21, =0x0
	mov x2, v7.d[1]
	cmp x21, x2
	b.ne comparison_fail
	ldr x21, =0x0
	mov x2, v20.d[0]
	cmp x21, x2
	b.ne comparison_fail
	ldr x21, =0x0
	mov x2, v20.d[1]
	cmp x21, x2
	b.ne comparison_fail
	ldr x21, =0x0
	mov x2, v30.d[0]
	cmp x21, x2
	b.ne comparison_fail
	ldr x21, =0x0
	mov x2, v30.d[1]
	cmp x21, x2
	b.ne comparison_fail
	/* Check system registers */
	ldr x21, =final_PCC_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a6a1 // chkeq c21, c2
	b.ne comparison_fail
	ldr x2, =esr_el1_dump_address
	ldr x2, [x2]
	mov x21, 0x83
	orr x2, x2, x21
	ldr x21, =0x920000a3
	cmp x21, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001091
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c22
	ldr x1, =check_data2
	ldr x2, =0x00001c23
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
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
	.zero 128
	.byte 0x00, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3936
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
	.byte 0x01
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
	.octa 0x40400000
	/* C9 */
	.octa 0x800000c1108001
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0x1090
	/* C18 */
	.octa 0x780070000000880008000
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x1080
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x404000d2
	/* C9 */
	.octa 0x800000c1108001
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x102c
	/* C16 */
	.octa 0x1090
	/* C18 */
	.octa 0x780070000000880008000
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x1
	/* C29 */
	.octa 0x780070000001000000000
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc00000000aa200060000000000000000
initial_DDC_EL1_value:
	.octa 0x80000000200700070000000000000001
initial_VBAR_EL1_value:
	.octa 0x208080005100021c0000000040400000
final_PCC_value:
	.octa 0x208080005100021c0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080000400000000040400000
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
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x020002b5 // add c21, c21, #0
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x020202b5 // add c21, c21, #128
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x020402b5 // add c21, c21, #256
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x020602b5 // add c21, c21, #384
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x020802b5 // add c21, c21, #512
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x020a02b5 // add c21, c21, #640
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x020c02b5 // add c21, c21, #768
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x020e02b5 // add c21, c21, #896
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x021002b5 // add c21, c21, #1024
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x021202b5 // add c21, c21, #1152
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x021402b5 // add c21, c21, #1280
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x021602b5 // add c21, c21, #1408
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x021802b5 // add c21, c21, #1536
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x021a02b5 // add c21, c21, #1664
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x021c02b5 // add c21, c21, #1792
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600c55 // ldr x21, [c2, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c55 // str x21, [c2, #0]
	ldr x21, =0x40400414
	mrs x2, ELR_EL1
	sub x21, x21, x2
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a2 // cvtp c2, x21
	.inst 0xc2d54042 // scvalue c2, c2, x21
	.inst 0x82600055 // ldr c21, [c2, #0]
	.inst 0x021e02b5 // add c21, c21, #1920
	.inst 0xc2c212a0 // br c21

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
