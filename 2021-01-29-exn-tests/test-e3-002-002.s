.section text0, #alloc, #execinstr
test_start:
	.inst 0xa251c79f // LDR-C.RIAW-C Ct:31 Rn:28 01:01 imm9:100011100 0:0 opc:01 10100010:10100010
	.inst 0xea10683f // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:1 imm6:011010 Rm:16 N:0 shift:00 01010:01010 opc:11 sf:1
	.inst 0x69c34853 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:19 Rn:2 Rt2:10010 imm7:0000110 L:1 1010011:1010011 opc:01
	.inst 0xe2ab040a // ALDUR-V.RI-S Rt:10 Rn:0 op2:01 imm9:010110000 V:1 op1:10 11100010:11100010
	.inst 0x385c6ba0 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:29 10:10 imm9:111000110 0:0 opc:01 111000:111000 size:00
	.zero 2212
	.inst 0xc2c2c2c2
	.zero 5924
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 1040
	.inst 0xc2dd67c3 // 0xc2dd67c3
	.inst 0xc2c0b3fe // 0xc2c0b3fe
	.inst 0xc2de47be // 0xc2de47be
	.inst 0xf84beffe // 0xf84beffe
	.inst 0xd4000001
	.zero 56300
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
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2400cd0 // ldr c16, [x6, #3]
	.inst 0xc24010dc // ldr c28, [x6, #4]
	.inst 0xc24014dd // ldr c29, [x6, #5]
	.inst 0xc24018de // ldr c30, [x6, #6]
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4106 // msr CSP_EL1, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0x3c0000
	msr CPACR_EL1, x6
	ldr x6, =0x4
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x4
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
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601166 // ldr c6, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	mov x11, #0xf
	and x6, x6, x11
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000cb // ldr c11, [x6, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24004cb // ldr c11, [x6, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24008cb // ldr c11, [x6, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400ccb // ldr c11, [x6, #3]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc24010cb // ldr c11, [x6, #4]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc24014cb // ldr c11, [x6, #5]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc24018cb // ldr c11, [x6, #6]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc2401ccb // ldr c11, [x6, #7]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc24020cb // ldr c11, [x6, #8]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc24024cb // ldr c11, [x6, #9]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0xc2c2c2c2
	mov x11, v10.d[0]
	cmp x6, x11
	b.ne comparison_fail
	ldr x6, =0x0
	mov x11, v10.d[1]
	cmp x6, x11
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc29c410b // mrs c11, CSP_EL1
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	ldr x11, =esr_el1_dump_address
	ldr x11, [x11]
	mov x6, 0x83
	orr x11, x11, x6
	ldr x6, =0x920000ab
	cmp x6, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001018
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c0
	ldr x1, =check_data1
	ldr x2, =0x000010c8
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
	ldr x0, =0x404008b8
	ldr x1, =check_data3
	ldr x2, =0x404008bc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40401fe0
	ldr x1, =check_data4
	ldr x2, =0x40401ff0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40402400
	ldr x1, =check_data5
	ldr x2, =0x40402414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 160
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3888
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0x9f, 0xc7, 0x51, 0xa2, 0x3f, 0x68, 0x10, 0xea, 0x53, 0x48, 0xc3, 0x69, 0x0a, 0x04, 0xab, 0xe2
	.byte 0xa0, 0x6b, 0x5c, 0x38
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc3, 0x67, 0xdd, 0xc2, 0xfe, 0xb3, 0xc0, 0xc2, 0xbe, 0x47, 0xde, 0xc2, 0xfe, 0xef, 0x4b, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40400808
	/* C1 */
	.octa 0x4080612fffffff
	/* C2 */
	.octa 0x80000000000100050000000000001000
	/* C16 */
	.octa 0x3fefdfe7b4
	/* C28 */
	.octa 0x80000000000100050000000040401fe0
	/* C29 */
	.octa 0x800000000000080000000000202
	/* C30 */
	.octa 0x800000030000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40400808
	/* C1 */
	.octa 0x4080612fffffff
	/* C2 */
	.octa 0x80000000000100050000000000001018
	/* C3 */
	.octa 0x800000030080000000000202
	/* C16 */
	.octa 0x3fefdfe7b4
	/* C18 */
	.octa 0xffffffffc2c2c2c2
	/* C19 */
	.octa 0xffffffffc2c2c2c2
	/* C28 */
	.octa 0x800000000001000500000000404011a0
	/* C29 */
	.octa 0x800000000000080000000000202
	/* C30 */
	.octa 0xc2c2c2c2c2c2c2c2
initial_SP_EL1_value:
	.octa 0x800000000000000000001000
initial_DDC_EL0_value:
	.octa 0x80000000000080000000000000000000
initial_DDC_EL1_value:
	.octa 0x800000006001000200ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040402000
final_SP_EL1_value:
	.octa 0x10be
final_PCC_value:
	.octa 0x200080004000041d0000000040402414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004300050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 128
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
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40402414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
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
