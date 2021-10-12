.section text0, #alloc, #execinstr
test_start:
	.inst 0xb23ff3c1 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:30 imms:111100 immr:111111 N:0 100100:100100 opc:01 sf:1
	.inst 0xc2d403bb // SCBNDS-C.CR-C Cd:27 Cn:29 000:000 opc:00 0:0 Rm:20 11000010110:11000010110
	.inst 0xb87363bf // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:110 o3:0 Rs:19 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x82de5566 // ALDRSB-R.RRB-32 Rt:6 Rn:11 opc:01 S:1 option:010 Rm:30 0:0 L:1 100000101:100000101
	.inst 0x82485bdd // ASTR-R.RI-32 Rt:29 Rn:30 op:10 imm9:010000101 L:0 1000001001:1000001001
	.zero 4
	.inst 0xd4000001
	.zero 58340
	.inst 0x700dfccb // 0x700dfccb
	.inst 0x427ffffd // 0x427ffffd
	.inst 0x887f08fe // 0x887f08fe
	.inst 0xc2c23323 // 0xc2c23323
	.zero 7152
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
	ldr x0, =initial_cap_values
	.inst 0xc2400007 // ldr c7, [x0, #0]
	.inst 0xc240040b // ldr c11, [x0, #1]
	.inst 0xc2400813 // ldr c19, [x0, #2]
	.inst 0xc2400c19 // ldr c25, [x0, #3]
	.inst 0xc240101d // ldr c29, [x0, #4]
	.inst 0xc240141e // ldr c30, [x0, #5]
	/* Set up flags and system registers */
	ldr x0, =0x0
	msr SPSR_EL3, x0
	ldr x0, =initial_SP_EL1_value
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0xc28c4100 // msr CSP_EL1, c0
	ldr x0, =0x200
	msr CPTR_EL3, x0
	ldr x0, =0x30d5d99f
	msr SCTLR_EL1, x0
	ldr x0, =0xc0000
	msr CPACR_EL1, x0
	ldr x0, =0x80
	msr S3_0_C1_C2_2, x0 // CCTLR_EL1
	ldr x0, =0x4
	msr S3_3_C1_C2_2, x0 // CCTLR_EL0
	ldr x0, =initial_DDC_EL0_value
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0xc2884120 // msr DDC_EL0, c0
	ldr x0, =initial_DDC_EL1_value
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0xc28c4120 // msr DDC_EL1, c0
	ldr x0, =0x80000000
	msr HCR_EL2, x0
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012a0 // ldr c0, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc28e4020 // msr CELR_EL3, c0
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b000 // cvtp c0, x0
	.inst 0xc2df4000 // scvalue c0, c0, x31
	.inst 0xc28b4120 // msr DDC_EL3, c0
	ldr x0, =0x30851035
	msr SCTLR_EL3, x0
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x0, =final_cap_values
	.inst 0xc2400015 // ldr c21, [x0, #0]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400415 // ldr c21, [x0, #1]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400815 // ldr c21, [x0, #2]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc2400c15 // ldr c21, [x0, #3]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2401015 // ldr c21, [x0, #4]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401415 // ldr c21, [x0, #5]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc2401815 // ldr c21, [x0, #6]
	.inst 0xc2d5a721 // chkeq c25, c21
	b.ne comparison_fail
	.inst 0xc2401c15 // ldr c21, [x0, #7]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2402015 // ldr c21, [x0, #8]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check system registers */
	ldr x0, =final_SP_EL1_value
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0xc29c4115 // mrs c21, CSP_EL1
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	ldr x0, =final_PCC_value
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	ldr x21, =esr_el1_dump_address
	ldr x21, [x21]
	mov x0, 0x83
	orr x21, x21, x0
	ldr x0, =0x920000eb
	cmp x0, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001100
	ldr x1, =check_data0
	ldr x2, =0x00001104
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff0
	ldr x1, =check_data1
	ldr x2, =0x00001ff8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffa
	ldr x1, =check_data2
	ldr x2, =0x00001ffb
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
	ldr x0, =0x40400018
	ldr x1, =check_data4
	ldr x2, =0x4040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x404080f0
	ldr x1, =check_data5
	ldr x2, =0x404080f4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040e400
	ldr x1, =check_data6
	ldr x2, =0x4040e410
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x0, =0x30850030
	msr SCTLR_EL3, x0
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b000 // cvtp c0, x0
	.inst 0xc2df4000 // scvalue c0, c0, x31
	.inst 0xc28b4120 // msr DDC_EL3, c0
	ldr x0, =0x30850030
	msr SCTLR_EL3, x0
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
	.zero 256
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xc1, 0xf3, 0x3f, 0xb2, 0xbb, 0x03, 0xd4, 0xc2, 0xbf, 0x63, 0x73, 0xb8, 0x66, 0x55, 0xde, 0x82
	.byte 0xdd, 0x5b, 0x48, 0x82
.data
check_data4:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0xcb, 0xfc, 0x0d, 0x70, 0xfd, 0xff, 0x7f, 0x42, 0xfe, 0x08, 0x7f, 0x88, 0x23, 0x33, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x80000000000100050000000000001ff0
	/* C11 */
	.octa 0x800000000007000c000000000000137a
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x20000000800100050000000040400018
	/* C29 */
	.octa 0x700060000000000001100
	/* C30 */
	.octa 0x4000000000050402006ffeff00000c80
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xaaeffeffaaaaaeaa
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x80000000000100050000000000001ff0
	/* C11 */
	.octa 0x200080004000c60c000000004042a39b
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x20000000800100050000000040400018
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000c000c60c000000004040e411
initial_SP_EL1_value:
	.octa 0x404080f0
initial_DDC_EL0_value:
	.octa 0xc0000000000300020002000000000001
initial_DDC_EL1_value:
	.octa 0x80000000410242f10000000040410001
initial_VBAR_EL1_value:
	.octa 0x200080004000c60c000000004040e001
final_SP_EL1_value:
	.octa 0x404080f0
final_PCC_value:
	.octa 0x2000000000010005000000004040001c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 128
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
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x02000000 // add c0, c0, #0
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x02020000 // add c0, c0, #128
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x02040000 // add c0, c0, #256
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x02060000 // add c0, c0, #384
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x02080000 // add c0, c0, #512
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x020a0000 // add c0, c0, #640
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x020c0000 // add c0, c0, #768
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x020e0000 // add c0, c0, #896
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x02100000 // add c0, c0, #1024
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x02120000 // add c0, c0, #1152
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x02140000 // add c0, c0, #1280
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x02160000 // add c0, c0, #1408
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x02180000 // add c0, c0, #1536
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x021a0000 // add c0, c0, #1664
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x021c0000 // add c0, c0, #1792
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x82600ea0 // ldr x0, [c21, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400ea0 // str x0, [c21, #0]
	ldr x0, =0x4040001c
	mrs x21, ELR_EL1
	sub x0, x0, x21
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2c042b5 // scvalue c21, c21, x0
	.inst 0x826002a0 // ldr c0, [c21, #0]
	.inst 0x021e0000 // add c0, c0, #1920
	.inst 0xc2c21000 // br c0

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
