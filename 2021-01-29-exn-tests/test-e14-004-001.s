.section text0, #alloc, #execinstr
test_start:
	.inst 0xf2b682bd // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:29 imm16:1011010000010101 hw:01 100101:100101 opc:11 sf:1
	.inst 0xc2ee13fe // EORFLGS-C.CI-C Cd:30 Cn:31 0:0 10:10 imm8:01110000 11000010111:11000010111
	.inst 0xb83e33ff // stset:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:011 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x3865401f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:100 o3:0 Rs:5 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xb499d1f5 // cbz:aarch64/instrs/branch/conditional/compare Rt:21 imm19:1001100111010001111 op:0 011010:011010 sf:1
	.inst 0x9bbe8bdf // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:30 Ra:2 o0:1 Rm:30 01:01 U:1 10011011:10011011
	.inst 0x9a81c3c2 // csel:aarch64/instrs/integer/conditional/select Rd:2 Rn:30 o2:0 0:0 cond:1100 Rm:1 011010100:011010100 op:0 sf:1
	.inst 0x421f7ef9 // ASTLR-C.R-C Ct:25 Rn:23 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2c113b4 // GCLIM-R.C-C Rd:20 Cn:29 100:100 opc:00 11000010110000010:11000010110000010
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400765 // ldr c5, [x27, #1]
	.inst 0xc2400b75 // ldr c21, [x27, #2]
	.inst 0xc2400f77 // ldr c23, [x27, #3]
	.inst 0xc2401379 // ldr c25, [x27, #4]
	/* Set up flags and system registers */
	ldr x27, =0x80000000
	msr SPSR_EL3, x27
	ldr x27, =initial_SP_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288411b // msr CSP_EL0, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30d5d99f
	msr SCTLR_EL1, x27
	ldr x27, =0xc0000
	msr CPACR_EL1, x27
	ldr x27, =0x0
	msr S3_0_C1_C2_2, x27 // CCTLR_EL1
	ldr x27, =0x0
	msr S3_3_C1_C2_2, x27 // CCTLR_EL0
	ldr x27, =initial_DDC_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288413b // msr DDC_EL0, c27
	ldr x27, =0x80000000
	msr HCR_EL2, x27
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010db // ldr c27, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc28e403b // msr CELR_EL3, c27
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x6, #0x9
	and x27, x27, x6
	cmp x27, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400366 // ldr c6, [x27, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400766 // ldr c6, [x27, #1]
	.inst 0xc2c6a4a1 // chkeq c5, c6
	b.ne comparison_fail
	.inst 0xc2400b66 // ldr c6, [x27, #2]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2400f66 // ldr c6, [x27, #3]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc2401366 // ldr c6, [x27, #4]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2401766 // ldr c6, [x27, #5]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2401b66 // ldr c6, [x27, #6]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_SP_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984106 // mrs c6, CSP_EL0
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a761 // chkeq c27, c6
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
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x04, 0x80, 0x04, 0x00, 0x10, 0x01, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xbd, 0x82, 0xb6, 0xf2, 0xfe, 0x13, 0xee, 0xc2, 0xff, 0x33, 0x3e, 0xb8, 0x1f, 0x40, 0x65, 0x38
	.byte 0xf5, 0xd1, 0x99, 0xb4, 0xdf, 0x8b, 0xbe, 0x9b, 0xc2, 0xc3, 0x81, 0x9a, 0xf9, 0x7e, 0x1f, 0x42
	.byte 0xb4, 0x13, 0xc1, 0xc2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C5 */
	.octa 0x80
	/* C21 */
	.octa 0xffffffffffffffff
	/* C23 */
	.octa 0x40000000400400090000000000001000
	/* C25 */
	.octa 0x1100004800480000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C5 */
	.octa 0x80
	/* C20 */
	.octa 0xffffffffffffffff
	/* C21 */
	.octa 0xffffffffffffffff
	/* C23 */
	.octa 0x40000000400400090000000000001000
	/* C25 */
	.octa 0x1100004800480000000000000
	/* C30 */
	.octa 0x400000000007000000000001000
initial_SP_EL0_value:
	.octa 0x400000000000000000000001000
initial_DDC_EL0_value:
	.octa 0xc0000000500400060000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x400000000000000000000001000
final_PCC_value:
	.octa 0x20008000602000000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000602000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
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
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x0200037b // add c27, c27, #0
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x0202037b // add c27, c27, #128
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x0204037b // add c27, c27, #256
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x0206037b // add c27, c27, #384
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x0208037b // add c27, c27, #512
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x020a037b // add c27, c27, #640
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x020c037b // add c27, c27, #768
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x020e037b // add c27, c27, #896
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x0210037b // add c27, c27, #1024
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x0212037b // add c27, c27, #1152
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x0214037b // add c27, c27, #1280
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x0216037b // add c27, c27, #1408
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x0218037b // add c27, c27, #1536
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x021a037b // add c27, c27, #1664
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x021c037b // add c27, c27, #1792
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x82600cdb // ldr x27, [c6, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cdb // str x27, [c6, #0]
	ldr x27, =0x40400028
	mrs x6, ELR_EL1
	sub x27, x27, x6
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b366 // cvtp c6, x27
	.inst 0xc2db40c6 // scvalue c6, c6, x27
	.inst 0x826000db // ldr c27, [c6, #0]
	.inst 0x021e037b // add c27, c27, #1920
	.inst 0xc2c21360 // br c27

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
