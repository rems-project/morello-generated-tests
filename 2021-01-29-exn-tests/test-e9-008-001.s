.section text0, #alloc, #execinstr
test_start:
	.inst 0xf821301e // ldset:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:0 00:00 opc:011 0:0 Rs:1 1:1 R:0 A:0 111000:111000 size:11
	.inst 0x8a97ebf2 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:18 Rn:31 imm6:111010 Rm:23 N:0 shift:10 01010:01010 opc:00 sf:1
	.inst 0x2aee765f // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:18 imm6:011101 Rm:14 N:1 shift:11 01010:01010 opc:01 sf:0
	.inst 0x7a0003ac // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:12 Rn:29 000000:000000 Rm:0 11010000:11010000 S:1 op:1 sf:0
	.inst 0xd4bfa0c3 // dcps3:aarch64/instrs/system/exceptions/debug/exception LL:11 000:000 imm16:1111110100000110 11010100101:11010100101
	.zero 1004
	.inst 0x82654d1e // ALDR-R.RI-64 Rt:30 Rn:8 op:11 imm9:001010100 L:1 1000001001:1000001001
	.inst 0xc2c102e8 // SCBNDS-C.CR-C Cd:8 Cn:23 000:000 opc:00 0:0 Rm:1 11000010110:11000010110
	.inst 0xea814c01 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:0 imm6:010011 Rm:1 N:0 shift:10 01010:01010 opc:11 sf:1
	.inst 0x1ac823ff // lslv:aarch64/instrs/integer/shift/variable Rd:31 Rn:31 op2:00 0010:0010 Rm:8 0011010110:0011010110 sf:0
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b48 // ldr c8, [x26, #2]
	.inst 0xc2400f57 // ldr c23, [x26, #3]
	/* Set up flags and system registers */
	ldr x26, =0x0
	msr SPSR_EL3, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0xc0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x4
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =initial_DDC_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc28c413a // msr DDC_EL1, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010da // ldr c26, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc28e403a // msr CELR_EL3, c26
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x6, #0xf
	and x26, x26, x6
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400346 // ldr c6, [x26, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400746 // ldr c6, [x26, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400b46 // ldr c6, [x26, #2]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2400f46 // ldr c6, [x26, #3]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2401346 // ldr c6, [x26, #4]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2401746 // ldr c6, [x26, #5]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x26, 0x0
	orr x6, x6, x26
	ldr x26, =0x2000000
	cmp x26, x6
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
	ldr x0, =0x00001ee0
	ldr x1, =check_data1
	ldr x2, =0x00001ee8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
	.byte 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x1e, 0x30, 0x21, 0xf8, 0xf2, 0xeb, 0x97, 0x8a, 0x5f, 0x76, 0xee, 0x2a, 0xac, 0x03, 0x00, 0x7a
	.byte 0xc3, 0xa0, 0xbf, 0xd4
.data
check_data3:
	.byte 0x1e, 0x4d, 0x65, 0x82, 0xe8, 0x02, 0xc1, 0xc2, 0x01, 0x4c, 0x81, 0xea, 0xff, 0x23, 0xc8, 0x1a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x80000000
	/* C8 */
	.octa 0x1c40
	/* C23 */
	.octa 0x400000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1000
	/* C8 */
	.octa 0x500060000000000000000
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0x400000000000000000000000
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc000000000300000000000410000f000
initial_DDC_EL1_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000d41d0000000040400001
final_PCC_value:
	.octa 0x200080005000d41d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000200070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x40400414
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x021e035a // add c26, c26, #1920
	.inst 0xc2c21340 // br c26

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
