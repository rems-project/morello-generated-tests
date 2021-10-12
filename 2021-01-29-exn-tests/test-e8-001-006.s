.section text0, #alloc, #execinstr
test_start:
	.inst 0x2b3ba01f // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:0 imm3:000 option:101 Rm:27 01011001:01011001 S:1 op:0 sf:0
	.inst 0xa218367e // STR-C.RIAW-C Ct:30 Rn:19 01:01 imm9:110000011 0:0 opc:00 10100010:10100010
	.inst 0xb884df7f // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:27 11:11 imm9:001001101 0:0 opc:10 111000:111000 size:10
	.inst 0x3991943e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:1 imm12:010001100101 opc:10 111001:111001 size:00
	.inst 0xf86013df // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:001 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.zero 1004
	.inst 0xc2c16406 // 0xc2c16406
	.inst 0x383e00bf // 0x383e00bf
	.inst 0x5ac01401 // 0x5ac01401
	.inst 0x428f8680 // 0x428f8680
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
	.inst 0xc2400945 // ldr c5, [x10, #2]
	.inst 0xc2400d53 // ldr c19, [x10, #3]
	.inst 0xc2401154 // ldr c20, [x10, #4]
	.inst 0xc240155b // ldr c27, [x10, #5]
	.inst 0xc240195e // ldr c30, [x10, #6]
	/* Set up flags and system registers */
	ldr x10, =0x0
	msr SPSR_EL3, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0xc0000
	msr CPACR_EL1, x10
	ldr x10, =0x4
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
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260138a // ldr c10, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x28, #0xf
	and x10, x10, x28
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240015c // ldr c28, [x10, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240055c // ldr c28, [x10, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240095c // ldr c28, [x10, #2]
	.inst 0xc2dca4a1 // chkeq c5, c28
	b.ne comparison_fail
	.inst 0xc2400d5c // ldr c28, [x10, #3]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc240115c // ldr c28, [x10, #4]
	.inst 0xc2dca661 // chkeq c19, c28
	b.ne comparison_fail
	.inst 0xc240155c // ldr c28, [x10, #5]
	.inst 0xc2dca681 // chkeq c20, c28
	b.ne comparison_fail
	.inst 0xc240195c // ldr c28, [x10, #6]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc2401d5c // ldr c28, [x10, #7]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc298403c // mrs c28, CELR_EL1
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	ldr x28, =esr_el1_dump_address
	ldr x28, [x28]
	mov x10, 0x83
	orr x28, x28, x10
	ldr x10, =0x920000a3
	cmp x10, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100a
	ldr x1, =check_data0
	ldr x2, =0x0000100b
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001130
	ldr x1, =check_data2
	ldr x2, =0x00001134
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001576
	ldr x1, =check_data3
	ldr x2, =0x00001577
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001810
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
	.zero 1392
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2688
.data
check_data0:
	.byte 0x01
.data
check_data1:
	.byte 0x81, 0x7e, 0x01, 0x00, 0x00, 0x00, 0x10, 0x10, 0x07, 0x00, 0x06, 0x20, 0x00, 0x00, 0x08, 0x40
	.byte 0x0e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x01
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1e, 0x25
.data
check_data5:
	.byte 0x1f, 0xa0, 0x3b, 0x2b, 0x7e, 0x36, 0x18, 0xa2, 0x7f, 0xdf, 0x84, 0xb8, 0x3e, 0x94, 0x91, 0x39
	.byte 0xdf, 0x13, 0x60, 0xf8
.data
check_data6:
	.byte 0x06, 0x64, 0xc1, 0xc2, 0xbf, 0x00, 0x3e, 0x38, 0x01, 0x14, 0xc0, 0x5a, 0x80, 0x86, 0x8f, 0x42
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40080000200600071010000000017e81
	/* C1 */
	.octa 0x1111
	/* C5 */
	.octa 0x100a
	/* C19 */
	.octa 0x1800
	/* C20 */
	.octa 0xe20
	/* C27 */
	.octa 0x10e3
	/* C30 */
	.octa 0x251e0000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40080000200600071010000000017e81
	/* C1 */
	.octa 0xe
	/* C5 */
	.octa 0x100a
	/* C6 */
	.octa 0x40080000200600070000000000001111
	/* C19 */
	.octa 0x1030
	/* C20 */
	.octa 0xe20
	/* C27 */
	.octa 0x1130
	/* C30 */
	.octa 0x1
initial_DDC_EL0_value:
	.octa 0xcc0000005901000000ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xcc000000063005780000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400000
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
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
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x82600f8a // ldr x10, [c28, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f8a // str x10, [c28, #0]
	ldr x10, =0x40400414
	mrs x28, ELR_EL1
	sub x10, x10, x28
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15c // cvtp c28, x10
	.inst 0xc2ca439c // scvalue c28, c28, x10
	.inst 0x8260038a // ldr c10, [c28, #0]
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
