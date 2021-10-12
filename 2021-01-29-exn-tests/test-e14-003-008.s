.section text0, #alloc, #execinstr
test_start:
	.inst 0x8255b7ed // ASTRB-R.RI-B Rt:13 Rn:31 op:01 imm9:101011011 L:0 1000001001:1000001001
	.inst 0xa24f6ffd // LDR-C.RIBW-C Ct:29 Rn:31 11:11 imm9:011110110 0:0 opc:01 10100010:10100010
	.inst 0xe26da3e1 // ASTUR-V.RI-H Rt:1 Rn:31 op2:00 imm9:011011010 V:1 op1:01 11100010:11100010
	.inst 0xc2df2bbd // BICFLGS-C.CR-C Cd:29 Cn:29 1010:1010 opc:00 Rm:31 11000010110:11000010110
	.inst 0x385337d8 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:24 Rn:30 01:01 imm9:100110011 0:0 opc:01 111000:111000 size:00
	.zero 1004
	.inst 0xb80ffc1e // 0xb80ffc1e
	.inst 0xc2c0103f // 0xc2c0103f
	.inst 0xeb3e689f // 0xeb3e689f
	.inst 0xc2c71001 // 0xc2c71001
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
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b6d // ldr c13, [x27, #2]
	.inst 0xc2400f7e // ldr c30, [x27, #3]
	/* Vector registers */
	mrs x27, cptr_el3
	bfc x27, #10, #1
	msr cptr_el3, x27
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	ldr x27, =0x4000000
	msr SPSR_EL3, x27
	ldr x27, =initial_SP_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288411b // msr CSP_EL0, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30d5d99f
	msr SCTLR_EL1, x27
	ldr x27, =0x3c0000
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
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260125b // ldr c27, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	.inst 0xc2400372 // ldr c18, [x27, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400772 // ldr c18, [x27, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400b72 // ldr c18, [x27, #2]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2400f72 // ldr c18, [x27, #3]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2401372 // ldr c18, [x27, #4]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x18, v1.d[0]
	cmp x27, x18
	b.ne comparison_fail
	ldr x27, =0x0
	mov x18, v1.d[1]
	cmp x27, x18
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_SP_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984112 // mrs c18, CSP_EL0
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	ldr x18, =esr_el1_dump_address
	ldr x18, [x18]
	mov x27, 0x83
	orr x18, x18, x27
	ldr x27, =0x920000ab
	cmp x27, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000102b
	ldr x1, =check_data0
	ldr x2, =0x0000102c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001084
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e30
	ldr x1, =check_data2
	ldr x2, =0x00001e40
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f0a
	ldr x1, =check_data3
	ldr x2, =0x00001f0c
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
	.zero 3632
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00
	.zero 448
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xed, 0xb7, 0x55, 0x82, 0xfd, 0x6f, 0x4f, 0xa2, 0xe1, 0xa3, 0x6d, 0xe2, 0xbd, 0x2b, 0xdf, 0xc2
	.byte 0xd8, 0x37, 0x53, 0x38
.data
check_data5:
	.byte 0x1e, 0xfc, 0x0f, 0xb8, 0x3f, 0x10, 0xc0, 0xc2, 0x9f, 0x68, 0x3e, 0xeb, 0x01, 0x10, 0xc7, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000008100070000000000000f81
	/* C1 */
	.octa 0x400000000000000000000000
	/* C13 */
	.octa 0x0
	/* C30 */
	.octa 0x800000004000c0029000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000000008100070000000000001080
	/* C1 */
	.octa 0x1080
	/* C13 */
	.octa 0x0
	/* C29 */
	.octa 0x1800000000000000000000000
	/* C30 */
	.octa 0x800000004000c0029000000000000000
initial_SP_EL0_value:
	.octa 0x900000005f020f020000000000000ed0
initial_DDC_EL0_value:
	.octa 0x40000000000080080000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004800001d0000000040400001
final_SP_EL0_value:
	.octa 0x900000005f020f020000000000001e30
final_PCC_value:
	.octa 0x200080004800001d0000000040400414
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
	.dword 0x0000000000001e30
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
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
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0200037b // add c27, c27, #0
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0202037b // add c27, c27, #128
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0204037b // add c27, c27, #256
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0206037b // add c27, c27, #384
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0208037b // add c27, c27, #512
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x020a037b // add c27, c27, #640
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x020c037b // add c27, c27, #768
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x020e037b // add c27, c27, #896
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0210037b // add c27, c27, #1024
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0212037b // add c27, c27, #1152
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0214037b // add c27, c27, #1280
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0216037b // add c27, c27, #1408
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0218037b // add c27, c27, #1536
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x021a037b // add c27, c27, #1664
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x021c037b // add c27, c27, #1792
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40400414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
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
