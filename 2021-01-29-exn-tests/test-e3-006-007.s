.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2cf23dc // SCBNDSE-C.CR-C Cd:28 Cn:30 000:000 opc:01 0:0 Rm:15 11000010110:11000010110
	.inst 0x421ffea1 // STLR-C.R-C Ct:1 Rn:21 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xcb5dffbe // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:29 imm6:111111 Rm:29 0:0 shift:01 01011:01011 S:0 op:1 sf:1
	.inst 0x085ffc1f // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:31 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xc89f7fde // stllr:aarch64/instrs/memory/ordered Rt:30 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x28a9c321 // 0x28a9c321
	.inst 0xc2bdcc08 // 0xc2bdcc08
	.inst 0x911ea411 // 0x911ea411
	.inst 0xc2d15bba // 0xc2d15bba
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400970 // ldr c16, [x11, #2]
	.inst 0xc2400d75 // ldr c21, [x11, #3]
	.inst 0xc2401179 // ldr c25, [x11, #4]
	.inst 0xc240157d // ldr c29, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
	/* Set up flags and system registers */
	ldr x11, =0x0
	msr SPSR_EL3, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0xc0000
	msr CPACR_EL1, x11
	ldr x11, =0x0
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x0
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260112b // ldr c11, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e402b // msr CELR_EL3, c11
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400169 // ldr c9, [x11, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400569 // ldr c9, [x11, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400969 // ldr c9, [x11, #2]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc2400d69 // ldr c9, [x11, #3]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401169 // ldr c9, [x11, #4]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2401569 // ldr c9, [x11, #5]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2401969 // ldr c9, [x11, #6]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2401d69 // ldr c9, [x11, #7]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc2402169 // ldr c9, [x11, #8]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402569 // ldr c9, [x11, #9]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a561 // chkeq c11, c9
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
	ldr x0, =0x40402008
	ldr x1, =check_data2
	ldr x2, =0x40402009
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
	.zero 16
.data
check_data1:
	.byte 0xdc, 0x23, 0xcf, 0xc2, 0xa1, 0xfe, 0x1f, 0x42, 0xbe, 0xff, 0x5d, 0xcb, 0x1f, 0xfc, 0x5f, 0x08
	.byte 0xde, 0x7f, 0x9f, 0xc8, 0x21, 0xc3, 0xa9, 0x28, 0x08, 0xcc, 0xbd, 0xc2, 0x11, 0xa4, 0x1e, 0x91
	.byte 0xba, 0x5b, 0xd1, 0xc2, 0x01, 0x00, 0x00, 0xd4
.data
check_data2:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8007e0070000000040402008
	/* C1 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C21 */
	.octa 0x1000
	/* C25 */
	.octa 0x1000
	/* C29 */
	.octa 0x880100070000000000001000
	/* C30 */
	.octa 0x300070000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x8007e0070000000040402008
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0x8007e007000000004040a008
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x404027b1
	/* C21 */
	.octa 0x1000
	/* C25 */
	.octa 0xf4c
	/* C26 */
	.octa 0x880100070000000400000000
	/* C29 */
	.octa 0x880100070000000000001000
	/* C30 */
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc000000020010005004088805444e001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000540070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000540070000000040400000
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40400028
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x021e016b // add c11, c11, #1920
	.inst 0xc2c21160 // br c11

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
