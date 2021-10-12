.section text0, #alloc, #execinstr
test_start:
	.inst 0x38a00376 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:27 00:00 opc:000 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xdac007b9 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:25 Rn:29 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xdac0143f // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:31 Rn:1 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x78107824 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:4 Rn:1 10:10 imm9:100000111 0:0 opc:00 111000:111000 size:01
	.inst 0xe2c3d07e // ASTUR-R.RI-64 Rt:30 Rn:3 op2:00 imm9:000111101 V:0 op1:11 11100010:11100010
	.zero 1004
	.inst 0x782d60bf // 0x782d60bf
	.inst 0xe24a2c17 // 0xe24a2c17
	.inst 0xb789c64d // 0xb789c64d
	.zero 14532
	.inst 0xa25ecaa5 // 0xa25ecaa5
	.inst 0xd4000001
	.zero 49960
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
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400983 // ldr c3, [x12, #2]
	.inst 0xc2400d84 // ldr c4, [x12, #3]
	.inst 0xc2401185 // ldr c5, [x12, #4]
	.inst 0xc240158d // ldr c13, [x12, #5]
	.inst 0xc2401995 // ldr c21, [x12, #6]
	.inst 0xc2401d9b // ldr c27, [x12, #7]
	/* Set up flags and system registers */
	ldr x12, =0x0
	msr SPSR_EL3, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30d5d99f
	msr SCTLR_EL1, x12
	ldr x12, =0xc0000
	msr CPACR_EL1, x12
	ldr x12, =0x4
	msr S3_0_C1_C2_2, x12 // CCTLR_EL1
	ldr x12, =0x0
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
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x8260104c // ldr c12, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400182 // ldr c2, [x12, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400982 // ldr c2, [x12, #2]
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	.inst 0xc2400d82 // ldr c2, [x12, #3]
	.inst 0xc2c2a481 // chkeq c4, c2
	b.ne comparison_fail
	.inst 0xc2401182 // ldr c2, [x12, #4]
	.inst 0xc2c2a4a1 // chkeq c5, c2
	b.ne comparison_fail
	.inst 0xc2401582 // ldr c2, [x12, #5]
	.inst 0xc2c2a5a1 // chkeq c13, c2
	b.ne comparison_fail
	.inst 0xc2401982 // ldr c2, [x12, #6]
	.inst 0xc2c2a6a1 // chkeq c21, c2
	b.ne comparison_fail
	.inst 0xc2401d82 // ldr c2, [x12, #7]
	.inst 0xc2c2a6c1 // chkeq c22, c2
	b.ne comparison_fail
	.inst 0xc2402182 // ldr c2, [x12, #8]
	.inst 0xc2c2a6e1 // chkeq c23, c2
	b.ne comparison_fail
	.inst 0xc2402582 // ldr c2, [x12, #9]
	.inst 0xc2c2a761 // chkeq c27, c2
	b.ne comparison_fail
	/* Check system registers */
	ldr x12, =final_PCC_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a581 // chkeq c12, c2
	b.ne comparison_fail
	ldr x2, =esr_el1_dump_address
	ldr x2, [x2]
	mov x12, 0x83
	orr x2, x2, x12
	ldr x12, =0x920000eb
	cmp x12, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001084
	ldr x1, =check_data2
	ldr x2, =0x00001086
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
	ldr x0, =0x404000a2
	ldr x1, =check_data4
	ldr x2, =0x404000a4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x4040040c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40403cd0
	ldr x1, =check_data6
	ldr x2, =0x40403cd8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 64
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00
	.zero 4016
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x80
.data
check_data3:
	.byte 0x76, 0x03, 0xa0, 0x38, 0xb9, 0x07, 0xc0, 0xda, 0x3f, 0x14, 0xc0, 0xda, 0x24, 0x78, 0x10, 0x78
	.byte 0x7e, 0xd0, 0xc3, 0xe2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xbf, 0x60, 0x2d, 0x78, 0x17, 0x2c, 0x4a, 0xe2, 0x4d, 0xc6, 0x89, 0xb7
.data
check_data6:
	.byte 0xa5, 0xca, 0x5e, 0xa2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000
	/* C1 */
	.octa 0x10f9
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0xc00000004004008a0000000000001084
	/* C13 */
	.octa 0x2000000008000
	/* C21 */
	.octa 0x90000000000500070000000000001180
	/* C27 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400000
	/* C1 */
	.octa 0x10f9
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x10000000000000000000000000
	/* C13 */
	.octa 0x2000000008000
	/* C21 */
	.octa 0x90000000000500070000000000001180
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc0000000000180060080000000000000
initial_DDC_EL1_value:
	.octa 0x80000000000540070000000080004001
initial_VBAR_EL1_value:
	.octa 0x200080007cd800ed0000000040400001
final_PCC_value:
	.octa 0x200080007cd800ed0000000040403cd8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000244000480000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001040
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 96
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
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x0200018c // add c12, c12, #0
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x0202018c // add c12, c12, #128
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x0204018c // add c12, c12, #256
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x0206018c // add c12, c12, #384
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x0208018c // add c12, c12, #512
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x020a018c // add c12, c12, #640
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x020c018c // add c12, c12, #768
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x020e018c // add c12, c12, #896
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x0210018c // add c12, c12, #1024
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x0212018c // add c12, c12, #1152
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x0214018c // add c12, c12, #1280
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x0216018c // add c12, c12, #1408
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x0218018c // add c12, c12, #1536
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x021a018c // add c12, c12, #1664
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
	.inst 0x021c018c // add c12, c12, #1792
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x82600c4c // ldr x12, [c2, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400c4c // str x12, [c2, #0]
	ldr x12, =0x40403cd8
	mrs x2, ELR_EL1
	sub x12, x12, x2
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b182 // cvtp c2, x12
	.inst 0xc2cc4042 // scvalue c2, c2, x12
	.inst 0x8260004c // ldr c12, [c2, #0]
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
