.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bfc03d // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:29 Rn:1 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x79e6403e // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:1 imm12:100110010000 opc:11 111001:111001 size:01
	.inst 0x425ffe5e // LDAR-C.R-C Ct:30 Rn:18 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x1a0e03a1 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:29 000000:000000 Rm:14 11010000:11010000 S:0 op:0 sf:0
	.inst 0x781e7fb3 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:19 Rn:29 11:11 imm9:111100111 0:0 opc:00 111000:111000 size:01
	.zero 4344
	.inst 0x00000080
	.zero 8944
	.inst 0xc2c8443e // 0xc2c8443e
	.inst 0x3ddf2aa0 // 0x3ddf2aa0
	.inst 0x82608947 // 0x82608947
	.inst 0xc221d6bf // 0xc221d6bf
	.inst 0xd4000001
	.zero 52204
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
	ldr x12, =initial_cap_values
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc2400588 // ldr c8, [x12, #1]
	.inst 0xc240098a // ldr c10, [x12, #2]
	.inst 0xc2400d92 // ldr c18, [x12, #3]
	.inst 0xc2401195 // ldr c21, [x12, #4]
	/* Set up flags and system registers */
	ldr x12, =0x0
	msr SPSR_EL3, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30d5d99f
	msr SCTLR_EL1, x12
	ldr x12, =0x3c0000
	msr CPACR_EL1, x12
	ldr x12, =0x4
	msr S3_0_C1_C2_2, x12 // CCTLR_EL1
	ldr x12, =0x4
	msr S3_3_C1_C2_2, x12 // CCTLR_EL0
	ldr x12, =initial_DDC_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc288412c // msr DDC_EL0, c12
	ldr x12, =initial_DDC_EL1_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc28c412c // msr DDC_EL1, c12
	ldr x12, =0x80000000
	msr HCR_EL2, x12
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260136c // ldr c12, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e402c // msr CELR_EL3, c12
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x27, #0xf
	and x12, x12, x27
	cmp x12, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240019b // ldr c27, [x12, #0]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc240059b // ldr c27, [x12, #1]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc240099b // ldr c27, [x12, #2]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc2400d9b // ldr c27, [x12, #3]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240119b // ldr c27, [x12, #4]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc240159b // ldr c27, [x12, #5]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x27, v0.d[0]
	cmp x12, x27
	b.ne comparison_fail
	ldr x12, =0x0
	mov x27, v0.d[1]
	cmp x12, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x12, =final_PCC_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x12, 0x83
	orr x27, x27, x12
	ldr x12, =0x920000eb
	cmp x12, x27
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
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001070
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b10
	ldr x1, =check_data2
	ldr x2, =0x00001b20
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
	ldr x0, =0x4040001c
	ldr x1, =check_data4
	ldr x2, =0x40400020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040110c
	ldr x1, =check_data5
	ldr x2, =0x4040110d
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040242c
	ldr x1, =check_data6
	ldr x2, =0x4040242e
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40403400
	ldr x1, =check_data7
	ldr x2, =0x40403414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
	.zero 4
.data
check_data5:
	.byte 0x80
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0x3e, 0x44, 0xc8, 0xc2, 0xa0, 0x2a, 0xdf, 0x3d, 0x47, 0x89, 0x60, 0x82, 0xbf, 0xd6, 0x21, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4040110c
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x800000006000000400000000403ffffc
	/* C18 */
	.octa 0x1000
	/* C21 */
	.octa 0xffffffffffff93c0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x800000006000000400000000403ffffc
	/* C18 */
	.octa 0x1000
	/* C21 */
	.octa 0xffffffffffff93c0
	/* C29 */
	.octa 0x80
initial_DDC_EL0_value:
	.octa 0x80100000020500070000000000000001
initial_DDC_EL1_value:
	.octa 0xc000000074120000000000000000c001
initial_VBAR_EL1_value:
	.octa 0x200080004000241d0000000040403000
final_PCC_value:
	.octa 0x200080004000241d0000000040403414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000060080000000040400000
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
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x0200018c // add c12, c12, #0
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x0202018c // add c12, c12, #128
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x0204018c // add c12, c12, #256
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x0206018c // add c12, c12, #384
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x0208018c // add c12, c12, #512
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x020a018c // add c12, c12, #640
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x020c018c // add c12, c12, #768
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x020e018c // add c12, c12, #896
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x0210018c // add c12, c12, #1024
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x0212018c // add c12, c12, #1152
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x0214018c // add c12, c12, #1280
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x0216018c // add c12, c12, #1408
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x0218018c // add c12, c12, #1536
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x021a018c // add c12, c12, #1664
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x021c018c // add c12, c12, #1792
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x82600f6c // ldr x12, [c27, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400f6c // str x12, [c27, #0]
	ldr x12, =0x40403414
	mrs x27, ELR_EL1
	sub x12, x12, x27
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b19b // cvtp c27, x12
	.inst 0xc2cc437b // scvalue c27, c27, x12
	.inst 0x8260036c // ldr c12, [c27, #0]
	.inst 0x021e018c // add c12, c12, #1920
	.inst 0xc2c21180 // br c12

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
