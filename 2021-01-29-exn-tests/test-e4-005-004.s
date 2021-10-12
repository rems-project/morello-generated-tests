.section text0, #alloc, #execinstr
test_start:
	.inst 0x3819fbdf // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:30 10:10 imm9:110011111 0:0 opc:00 111000:111000 size:00
	.inst 0x7939dff6 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:22 Rn:31 imm12:111001110111 opc:00 111001:111001 size:01
	.inst 0x79bcec1f // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:0 imm12:111100111011 opc:10 111001:111001 size:01
	.inst 0xc2c592f6 // CVTD-C.R-C Cd:22 Rn:23 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xa849d41e // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:30 Rn:0 Rt2:10101 imm7:0010011 L:1 1010000:1010000 opc:10
	.zero 24556
	.inst 0xd4000001
	.zero 1020
	.inst 0xb237e40b // 0xb237e40b
	.inst 0xc2c131bf // 0xc2c131bf
	.inst 0x3821131f // 0x3821131f
	.inst 0xd61f01c0 // 0xd61f01c0
	.zero 39920
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
	.inst 0xc24008ce // ldr c14, [x6, #2]
	.inst 0xc2400cd6 // ldr c22, [x6, #3]
	.inst 0xc24010d7 // ldr c23, [x6, #4]
	.inst 0xc24014d8 // ldr c24, [x6, #5]
	.inst 0xc24018de // ldr c30, [x6, #6]
	/* Set up flags and system registers */
	ldr x6, =0x0
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884106 // msr CSP_EL0, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x4
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
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601246 // ldr c6, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	.inst 0xc24000d2 // ldr c18, [x6, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24004d2 // ldr c18, [x6, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24008d2 // ldr c18, [x6, #2]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc2400cd2 // ldr c18, [x6, #3]
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	.inst 0xc24010d2 // ldr c18, [x6, #4]
	.inst 0xc2d2a6c1 // chkeq c22, c18
	b.ne comparison_fail
	.inst 0xc24014d2 // ldr c18, [x6, #5]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc24018d2 // ldr c18, [x6, #6]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc2401cd2 // ldr c18, [x6, #7]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984112 // mrs c18, CSP_EL0
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	ldr x18, =esr_el1_dump_address
	ldr x18, [x18]
	mov x6, 0x83
	orr x18, x18, x6
	ldr x6, =0x920000a3
	cmp x6, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001cee
	ldr x1, =check_data0
	ldr x2, =0x00001cf0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f0a
	ldr x1, =check_data1
	ldr x2, =0x00001f0c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fbd
	ldr x1, =check_data2
	ldr x2, =0x00001fbe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x40406000
	ldr x1, =check_data5
	ldr x2, =0x40406004
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40406400
	ldr x1, =check_data6
	ldr x2, =0x40406410
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00
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
	.byte 0xff
.data
check_data4:
	.byte 0xdf, 0xfb, 0x19, 0x38, 0xf6, 0xdf, 0x39, 0x79, 0x1f, 0xec, 0xbc, 0x79, 0xf6, 0x92, 0xc5, 0xc2
	.byte 0x1e, 0xd4, 0x49, 0xa8
.data
check_data5:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0x0b, 0xe4, 0x37, 0xb2, 0xbf, 0x31, 0xc1, 0xc2, 0x1f, 0x13, 0x21, 0x38, 0xc0, 0x01, 0x1f, 0xd6

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x94
	/* C1 */
	.octa 0x0
	/* C14 */
	.octa 0x40406000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0xffffffffffe001
	/* C24 */
	.octa 0x1ffe
	/* C30 */
	.octa 0x201e
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x94
	/* C1 */
	.octa 0x0
	/* C11 */
	.octa 0x66666666666666f6
	/* C14 */
	.octa 0x40406000
	/* C22 */
	.octa 0xc00000002007001700ffffffffffe001
	/* C23 */
	.octa 0xffffffffffe001
	/* C24 */
	.octa 0x1ffe
	/* C30 */
	.octa 0x201e
initial_SP_EL0_value:
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc0000000200700170000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000440d0000000040406000
final_SP_EL0_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080004000440d0000000040406004
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000207820e0000000040400000
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
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40406004
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
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
