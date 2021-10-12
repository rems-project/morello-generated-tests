.section text0, #alloc, #execinstr
test_start:
	.inst 0x38a00376 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:27 00:00 opc:000 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xdac007b9 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:25 Rn:29 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xdac0143f // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:31 Rn:1 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x78107824 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:4 Rn:1 10:10 imm9:100000111 0:0 opc:00 111000:111000 size:01
	.inst 0xe2c3d07e // ASTUR-R.RI-64 Rt:30 Rn:3 op2:00 imm9:000111101 V:0 op1:11 11100010:11100010
	.zero 35820
	.inst 0x782d60bf // 0x782d60bf
	.inst 0xe24a2c17 // 0xe24a2c17
	.inst 0xb789c64d // 0xb789c64d
	.inst 0xa25ecaa5 // 0xa25ecaa5
	.inst 0xd4000001
	.zero 29676
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
	.inst 0xc24008c3 // ldr c3, [x6, #2]
	.inst 0xc2400cc4 // ldr c4, [x6, #3]
	.inst 0xc24010c5 // ldr c5, [x6, #4]
	.inst 0xc24014cd // ldr c13, [x6, #5]
	.inst 0xc24018d5 // ldr c21, [x6, #6]
	.inst 0xc2401cdb // ldr c27, [x6, #7]
	/* Set up flags and system registers */
	ldr x6, =0x0
	msr SPSR_EL3, x6
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
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82601266 // ldr c6, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
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
	.inst 0xc24000d3 // ldr c19, [x6, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24004d3 // ldr c19, [x6, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc24008d3 // ldr c19, [x6, #2]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2400cd3 // ldr c19, [x6, #3]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc24010d3 // ldr c19, [x6, #4]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc24014d3 // ldr c19, [x6, #5]
	.inst 0xc2d3a5a1 // chkeq c13, c19
	b.ne comparison_fail
	.inst 0xc24018d3 // ldr c19, [x6, #6]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc2401cd3 // ldr c19, [x6, #7]
	.inst 0xc2d3a6c1 // chkeq c22, c19
	b.ne comparison_fail
	.inst 0xc24020d3 // ldr c19, [x6, #8]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc24024d3 // ldr c19, [x6, #9]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984033 // mrs c19, CELR_EL1
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	mov x6, 0x83
	orr x19, x19, x6
	ldr x6, =0x920000eb
	cmp x6, x19
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
	ldr x0, =0x00001d42
	ldr x1, =check_data2
	ldr x2, =0x00001d44
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ec0
	ldr x1, =check_data3
	ldr x2, =0x00001ed0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f20
	ldr x1, =check_data4
	ldr x2, =0x00001f22
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40408c00
	ldr x1, =check_data6
	ldr x2, =0x40408c14
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
	.byte 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x00, 0x80
.data
check_data1:
	.byte 0x60
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x76, 0x03, 0xa0, 0x38, 0xb9, 0x07, 0xc0, 0xda, 0x3f, 0x14, 0xc0, 0xda, 0x24, 0x78, 0x10, 0x78
	.byte 0x7e, 0xd0, 0xc3, 0xe2
.data
check_data6:
	.byte 0xbf, 0x60, 0x2d, 0x78, 0x17, 0x2c, 0x4a, 0xe2, 0x4d, 0xc6, 0x89, 0xb7, 0xa5, 0xca, 0x5e, 0xa2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000300070000000000001ca0
	/* C1 */
	.octa 0x2019
	/* C3 */
	.octa 0x400000007c0038049f82148000001fc8
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x1000
	/* C13 */
	.octa 0x8000
	/* C21 */
	.octa 0x2000
	/* C27 */
	.octa 0x1010
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000300070000000000001ca0
	/* C1 */
	.octa 0x2019
	/* C3 */
	.octa 0x400000007c0038049f82148000001fc8
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C13 */
	.octa 0x8000
	/* C21 */
	.octa 0x2000
	/* C22 */
	.octa 0xc0
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x1010
initial_DDC_EL0_value:
	.octa 0xc0000000002100050080000000000001
initial_DDC_EL1_value:
	.octa 0xd00000000401c0050000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080005000841d0000000040408800
final_PCC_value:
	.octa 0x200080005000841d0000000040408c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200020000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001ec0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
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
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600e66 // ldr x6, [c19, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e66 // str x6, [c19, #0]
	ldr x6, =0x40408c14
	mrs x19, ELR_EL1
	sub x6, x6, x19
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d3 // cvtp c19, x6
	.inst 0xc2c64273 // scvalue c19, c19, x6
	.inst 0x82600266 // ldr c6, [c19, #0]
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
