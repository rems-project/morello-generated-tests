.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2675414 // ALDUR-V.RI-H Rt:20 Rn:0 op2:01 imm9:001110101 V:1 op1:01 11100010:11100010
	.inst 0xc2c0d3d3 // GCPERM-R.C-C Rd:19 Cn:30 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2bdc001 // ADD-C.CRI-C Cd:1 Cn:0 imm3:000 option:110 Rm:29 11000010101:11000010101
	.inst 0xa20b0efd // STR-C.RIBW-C Ct:29 Rn:23 11:11 imm9:010110000 0:0 opc:00 10100010:10100010
	.inst 0xb9ae2000 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:0 imm12:101110001000 opc:10 111001:111001 size:10
	.zero 1004
	.inst 0xf8136b7d // 0xf8136b7d
	.inst 0xa21bc47e // 0xa21bc47e
	.inst 0xb7698ec8 // tbnz:aarch64/instrs/branch/conditional/test Rt:8 imm14:00110001110110 b40:01101 op:1 011011:011011 b5:1
	.inst 0xc2c59020 // CVTD-C.R-C Cd:0 Rn:1 100:100 opc:00 11000010110001011:11000010110001011
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400443 // ldr c3, [x2, #1]
	.inst 0xc2400848 // ldr c8, [x2, #2]
	.inst 0xc2400c57 // ldr c23, [x2, #3]
	.inst 0xc240105b // ldr c27, [x2, #4]
	.inst 0xc240145d // ldr c29, [x2, #5]
	.inst 0xc240185e // ldr c30, [x2, #6]
	/* Set up flags and system registers */
	ldr x2, =0x4000000
	msr SPSR_EL3, x2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0x3c0000
	msr CPACR_EL1, x2
	ldr x2, =0x0
	msr S3_0_C1_C2_2, x2 // CCTLR_EL1
	ldr x2, =0x4
	msr S3_3_C1_C2_2, x2 // CCTLR_EL0
	ldr x2, =initial_DDC_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884122 // msr DDC_EL0, c2
	ldr x2, =initial_DDC_EL1_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc28c4122 // msr DDC_EL1, c2
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601202 // ldr c2, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc28e4022 // msr CELR_EL3, c2
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400050 // ldr c16, [x2, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400450 // ldr c16, [x2, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400850 // ldr c16, [x2, #2]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400c50 // ldr c16, [x2, #3]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc2401050 // ldr c16, [x2, #4]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc2401450 // ldr c16, [x2, #5]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc2401850 // ldr c16, [x2, #6]
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	.inst 0xc2401c50 // ldr c16, [x2, #7]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2402050 // ldr c16, [x2, #8]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x2, =0x0
	mov x16, v20.d[0]
	cmp x2, x16
	b.ne comparison_fail
	ldr x2, =0x0
	mov x16, v20.d[1]
	cmp x2, x16
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x2, 0x83
	orr x16, x16, x2
	ldr x2, =0x920000ab
	cmp x2, x16
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
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001408
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
	ldr x0, =0x4040007c
	ldr x1, =check_data4
	ldr x2, =0x4040007e
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
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
	.byte 0x01, 0x42, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00
.data
check_data2:
	.byte 0x01, 0x42, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00
.data
check_data3:
	.byte 0x14, 0x54, 0x67, 0xe2, 0xd3, 0xd3, 0xc0, 0xc2, 0x01, 0xc0, 0xbd, 0xc2, 0xfd, 0x0e, 0x0b, 0xa2
	.byte 0x00, 0x20, 0xae, 0xb9
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x7d, 0x6b, 0x13, 0xf8, 0x7e, 0xc4, 0x1b, 0xa2, 0xc8, 0x8e, 0x69, 0xb7, 0x20, 0x90, 0xc5, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000000340070000000040000007
	/* C3 */
	.octa 0x1000
	/* C8 */
	.octa 0x0
	/* C23 */
	.octa 0x4000000000a900070000000000001480
	/* C27 */
	.octa 0x14ca
	/* C29 */
	.octa 0x200000000000100000010080004201
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x4000000000050004ffffffffc0004208
	/* C1 */
	.octa 0x200000034007ffffffffc0004208
	/* C3 */
	.octa 0xbc0
	/* C8 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x4000000000a900070000000000001f80
	/* C27 */
	.octa 0x14ca
	/* C29 */
	.octa 0x200000000000100000010080004201
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000202d002600ffffffc000c000
initial_DDC_EL1_value:
	.octa 0x400000000005000400ffffff00000000
initial_VBAR_EL1_value:
	.octa 0x200080005000d2010000000040400000
final_PCC_value:
	.octa 0x200080005000d2010000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
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
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600e02 // ldr x2, [c16, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e02 // str x2, [c16, #0]
	ldr x2, =0x40400414
	mrs x16, ELR_EL1
	sub x2, x2, x16
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b050 // cvtp c16, x2
	.inst 0xc2c24210 // scvalue c16, c16, x2
	.inst 0x82600202 // ldr c2, [c16, #0]
	.inst 0x021e0042 // add c2, c2, #1920
	.inst 0xc2c21040 // br c2

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
