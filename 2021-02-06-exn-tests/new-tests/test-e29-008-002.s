.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dd05f8 // BUILD-C.C-C Cd:24 Cn:15 001:001 opc:00 0:0 Cm:29 11000010110:11000010110
	.inst 0x3820201f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:010 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x82de683b // ALDRSH-R.RRB-32 Rt:27 Rn:1 opc:10 S:0 option:011 Rm:30 0:0 L:1 100000101:100000101
	.inst 0xd61f02e0 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:23 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 32752
	.inst 0x785b001d // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:0 00:00 imm9:110110000 0:0 opc:01 111000:111000 size:01
	.zero 3068
	.inst 0xc2c5d3a0 // CVTDZ-C.R-C Cd:0 Rn:29 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xb7d98107 // tbnz:aarch64/instrs/branch/conditional/test Rt:7 imm14:00110000001000 b40:11011 op:1 011011:011011 b5:1
	.zero 12316
	.inst 0xc2c130f3 // GCFLGS-R.C-C Rd:19 Cn:7 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2eb7380 // EORFLGS-C.CI-C Cd:0 Cn:28 0:0 10:10 imm8:01011011 11000010111:11000010111
	.inst 0xd4000001
	.zero 17360
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c7 // ldr c7, [x6, #2]
	.inst 0xc2400ccf // ldr c15, [x6, #3]
	.inst 0xc24010d7 // ldr c23, [x6, #4]
	.inst 0xc24014dc // ldr c28, [x6, #5]
	.inst 0xc24018dd // ldr c29, [x6, #6]
	.inst 0xc2401cde // ldr c30, [x6, #7]
	/* Set up flags and system registers */
	ldr x6, =0x0
	msr SPSR_EL3, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x8
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =initial_DDC_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4126 // msr DDC_EL1, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82601286 // ldr c6, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d4 // ldr c20, [x6, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24004d4 // ldr c20, [x6, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24008d4 // ldr c20, [x6, #2]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2400cd4 // ldr c20, [x6, #3]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc24010d4 // ldr c20, [x6, #4]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc24014d4 // ldr c20, [x6, #5]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc24018d4 // ldr c20, [x6, #6]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc2401cd4 // ldr c20, [x6, #7]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc24020d4 // ldr c20, [x6, #8]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc24024d4 // ldr c20, [x6, #9]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc24028d4 // ldr c20, [x6, #10]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x20, 0x80
	orr x6, x6, x20
	ldr x20, =0x920000a1
	cmp x20, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001001
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001202
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40408000
	ldr x1, =check_data3
	ldr x2, =0x40408004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40408c00
	ldr x1, =check_data4
	ldr x2, =0x40408c08
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040bc24
	ldr x1, =check_data5
	ldr x2, =0x4040bc30
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
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.byte 0x01
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xf8, 0x05, 0xdd, 0xc2, 0x1f, 0x20, 0x20, 0x38, 0x3b, 0x68, 0xde, 0x82, 0xe0, 0x02, 0x1f, 0xd6
.data
check_data3:
	.byte 0x1d, 0x00, 0x5b, 0x78
.data
check_data4:
	.byte 0xa0, 0xd3, 0xc5, 0xc2, 0x07, 0x81, 0xd9, 0xb7
.data
check_data5:
	.byte 0xf3, 0x30, 0xc1, 0xc2, 0x80, 0x73, 0xeb, 0xc2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1001
	/* C1 */
	.octa 0x80000000400000020000000000000200
	/* C7 */
	.octa 0x800000000000000
	/* C15 */
	.octa 0x40000000070000000000000000
	/* C23 */
	.octa 0x40408000
	/* C28 */
	.octa 0x3fff800000000000000000000000
	/* C29 */
	.octa 0x40100050000000000004000
	/* C30 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x3fff800000005b00000000000000
	/* C1 */
	.octa 0x80000000400000020000000000000200
	/* C7 */
	.octa 0x800000000000000
	/* C15 */
	.octa 0x40000000070000000000000000
	/* C19 */
	.octa 0x800000000000000
	/* C23 */
	.octa 0x40408000
	/* C24 */
	.octa 0x70000000000000000
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x3fff800000000000000000000000
	/* C29 */
	.octa 0x40100050000000000004000
	/* C30 */
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc00000005200032100ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x80070007008400000000e001
initial_VBAR_EL1_value:
	.octa 0x200080004000850c0000000040408800
final_PCC_value:
	.octa 0x200080004000850c000000004040bc30
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x4040bc30
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
