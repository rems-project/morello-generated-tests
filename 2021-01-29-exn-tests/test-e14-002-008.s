.section text0, #alloc, #execinstr
test_start:
	.inst 0xd137601b // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:27 Rn:0 imm12:110111011000 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x48dffffe // ldarh:aarch64/instrs/memory/ordered Rt:30 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x1ac30fde // sdiv:aarch64/instrs/integer/arithmetic/div Rd:30 Rn:30 o1:1 00001:00001 Rm:3 0011010110:0011010110 sf:0
	.inst 0x78e1503d // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:1 00:00 opc:101 0:0 Rs:1 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xa2be7f1f // CAS-C.R-C Ct:31 Rn:24 11111:11111 R:0 Cs:30 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c073a1 // 0xc2c073a1
	.inst 0x5120955f // 0x5120955f
	.inst 0x089f7f7b // 0x89f7f7b
	.inst 0xc2c0b3c0 // 0xc2c0b3c0
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e3 // ldr c3, [x15, #2]
	.inst 0xc2400df8 // ldr c24, [x15, #3]
	/* Set up flags and system registers */
	ldr x15, =0x0
	msr SPSR_EL3, x15
	ldr x15, =initial_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288410f // msr CSP_EL0, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x4
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010cf // ldr c15, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc28e402f // msr CELR_EL3, c15
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e6 // ldr c6, [x15, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24005e6 // ldr c6, [x15, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc24009e6 // ldr c6, [x15, #2]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2400de6 // ldr c6, [x15, #3]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc24011e6 // ldr c6, [x15, #4]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc24015e6 // ldr c6, [x15, #5]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc24019e6 // ldr c6, [x15, #6]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a5e1 // chkeq c15, c6
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
	ldr x0, =0x0000101c
	ldr x1, =check_data1
	ldr x2, =0x0000101e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001042
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017fe
	ldr x1, =check_data3
	ldr x2, =0x000017ff
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
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x40, 0x01, 0x01
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1d, 0x90, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x40, 0x01, 0x01
.data
check_data1:
	.byte 0x1d, 0x90
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xfe
.data
check_data4:
	.byte 0x1b, 0x60, 0x37, 0xd1, 0xfe, 0xff, 0xdf, 0x48, 0xde, 0x0f, 0xc3, 0x1a, 0x3d, 0x50, 0xe1, 0x78
	.byte 0x1f, 0x7f, 0xbe, 0xa2, 0xa1, 0x73, 0xc0, 0xc2, 0x5f, 0x95, 0x20, 0x51, 0x7b, 0x7f, 0x9f, 0x08
	.byte 0xc0, 0xb3, 0xc0, 0xc2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x25d6
	/* C1 */
	.octa 0x101c
	/* C3 */
	.octa 0x0
	/* C24 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x901d
	/* C3 */
	.octa 0x0
	/* C24 */
	.octa 0x1000
	/* C27 */
	.octa 0x17fe
	/* C29 */
	.octa 0x901d
	/* C30 */
	.octa 0x1014000010101010101010101010101
initial_SP_EL0_value:
	.octa 0x1040
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000080200000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080200000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40400028
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021e01ef // add c15, c15, #1920
	.inst 0xc2c211e0 // br c15

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0