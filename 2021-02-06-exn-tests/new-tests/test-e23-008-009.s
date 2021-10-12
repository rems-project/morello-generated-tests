.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ac12d91 // rorv:aarch64/instrs/integer/shift/variable Rd:17 Rn:12 op2:11 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0x383713ff // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:001 o3:0 Rs:23 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc254f41f // LDR-C.RIB-C Ct:31 Rn:0 imm12:010100111101 L:1 110000100:110000100
	.inst 0xbc4a4c21 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:1 Rn:1 11:11 imm9:010100100 0:0 opc:01 111100:111100 size:10
	.inst 0x085ffebe // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:30 Rn:21 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x38ce1dfe // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:15 11:11 imm9:011100001 0:0 opc:11 111000:111000 size:00
	.inst 0xd361c5e6 // ubfm:aarch64/instrs/integer/bitfield Rd:6 Rn:15 imms:110001 immr:100001 N:1 100110:100110 opc:10 sf:1
	.inst 0xf9a7c341 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:26 imm12:100111110000 opc:10 111001:111001 size:11
	.inst 0xa84d67a0 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:0 Rn:29 Rt2:11001 imm7:0011010 L:1 1010000:1010000 opc:10
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc240090f // ldr c15, [x8, #2]
	.inst 0xc2400d15 // ldr c21, [x8, #3]
	.inst 0xc2401117 // ldr c23, [x8, #4]
	.inst 0xc240151d // ldr c29, [x8, #5]
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
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601088 // ldr c8, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
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
	.inst 0xc2400104 // ldr c4, [x8, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400504 // ldr c4, [x8, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400904 // ldr c4, [x8, #2]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2400d04 // ldr c4, [x8, #3]
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	.inst 0xc2401104 // ldr c4, [x8, #4]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc2401504 // ldr c4, [x8, #5]
	.inst 0xc2c4a6e1 // chkeq c23, c4
	b.ne comparison_fail
	.inst 0xc2401904 // ldr c4, [x8, #6]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc2401d04 // ldr c4, [x8, #7]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2402104 // ldr c4, [x8, #8]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x4, v1.d[0]
	cmp x8, x4
	b.ne comparison_fail
	ldr x8, =0x0
	mov x4, v1.d[1]
	cmp x8, x4
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984104 // mrs c4, CSP_EL0
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001058
	ldr x1, =check_data0
	ldr x2, =0x00001068
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x000010e1
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001db0
	ldr x1, =check_data2
	ldr x2, =0x00001db4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x40407ee0
	ldr x1, =check_data5
	ldr x2, =0x40407ef0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40407ffe
	ldr x1, =check_data6
	ldr x2, =0x40407fff
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 224
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3856
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0xff
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x91, 0x2d, 0xc1, 0x9a, 0xff, 0x13, 0x37, 0x38, 0x1f, 0xf4, 0x54, 0xc2, 0x21, 0x4c, 0x4a, 0xbc
	.byte 0xbe, 0xfe, 0x5f, 0x08, 0xfe, 0x1d, 0xce, 0x38, 0xe6, 0xc5, 0x61, 0xd3, 0x41, 0xc3, 0xa7, 0xf9
	.byte 0xa0, 0x67, 0x4d, 0xa8, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000001dfa00010000000040402b10
	/* C1 */
	.octa 0x80000000000100050000000000001d0c
	/* C15 */
	.octa 0x80000000000100050000000040407f1d
	/* C21 */
	.octa 0x80000000000100050000000000001ffe
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000100050000000000000f88
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000000100050000000000001db0
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x80000000000100050000000040407ffe
	/* C21 */
	.octa 0x80000000000100050000000000001ffe
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000100050000000000000f88
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000400000e100000000000010e0
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc0000000400000e100000000000010e0
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
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword initial_SP_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000010e0
	.dword 0x0000000040407ee0
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
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600c88 // ldr x8, [c4, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c88 // str x8, [c4, #0]
	ldr x8, =0x40400028
	mrs x4, ELR_EL1
	sub x8, x8, x4
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b104 // cvtp c4, x8
	.inst 0xc2c84084 // scvalue c4, c4, x8
	.inst 0x82600088 // ldr c8, [c4, #0]
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
