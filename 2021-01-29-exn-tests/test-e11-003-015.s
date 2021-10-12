.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2deff1d // ALDUR-C.RI-C Ct:29 Rn:24 op2:11 imm9:111101111 V:0 op1:11 11100010:11100010
	.inst 0x826c5405 // ALDRB-R.RI-B Rt:5 Rn:0 op:01 imm9:011000101 L:1 1000001001:1000001001
	.inst 0xc2dd0411 // BUILD-C.C-C Cd:17 Cn:0 001:001 opc:00 0:0 Cm:29 11000010110:11000010110
	.inst 0x9b5e7fe1 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:31 Ra:11111 0:0 Rm:30 10:10 U:0 10011011:10011011
	.inst 0xc818ffb1 // stlxr:aarch64/instrs/memory/exclusive/single Rt:17 Rn:29 Rt2:11111 o0:1 Rs:24 0:0 L:0 0010000:0010000 size:11
	.zero 5100
	.inst 0x9b2087c7 // 0x9b2087c7
	.inst 0x887fabc1 // 0x887fabc1
	.inst 0x7804a434 // 0x7804a434
	.inst 0xc2ffa3ac // 0xc2ffa3ac
	.inst 0xd4000001
	.zero 60396
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400654 // ldr c20, [x18, #1]
	.inst 0xc2400a58 // ldr c24, [x18, #2]
	.inst 0xc2400e5e // ldr c30, [x18, #3]
	/* Set up flags and system registers */
	ldr x18, =0x0
	msr SPSR_EL3, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30d5d99f
	msr SCTLR_EL1, x18
	ldr x18, =0xc0000
	msr CPACR_EL1, x18
	ldr x18, =0x4
	msr S3_0_C1_C2_2, x18 // CCTLR_EL1
	ldr x18, =0x0
	msr S3_3_C1_C2_2, x18 // CCTLR_EL0
	ldr x18, =initial_DDC_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884132 // msr DDC_EL0, c18
	ldr x18, =initial_DDC_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc28c4132 // msr DDC_EL1, c18
	ldr x18, =0x80000000
	msr HCR_EL2, x18
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601132 // ldr c18, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e4032 // msr CELR_EL3, c18
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400249 // ldr c9, [x18, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400649 // ldr c9, [x18, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400a49 // ldr c9, [x18, #2]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2400e49 // ldr c9, [x18, #3]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2401249 // ldr c9, [x18, #4]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2401649 // ldr c9, [x18, #5]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401a49 // ldr c9, [x18, #6]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2401e49 // ldr c9, [x18, #7]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2402249 // ldr c9, [x18, #8]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc2402649 // ldr c9, [x18, #9]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402a49 // ldr c9, [x18, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x18, =final_PCC_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	ldr x9, =esr_el1_dump_address
	ldr x9, [x9]
	mov x18, 0x83
	orr x9, x9, x18
	ldr x18, =0x920000eb
	cmp x18, x9
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
	ldr x0, =0x00001fe4
	ldr x1, =check_data1
	ldr x2, =0x00001fe6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
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
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40401400
	ldr x1, =check_data5
	ldr x2, =0x40401414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 4064
	.byte 0xe4, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xe4, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x1d, 0xff, 0xde, 0xe2, 0x05, 0x54, 0x6c, 0x82, 0x11, 0x04, 0xdd, 0xc2, 0xe1, 0x7f, 0x5e, 0x9b
	.byte 0xb1, 0xff, 0x18, 0xc8
.data
check_data5:
	.byte 0xc7, 0x87, 0x20, 0x9b, 0xc1, 0xab, 0x7f, 0x88, 0x34, 0xa4, 0x04, 0x78, 0xac, 0xa3, 0xff, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001f39
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x90000000000100050000000000001011
	/* C30 */
	.octa 0x1ff0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001f39
	/* C1 */
	.octa 0x202e
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0xfffffffffc1ad390
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x101800000000080000000000000
	/* C17 */
	.octa 0x80000000000100050000000000001f39
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x90000000000100050000000000001011
	/* C29 */
	.octa 0x101800000000080000000000000
	/* C30 */
	.octa 0x1ff0
initial_DDC_EL0_value:
	.octa 0x800000000000000000000000
initial_DDC_EL1_value:
	.octa 0xc00000000006000100fffffff8000001
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040401000
final_PCC_value:
	.octa 0x200080004000041d0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700010000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
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
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02000252 // add c18, c18, #0
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02020252 // add c18, c18, #128
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02040252 // add c18, c18, #256
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02060252 // add c18, c18, #384
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02080252 // add c18, c18, #512
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x020a0252 // add c18, c18, #640
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x020c0252 // add c18, c18, #768
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x020e0252 // add c18, c18, #896
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02100252 // add c18, c18, #1024
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02120252 // add c18, c18, #1152
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02140252 // add c18, c18, #1280
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02160252 // add c18, c18, #1408
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02180252 // add c18, c18, #1536
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x021a0252 // add c18, c18, #1664
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x021c0252 // add c18, c18, #1792
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40401414
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x021e0252 // add c18, c18, #1920
	.inst 0xc2c21240 // br c18

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
