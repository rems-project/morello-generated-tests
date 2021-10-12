.section text0, #alloc, #execinstr
test_start:
	.inst 0x386033ba // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:29 00:00 opc:011 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x82705d21 // ALDR-R.RI-64 Rt:1 Rn:9 op:11 imm9:100000101 L:1 1000001001:1000001001
	.inst 0x225f7e5e // LDXR-C.R-C Ct:30 Rn:18 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xe219f7bf // ALDURB-R.RI-32 Rt:31 Rn:29 op2:01 imm9:110011111 V:0 op1:00 11100010:11100010
	.inst 0xa2e383b8 // SWPAL-CC.R-C Ct:24 Rn:29 100000:100000 Cs:3 1:1 R:1 A:1 10100010:10100010
	.zero 1004
	.inst 0x78cb4bc5 // 0x78cb4bc5
	.inst 0x787d337e // 0x787d337e
	.inst 0xfc54769e // 0xfc54769e
	.inst 0x782003bf // 0x782003bf
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400603 // ldr c3, [x16, #1]
	.inst 0xc2400a09 // ldr c9, [x16, #2]
	.inst 0xc2400e12 // ldr c18, [x16, #3]
	.inst 0xc2401214 // ldr c20, [x16, #4]
	.inst 0xc240161b // ldr c27, [x16, #5]
	.inst 0xc2401a1d // ldr c29, [x16, #6]
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x1c0000
	msr CPACR_EL1, x16
	ldr x16, =0x4
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =initial_DDC_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4130 // msr DDC_EL1, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82601270 // ldr c16, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400213 // ldr c19, [x16, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400613 // ldr c19, [x16, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400a13 // ldr c19, [x16, #2]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2400e13 // ldr c19, [x16, #3]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc2401213 // ldr c19, [x16, #4]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc2401613 // ldr c19, [x16, #5]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2401a13 // ldr c19, [x16, #6]
	.inst 0xc2d3a681 // chkeq c20, c19
	b.ne comparison_fail
	.inst 0xc2401e13 // ldr c19, [x16, #7]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2402213 // ldr c19, [x16, #8]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc2402613 // ldr c19, [x16, #9]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2402a13 // ldr c19, [x16, #10]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x19, v30.d[0]
	cmp x16, x19
	b.ne comparison_fail
	ldr x16, =0x0
	mov x19, v30.d[1]
	cmp x16, x19
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984033 // mrs c19, CELR_EL1
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	mov x16, 0x83
	orr x19, x19, x16
	ldr x16, =0x920000a3
	cmp x16, x19
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
	ldr x0, =0x0000179b
	ldr x1, =check_data1
	ldr x2, =0x0000179c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017fc
	ldr x1, =check_data2
	ldr x2, =0x000017fe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001828
	ldr x1, =check_data3
	ldr x2, =0x00001830
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fa0
	ldr x1, =check_data4
	ldr x2, =0x00001fb0
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
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040fff0
	ldr x1, =check_data7
	ldr x2, =0x4040fff8
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x4040fffc
	ldr x1, =check_data8
	ldr x2, =0x4040fffe
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.byte 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3984
	.byte 0x48, 0xff, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 80
.data
check_data0:
	.byte 0xfc, 0x1f
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x48, 0xff, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0xba, 0x33, 0x60, 0x38, 0x21, 0x5d, 0x70, 0x82, 0x5e, 0x7e, 0x5f, 0x22, 0xbf, 0xf7, 0x19, 0xe2
	.byte 0xb8, 0x83, 0xe3, 0xa2
.data
check_data6:
	.byte 0xc5, 0x4b, 0xcb, 0x78, 0x7e, 0x33, 0x7d, 0x78, 0x9e, 0x76, 0x54, 0xfc, 0xbf, 0x03, 0x20, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 8
.data
check_data8:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x80000000400100040000000000001000
	/* C18 */
	.octa 0x1fa0
	/* C20 */
	.octa 0x4040fff0
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x800000000001000500000000000017fc
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x80000000400100040000000000001000
	/* C18 */
	.octa 0x1fa0
	/* C20 */
	.octa 0x4040ff37
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x800000000001000500000000000017fc
	/* C30 */
	.octa 0x800
initial_DDC_EL0_value:
	.octa 0xd0100000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080006400e41d0000000040400000
final_PCC_value:
	.octa 0x200080006400e41d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 144
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600e70 // ldr x16, [c19, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e70 // str x16, [c19, #0]
	ldr x16, =0x40400414
	mrs x19, ELR_EL1
	sub x16, x16, x19
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b213 // cvtp c19, x16
	.inst 0xc2d04273 // scvalue c19, c19, x16
	.inst 0x82600270 // ldr c16, [c19, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
