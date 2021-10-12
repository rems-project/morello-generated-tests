.section text0, #alloc, #execinstr
test_start:
	.inst 0x2b3ba01f // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:0 imm3:000 option:101 Rm:27 01011001:01011001 S:1 op:0 sf:0
	.inst 0xa218367e // STR-C.RIAW-C Ct:30 Rn:19 01:01 imm9:110000011 0:0 opc:00 10100010:10100010
	.inst 0xb884df7f // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:27 11:11 imm9:001001101 0:0 opc:10 111000:111000 size:10
	.inst 0x3991943e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:1 imm12:010001100101 opc:10 111001:111001 size:00
	.inst 0xf86013df // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:001 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c16406 // 0xc2c16406
	.inst 0x383e00bf // 0x383e00bf
	.inst 0x5ac01401 // 0x5ac01401
	.inst 0x428f8680 // 0x428f8680
	.inst 0xd4000001
	.zero 65496
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba5 // ldr c5, [x29, #2]
	.inst 0xc2400fb3 // ldr c19, [x29, #3]
	.inst 0xc24013b4 // ldr c20, [x29, #4]
	.inst 0xc24017bb // ldr c27, [x29, #5]
	.inst 0xc2401bbe // ldr c30, [x29, #6]
	/* Set up flags and system registers */
	ldr x29, =0x0
	msr SPSR_EL3, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30d5d99f
	msr SCTLR_EL1, x29
	ldr x29, =0xc0000
	msr CPACR_EL1, x29
	ldr x29, =0x0
	msr S3_0_C1_C2_2, x29 // CCTLR_EL1
	ldr x29, =0x4
	msr S3_3_C1_C2_2, x29 // CCTLR_EL0
	ldr x29, =initial_DDC_EL0_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc288413d // msr DDC_EL0, c29
	ldr x29, =0x80000000
	msr HCR_EL2, x29
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260109d // ldr c29, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc28e403d // msr CELR_EL3, c29
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x4, #0xf
	and x29, x29, x4
	cmp x29, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003a4 // ldr c4, [x29, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24007a4 // ldr c4, [x29, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400ba4 // ldr c4, [x29, #2]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2400fa4 // ldr c4, [x29, #3]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc24013a4 // ldr c4, [x29, #4]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc24017a4 // ldr c4, [x29, #5]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc2401ba4 // ldr c4, [x29, #6]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2401fa4 // ldr c4, [x29, #7]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check system registers */
	ldr x29, =final_PCC_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001009
	ldr x1, =check_data1
	ldr x2, =0x0000100a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001090
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000145c
	ldr x1, =check_data3
	ldr x2, =0x00001460
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001520
	ldr x1, =check_data4
	ldr x2, =0x00001540
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001800
	ldr x1, =check_data5
	ldr x2, =0x00001801
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
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
	.byte 0xfd, 0x00, 0xff, 0xff, 0x00, 0xf7, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xfd, 0x00, 0xff, 0xff, 0x00, 0xf7, 0xff, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xbc, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd4, 0x87, 0x00, 0x00, 0x40, 0x00, 0x80, 0x01, 0x00
	.byte 0x15, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x1f, 0xa0, 0x3b, 0x2b, 0x7e, 0x36, 0x18, 0xa2, 0x7f, 0xdf, 0x84, 0xb8, 0x3e, 0x94, 0x91, 0x39
	.byte 0xdf, 0x13, 0x60, 0xf8, 0x06, 0x64, 0xc1, 0xc2, 0xbf, 0x00, 0x3e, 0x38, 0x01, 0x14, 0xc0, 0x5a
	.byte 0x80, 0x86, 0x8f, 0x42, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1800040000087d400000000000200
	/* C1 */
	.octa 0xfffffffffffffba4
	/* C5 */
	.octa 0x800
	/* C19 */
	.octa 0x80
	/* C20 */
	.octa 0x330
	/* C27 */
	.octa 0x40f
	/* C30 */
	.octa 0xbc0000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1800040000087d400000000000200
	/* C1 */
	.octa 0x15
	/* C5 */
	.octa 0x800
	/* C6 */
	.octa 0x1800040000087fffffffffffffba4
	/* C19 */
	.octa 0xfffffffffffff8b0
	/* C20 */
	.octa 0x330
	/* C27 */
	.octa 0x45c
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xcc00000006af040500ffffffffff9000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080000000a0100000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0100000000040400000
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
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x020003bd // add c29, c29, #0
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x020203bd // add c29, c29, #128
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x020403bd // add c29, c29, #256
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x020603bd // add c29, c29, #384
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x020803bd // add c29, c29, #512
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x020a03bd // add c29, c29, #640
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x020c03bd // add c29, c29, #768
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x020e03bd // add c29, c29, #896
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x021003bd // add c29, c29, #1024
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x021203bd // add c29, c29, #1152
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x021403bd // add c29, c29, #1280
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x021603bd // add c29, c29, #1408
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x021803bd // add c29, c29, #1536
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x021a03bd // add c29, c29, #1664
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x021c03bd // add c29, c29, #1792
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x82600c9d // ldr x29, [c4, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400c9d // str x29, [c4, #0]
	ldr x29, =0x40400028
	mrs x4, ELR_EL1
	sub x29, x29, x4
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3a4 // cvtp c4, x29
	.inst 0xc2dd4084 // scvalue c4, c4, x29
	.inst 0x8260009d // ldr c29, [c4, #0]
	.inst 0x021e03bd // add c29, c29, #1920
	.inst 0xc2c213a0 // br c29

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0