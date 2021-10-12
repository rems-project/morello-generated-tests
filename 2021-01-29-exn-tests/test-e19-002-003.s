.section text0, #alloc, #execinstr
test_start:
	.inst 0x78be43c0 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:30 00:00 opc:100 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x3a160301 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:24 000000:000000 Rm:22 11010000:11010000 S:1 op:0 sf:0
	.inst 0xe2db97be // ALDUR-R.RI-64 Rt:30 Rn:29 op2:01 imm9:110111001 V:0 op1:11 11100010:11100010
	.inst 0x1084233f // ADR-C.I-C Rd:31 immhi:000010000100011001 P:1 10000:10000 immlo:00 op:0
	.inst 0x78e623df // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:30 00:00 opc:010 0:0 Rs:6 1:1 R:1 A:1 111000:111000 size:01
	.zero 108
	.inst 0x8296f87f // ALDRSH-R.RRB-64 Rt:31 Rn:3 opc:10 S:1 option:111 Rm:22 0:0 L:0 100000101:100000101
	.inst 0x387d83ae // swpb:aarch64/instrs/memory/atomicops/swp Rt:14 Rn:29 100000:100000 Rs:29 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xd4000001
	.zero 884
	.inst 0xc2d28721 // 0xc2d28721
	.inst 0xd65f0000 // 0xd65f0000
	.zero 64504
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
	.inst 0xc2400103 // ldr c3, [x8, #0]
	.inst 0xc2400512 // ldr c18, [x8, #1]
	.inst 0xc2400916 // ldr c22, [x8, #2]
	.inst 0xc2400d19 // ldr c25, [x8, #3]
	.inst 0xc240111d // ldr c29, [x8, #4]
	.inst 0xc240151e // ldr c30, [x8, #5]
	/* Set up flags and system registers */
	ldr x8, =0x0
	msr SPSR_EL3, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0xc0000
	msr CPACR_EL1, x8
	ldr x8, =0x8
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
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012e8 // ldr c8, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	mov x23, #0xf
	and x8, x8, x23
	cmp x8, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400117 // ldr c23, [x8, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400517 // ldr c23, [x8, #1]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400917 // ldr c23, [x8, #2]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2400d17 // ldr c23, [x8, #3]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2401117 // ldr c23, [x8, #4]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2401517 // ldr c23, [x8, #5]
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	.inst 0xc2401917 // ldr c23, [x8, #6]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2401d17 // ldr c23, [x8, #7]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x8, 0x83
	orr x23, x23, x8
	ldr x8, =0x920000a3
	cmp x8, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001057
	ldr x1, =check_data2
	ldr x2, =0x00001058
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
	ldr x0, =0x4040001a
	ldr x1, =check_data4
	ldr x2, =0x4040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400080
	ldr x1, =check_data5
	ldr x2, =0x4040008c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400408
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 16
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x00, 0x10
.data
check_data1:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x1f
.data
check_data2:
	.byte 0x57
.data
check_data3:
	.byte 0xc0, 0x43, 0xbe, 0x78, 0x01, 0x03, 0x16, 0x3a, 0xbe, 0x97, 0xdb, 0xe2, 0x3f, 0x23, 0x84, 0x10
	.byte 0xdf, 0x23, 0xe6, 0x78
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x7f, 0xf8, 0x96, 0x82, 0xae, 0x83, 0x7d, 0x38, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0x21, 0x87, 0xd2, 0xc2, 0x00, 0x00, 0x5f, 0xd6

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x10
	/* C18 */
	.octa 0x1883bb870001800000000000
	/* C22 */
	.octa 0x20200005
	/* C25 */
	.octa 0x620208220002000001ffe000
	/* C29 */
	.octa 0xc0000000600000020000000000001057
	/* C30 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x10
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x1883bb870001800000000000
	/* C22 */
	.octa 0x20200005
	/* C25 */
	.octa 0x620208220002000001ffe000
	/* C29 */
	.octa 0xc0000000600000020000000000001057
	/* C30 */
	.octa 0x1f80000000000001
initial_DDC_EL0_value:
	.octa 0xc0000000106900070000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000101e9105000000003e810401
initial_VBAR_EL1_value:
	.octa 0x20008000400000800000000040400001
final_PCC_value:
	.octa 0x2000800040000080000000004040008c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600200000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
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
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x82600ee8 // ldr x8, [c23, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ee8 // str x8, [c23, #0]
	ldr x8, =0x4040008c
	mrs x23, ELR_EL1
	sub x8, x8, x23
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b117 // cvtp c23, x8
	.inst 0xc2c842f7 // scvalue c23, c23, x8
	.inst 0x826002e8 // ldr c8, [c23, #0]
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
