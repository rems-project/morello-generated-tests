.section text0, #alloc, #execinstr
test_start:
	.inst 0xa93093a0 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:29 Rt2:00100 imm7:1100001 L:0 1010010:1010010 opc:10
	.inst 0x027d6bff // ADD-C.CIS-C Cd:31 Cn:31 imm12:111101011010 sh:1 A:0 00000010:00000010
	.inst 0xb88058dd // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:29 Rn:6 10:10 imm9:000000101 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c5b000 // CVTP-C.R-C Cd:0 Rn:0 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x827ea9fd // ALDR-R.RI-32 Rt:29 Rn:15 op:10 imm9:111101010 L:1 1000001001:1000001001
	.zero 1004
	.inst 0xa90a5488 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:8 Rn:4 Rt2:10101 imm7:0010100 L:0 1010010:1010010 opc:10
	.inst 0x7818a416 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:22 Rn:0 01:01 imm9:110001010 0:0 opc:00 111000:111000 size:01
	.inst 0x1ac12449 // lsrv:aarch64/instrs/integer/shift/variable Rd:9 Rn:2 op2:01 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0xc2d743c1 // SCVALUE-C.CR-C Cd:1 Cn:30 000:000 opc:10 0:0 Rm:23 11000010110:11000010110
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400764 // ldr c4, [x27, #1]
	.inst 0xc2400b66 // ldr c6, [x27, #2]
	.inst 0xc2400f68 // ldr c8, [x27, #3]
	.inst 0xc240136f // ldr c15, [x27, #4]
	.inst 0xc2401775 // ldr c21, [x27, #5]
	.inst 0xc2401b76 // ldr c22, [x27, #6]
	.inst 0xc2401f77 // ldr c23, [x27, #7]
	.inst 0xc240237d // ldr c29, [x27, #8]
	.inst 0xc240277e // ldr c30, [x27, #9]
	/* Set up flags and system registers */
	ldr x27, =0x0
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
	ldr x27, =0x4
	msr S3_0_C1_C2_2, x27 // CCTLR_EL1
	ldr x27, =0x8
	msr S3_3_C1_C2_2, x27 // CCTLR_EL0
	ldr x27, =initial_DDC_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288413b // msr DDC_EL0, c27
	ldr x27, =initial_DDC_EL1_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc28c413b // msr DDC_EL1, c27
	ldr x27, =0x80000000
	msr HCR_EL2, x27
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260131b // ldr c27, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400378 // ldr c24, [x27, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400778 // ldr c24, [x27, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400b78 // ldr c24, [x27, #2]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2400f78 // ldr c24, [x27, #3]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2401378 // ldr c24, [x27, #4]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc2401778 // ldr c24, [x27, #5]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401b78 // ldr c24, [x27, #6]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc2401f78 // ldr c24, [x27, #7]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc2402378 // ldr c24, [x27, #8]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc2402778 // ldr c24, [x27, #9]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2402b78 // ldr c24, [x27, #10]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_SP_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984118 // mrs c24, CSP_EL0
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x24, 0x80
	orr x27, x27, x24
	ldr x24, =0x920000a1
	cmp x24, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010c8
	ldr x1, =check_data0
	ldr x2, =0x000010d8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001418
	ldr x1, =check_data1
	ldr x2, =0x0000141c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f80
	ldr x1, =check_data2
	ldr x2, =0x00001f90
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fc0
	ldr x1, =check_data3
	ldr x2, =0x00001fc2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xc0, 0x46, 0xc2, 0xbf, 0xff, 0xff, 0xff, 0xff, 0x28, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xa0, 0x93, 0x30, 0xa9, 0xff, 0x6b, 0x7d, 0x02, 0xdd, 0x58, 0x80, 0xb8, 0x00, 0xb0, 0xc5, 0xc2
	.byte 0xfd, 0xa9, 0x7e, 0x82
.data
check_data5:
	.byte 0x88, 0x54, 0x0a, 0xa9, 0x16, 0xa4, 0x18, 0x78, 0x49, 0x24, 0xc1, 0x1a, 0xc1, 0x43, 0xd7, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffbfc246c0
	/* C4 */
	.octa 0x1028
	/* C6 */
	.octa 0x1413
	/* C8 */
	.octa 0x0
	/* C15 */
	.octa 0x800000004042000afffffffffffff862
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x1
	/* C29 */
	.octa 0x2078
	/* C30 */
	.octa 0x120ad0000000000000001
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1f4a
	/* C1 */
	.octa 0x120ad0000000000000001
	/* C4 */
	.octa 0x1028
	/* C6 */
	.octa 0x1413
	/* C8 */
	.octa 0x0
	/* C15 */
	.octa 0x800000004042000afffffffffffff862
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x1
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x120ad0000000000000001
initial_SP_EL0_value:
	.octa 0x140030000000000000000
initial_DDC_EL0_value:
	.octa 0xc00000000007000500ffffffffff8001
initial_DDC_EL1_value:
	.octa 0x4000000000094005008000000000e000
initial_VBAR_EL1_value:
	.octa 0x200080004800ce020000000040400000
final_SP_EL0_value:
	.octa 0x140030000000000f5a000
final_PCC_value:
	.octa 0x200080004800ce020000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000007dd930000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000010c0
	.dword 0x00000000000010d0
	.dword 0x0000000000001f80
	.dword 0x0000000000001fc0
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
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x0200037b // add c27, c27, #0
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x0202037b // add c27, c27, #128
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x0204037b // add c27, c27, #256
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x0206037b // add c27, c27, #384
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x0208037b // add c27, c27, #512
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x020a037b // add c27, c27, #640
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x020c037b // add c27, c27, #768
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x020e037b // add c27, c27, #896
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x0210037b // add c27, c27, #1024
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x0212037b // add c27, c27, #1152
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x0214037b // add c27, c27, #1280
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x0216037b // add c27, c27, #1408
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x0218037b // add c27, c27, #1536
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x021a037b // add c27, c27, #1664
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
	.inst 0x021c037b // add c27, c27, #1792
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x82600f1b // ldr x27, [c24, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f1b // str x27, [c24, #0]
	ldr x27, =0x40400414
	mrs x24, ELR_EL1
	sub x27, x27, x24
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b378 // cvtp c24, x27
	.inst 0xc2db4318 // scvalue c24, c24, x27
	.inst 0x8260031b // ldr c27, [c24, #0]
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
