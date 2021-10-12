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
	.inst 0xc2da831b // SCTAG-C.CR-C Cd:27 Cn:24 000:000 0:0 10:10 Rm:26 11000010110:11000010110
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006e9 // ldr c9, [x23, #1]
	.inst 0xc2400aeb // ldr c11, [x23, #2]
	.inst 0xc2400eef // ldr c15, [x23, #3]
	.inst 0xc24012f0 // ldr c16, [x23, #4]
	.inst 0xc24016f2 // ldr c18, [x23, #5]
	.inst 0xc2401af6 // ldr c22, [x23, #6]
	.inst 0xc2401efd // ldr c29, [x23, #7]
	.inst 0xc24022fe // ldr c30, [x23, #8]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0x3c0000
	msr CPACR_EL1, x23
	ldr x23, =0x4
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x0
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x0, =pcc_return_ddc_capabilities
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0x82601017 // ldr c23, [c0, #1]
	.inst 0x82602000 // ldr c0, [c0, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x0, #0xf
	and x23, x23, x0
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc2c0a421 // chkeq c1, c0
	b.ne comparison_fail
	.inst 0xc24006e0 // ldr c0, [x23, #1]
	.inst 0xc2c0a521 // chkeq c9, c0
	b.ne comparison_fail
	.inst 0xc2400ae0 // ldr c0, [x23, #2]
	.inst 0xc2c0a561 // chkeq c11, c0
	b.ne comparison_fail
	.inst 0xc2400ee0 // ldr c0, [x23, #3]
	.inst 0xc2c0a5e1 // chkeq c15, c0
	b.ne comparison_fail
	.inst 0xc24012e0 // ldr c0, [x23, #4]
	.inst 0xc2c0a601 // chkeq c16, c0
	b.ne comparison_fail
	.inst 0xc24016e0 // ldr c0, [x23, #5]
	.inst 0xc2c0a641 // chkeq c18, c0
	b.ne comparison_fail
	.inst 0xc2401ae0 // ldr c0, [x23, #6]
	.inst 0xc2c0a6c1 // chkeq c22, c0
	b.ne comparison_fail
	.inst 0xc2401ee0 // ldr c0, [x23, #7]
	.inst 0xc2c0a741 // chkeq c26, c0
	b.ne comparison_fail
	.inst 0xc24022e0 // ldr c0, [x23, #8]
	.inst 0xc2c0a7a1 // chkeq c29, c0
	b.ne comparison_fail
	.inst 0xc24026e0 // ldr c0, [x23, #9]
	.inst 0xc2c0a7c1 // chkeq c30, c0
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x0, v7.d[0]
	cmp x23, x0
	b.ne comparison_fail
	ldr x23, =0x0
	mov x0, v7.d[1]
	cmp x23, x0
	b.ne comparison_fail
	ldr x23, =0x0
	mov x0, v20.d[0]
	cmp x23, x0
	b.ne comparison_fail
	ldr x23, =0x0
	mov x0, v20.d[1]
	cmp x23, x0
	b.ne comparison_fail
	ldr x23, =0x0
	mov x0, v30.d[0]
	cmp x23, x0
	b.ne comparison_fail
	ldr x23, =0x0
	mov x0, v30.d[1]
	cmp x23, x0
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984020 // mrs c0, CELR_EL1
	.inst 0xc2c0a6e1 // chkeq c23, c0
	b.ne comparison_fail
	ldr x0, =esr_el1_dump_address
	ldr x0, [x0]
	mov x23, 0x83
	orr x0, x0, x23
	ldr x23, =0x920000a3
	cmp x23, x0
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
	ldr x0, =0x00001011
	ldr x1, =check_data1
	ldr x2, =0x00001012
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ba0
	ldr x1, =check_data2
	ldr x2, =0x00001bb0
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
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.zero 16
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2944
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1104
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x01
.data
check_data2:
	.zero 16
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
	.octa 0x1000
	/* C9 */
	.octa 0x580000000000001
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0x1011
	/* C18 */
	.octa 0x8007a0b70004fff800008000
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x1ba0
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x10d2
	/* C9 */
	.octa 0x580000000000001
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x102c
	/* C16 */
	.octa 0x1011
	/* C18 */
	.octa 0x8007a0b70004fff800008000
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x1
	/* C29 */
	.octa 0x8007a0b70005000000000000
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc0000000380200030000000000000000
initial_DDC_EL1_value:
	.octa 0x800000000000c0000000000000000001
initial_VBAR_EL1_value:
	.octa 0x208080005000001d0000000040400000
final_PCC_value:
	.octa 0x208080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080140050000000040400000
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600c17 // ldr x23, [c0, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c17 // str x23, [c0, #0]
	ldr x23, =0x40400414
	mrs x0, ELR_EL1
	sub x23, x23, x0
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e0 // cvtp c0, x23
	.inst 0xc2d74000 // scvalue c0, c0, x23
	.inst 0x82600017 // ldr c23, [c0, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
