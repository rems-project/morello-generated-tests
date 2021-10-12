.section text0, #alloc, #execinstr
test_start:
	.inst 0xd137601b // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:27 Rn:0 imm12:110111011000 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x48dffffe // ldarh:aarch64/instrs/memory/ordered Rt:30 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x1ac30fde // sdiv:aarch64/instrs/integer/arithmetic/div Rd:30 Rn:30 o1:1 00001:00001 Rm:3 0011010110:0011010110 sf:0
	.inst 0x78e1503d // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:1 00:00 opc:101 0:0 Rs:1 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xa2be7f1f // CAS-C.R-C Ct:31 Rn:24 11111:11111 R:0 Cs:30 1:1 L:0 1:1 10100010:10100010
	.zero 9196
	.inst 0xc2c073a1 // 0xc2c073a1
	.inst 0x5120955f // 0x5120955f
	.inst 0x089f7f7b // 0x89f7f7b
	.inst 0xc2c0b3c0 // 0xc2c0b3c0
	.inst 0xd4000001
	.zero 56300
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
	.inst 0xc2400963 // ldr c3, [x11, #2]
	.inst 0xc2400d78 // ldr c24, [x11, #3]
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
	ldr x11, =0xc0000
	msr CPACR_EL1, x11
	ldr x11, =0x4
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x4
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =initial_DDC_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c412b // msr DDC_EL1, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260132b // ldr c11, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	.inst 0xc2400179 // ldr c25, [x11, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400579 // ldr c25, [x11, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400979 // ldr c25, [x11, #2]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2400d79 // ldr c25, [x11, #3]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc2401179 // ldr c25, [x11, #4]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc2401579 // ldr c25, [x11, #5]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2401979 // ldr c25, [x11, #6]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984119 // mrs c25, CSP_EL0
	.inst 0xc2d9a561 // chkeq c11, c25
	b.ne comparison_fail
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a561 // chkeq c11, c25
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x11, 0x83
	orr x25, x25, x11
	ldr x11, =0x920000a3
	cmp x11, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017f0
	ldr x1, =check_data1
	ldr x2, =0x000017f2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000019e8
	ldr x1, =check_data2
	ldr x2, =0x000019e9
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40402400
	ldr x1, =check_data4
	ldr x2, =0x40402414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.byte 0x01, 0x90, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01, 0x90
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xe8
.data
check_data3:
	.byte 0x1b, 0x60, 0x37, 0xd1, 0xfe, 0xff, 0xdf, 0x48, 0xde, 0x0f, 0xc3, 0x1a, 0x3d, 0x50, 0xe1, 0x78
	.byte 0x1f, 0x7f, 0xbe, 0xa2
.data
check_data4:
	.byte 0xa1, 0x73, 0xc0, 0xc2, 0x5f, 0x95, 0x20, 0x51, 0x7b, 0x7f, 0x9f, 0x08, 0xc0, 0xb3, 0xc0, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x27c0
	/* C1 */
	.octa 0x1000
	/* C3 */
	.octa 0x0
	/* C24 */
	.octa 0x88000000000002
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x9001
	/* C3 */
	.octa 0x0
	/* C24 */
	.octa 0x88000000000002
	/* C27 */
	.octa 0x19e8
	/* C29 */
	.octa 0x9001
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x17f0
initial_DDC_EL0_value:
	.octa 0xc0000000000080080000000000000001
initial_DDC_EL1_value:
	.octa 0x40000000000600010000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000201d0000000040402000
final_SP_EL0_value:
	.octa 0x17f0
final_PCC_value:
	.octa 0x200080004000201d0000000040402414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000040400000
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x82600f2b // ldr x11, [c25, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f2b // str x11, [c25, #0]
	ldr x11, =0x40402414
	mrs x25, ELR_EL1
	sub x11, x11, x25
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b179 // cvtp c25, x11
	.inst 0xc2cb4339 // scvalue c25, c25, x11
	.inst 0x8260032b // ldr c11, [c25, #0]
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
