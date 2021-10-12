.section text0, #alloc, #execinstr
test_start:
	.inst 0xc8a67c13 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:19 Rn:0 11111:11111 o0:0 Rs:6 1:1 L:0 0010001:0010001 size:11
	.inst 0xc2c031e8 // GCLEN-R.C-C Rd:8 Cn:15 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x8817ffdc // stlxr:aarch64/instrs/memory/exclusive/single Rt:28 Rn:30 Rt2:11111 o0:1 Rs:23 0:0 L:0 0010000:0010000 size:10
	.inst 0xe2e3d541 // ALDUR-V.RI-D Rt:1 Rn:10 op2:01 imm9:000111101 V:1 op1:11 11100010:11100010
	.inst 0x3849cfdf // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:30 11:11 imm9:010011100 0:0 opc:01 111000:111000 size:00
	.inst 0xe278a7ff // ALDUR-V.RI-H Rt:31 Rn:31 op2:01 imm9:110001010 V:1 op1:01 11100010:11100010
	.inst 0x391e67bf // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:29 imm12:011110011001 opc:00 111001:111001 size:00
	.inst 0x3806543d // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:1 01:01 imm9:001100101 0:0 opc:00 111000:111000 size:00
	.inst 0xc8aaffea // cas:aarch64/instrs/memory/atomicops/cas/single Rt:10 Rn:31 11111:11111 o0:1 Rs:10 1:1 L:0 0010001:0010001 size:11
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa6 // ldr c6, [x21, #2]
	.inst 0xc2400eaa // ldr c10, [x21, #3]
	.inst 0xc24012af // ldr c15, [x21, #4]
	.inst 0xc24016bd // ldr c29, [x21, #5]
	.inst 0xc2401abe // ldr c30, [x21, #6]
	/* Set up flags and system registers */
	ldr x21, =0x0
	msr SPSR_EL3, x21
	ldr x21, =initial_SP_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884115 // msr CSP_EL0, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30d5d99f
	msr SCTLR_EL1, x21
	ldr x21, =0x3c0000
	msr CPACR_EL1, x21
	ldr x21, =0x0
	msr S3_0_C1_C2_2, x21 // CCTLR_EL1
	ldr x21, =0x0
	msr S3_3_C1_C2_2, x21 // CCTLR_EL0
	ldr x21, =initial_DDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884135 // msr DDC_EL0, c21
	ldr x21, =0x80000000
	msr HCR_EL2, x21
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601375 // ldr c21, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e4035 // msr CELR_EL3, c21
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002bb // ldr c27, [x21, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24006bb // ldr c27, [x21, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400abb // ldr c27, [x21, #2]
	.inst 0xc2dba4c1 // chkeq c6, c27
	b.ne comparison_fail
	.inst 0xc2400ebb // ldr c27, [x21, #3]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc24012bb // ldr c27, [x21, #4]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc24016bb // ldr c27, [x21, #5]
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	.inst 0xc2401abb // ldr c27, [x21, #6]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc2401ebb // ldr c27, [x21, #7]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc24022bb // ldr c27, [x21, #8]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x27, v1.d[0]
	cmp x21, x27
	b.ne comparison_fail
	ldr x21, =0x0
	mov x27, v1.d[1]
	cmp x21, x27
	b.ne comparison_fail
	ldr x21, =0x0
	mov x27, v31.d[0]
	cmp x21, x27
	b.ne comparison_fail
	ldr x21, =0x0
	mov x27, v31.d[1]
	cmp x21, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x21, =final_SP_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc298411b // mrs c27, CSP_EL0
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	ldr x21, =final_PCC_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000109c
	ldr x1, =check_data1
	ldr x2, =0x0000109d
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011aa
	ldr x1, =check_data2
	ldr x2, =0x000011ac
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001200
	ldr x1, =check_data3
	ldr x2, =0x00001208
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001220
	ldr x1, =check_data4
	ldr x2, =0x00001228
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffe
	ldr x1, =check_data5
	ldr x2, =0x00001fff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40406000
	ldr x1, =check_data7
	ldr x2, =0x40406008
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
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x65
.data
check_data6:
	.byte 0x13, 0x7c, 0xa6, 0xc8, 0xe8, 0x31, 0xc0, 0xc2, 0xdc, 0xff, 0x17, 0x88, 0x41, 0xd5, 0xe3, 0xe2
	.byte 0xdf, 0xcf, 0x49, 0x38, 0xff, 0xa7, 0x78, 0xe2, 0xbf, 0x67, 0x1e, 0x39, 0x3d, 0x54, 0x06, 0x38
	.byte 0xea, 0xff, 0xaa, 0xc8, 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1200
	/* C1 */
	.octa 0x1ffe
	/* C6 */
	.octa 0xffffffffffffffff
	/* C10 */
	.octa 0x80000000700040080000000040405fc3
	/* C15 */
	.octa 0x100100030000000000000001
	/* C29 */
	.octa 0x1865
	/* C30 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1200
	/* C1 */
	.octa 0x2063
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0xffffffffffffffff
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x100100030000000000000001
	/* C23 */
	.octa 0x1
	/* C29 */
	.octa 0x1865
	/* C30 */
	.octa 0x109c
initial_SP_EL0_value:
	.octa 0x80000000000100050000000000001220
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x80000000000100050000000000001220
final_PCC_value:
	.octa 0x200080000005004f0000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000005004f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001ff0
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
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020002b5 // add c21, c21, #0
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020202b5 // add c21, c21, #128
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020402b5 // add c21, c21, #256
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020602b5 // add c21, c21, #384
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020802b5 // add c21, c21, #512
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020a02b5 // add c21, c21, #640
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020c02b5 // add c21, c21, #768
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020e02b5 // add c21, c21, #896
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021002b5 // add c21, c21, #1024
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021202b5 // add c21, c21, #1152
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021402b5 // add c21, c21, #1280
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021602b5 // add c21, c21, #1408
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021802b5 // add c21, c21, #1536
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021a02b5 // add c21, c21, #1664
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021c02b5 // add c21, c21, #1792
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40400028
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021e02b5 // add c21, c21, #1920
	.inst 0xc2c212a0 // br c21

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
