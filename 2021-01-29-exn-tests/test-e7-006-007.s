.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bfc03d // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:29 Rn:1 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x79e6403e // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:1 imm12:100110010000 opc:11 111001:111001 size:01
	.inst 0x425ffe5e // LDAR-C.R-C Ct:30 Rn:18 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x1a0e03a1 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:29 000000:000000 Rm:14 11010000:11010000 S:0 op:0 sf:0
	.inst 0x781e7fb3 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:19 Rn:29 11:11 imm9:111100111 0:0 opc:00 111000:111000 size:01
	.zero 236
	.inst 0x00000080
	.zero 4860
	.inst 0xc2c8443e // 0xc2c8443e
	.inst 0x3ddf2aa0 // 0x3ddf2aa0
	.inst 0x82608947 // 0x82608947
	.inst 0xc221d6bf // 0xc221d6bf
	.inst 0xd4000001
	.zero 60396
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
	ldr x11, =initial_cap_values
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400568 // ldr c8, [x11, #1]
	.inst 0xc240096a // ldr c10, [x11, #2]
	.inst 0xc2400d72 // ldr c18, [x11, #3]
	.inst 0xc2401175 // ldr c21, [x11, #4]
	/* Set up flags and system registers */
	ldr x11, =0x0
	msr SPSR_EL3, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0x1c0000
	msr CPACR_EL1, x11
	ldr x11, =0x4
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x4
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =initial_DDC_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c412b // msr DDC_EL1, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260118b // ldr c11, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e402b // msr CELR_EL3, c11
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x12, #0xf
	and x11, x11, x12
	cmp x11, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240016c // ldr c12, [x11, #0]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc240056c // ldr c12, [x11, #1]
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	.inst 0xc240096c // ldr c12, [x11, #2]
	.inst 0xc2cca541 // chkeq c10, c12
	b.ne comparison_fail
	.inst 0xc2400d6c // ldr c12, [x11, #3]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc240116c // ldr c12, [x11, #4]
	.inst 0xc2cca6a1 // chkeq c21, c12
	b.ne comparison_fail
	.inst 0xc240156c // ldr c12, [x11, #5]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x12, v0.d[0]
	cmp x11, x12
	b.ne comparison_fail
	ldr x11, =0x0
	mov x12, v0.d[1]
	cmp x11, x12
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	ldr x12, =esr_el1_dump_address
	ldr x12, [x12]
	mov x11, 0x83
	orr x12, x12, x11
	ldr x11, =0x920000e3
	cmp x11, x12
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
	ldr x0, =0x000014b0
	ldr x1, =check_data1
	ldr x2, =0x000014c0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f60
	ldr x1, =check_data2
	ldr x2, =0x00001f70
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
	ldr x0, =0x40400100
	ldr x1, =check_data4
	ldr x2, =0x40400101
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40401400
	ldr x1, =check_data5
	ldr x2, =0x40401414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40401420
	ldr x1, =check_data6
	ldr x2, =0x40401422
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x3d, 0xc0, 0xbf, 0x38, 0x3e, 0x40, 0xe6, 0x79, 0x5e, 0xfe, 0x5f, 0x42, 0xa1, 0x03, 0x0e, 0x1a
	.byte 0xb3, 0x7f, 0x1e, 0x78
.data
check_data4:
	.byte 0x80
.data
check_data5:
	.byte 0x3e, 0x44, 0xc8, 0xc2, 0xa0, 0x2a, 0xdf, 0x3d, 0x47, 0x89, 0x60, 0x82, 0xbf, 0xd6, 0x21, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40400100
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x80000000600000010000000000000fe0
	/* C18 */
	.octa 0x1000
	/* C21 */
	.octa 0xffffffffffff880c
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x80000000600000010000000000000fe0
	/* C18 */
	.octa 0x1000
	/* C21 */
	.octa 0xffffffffffff880c
	/* C29 */
	.octa 0x80
initial_DDC_EL0_value:
	.octa 0xc0100000000300070000000000000000
initial_DDC_EL1_value:
	.octa 0xc00000005f8210040000000000000000
initial_VBAR_EL1_value:
	.octa 0x20008000544004550000000040401000
final_PCC_value:
	.octa 0x20008000544004550000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40401414
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x021e016b // add c11, c11, #1920
	.inst 0xc2c21160 // br c11

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
