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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c3 // ldr c3, [x14, #2]
	.inst 0xc2400dd8 // ldr c24, [x14, #3]
	/* Set up flags and system registers */
	ldr x14, =0x0
	msr SPSR_EL3, x14
	ldr x14, =initial_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288410e // msr CSP_EL0, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0xc0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x4
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260110e // ldr c14, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c8 // ldr c8, [x14, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24005c8 // ldr c8, [x14, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc24009c8 // ldr c8, [x14, #2]
	.inst 0xc2c8a461 // chkeq c3, c8
	b.ne comparison_fail
	.inst 0xc2400dc8 // ldr c8, [x14, #3]
	.inst 0xc2c8a701 // chkeq c24, c8
	b.ne comparison_fail
	.inst 0xc24011c8 // ldr c8, [x14, #4]
	.inst 0xc2c8a761 // chkeq c27, c8
	b.ne comparison_fail
	.inst 0xc24015c8 // ldr c8, [x14, #5]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc24019c8 // ldr c8, [x14, #6]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a5c1 // chkeq c14, c8
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
	ldr x0, =0x000017fe
	ldr x1, =check_data2
	ldr x2, =0x000017ff
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
	ldr x0, =0x4040f9e0
	ldr x1, =check_data4
	ldr x2, =0x4040f9e2
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x80, 0x01, 0x01, 0x01, 0x01
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1d, 0x90, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x80, 0x01, 0x01, 0x01, 0x01
.data
check_data1:
	.byte 0x1d, 0x90
.data
check_data2:
	.byte 0xfe
.data
check_data3:
	.byte 0x1b, 0x60, 0x37, 0xd1, 0xfe, 0xff, 0xdf, 0x48, 0xde, 0x0f, 0xc3, 0x1a, 0x3d, 0x50, 0xe1, 0x78
	.byte 0x1f, 0x7f, 0xbe, 0xa2, 0xa1, 0x73, 0xc0, 0xc2, 0x5f, 0x95, 0x20, 0x51, 0x7b, 0x7f, 0x9f, 0x08
	.byte 0xc0, 0xb3, 0xc0, 0xc2, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 2

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
	.octa 0x1
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
	.octa 0x1010101800101010101010101010101
initial_SP_EL0_value:
	.octa 0x4040f9e0
initial_DDC_EL0_value:
	.octa 0xc0100000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000080080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400028
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
