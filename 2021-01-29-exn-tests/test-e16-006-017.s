.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c71000 // RRLEN-R.R-C Rd:0 Rn:0 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x28ebb3a0 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:0 Rn:29 Rt2:01100 imm7:1010111 L:1 1010001:1010001 opc:00
	.inst 0x382063e0 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:31 00:00 opc:110 0:0 Rs:0 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xf806f66c // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:19 01:01 imm9:001101111 0:0 opc:00 111000:111000 size:11
	.inst 0xe276401b // ASTUR-V.RI-H Rt:27 Rn:0 op2:00 imm9:101100100 V:1 op1:01 11100010:11100010
	.zero 1004
	.inst 0x1281bac0 // 0x1281bac0
	.inst 0x383f305d // 0x383f305d
	.inst 0xe246a426 // 0xe246a426
	.inst 0xd85fab5d // 0xd85fab5d
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
	ldr x30, =initial_cap_values
	.inst 0xc24003c0 // ldr c0, [x30, #0]
	.inst 0xc24007c1 // ldr c1, [x30, #1]
	.inst 0xc2400bc2 // ldr c2, [x30, #2]
	.inst 0xc2400fd3 // ldr c19, [x30, #3]
	.inst 0xc24013dd // ldr c29, [x30, #4]
	/* Set up flags and system registers */
	ldr x30, =0x4000000
	msr SPSR_EL3, x30
	ldr x30, =initial_SP_EL0_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc288411e // msr CSP_EL0, c30
	ldr x30, =0x200
	msr CPTR_EL3, x30
	ldr x30, =0x30d5d99f
	msr SCTLR_EL1, x30
	ldr x30, =0x3c0000
	msr CPACR_EL1, x30
	ldr x30, =0x4
	msr S3_0_C1_C2_2, x30 // CCTLR_EL1
	ldr x30, =0x0
	msr S3_3_C1_C2_2, x30 // CCTLR_EL0
	ldr x30, =initial_DDC_EL0_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc288413e // msr DDC_EL0, c30
	ldr x30, =initial_DDC_EL1_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc28c413e // msr DDC_EL1, c30
	ldr x30, =0x80000000
	msr HCR_EL2, x30
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260115e // ldr c30, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e403e // msr CELR_EL3, c30
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01e // cvtp c30, x0
	.inst 0xc2df43de // scvalue c30, c30, x31
	.inst 0xc28b413e // msr DDC_EL3, c30
	ldr x30, =0x30851035
	msr SCTLR_EL3, x30
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x30, =final_cap_values
	.inst 0xc24003ca // ldr c10, [x30, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24007ca // ldr c10, [x30, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400bca // ldr c10, [x30, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400fca // ldr c10, [x30, #3]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc24013ca // ldr c10, [x30, #4]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc24017ca // ldr c10, [x30, #5]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc2401bca // ldr c10, [x30, #6]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x30, =final_SP_EL0_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc298410a // mrs c10, CSP_EL0
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	ldr x30, =final_PCC_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x30, 0x83
	orr x10, x10, x30
	ldr x30, =0x920000eb
	cmp x30, x10
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
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400400
	ldr x1, =check_data2
	ldr x2, =0x40400414
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x30, =0x30850030
	msr SCTLR_EL3, x30
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01e // cvtp c30, x0
	.inst 0xc2df43de // scvalue c30, c30, x31
	.inst 0xc28b413e // msr DDC_EL3, c30
	ldr x30, =0x30850030
	msr SCTLR_EL3, x30
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
	.byte 0x89, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 16
	.byte 0x89
.data
check_data1:
	.byte 0x00, 0x10, 0xc7, 0xc2, 0xa0, 0xb3, 0xeb, 0x28, 0xe0, 0x63, 0x20, 0x38, 0x6c, 0xf6, 0x06, 0xf8
	.byte 0x1b, 0x40, 0x76, 0xe2
.data
check_data2:
	.byte 0xc0, 0xba, 0x81, 0x12, 0x5d, 0x30, 0x3f, 0x38, 0x26, 0xa4, 0x46, 0xe2, 0x5d, 0xab, 0x5f, 0xd8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x103ba00000000
	/* C1 */
	.octa 0xfa0
	/* C2 */
	.octa 0xc0000000580000040000000000001000
	/* C19 */
	.octa 0x40000000000600010000000000001008
	/* C29 */
	.octa 0x8000000000970c070000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xfffff229
	/* C1 */
	.octa 0xfa0
	/* C2 */
	.octa 0xc0000000580000040000000000001000
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C19 */
	.octa 0x40000000000600010000000000001077
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000000100050000000000001010
initial_DDC_EL0_value:
	.octa 0x40000000000100070080000000000000
initial_DDC_EL1_value:
	.octa 0x80000000080600000000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004800cc1d0000000040400001
final_SP_EL0_value:
	.octa 0xc0000000000100050000000000001010
final_PCC_value:
	.octa 0x200080004800cc1d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000401800000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
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
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x020003de // add c30, c30, #0
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x020203de // add c30, c30, #128
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x020403de // add c30, c30, #256
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x020603de // add c30, c30, #384
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x020803de // add c30, c30, #512
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x020a03de // add c30, c30, #640
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x020c03de // add c30, c30, #768
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x020e03de // add c30, c30, #896
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x021003de // add c30, c30, #1024
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x021203de // add c30, c30, #1152
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x021403de // add c30, c30, #1280
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x021603de // add c30, c30, #1408
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x021803de // add c30, c30, #1536
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x021a03de // add c30, c30, #1664
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x021c03de // add c30, c30, #1792
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x82600d5e // ldr x30, [c10, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400d5e // str x30, [c10, #0]
	ldr x30, =0x40400414
	mrs x10, ELR_EL1
	sub x30, x30, x10
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ca // cvtp c10, x30
	.inst 0xc2de414a // scvalue c10, c10, x30
	.inst 0x8260015e // ldr c30, [c10, #0]
	.inst 0x021e03de // add c30, c30, #1920
	.inst 0xc2c213c0 // br c30

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
