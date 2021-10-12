.section text0, #alloc, #execinstr
test_start:
	.inst 0x783133bf // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:011 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25000 // RET-C-C 00000:00000 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x3821303f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c132c0 // GCFLGS-R.C-C Rd:0 Cn:22 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xf927497f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:11 imm12:100111010010 opc:00 111001:111001 size:11
	.zero 1004
	.inst 0x5ac01411 // 0x5ac01411
	.inst 0xa25cdbd8 // 0xa25cdbd8
	.inst 0x78e44826 // 0x78e44826
	.inst 0xc2daa7a1 // 0xc2daa7a1
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae4 // ldr c4, [x23, #2]
	.inst 0xc2400eeb // ldr c11, [x23, #3]
	.inst 0xc24012f1 // ldr c17, [x23, #4]
	.inst 0xc24016fa // ldr c26, [x23, #5]
	.inst 0xc2401afd // ldr c29, [x23, #6]
	.inst 0xc2401efe // ldr c30, [x23, #7]
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x4
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x0
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82601117 // ldr c23, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x8, #0xf
	and x23, x23, x8
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e8 // ldr c8, [x23, #0]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc24006e8 // ldr c8, [x23, #1]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc2400ae8 // ldr c8, [x23, #2]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc2400ee8 // ldr c8, [x23, #3]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc24012e8 // ldr c8, [x23, #4]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc24016e8 // ldr c8, [x23, #5]
	.inst 0xc2c8a701 // chkeq c24, c8
	b.ne comparison_fail
	.inst 0xc2401ae8 // ldr c8, [x23, #6]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2401ee8 // ldr c8, [x23, #7]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc24022e8 // ldr c8, [x23, #8]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x23, 0x83
	orr x8, x8, x23
	ldr x23, =0x920000eb
	cmp x23, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001700
	ldr x1, =check_data0
	ldr x2, =0x00001701
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001854
	ldr x1, =check_data1
	ldr x2, =0x00001856
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001cd0
	ldr x1, =check_data2
	ldr x2, =0x00001ce0
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
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40405200
	ldr x1, =check_data5
	ldr x2, =0x40405202
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xbf, 0x33, 0x31, 0x78, 0x00, 0x50, 0xc2, 0xc2, 0x3f, 0x30, 0x21, 0x38, 0xc0, 0x32, 0xc1, 0xc2
	.byte 0x7f, 0x49, 0x27, 0xf9
.data
check_data4:
	.byte 0x11, 0x14, 0xc0, 0x5a, 0xd8, 0xdb, 0x5c, 0xa2, 0x26, 0x48, 0xe4, 0x78, 0xa1, 0xa7, 0xda, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000802780000000000040400009
	/* C1 */
	.octa 0xc0000000600000020000000000001700
	/* C4 */
	.octa 0x40403b00
	/* C11 */
	.octa 0x4000000000210004ff00000000000006
	/* C17 */
	.octa 0x0
	/* C26 */
	.octa 0xffffffffffffffffffffffffffffe7ab
	/* C29 */
	.octa 0x1854
	/* C30 */
	.octa 0x2000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xc0000000600000020000000000001700
	/* C4 */
	.octa 0x40403b00
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x4000000000210004ff00000000000006
	/* C17 */
	.octa 0x1f
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0xffffffffffffffffffffffffffffe7ab
	/* C29 */
	.octa 0x1854
	/* C30 */
	.octa 0x2000
initial_DDC_EL0_value:
	.octa 0xc0000000200140050080000000000000
initial_DDC_EL1_value:
	.octa 0x80000000200010000000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400000
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
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
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400414
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
