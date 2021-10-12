.section text0, #alloc, #execinstr
test_start:
	.inst 0x783133bf // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:011 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25000 // RET-C-C 00000:00000 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 11256
	.inst 0x5ac01411 // 0x5ac01411
	.inst 0xa25cdbd8 // 0xa25cdbd8
	.inst 0x78e44826 // 0x78e44826
	.inst 0xc2daa7a1 // 0xc2daa7a1
	.inst 0xd4000001
	.zero 25572
	.inst 0x3821303f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c132c0 // GCFLGS-R.C-C Rd:0 Cn:22 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xf927497f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:11 imm12:100111010010 opc:00 111001:111001 size:11
	.zero 28668
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b84 // ldr c4, [x28, #2]
	.inst 0xc2400f8b // ldr c11, [x28, #3]
	.inst 0xc2401391 // ldr c17, [x28, #4]
	.inst 0xc240179a // ldr c26, [x28, #5]
	.inst 0xc2401b9d // ldr c29, [x28, #6]
	.inst 0xc2401f9e // ldr c30, [x28, #7]
	/* Set up flags and system registers */
	ldr x28, =0x0
	msr SPSR_EL3, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0xc0000
	msr CPACR_EL1, x28
	ldr x28, =0x0
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x0
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
	ldr x28, =initial_DDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288413c // msr DDC_EL0, c28
	ldr x28, =initial_DDC_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28c413c // msr DDC_EL1, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011fc // ldr c28, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e403c // msr CELR_EL3, c28
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x15, #0xf
	and x28, x28, x15
	cmp x28, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038f // ldr c15, [x28, #0]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240078f // ldr c15, [x28, #1]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc2400b8f // ldr c15, [x28, #2]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc2400f8f // ldr c15, [x28, #3]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc240138f // ldr c15, [x28, #4]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc240178f // ldr c15, [x28, #5]
	.inst 0xc2cfa701 // chkeq c24, c15
	b.ne comparison_fail
	.inst 0xc2401b8f // ldr c15, [x28, #6]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc2401f8f // ldr c15, [x28, #7]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc240238f // ldr c15, [x28, #8]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	ldr x15, =esr_el1_dump_address
	ldr x15, [x15]
	mov x28, 0x83
	orr x15, x15, x28
	ldr x28, =0x920000e3
	cmp x28, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001011
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000147a
	ldr x1, =check_data1
	ldr x2, =0x0000147c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400008
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40402c00
	ldr x1, =check_data3
	ldr x2, =0x40402c14
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40408ff8
	ldr x1, =check_data4
	ldr x2, =0x40409004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040ffec
	ldr x1, =check_data5
	ldr x2, =0x4040ffee
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
	.zero 16
	.byte 0x10
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xbf, 0x33, 0x31, 0x78, 0x00, 0x50, 0xc2, 0xc2
.data
check_data3:
	.byte 0x11, 0x14, 0xc0, 0x5a, 0xd8, 0xdb, 0x5c, 0xa2, 0x26, 0x48, 0xe4, 0x78, 0xa1, 0xa7, 0xda, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.byte 0x3f, 0x30, 0x21, 0x38, 0xc0, 0x32, 0xc1, 0xc2, 0x7f, 0x49, 0x27, 0xf9
.data
check_data5:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x200080008007800f0000000040408ff9
	/* C1 */
	.octa 0xc0000000000700060000000000001010
	/* C4 */
	.octa 0x4040efdc
	/* C11 */
	.octa 0x400000000007800e004100001fff1181
	/* C17 */
	.octa 0x0
	/* C26 */
	.octa 0x147a
	/* C29 */
	.octa 0x147a
	/* C30 */
	.octa 0x1330
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xc0000000000700060000000000001010
	/* C4 */
	.octa 0x4040efdc
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x400000000007800e004100001fff1181
	/* C17 */
	.octa 0x1f
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x147a
	/* C29 */
	.octa 0x147a
	/* C30 */
	.octa 0x1330
initial_DDC_EL0_value:
	.octa 0xc0000000400100050000000000000001
initial_DDC_EL1_value:
	.octa 0x90000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000241d0000000040402800
final_PCC_value:
	.octa 0x200080004000241d0000000040402c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001007900f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40402c14
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x021e039c // add c28, c28, #1920
	.inst 0xc2c21380 // br c28

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
