.section text0, #alloc, #execinstr
test_start:
	.inst 0x383013be // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:29 00:00 opc:001 0:0 Rs:16 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xf9392053 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:19 Rn:2 imm12:111001001000 opc:00 111001:111001 size:11
	.inst 0x7812e3e7 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:7 Rn:31 00:00 imm9:100101110 0:0 opc:00 111000:111000 size:01
	.inst 0xc2dee008 // SCFLGS-C.CR-C Cd:8 Cn:0 111000:111000 Rm:30 11000010110:11000010110
	.inst 0xa97c483f // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:1 Rt2:10010 imm7:1111000 L:1 1010010:1010010 opc:10
	.zero 1004
	.inst 0xe24abe1f // 0xe24abe1f
	.inst 0x02985014 // 0x2985014
	.inst 0xb8b783a8 // 0xb8b783a8
	.inst 0xc2080261 // STR-C.RIB-C Ct:1 Rn:19 imm12:001000000000 L:0 110000100:110000100
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400882 // ldr c2, [x4, #2]
	.inst 0xc2400c87 // ldr c7, [x4, #3]
	.inst 0xc2401090 // ldr c16, [x4, #4]
	.inst 0xc2401493 // ldr c19, [x4, #5]
	.inst 0xc2401897 // ldr c23, [x4, #6]
	.inst 0xc2401c9d // ldr c29, [x4, #7]
	/* Set up flags and system registers */
	ldr x4, =0x0
	msr SPSR_EL3, x4
	ldr x4, =initial_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884104 // msr CSP_EL0, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0xc0000
	msr CPACR_EL1, x4
	ldr x4, =0x4
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =0x0
	msr S3_3_C1_C2_2, x4 // CCTLR_EL0
	ldr x4, =initial_DDC_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884124 // msr DDC_EL0, c4
	ldr x4, =initial_DDC_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc28c4124 // msr DDC_EL1, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010a4 // ldr c4, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc28e4024 // msr CELR_EL3, c4
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400085 // ldr c5, [x4, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400485 // ldr c5, [x4, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400885 // ldr c5, [x4, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400c85 // ldr c5, [x4, #3]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2401085 // ldr c5, [x4, #4]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2401485 // ldr c5, [x4, #5]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc2401885 // ldr c5, [x4, #6]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2401c85 // ldr c5, [x4, #7]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc2402085 // ldr c5, [x4, #8]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2402485 // ldr c5, [x4, #9]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402885 // ldr c5, [x4, #10]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984105 // mrs c5, CSP_EL0
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x4, 0x83
	orr x5, x5, x4
	ldr x4, =0x920000a3
	cmp x4, x5
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
	ldr x0, =0x0000110e
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fac
	ldr x1, =check_data2
	ldr x2, =0x00001fae
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
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
	.byte 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x21
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xbe, 0x13, 0x30, 0x38, 0x53, 0x20, 0x39, 0xf9, 0xe7, 0xe3, 0x12, 0x78, 0x08, 0xe0, 0xde, 0xc2
	.byte 0x3f, 0x48, 0x7c, 0xa9
.data
check_data4:
	.byte 0x1f, 0xbe, 0x4a, 0xe2, 0x14, 0x50, 0x98, 0x02, 0xa8, 0x83, 0xb7, 0xb8, 0x61, 0x02, 0x08, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc00020000000000000020000
	/* C1 */
	.octa 0x2100000000000000b00000000000000f
	/* C2 */
	.octa 0xffffffffffff9dc0
	/* C7 */
	.octa 0x0
	/* C16 */
	.octa 0x800000006004000a0000000000001f01
	/* C19 */
	.octa 0xfffffffffffff000
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc00020000000000000020000
	/* C1 */
	.octa 0x2100000000000000b00000000000000f
	/* C2 */
	.octa 0xffffffffffff9dc0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0xfffff000
	/* C16 */
	.octa 0x800000006004000a0000000000001f01
	/* C19 */
	.octa 0xfffffffffffff000
	/* C20 */
	.octa 0xc0002000000000000001f9ec
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0xfe
initial_SP_EL0_value:
	.octa 0x11e0
initial_DDC_EL0_value:
	.octa 0xc0000000000040000000000000000000
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080006000001d0000000040400000
final_SP_EL0_value:
	.octa 0x11e0
final_PCC_value:
	.octa 0x200080006000001d0000000040400414
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
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x82600ca4 // ldr x4, [c5, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ca4 // str x4, [c5, #0]
	ldr x4, =0x40400414
	mrs x5, ELR_EL1
	sub x4, x4, x5
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b085 // cvtp c5, x4
	.inst 0xc2c440a5 // scvalue c5, c5, x4
	.inst 0x826000a4 // ldr c4, [c5, #0]
	.inst 0x021e0084 // add c4, c4, #1920
	.inst 0xc2c21080 // br c4

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
