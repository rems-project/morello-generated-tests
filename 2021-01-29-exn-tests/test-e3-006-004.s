.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2cf23dc // SCBNDSE-C.CR-C Cd:28 Cn:30 000:000 opc:01 0:0 Rm:15 11000010110:11000010110
	.inst 0x421ffea1 // STLR-C.R-C Ct:1 Rn:21 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xcb5dffbe // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:29 imm6:111111 Rm:29 0:0 shift:01 01011:01011 S:0 op:1 sf:1
	.inst 0x085ffc1f // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:31 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xc89f7fde // stllr:aarch64/instrs/memory/ordered Rt:30 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.zero 1004
	.inst 0x28a9c321 // 0x28a9c321
	.inst 0xc2bdcc08 // 0xc2bdcc08
	.inst 0x911ea411 // 0x911ea411
	.inst 0xc2d15bba // 0xc2d15bba
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
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008d0 // ldr c16, [x6, #2]
	.inst 0xc2400cd5 // ldr c21, [x6, #3]
	.inst 0xc24010d9 // ldr c25, [x6, #4]
	.inst 0xc24014dd // ldr c29, [x6, #5]
	.inst 0xc24018de // ldr c30, [x6, #6]
	/* Set up flags and system registers */
	ldr x6, =0x0
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
	ldr x6, =initial_DDC_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4126 // msr DDC_EL1, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601086 // ldr c6, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c4 // ldr c4, [x6, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24004c4 // ldr c4, [x6, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc24008c4 // ldr c4, [x6, #2]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc2400cc4 // ldr c4, [x6, #3]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc24010c4 // ldr c4, [x6, #4]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc24014c4 // ldr c4, [x6, #5]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc24018c4 // ldr c4, [x6, #6]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc2401cc4 // ldr c4, [x6, #7]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc24020c4 // ldr c4, [x6, #8]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc24024c4 // ldr c4, [x6, #9]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	ldr x4, =esr_el1_dump_address
	ldr x4, [x4]
	mov x6, 0x83
	orr x4, x4, x6
	ldr x6, =0x920000eb
	cmp x6, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000126c
	ldr x1, =check_data1
	ldr x2, =0x0000126d
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
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xdc, 0x23, 0xcf, 0xc2, 0xa1, 0xfe, 0x1f, 0x42, 0xbe, 0xff, 0x5d, 0xcb, 0x1f, 0xfc, 0x5f, 0x08
	.byte 0xde, 0x7f, 0x9f, 0xc8
.data
check_data3:
	.byte 0x21, 0xc3, 0xa9, 0x28, 0x08, 0xcc, 0xbd, 0xc2, 0x11, 0xa4, 0x1e, 0x91, 0xba, 0x5b, 0xd1, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80004007000000000000126c
	/* C1 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C21 */
	.octa 0x1000
	/* C25 */
	.octa 0x1000
	/* C29 */
	.octa 0x18000000000000001
	/* C30 */
	.octa 0x700060000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80004007000000000000126c
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0x800040070000000000001274
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x1a15
	/* C21 */
	.octa 0x1000
	/* C25 */
	.octa 0xf4c
	/* C26 */
	.octa 0x18000000400000000
	/* C29 */
	.octa 0x18000000000000001
	/* C30 */
	.octa 0x8000000000000000
initial_DDC_EL0_value:
	.octa 0xc00000000006000500ffffffff800003
initial_DDC_EL1_value:
	.octa 0x40000000500c000400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080005000d41d0000000040400000
final_PCC_value:
	.octa 0x200080005000d41d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080005002d0040000000040400000
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600c86 // ldr x6, [c4, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c86 // str x6, [c4, #0]
	ldr x6, =0x40400414
	mrs x4, ELR_EL1
	sub x6, x6, x4
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c4 // cvtp c4, x6
	.inst 0xc2c64084 // scvalue c4, c4, x6
	.inst 0x82600086 // ldr c6, [c4, #0]
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
