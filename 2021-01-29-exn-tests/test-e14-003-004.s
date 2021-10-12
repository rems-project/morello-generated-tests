.section text0, #alloc, #execinstr
test_start:
	.inst 0x8255b7ed // ASTRB-R.RI-B Rt:13 Rn:31 op:01 imm9:101011011 L:0 1000001001:1000001001
	.inst 0xa24f6ffd // LDR-C.RIBW-C Ct:29 Rn:31 11:11 imm9:011110110 0:0 opc:01 10100010:10100010
	.inst 0xe26da3e1 // ASTUR-V.RI-H Rt:1 Rn:31 op2:00 imm9:011011010 V:1 op1:01 11100010:11100010
	.inst 0xc2df2bbd // BICFLGS-C.CR-C Cd:29 Cn:29 1010:1010 opc:00 Rm:31 11000010110:11000010110
	.inst 0x385337d8 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:24 Rn:30 01:01 imm9:100110011 0:0 opc:01 111000:111000 size:00
	.zero 9196
	.inst 0xb80ffc1e // 0xb80ffc1e
	.inst 0xc2c0103f // 0xc2c0103f
	.inst 0xeb3e689f // 0xeb3e689f
	.inst 0xc2c71001 // 0xc2c71001
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc240090d // ldr c13, [x8, #2]
	.inst 0xc2400d1e // ldr c30, [x8, #3]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	ldr x8, =0x4000000
	msr SPSR_EL3, x8
	ldr x8, =initial_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884108 // msr CSP_EL0, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0x3c0000
	msr CPACR_EL1, x8
	ldr x8, =0x0
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x0
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601128 // ldr c8, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400109 // ldr c9, [x8, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400509 // ldr c9, [x8, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400909 // ldr c9, [x8, #2]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc2400d09 // ldr c9, [x8, #3]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2401109 // ldr c9, [x8, #4]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x9, v1.d[0]
	cmp x8, x9
	b.ne comparison_fail
	ldr x8, =0x0
	mov x9, v1.d[1]
	cmp x8, x9
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984109 // mrs c9, CSP_EL0
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	ldr x9, =esr_el1_dump_address
	ldr x9, [x9]
	mov x8, 0x83
	orr x9, x9, x8
	ldr x8, =0x920000ab
	cmp x8, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010db
	ldr x1, =check_data0
	ldr x2, =0x000010dc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001bf8
	ldr x1, =check_data1
	ldr x2, =0x00001bfc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ee0
	ldr x1, =check_data2
	ldr x2, =0x00001ef0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fba
	ldr x1, =check_data3
	ldr x2, =0x00001fbc
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
	ldr x0, =0x40402400
	ldr x1, =check_data5
	ldr x2, =0x40402414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.zero 3808
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 272
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0xc0
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
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
	.octa 0x40000000000700030000000000001af9
	/* C1 */
	.octa 0x400000000000000000000000
	/* C13 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000005000e0080c101c0000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000000000700030000000000001bf8
	/* C1 */
	.octa 0x1bf8
	/* C13 */
	.octa 0x0
	/* C29 */
	.octa 0x101800000000000000000000000
	/* C30 */
	.octa 0x800000000005000e0080c101c0000000
initial_SP_EL0_value:
	.octa 0x90000000004700000000000000000f80
initial_DDC_EL0_value:
	.octa 0x40000000100000080000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080006800201d0000000040402001
final_SP_EL0_value:
	.octa 0x90000000004700000000000000001ee0
final_PCC_value:
	.octa 0x200080006800201d0000000040402414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001ee0
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40402414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
