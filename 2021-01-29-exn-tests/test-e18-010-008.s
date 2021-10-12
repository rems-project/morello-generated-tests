.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2bf7d80 // CAS-C.R-C Ct:0 Rn:12 11111:11111 R:0 Cs:31 1:1 L:0 1:1 10100010:10100010
	.inst 0x48dffdc1 // ldarh:aarch64/instrs/memory/ordered Rt:1 Rn:14 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xd3773bde // ubfm:aarch64/instrs/integer/bitfield Rd:30 Rn:30 imms:001110 immr:110111 N:1 100110:100110 opc:10 sf:1
	.inst 0xb8604a60 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:0 Rn:19 10:10 S:0 option:010 Rm:0 1:1 opc:01 111000:111000 size:10
	.inst 0xc2bdacff // ADD-C.CRI-C Cd:31 Cn:7 imm3:011 option:101 Rm:29 11000010101:11000010101
	.inst 0xc2d127c1 // 0xc2d127c1
	.inst 0x7a5b6b26 // 0x7a5b6b26
	.inst 0xc2c5b25f // 0xc2c5b25f
	.inst 0x78a13000 // 0x78a13000
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400607 // ldr c7, [x16, #1]
	.inst 0xc2400a0c // ldr c12, [x16, #2]
	.inst 0xc2400e0e // ldr c14, [x16, #3]
	.inst 0xc2401211 // ldr c17, [x16, #4]
	.inst 0xc2401612 // ldr c18, [x16, #5]
	.inst 0xc2401a13 // ldr c19, [x16, #6]
	.inst 0xc2401e1d // ldr c29, [x16, #7]
	/* Set up flags and system registers */
	ldr x16, =0x10000000
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601150 // ldr c16, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	.inst 0xc240020a // ldr c10, [x16, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240060a // ldr c10, [x16, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a0a // ldr c10, [x16, #2]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc2400e0a // ldr c10, [x16, #3]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc240120a // ldr c10, [x16, #4]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc240160a // ldr c10, [x16, #5]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc2401a0a // ldr c10, [x16, #6]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc2401e0a // ldr c10, [x16, #7]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc240220a // ldr c10, [x16, #8]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc298410a // mrs c10, CSP_EL0
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001082
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001410
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	.byte 0x80, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x80, 0x10, 0x00, 0x00
.data
check_data1:
	.byte 0xff, 0xff
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x80, 0x7d, 0xbf, 0xa2, 0xc1, 0xfd, 0xdf, 0x48, 0xde, 0x3b, 0x77, 0xd3, 0x60, 0x4a, 0x60, 0xb8
	.byte 0xff, 0xac, 0xbd, 0xc2, 0xc1, 0x27, 0xd1, 0xc2, 0x26, 0x6b, 0x5b, 0x7a, 0x5f, 0xb2, 0xc5, 0xc2
	.byte 0x00, 0x30, 0xa1, 0x78, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C7 */
	.octa 0x4000c000ec7fffffffffc000
	/* C12 */
	.octa 0x1400
	/* C14 */
	.octa 0x1002
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x1
	/* C19 */
	.octa 0x0
	/* C29 */
	.octa 0x1663
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffffffffffffff
	/* C7 */
	.octa 0x4000c000ec7fffffffffc000
	/* C12 */
	.octa 0x1400
	/* C14 */
	.octa 0x1002
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x1
	/* C19 */
	.octa 0x0
	/* C29 */
	.octa 0x1663
initial_DDC_EL0_value:
	.octa 0xd0000000080b000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x4000c000ec80000000007318
final_PCC_value:
	.octa 0x20008000000000000000000040400028
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
	.dword el1_vector_jump_cap
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
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
