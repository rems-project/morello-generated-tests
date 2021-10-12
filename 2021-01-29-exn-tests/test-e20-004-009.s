.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2b813fc // ASTUR-V.RI-S Rt:28 Rn:31 op2:00 imm9:110000001 V:1 op1:10 11100010:11100010
	.inst 0xb15377df // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:30 imm12:010011011101 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x4b20ab9f // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:28 imm3:010 option:101 Rm:0 01011001:01011001 S:0 op:1 sf:0
	.inst 0xc2c710e1 // RRLEN-R.R-C Rd:1 Rn:7 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x3881fae1 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:23 10:10 imm9:000011111 0:0 opc:10 111000:111000 size:00
	.inst 0x3a5e7824 // 0x3a5e7824
	.inst 0xe21493fd // 0xe21493fd
	.inst 0xc2dad0e0 // 0xc2dad0e0
	.inst 0xb8fd72d4 // 0xb8fd72d4
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a7 // ldr c7, [x5, #1]
	.inst 0xc24008b6 // ldr c22, [x5, #2]
	.inst 0xc2400cb7 // ldr c23, [x5, #3]
	.inst 0xc24010bc // ldr c28, [x5, #4]
	.inst 0xc24014bd // ldr c29, [x5, #5]
	.inst 0xc24018be // ldr c30, [x5, #6]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q28, =0x0
	/* Set up flags and system registers */
	ldr x5, =0x4000000
	msr SPSR_EL3, x5
	ldr x5, =initial_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884105 // msr CSP_EL0, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0x3c0000
	msr CPACR_EL1, x5
	ldr x5, =0x0
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x4
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82601065 // ldr c5, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x3, #0xf
	and x5, x5, x3
	cmp x5, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a3 // ldr c3, [x5, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24004a3 // ldr c3, [x5, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24008a3 // ldr c3, [x5, #2]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc2400ca3 // ldr c3, [x5, #3]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc24010a3 // ldr c3, [x5, #4]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc24014a3 // ldr c3, [x5, #5]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc24018a3 // ldr c3, [x5, #6]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2401ca3 // ldr c3, [x5, #7]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc24020a3 // ldr c3, [x5, #8]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x3, v28.d[0]
	cmp x5, x3
	b.ne comparison_fail
	ldr x5, =0x0
	mov x3, v28.d[1]
	cmp x5, x3
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984103 // mrs c3, CSP_EL0
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100f
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001184
	ldr x1, =check_data2
	ldr x2, =0x00001188
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001208
	ldr x1, =check_data3
	ldr x2, =0x0000120c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0000138c
	ldr x1, =check_data4
	ldr x2, =0x0000138d
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.zero 128
	.byte 0x20, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x80, 0x00, 0x20
	.zero 368
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x20, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x01, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xfc, 0x13, 0xb8, 0xe2, 0xdf, 0x77, 0x53, 0xb1, 0x9f, 0xab, 0x20, 0x4b, 0xe1, 0x10, 0xc7, 0xc2
	.byte 0xe1, 0xfa, 0x81, 0x38, 0x24, 0x78, 0x5e, 0x3a, 0xfd, 0x93, 0x14, 0xe2, 0xe0, 0xd0, 0xda, 0xc2
	.byte 0xd4, 0x72, 0xfd, 0xb8, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C7 */
	.octa 0x90000000002140050000000000001320
	/* C22 */
	.octa 0x1005
	/* C23 */
	.octa 0x80000000510000010000000000000ff0
	/* C28 */
	.octa 0x1240
	/* C29 */
	.octa 0x40000000
	/* C30 */
	.octa 0x7fffffffffc10000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x90000000002140050000000000001320
	/* C20 */
	.octa 0x100
	/* C22 */
	.octa 0x1005
	/* C23 */
	.octa 0x80000000510000010000000000000ff0
	/* C28 */
	.octa 0x1240
	/* C29 */
	.octa 0x40000000
	/* C30 */
	.octa 0x7fffffffffc10000
initial_SP_EL0_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc0000000584802030000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x1240
final_PCC_value:
	.octa 0x20008000100000000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0