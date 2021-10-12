.section text0, #alloc, #execinstr
test_start:
	.inst 0x1224d7f2 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:18 Rn:31 imms:110101 immr:100100 N:0 100100:100100 opc:00 sf:0
	.inst 0xd125a426 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:6 Rn:1 imm12:100101101001 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x889ffc64 // stlr:aarch64/instrs/memory/ordered Rt:4 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c411df // LDPBR-C.C-C Ct:31 Cn:14 100:100 opc:00 11000010110001000:11000010110001000
	.zero 32992
	.inst 0xd4000001
	.zero 16212
	.inst 0x08017c18 // stxrb:aarch64/instrs/memory/exclusive/single Rt:24 Rn:0 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:00
	.inst 0xb99e6496 // 0xb99e6496
	.inst 0xc2c6c10c // 0xc2c6c10c
	.inst 0x427f7c81 // 0x427f7c81
	.inst 0xc2c433b5 // 0xc2c433b5
	.zero 16292
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a3 // ldr c3, [x13, #1]
	.inst 0xc24009a4 // ldr c4, [x13, #2]
	.inst 0xc2400da8 // ldr c8, [x13, #3]
	.inst 0xc24011ae // ldr c14, [x13, #4]
	.inst 0xc24015bd // ldr c29, [x13, #5]
	/* Set up flags and system registers */
	ldr x13, =0x0
	msr SPSR_EL3, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0xc0000
	msr CPACR_EL1, x13
	ldr x13, =0x0
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =0x80
	msr S3_3_C1_C2_2, x13 // CCTLR_EL0
	ldr x13, =initial_DDC_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc288412d // msr DDC_EL0, c13
	ldr x13, =0x80000000
	msr HCR_EL2, x13
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260138d // ldr c13, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc28e402d // msr CELR_EL3, c13
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x28, #0xf
	and x13, x13, x28
	cmp x13, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001bc // ldr c28, [x13, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24005bc // ldr c28, [x13, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc24009bc // ldr c28, [x13, #2]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc2400dbc // ldr c28, [x13, #3]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc24011bc // ldr c28, [x13, #4]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc24015bc // ldr c28, [x13, #5]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc24019bc // ldr c28, [x13, #6]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc2401dbc // ldr c28, [x13, #7]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc24021bc // ldr c28, [x13, #8]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc24025bc // ldr c28, [x13, #9]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc24029bc // ldr c28, [x13, #10]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc2402dbc // ldr c28, [x13, #11]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc298403c // mrs c28, CELR_EL1
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001204
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001820
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fc0
	ldr x1, =check_data3
	ldr x2, =0x00001fe0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x404000f8
	ldr x1, =check_data5
	ldr x2, =0x404000f9
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40401f5c
	ldr x1, =check_data6
	ldr x2, =0x40401f60
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x404080f0
	ldr x1, =check_data7
	ldr x2, =0x404080f4
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x4040c048
	ldr x1, =check_data8
	ldr x2, =0x4040c05c
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
	.zero 2064
	.byte 0x49, 0xc0, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x1b, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 1952
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x02, 0x00, 0x00
	.byte 0xf0, 0x80, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0xc1, 0x00, 0x80, 0x00, 0x20
	.zero 32
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xf8, 0x00, 0x40, 0x40
.data
check_data2:
	.zero 16
	.byte 0x49, 0xc0, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x1b, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x02, 0x00, 0x00
	.byte 0xf0, 0x80, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0xc1, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.byte 0xf2, 0xd7, 0x24, 0x12, 0x26, 0xa4, 0x25, 0xd1, 0x64, 0xfc, 0x9f, 0x88, 0xdf, 0x11, 0xc4, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 4
.data
check_data7:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data8:
	.byte 0x18, 0x7c, 0x01, 0x08, 0x96, 0x64, 0x9e, 0xb9, 0x0c, 0xc1, 0xc6, 0xc2, 0x81, 0x7c, 0x7f, 0x42
	.byte 0xb5, 0x33, 0xc4, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000009c0050000000000001000
	/* C3 */
	.octa 0x1200
	/* C4 */
	.octa 0x800000000001000500000000404000f8
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000000600020000000000001800
	/* C29 */
	.octa 0x900000005f9c1fb80000000000001fc0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400000000009c0050000000000001000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1200
	/* C4 */
	.octa 0x800000000001000500000000404000f8
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000000600020000000000001800
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x201800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x900000005f9c1fb80000000000001fc0
	/* C30 */
	.octa 0x20008000801b0003000000004040c05d
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080004100800800000000404080f4
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
	.dword 0x0000000000001800
	.dword 0x0000000000001810
	.dword 0x0000000000001fc0
	.dword 0x0000000000001fd0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword initial_DDC_EL0_value
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
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x404080f4
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021e01ad // add c13, c13, #1920
	.inst 0xc2c211a0 // br c13

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
