.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2b1803a // SWPA-CC.R-C Ct:26 Rn:1 100000:100000 Cs:17 1:1 R:0 A:1 10100010:10100010
	.inst 0xbd7643bf // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:31 Rn:29 imm12:110110010000 opc:01 111101:111101 size:10
	.inst 0xc2c23142 // BLRS-C-C 00010:00010 Cn:10 100:100 opc:01 11000010110000100:11000010110000100
	.zero 4
	.inst 0x38478829 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:1 10:10 imm9:001111000 0:0 opc:01 111000:111000 size:00
	.inst 0xa2eb7e04 // CASA-C.R-C Ct:4 Rn:16 11111:11111 R:0 Cs:11 1:1 L:1 1:1 10100010:10100010
	.zero 1000
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
	ldr x25, =initial_cap_values
	.inst 0xc2400321 // ldr c1, [x25, #0]
	.inst 0xc2400724 // ldr c4, [x25, #1]
	.inst 0xc2400b2a // ldr c10, [x25, #2]
	.inst 0xc2400f2d // ldr c13, [x25, #3]
	.inst 0xc2401330 // ldr c16, [x25, #4]
	.inst 0xc2401731 // ldr c17, [x25, #5]
	.inst 0xc2401b3d // ldr c29, [x25, #6]
	/* Set up flags and system registers */
	ldr x25, =0x4000000
	msr SPSR_EL3, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0x3c0000
	msr CPACR_EL1, x25
	ldr x25, =0x0
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0x0
	msr S3_3_C1_C2_2, x25 // CCTLR_EL0
	ldr x25, =initial_DDC_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4139 // msr DDC_EL1, c25
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82601079 // ldr c25, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc28e4039 // msr CELR_EL3, c25
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400323 // ldr c3, [x25, #0]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400723 // ldr c3, [x25, #1]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2400b23 // ldr c3, [x25, #2]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2400f23 // ldr c3, [x25, #3]
	.inst 0xc2c3a541 // chkeq c10, c3
	b.ne comparison_fail
	.inst 0xc2401323 // ldr c3, [x25, #4]
	.inst 0xc2c3a5a1 // chkeq c13, c3
	b.ne comparison_fail
	.inst 0xc2401723 // ldr c3, [x25, #5]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2401b23 // ldr c3, [x25, #6]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2401f23 // ldr c3, [x25, #7]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc2402323 // ldr c3, [x25, #8]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc2402723 // ldr c3, [x25, #9]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402b23 // ldr c3, [x25, #10]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x3, v31.d[0]
	cmp x25, x3
	b.ne comparison_fail
	ldr x25, =0x0
	mov x3, v31.d[1]
	cmp x25, x3
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x25, 0x83
	orr x3, x3, x25
	ldr x25, =0x920000ab
	cmp x25, x3
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
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x4040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400010
	ldr x1, =check_data3
	ldr x2, =0x40400018
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
	ldr x0, =0x4040203e
	ldr x1, =check_data5
	ldr x2, =0x40402040
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40408ad8
	ldr x1, =check_data6
	ldr x2, =0x40408ad9
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040c040
	ldr x1, =check_data7
	ldr x2, =0x4040c044
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x3a, 0x80, 0xb1, 0xa2, 0xbf, 0x43, 0x76, 0xbd, 0x42, 0x31, 0xc2, 0xc2
.data
check_data3:
	.byte 0x29, 0x88, 0x47, 0x38, 0x04, 0x7e, 0xeb, 0xa2
.data
check_data4:
	.byte 0xa1, 0x8b, 0x4d, 0x38, 0x9f, 0x10, 0x24, 0x78, 0xdd, 0x58, 0xe8, 0xf0, 0xb8, 0xf9, 0x7d, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xdc100000000200030000000000001000
	/* C4 */
	.octa 0x1000
	/* C10 */
	.octa 0x20008000000100070000000040400011
	/* C13 */
	.octa 0x1e5cc03e
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0xff
	/* C29 */
	.octa 0x80000000000300070000000040408a00
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x1000
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x20008000000100070000000040400011
	/* C13 */
	.octa 0x1e5cc03e
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0xff
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x10f1b000
	/* C30 */
	.octa 0x2000800008070006000000004040000d
initial_DDC_EL1_value:
	.octa 0xc0000000004140050080000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004000010d0000000040400000
final_PCC_value:
	.octa 0x200080004000010d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080700060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600c79 // ldr x25, [c3, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c79 // str x25, [c3, #0]
	ldr x25, =0x40400414
	mrs x3, ELR_EL1
	sub x25, x25, x3
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b323 // cvtp c3, x25
	.inst 0xc2d94063 // scvalue c3, c3, x25
	.inst 0x82600079 // ldr c25, [c3, #0]
	.inst 0x021e0339 // add c25, c25, #1920
	.inst 0xc2c21320 // br c25

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
