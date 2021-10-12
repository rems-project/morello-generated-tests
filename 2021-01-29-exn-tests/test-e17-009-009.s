.section text0, #alloc, #execinstr
test_start:
	.inst 0x783133bf // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:011 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25000 // RET-C-C 00000:00000 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x3821303f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c132c0 // GCFLGS-R.C-C Rd:0 Cn:22 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xf927497f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:11 imm12:100111010010 opc:00 111001:111001 size:11
	.zero 21484
	.inst 0x5ac01411 // 0x5ac01411
	.inst 0xa25cdbd8 // 0xa25cdbd8
	.inst 0x78e44826 // 0x78e44826
	.inst 0xc2daa7a1 // 0xc2daa7a1
	.inst 0xd4000001
	.zero 44012
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
	.inst 0xc2400904 // ldr c4, [x8, #2]
	.inst 0xc2400d0b // ldr c11, [x8, #3]
	.inst 0xc2401111 // ldr c17, [x8, #4]
	.inst 0xc240151a // ldr c26, [x8, #5]
	.inst 0xc240191d // ldr c29, [x8, #6]
	.inst 0xc2401d1e // ldr c30, [x8, #7]
	/* Set up flags and system registers */
	ldr x8, =0x0
	msr SPSR_EL3, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0xc0000
	msr CPACR_EL1, x8
	ldr x8, =0x4
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x0
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010a8 // ldr c8, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x5, #0xf
	and x8, x8, x5
	cmp x8, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400105 // ldr c5, [x8, #0]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400505 // ldr c5, [x8, #1]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2400905 // ldr c5, [x8, #2]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2400d05 // ldr c5, [x8, #3]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2401105 // ldr c5, [x8, #4]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2401505 // ldr c5, [x8, #5]
	.inst 0xc2c5a701 // chkeq c24, c5
	b.ne comparison_fail
	.inst 0xc2401905 // ldr c5, [x8, #6]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2401d05 // ldr c5, [x8, #7]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402105 // ldr c5, [x8, #8]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x8, 0x83
	orr x5, x5, x8
	ldr x8, =0x920000eb
	cmp x8, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001003
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001050
	ldr x1, =check_data1
	ldr x2, =0x00001060
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001220
	ldr x1, =check_data2
	ldr x2, =0x00001222
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
	ldr x0, =0x40401404
	ldr x1, =check_data4
	ldr x2, =0x40401406
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40405400
	ldr x1, =check_data5
	ldr x2, =0x40405414
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
	.byte 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x82
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xbf, 0x33, 0x31, 0x78, 0x00, 0x50, 0xc2, 0xc2, 0x3f, 0x30, 0x21, 0x38, 0xc0, 0x32, 0xc1, 0xc2
	.byte 0x7f, 0x49, 0x27, 0xf9
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x11, 0x14, 0xc0, 0x5a, 0xd8, 0xdb, 0x5c, 0xa2, 0x26, 0x48, 0xe4, 0x78, 0xa1, 0xa7, 0xda, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000800600030000000040400009
	/* C1 */
	.octa 0xc0000000000100050000000000001002
	/* C4 */
	.octa 0x40400402
	/* C11 */
	.octa 0x80
	/* C17 */
	.octa 0x0
	/* C26 */
	.octa 0xffffffffffffffffffffffffffffeddf
	/* C29 */
	.octa 0x1220
	/* C30 */
	.octa 0x1380
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xc0000000000100050000000000001002
	/* C4 */
	.octa 0x40400402
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x80
	/* C17 */
	.octa 0x1f
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0xffffffffffffffffffffffffffffeddf
	/* C29 */
	.octa 0x1220
	/* C30 */
	.octa 0x1380
initial_DDC_EL0_value:
	.octa 0xc0000000400000220000000000000001
initial_DDC_EL1_value:
	.octa 0x90000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000441d0000000040405000
final_PCC_value:
	.octa 0x200080004000441d0000000040405414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001050
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40405414
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
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
