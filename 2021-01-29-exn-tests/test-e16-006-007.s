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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2400d53 // ldr c19, [x10, #3]
	.inst 0xc240115d // ldr c29, [x10, #4]
	/* Set up flags and system registers */
	ldr x10, =0x4000000
	msr SPSR_EL3, x10
	ldr x10, =initial_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288410a // msr CSP_EL0, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0x3c0000
	msr CPACR_EL1, x10
	ldr x10, =0x0
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x4
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =initial_DDC_EL1_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc28c412a // msr DDC_EL1, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260108a // ldr c10, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc28e402a // msr CELR_EL3, c10
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400144 // ldr c4, [x10, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400544 // ldr c4, [x10, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400944 // ldr c4, [x10, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400d44 // ldr c4, [x10, #3]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2401144 // ldr c4, [x10, #4]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc2401544 // ldr c4, [x10, #5]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc2401944 // ldr c4, [x10, #6]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984104 // mrs c4, CSP_EL0
	.inst 0xc2c4a541 // chkeq c10, c4
	b.ne comparison_fail
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a541 // chkeq c10, c4
	b.ne comparison_fail
	ldr x4, =esr_el1_dump_address
	ldr x4, [x4]
	mov x10, 0x83
	orr x4, x4, x10
	ldr x10, =0x920000eb
	cmp x10, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001011
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001640
	ldr x1, =check_data2
	ldr x2, =0x00001648
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
	ldr x0, =0x40403ffc
	ldr x1, =check_data6
	ldr x2, =0x40403ffe
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x01
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x10, 0xc7, 0xc2, 0xa0, 0xb3, 0xeb, 0x28, 0xe0, 0x63, 0x20, 0x38, 0x6c, 0xf6, 0x06, 0xf8
	.byte 0x1b, 0x40, 0x76, 0xe2
.data
check_data5:
	.byte 0xc0, 0xba, 0x81, 0x12, 0x5d, 0x30, 0x3f, 0x38, 0x26, 0xa4, 0x46, 0xe2, 0x5d, 0xab, 0x5f, 0xd8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x7e40ff0000000
	/* C1 */
	.octa 0x40403f92
	/* C2 */
	.octa 0xc0000000000100050000000000001ffe
	/* C19 */
	.octa 0x40000000400402450000000000001640
	/* C29 */
	.octa 0x80000000400010000000000000001004
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xfffff229
	/* C1 */
	.octa 0x40403f92
	/* C2 */
	.octa 0xc0000000000100050000000000001ffe
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C19 */
	.octa 0x400000004004024500000000000016af
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000000100050000000000001010
initial_DDC_EL0_value:
	.octa 0x740120000000000040000
initial_DDC_EL1_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004800cd010000000040400001
final_SP_EL0_value:
	.octa 0xc0000000000100050000000000001010
final_PCC_value:
	.octa 0x200080004800cd010000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000040400000
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x82600c8a // ldr x10, [c4, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c8a // str x10, [c4, #0]
	ldr x10, =0x40400414
	mrs x4, ELR_EL1
	sub x10, x10, x4
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b144 // cvtp c4, x10
	.inst 0xc2ca4084 // scvalue c4, c4, x10
	.inst 0x8260008a // ldr c10, [c4, #0]
	.inst 0x021e014a // add c10, c10, #1920
	.inst 0xc2c21140 // br c10

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
