.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1939d // CLRTAG-C.C-C Cd:29 Cn:28 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x889ffc55 // stlr:aarch64/instrs/memory/ordered Rt:21 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x8834fbe0 // stlxp:aarch64/instrs/memory/exclusive/pair Rt:0 Rn:31 Rt2:11110 o0:1 Rs:20 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0x82548865 // ASTR-R.RI-32 Rt:5 Rn:3 op:10 imm9:101001000 L:0 1000001001:1000001001
	.inst 0x29b9ffbe // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:30 Rn:29 Rt2:11111 imm7:1110011 L:0 1010011:1010011 opc:00
	.zero 1004
	.inst 0xd8001f06 // 0xd8001f06
	.inst 0x386a30c1 // 0x386a30c1
	.inst 0x382802bf // 0x382802bf
	.inst 0x38bfc00d // 0x38bfc00d
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc2400923 // ldr c3, [x9, #2]
	.inst 0xc2400d25 // ldr c5, [x9, #3]
	.inst 0xc2401126 // ldr c6, [x9, #4]
	.inst 0xc2401528 // ldr c8, [x9, #5]
	.inst 0xc240192a // ldr c10, [x9, #6]
	.inst 0xc2401d35 // ldr c21, [x9, #7]
	.inst 0xc240213c // ldr c28, [x9, #8]
	/* Set up flags and system registers */
	ldr x9, =0x4000000
	msr SPSR_EL3, x9
	ldr x9, =initial_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884109 // msr CSP_EL0, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0xc0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x4
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =initial_DDC_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28c4129 // msr DDC_EL1, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601089 // ldr c9, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400124 // ldr c4, [x9, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400524 // ldr c4, [x9, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400924 // ldr c4, [x9, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400d24 // ldr c4, [x9, #3]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc2401124 // ldr c4, [x9, #4]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2401524 // ldr c4, [x9, #5]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2401924 // ldr c4, [x9, #6]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc2401d24 // ldr c4, [x9, #7]
	.inst 0xc2c4a541 // chkeq c10, c4
	b.ne comparison_fail
	.inst 0xc2402124 // ldr c4, [x9, #8]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc2402524 // ldr c4, [x9, #9]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc2402924 // ldr c4, [x9, #10]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc2402d24 // ldr c4, [x9, #11]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc2403124 // ldr c4, [x9, #12]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984104 // mrs c4, CSP_EL0
	.inst 0xc2c4a521 // chkeq c9, c4
	b.ne comparison_fail
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a521 // chkeq c9, c4
	b.ne comparison_fail
	ldr x4, =esr_el1_dump_address
	ldr x4, [x4]
	mov x9, 0x83
	orr x4, x4, x9
	ldr x9, =0x920000eb
	cmp x9, x4
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
	ldr x0, =0x00001540
	ldr x1, =check_data1
	ldr x2, =0x00001544
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001801
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001820
	ldr x1, =check_data3
	ldr x2, =0x00001828
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
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x9d, 0x93, 0xc1, 0xc2, 0x55, 0xfc, 0x9f, 0x88, 0xe0, 0xfb, 0x34, 0x88, 0x65, 0x88, 0x54, 0x82
	.byte 0xbe, 0xff, 0xb9, 0x29
.data
check_data5:
	.byte 0x06, 0x1f, 0x00, 0xd8, 0xc1, 0x30, 0x6a, 0x38, 0xbf, 0x02, 0x28, 0x38, 0x0d, 0xc0, 0xbf, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1002
	/* C2 */
	.octa 0x40000000000100050000000000001000
	/* C3 */
	.octa 0x1020
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x1800
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C21 */
	.octa 0x1000
	/* C28 */
	.octa 0x34
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1002
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000000100050000000000001000
	/* C3 */
	.octa 0x1020
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x1800
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C20 */
	.octa 0x1
	/* C21 */
	.octa 0x1000
	/* C28 */
	.octa 0x34
	/* C29 */
	.octa 0x34
initial_SP_EL0_value:
	.octa 0x40000000000300030000000000001820
initial_DDC_EL0_value:
	.octa 0x400000000000c000000000000000c001
initial_DDC_EL1_value:
	.octa 0xc00000000003000700ffe00000100001
initial_VBAR_EL1_value:
	.octa 0x200080004414001d0000000040400000
final_SP_EL0_value:
	.octa 0x40000000000300030000000000001820
final_PCC_value:
	.octa 0x200080004414001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
