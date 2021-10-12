.section text0, #alloc, #execinstr
test_start:
	.inst 0x386070c6 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:6 Rn:6 00:00 opc:111 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x485f7cb1 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:17 Rn:5 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xb8ac501f // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:0 00:00 opc:101 0:0 Rs:12 1:1 R:0 A:1 111000:111000 size:10
	.inst 0x3626bcad // tbz:aarch64/instrs/branch/conditional/test Rt:13 imm14:11010111100101 b40:00100 op:0 011011:011011 b5:0
	.inst 0xa2fd7c16 // CASA-C.R-C Ct:22 Rn:0 11111:11111 R:0 Cs:29 1:1 L:1 1:1 10100010:10100010
	.zero 4
	.inst 0x9ac827fe // 0x9ac827fe
	.inst 0xf87622bf // 0xf87622bf
	.inst 0xd4000001
	.zero 988
	.inst 0x3a1e03fe // 0x3a1e03fe
	.inst 0xd63f03e0 // 0xd63f03e0
	.zero 64504
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2400a66 // ldr c6, [x19, #2]
	.inst 0xc2400e6c // ldr c12, [x19, #3]
	.inst 0xc240126d // ldr c13, [x19, #4]
	.inst 0xc2401675 // ldr c21, [x19, #5]
	.inst 0xc2401a76 // ldr c22, [x19, #6]
	/* Set up flags and system registers */
	ldr x19, =0x0
	msr SPSR_EL3, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
	msr CPACR_EL1, x19
	ldr x19, =0xc
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x0
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =initial_DDC_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4133 // msr DDC_EL1, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011d3 // ldr c19, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026e // ldr c14, [x19, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240066e // ldr c14, [x19, #1]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc2400a6e // ldr c14, [x19, #2]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc2400e6e // ldr c14, [x19, #3]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc240126e // ldr c14, [x19, #4]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc240166e // ldr c14, [x19, #5]
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	.inst 0xc2401a6e // ldr c14, [x19, #6]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc2401e6e // ldr c14, [x19, #7]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	ldr x14, =esr_el1_dump_address
	ldr x14, [x14]
	mov x19, 0x83
	orr x14, x14, x19
	ldr x19, =0x920000a3
	cmp x19, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x00001009
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017fc
	ldr x1, =check_data1
	ldr x2, =0x000017fe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000181c
	ldr x1, =check_data2
	ldr x2, =0x00001820
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
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
	ldr x0, =0x40400018
	ldr x1, =check_data5
	ldr x2, =0x40400024
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400408
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2048
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x80
	.zero 2016
.data
check_data0:
	.byte 0x1c
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x01, 0x00, 0x00, 0x80
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xc6, 0x70, 0x60, 0x38, 0xb1, 0x7c, 0x5f, 0x48, 0x1f, 0x50, 0xac, 0xb8, 0xad, 0xbc, 0x26, 0x36
	.byte 0x16, 0x7c, 0xfd, 0xa2
.data
check_data5:
	.byte 0xfe, 0x27, 0xc8, 0x9a, 0xbf, 0x22, 0x76, 0xf8, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0xfe, 0x03, 0x1e, 0x3a, 0xe0, 0x03, 0x3f, 0xd6

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x181c
	/* C5 */
	.octa 0x17fc
	/* C6 */
	.octa 0x1008
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x10
	/* C21 */
	.octa 0x1ff0
	/* C22 */
	.octa 0x4000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x181c
	/* C5 */
	.octa 0x17fc
	/* C6 */
	.octa 0x1c
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x10
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x1ff0
	/* C22 */
	.octa 0x4000000000000000000000000000
initial_DDC_EL0_value:
	.octa 0xc8000000400800140000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000400000180000000040400000
final_PCC_value:
	.octa 0x20008000400000180000000040400024
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
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x82600dd3 // ldr x19, [c14, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400dd3 // str x19, [c14, #0]
	ldr x19, =0x40400024
	mrs x14, ELR_EL1
	sub x19, x19, x14
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26e // cvtp c14, x19
	.inst 0xc2d341ce // scvalue c14, c14, x19
	.inst 0x826001d3 // ldr c19, [c14, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
