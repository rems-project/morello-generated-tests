.section text0, #alloc, #execinstr
test_start:
	.inst 0x382023bf // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:010 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x3848c481 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:4 01:01 imm9:010001100 0:0 opc:01 111000:111000 size:00
	.inst 0xb3731b1e // bfm:aarch64/instrs/integer/bitfield Rd:30 Rn:24 imms:000110 immr:110011 N:1 100110:100110 opc:01 sf:1
	.inst 0x221dfffe // STLXR-R.CR-C Ct:30 Rn:31 (1)(1)(1)(1)(1):11111 1:1 Rs:29 0:0 L:0 001000100:001000100
	.inst 0xc2df03dd // SCBNDS-C.CR-C Cd:29 Cn:30 000:000 opc:00 0:0 Rm:31 11000010110:11000010110
	.inst 0xa88237c2 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:2 Rn:30 Rt2:01101 imm7:0000100 L:0 1010001:1010001 opc:10
	.inst 0xc2c0503e // GCVALUE-R.C-C Rd:30 Cn:1 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x926c77f6 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:22 Rn:31 imms:011101 immr:101100 N:1 100100:100100 opc:00 sf:1
	.inst 0xc2e01827 // CVT-C.CR-C Cd:7 Cn:1 0110:0110 0:0 0:0 Rm:0 11000010111:11000010111
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
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400964 // ldr c4, [x11, #2]
	.inst 0xc2400d6d // ldr c13, [x11, #3]
	.inst 0xc2401178 // ldr c24, [x11, #4]
	.inst 0xc240157d // ldr c29, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
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
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011eb // ldr c11, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
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
	.inst 0xc240016f // ldr c15, [x11, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240056f // ldr c15, [x11, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240096f // ldr c15, [x11, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400d6f // ldr c15, [x11, #3]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc240116f // ldr c15, [x11, #4]
	.inst 0xc2cfa4e1 // chkeq c7, c15
	b.ne comparison_fail
	.inst 0xc240156f // ldr c15, [x11, #5]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc240196f // ldr c15, [x11, #6]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc2401d6f // ldr c15, [x11, #7]
	.inst 0xc2cfa701 // chkeq c24, c15
	b.ne comparison_fail
	.inst 0xc240216f // ldr c15, [x11, #8]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc240256f // ldr c15, [x11, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc298410f // mrs c15, CSP_EL0
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa561 // chkeq c11, c15
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
	ldr x0, =0x00001b60
	ldr x1, =check_data1
	ldr x2, =0x00001b70
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x4040fffe
	ldr x1, =check_data3
	ldr x2, =0x4040ffff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd6, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xbf, 0x23, 0x20, 0x38, 0x81, 0xc4, 0x48, 0x38, 0x1e, 0x1b, 0x73, 0xb3, 0xfe, 0xff, 0x1d, 0x22
	.byte 0xdd, 0x03, 0xdf, 0xc2, 0xc2, 0x37, 0x82, 0xa8, 0x3e, 0x50, 0xc0, 0xc2, 0xf6, 0x77, 0x6c, 0x92
	.byte 0x27, 0x18, 0xe0, 0xc2, 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x4040fffe
	/* C13 */
	.octa 0xd6000000000000
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x4041008a
	/* C7 */
	.octa 0x0
	/* C13 */
	.octa 0xd6000000000000
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x500010000000000000001000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1b60
initial_DDC_EL0_value:
	.octa 0xc00000000003000300fefffa00000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x1b60
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
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
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
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400028
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
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
