.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2b1803a // SWPA-CC.R-C Ct:26 Rn:1 100000:100000 Cs:17 1:1 R:0 A:1 10100010:10100010
	.inst 0xbd7643bf // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:31 Rn:29 imm12:110110010000 opc:01 111101:111101 size:10
	.inst 0xc2c23142 // BLRS-C-C 00010:00010 Cn:10 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x38478829 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:1 10:10 imm9:001111000 0:0 opc:01 111000:111000 size:00
	.inst 0xa2eb7e04 // CASA-C.R-C Ct:4 Rn:16 11111:11111 R:0 Cs:11 1:1 L:1 1:1 10100010:10100010
	.zero 1004
	.inst 0x384d8ba1 // 0x384d8ba1
	.inst 0x7824109f // 0x7824109f
	.inst 0xf0e858dd // 0xf0e858dd
	.inst 0x787df9b8 // 0x787df9b8
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
	ldr x28, =initial_cap_values
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400784 // ldr c4, [x28, #1]
	.inst 0xc2400b8a // ldr c10, [x28, #2]
	.inst 0xc2400f8d // ldr c13, [x28, #3]
	.inst 0xc2401390 // ldr c16, [x28, #4]
	.inst 0xc2401791 // ldr c17, [x28, #5]
	.inst 0xc2401b9d // ldr c29, [x28, #6]
	/* Set up flags and system registers */
	ldr x28, =0x4000000
	msr SPSR_EL3, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0x3c0000
	msr CPACR_EL1, x28
	ldr x28, =0x8
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x0
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
	ldr x28, =initial_DDC_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28c413c // msr DDC_EL1, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260133c // ldr c28, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc28e403c // msr CELR_EL3, c28
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400399 // ldr c25, [x28, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400799 // ldr c25, [x28, #1]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400b99 // ldr c25, [x28, #2]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc2400f99 // ldr c25, [x28, #3]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc2401399 // ldr c25, [x28, #4]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc2401799 // ldr c25, [x28, #5]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401b99 // ldr c25, [x28, #6]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc2401f99 // ldr c25, [x28, #7]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc2402399 // ldr c25, [x28, #8]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc2402799 // ldr c25, [x28, #9]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402b99 // ldr c25, [x28, #10]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x25, v31.d[0]
	cmp x28, x25
	b.ne comparison_fail
	ldr x28, =0x0
	mov x25, v31.d[1]
	cmp x28, x25
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x28, 0x83
	orr x25, x25, x28
	ldr x28, =0x920000a3
	cmp x28, x25
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
	ldr x0, =0x00001078
	ldr x1, =check_data1
	ldr x2, =0x00001079
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
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
	ldr x0, =0x404002d8
	ldr x1, =check_data4
	ldr x2, =0x404002d9
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
	ldr x0, =0x40403840
	ldr x1, =check_data6
	ldr x2, =0x40403844
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
	.byte 0x00, 0x00, 0x04, 0xee, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x3a, 0x80, 0xb1, 0xa2, 0xbf, 0x43, 0x76, 0xbd, 0x42, 0x31, 0xc2, 0xc2, 0x29, 0x88, 0x47, 0x38
	.byte 0x04, 0x7e, 0xeb, 0xa2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xa1, 0x8b, 0x4d, 0x38, 0x9f, 0x10, 0x24, 0x78, 0xdd, 0x58, 0xe8, 0xf0, 0xb8, 0xf9, 0x7d, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xdc100000400101820000000000001000
	/* C4 */
	.octa 0x1002
	/* C10 */
	.octa 0x2000800008000010000000004040000d
	/* C13 */
	.octa 0x5e9cbffc
	/* C16 */
	.octa 0xcc000000600080010000000000048001
	/* C17 */
	.octa 0x80000000000000000000000000000
	/* C29 */
	.octa 0x8000000020c720070000000040400200
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x1002
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x2000800008000010000000004040000d
	/* C13 */
	.octa 0x5e9cbffc
	/* C16 */
	.octa 0xcc000000600080010000000000048001
	/* C17 */
	.octa 0x80000000000000000000000000000
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0xee040000
	/* C29 */
	.octa 0xffffffffd0b1b000
	/* C30 */
	.octa 0x2000800040120000000000004040000d
initial_DDC_EL1_value:
	.octa 0xc00000003ffb000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x200080004600fc080000000040400000
final_PCC_value:
	.octa 0x200080004600fc080000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000401200000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x82600f3c // ldr x28, [c25, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f3c // str x28, [c25, #0]
	ldr x28, =0x40400414
	mrs x25, ELR_EL1
	sub x28, x28, x25
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b399 // cvtp c25, x28
	.inst 0xc2dc4339 // scvalue c25, c25, x28
	.inst 0x8260033c // ldr c28, [c25, #0]
	.inst 0x021e039c // add c28, c28, #1920
	.inst 0xc2c21380 // br c28

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
