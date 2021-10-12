.section text0, #alloc, #execinstr
test_start:
	.inst 0xe24a8a41 // ALDURSH-R.RI-64 Rt:1 Rn:18 op2:10 imm9:010101000 V:0 op1:01 11100010:11100010
	.inst 0x089f7fee // stllrb:aarch64/instrs/memory/ordered Rt:14 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x485f7e13 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:19 Rn:16 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x384c6fa1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:29 11:11 imm9:011000110 0:0 opc:01 111000:111000 size:00
	.inst 0x82dd66c1 // ALDRSB-R.RRB-32 Rt:1 Rn:22 opc:01 S:0 option:011 Rm:29 0:0 L:1 100000101:100000101
	.inst 0x387b63ff // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:27 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xe29b88f3 // ALDURSW-R.RI-64 Rt:19 Rn:7 op2:10 imm9:110111000 V:0 op1:10 11100010:11100010
	.inst 0x1ac12549 // lsrv:aarch64/instrs/integer/shift/variable Rd:9 Rn:10 op2:01 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0x796a1bbd // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:29 imm12:101010000110 opc:01 111001:111001 size:01
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
	.inst 0xc2400107 // ldr c7, [x8, #0]
	.inst 0xc240050e // ldr c14, [x8, #1]
	.inst 0xc2400910 // ldr c16, [x8, #2]
	.inst 0xc2400d12 // ldr c18, [x8, #3]
	.inst 0xc2401116 // ldr c22, [x8, #4]
	.inst 0xc240151b // ldr c27, [x8, #5]
	.inst 0xc240191d // ldr c29, [x8, #6]
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
	ldr x8, =0xc0000
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
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601308 // ldr c8, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
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
	.inst 0xc2400118 // ldr c24, [x8, #0]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400518 // ldr c24, [x8, #1]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2400918 // ldr c24, [x8, #2]
	.inst 0xc2d8a5c1 // chkeq c14, c24
	b.ne comparison_fail
	.inst 0xc2400d18 // ldr c24, [x8, #3]
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	.inst 0xc2401118 // ldr c24, [x8, #4]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2401518 // ldr c24, [x8, #5]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc2401918 // ldr c24, [x8, #6]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc2401d18 // ldr c24, [x8, #7]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc2402118 // ldr c24, [x8, #8]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984118 // mrs c24, CSP_EL0
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000014c0
	ldr x1, =check_data1
	ldr x2, =0x000014c2
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
	ldr x0, =0x404000d4
	ldr x1, =check_data3
	ldr x2, =0x404000d6
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40408af2
	ldr x1, =check_data4
	ldr x2, =0x40408af3
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40409ffe
	ldr x1, =check_data5
	ldr x2, =0x4040a000
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040fff8
	ldr x1, =check_data6
	ldr x2, =0x4040fffc
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040fffe
	ldr x1, =check_data7
	ldr x2, =0x4040ffff
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.zero 4096
.data
check_data0:
	.byte 0x01
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x41, 0x8a, 0x4a, 0xe2, 0xee, 0x7f, 0x9f, 0x08, 0x13, 0x7e, 0x5f, 0x48, 0xa1, 0x6f, 0x4c, 0x38
	.byte 0xc1, 0x66, 0xdd, 0x82, 0xff, 0x63, 0x7b, 0x38, 0xf3, 0x88, 0x9b, 0xe2, 0x49, 0x25, 0xc1, 0x1a
	.byte 0xbd, 0x1b, 0x6a, 0x79, 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 4
.data
check_data7:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x40410040
	/* C14 */
	.octa 0x1
	/* C16 */
	.octa 0x800000000001000500000000000014c0
	/* C18 */
	.octa 0x4040002c
	/* C22 */
	.octa 0x750c
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x8000000000078af70000000040408a2c
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x40410040
	/* C14 */
	.octa 0x1
	/* C16 */
	.octa 0x800000000001000500000000000014c0
	/* C18 */
	.octa 0x4040002c
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x750c
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000000100050000000000001000
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc0000000000100050000000000001000
final_PCC_value:
	.octa 0x200080000000c0000000000040400028
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
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
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
