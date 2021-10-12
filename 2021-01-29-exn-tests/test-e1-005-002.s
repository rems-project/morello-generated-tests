.section text0, #alloc, #execinstr
test_start:
	.inst 0xe27483d2 // ASTUR-V.RI-H Rt:18 Rn:30 op2:00 imm9:101001000 V:1 op1:01 11100010:11100010
	.inst 0xe2dcefdd // ALDUR-C.RI-C Ct:29 Rn:30 op2:11 imm9:111001110 V:0 op1:11 11100010:11100010
	.inst 0x117727aa // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:10 Rn:29 imm12:110111001001 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0x827e40a0 // ALDR-C.RI-C Ct:0 Rn:5 op:00 imm9:111100100 L:1 1000001001:1000001001
	.inst 0x5067863f // ADR-C.I-C Rd:31 immhi:110011110000110001 P:0 10000:10000 immlo:10 op:0
	.inst 0xc2f243ff // 0xc2f243ff
	.inst 0xa2feffb5 // 0xa2feffb5
	.inst 0xc2c0d0f3 // 0xc2c0d0f3
	.inst 0x825be825 // 0x825be825
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
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400565 // ldr c5, [x11, #1]
	.inst 0xc2400975 // ldr c21, [x11, #2]
	.inst 0xc2400d7e // ldr c30, [x11, #3]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q18, =0x0
	/* Set up flags and system registers */
	ldr x11, =0x0
	msr SPSR_EL3, x11
	ldr x11, =initial_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288410b // msr CSP_EL0, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0x3c0000
	msr CPACR_EL1, x11
	ldr x11, =0x0
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x4
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260136b // ldr c11, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
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
	.inst 0xc240017b // ldr c27, [x11, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240057b // ldr c27, [x11, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240097b // ldr c27, [x11, #2]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc2400d7b // ldr c27, [x11, #3]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc240117b // ldr c27, [x11, #4]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc240157b // ldr c27, [x11, #5]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240197b // ldr c27, [x11, #6]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x27, v18.d[0]
	cmp x11, x27
	b.ne comparison_fail
	ldr x11, =0x0
	mov x27, v18.d[1]
	cmp x11, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc298411b // mrs c27, CSP_EL0
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba561 // chkeq c11, c27
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
	ldr x0, =0x00001f4a
	ldr x1, =check_data1
	ldr x2, =0x00001f4c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fd0
	ldr x1, =check_data2
	ldr x2, =0x00001fe0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040a020
	ldr x1, =check_data5
	ldr x2, =0x4040a030
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.zero 4048
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xe0, 0x81, 0x40, 0x40
.data
check_data4:
	.byte 0xd2, 0x83, 0x74, 0xe2, 0xdd, 0xef, 0xdc, 0xe2, 0xaa, 0x27, 0x77, 0x11, 0xa0, 0x40, 0x7e, 0x82
	.byte 0x3f, 0x86, 0x67, 0x50, 0xff, 0x43, 0xf2, 0xc2, 0xb5, 0xff, 0xfe, 0xa2, 0xf3, 0xd0, 0xc0, 0xc2
	.byte 0x25, 0xe8, 0x5b, 0x82, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 16

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000000100050000000000001900
	/* C5 */
	.octa 0x901000000001000500000000404081e0
	/* C21 */
	.octa 0x0
	/* C30 */
	.octa 0xd0100000000100050000000000002002
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40000000000100050000000000001900
	/* C5 */
	.octa 0x901000000001000500000000404081e0
	/* C10 */
	.octa 0xdca000
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080000005004f0000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000005004f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001fd0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 80
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
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400028
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
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
