.section text0, #alloc, #execinstr
test_start:
	.inst 0x783133bf // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:011 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25000 // RET-C-C 00000:00000 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 13304
	.inst 0x5ac01411 // 0x5ac01411
	.inst 0xa25cdbd8 // 0xa25cdbd8
	.inst 0x78e44826 // 0x78e44826
	.inst 0xc2daa7a1 // 0xc2daa7a1
	.inst 0xd4000001
	.zero 19436
	.inst 0x3821303f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c132c0 // GCFLGS-R.C-C Rd:0 Cn:22 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xf927497f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:11 imm12:100111010010 opc:00 111001:111001 size:11
	.zero 32756
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e4 // ldr c4, [x15, #2]
	.inst 0xc2400deb // ldr c11, [x15, #3]
	.inst 0xc24011f1 // ldr c17, [x15, #4]
	.inst 0xc24015fa // ldr c26, [x15, #5]
	.inst 0xc24019fd // ldr c29, [x15, #6]
	.inst 0xc2401dfe // ldr c30, [x15, #7]
	/* Set up flags and system registers */
	ldr x15, =0x0
	msr SPSR_EL3, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x0
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260132f // ldr c15, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc28e402f // msr CELR_EL3, c15
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x25, #0xf
	and x15, x15, x25
	cmp x15, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f9 // ldr c25, [x15, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24005f9 // ldr c25, [x15, #1]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc24009f9 // ldr c25, [x15, #2]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc2400df9 // ldr c25, [x15, #3]
	.inst 0xc2d9a561 // chkeq c11, c25
	b.ne comparison_fail
	.inst 0xc24011f9 // ldr c25, [x15, #4]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc24015f9 // ldr c25, [x15, #5]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc24019f9 // ldr c25, [x15, #6]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc2401df9 // ldr c25, [x15, #7]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc24021f9 // ldr c25, [x15, #8]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x15, 0x83
	orr x25, x25, x15
	ldr x15, =0x920000e3
	cmp x15, x25
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
	ldr x0, =0x00001808
	ldr x1, =check_data1
	ldr x2, =0x0000180a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40403400
	ldr x1, =check_data4
	ldr x2, =0x40403414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40408000
	ldr x1, =check_data5
	ldr x2, =0x4040800c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040ffe4
	ldr x1, =check_data6
	ldr x2, =0x4040ffe6
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
	.byte 0xbf, 0x33, 0x31, 0x78, 0x00, 0x50, 0xc2, 0xc2
.data
check_data4:
	.byte 0x11, 0x14, 0xc0, 0x5a, 0xd8, 0xdb, 0x5c, 0xa2, 0x26, 0x48, 0xe4, 0x78, 0xa1, 0xa7, 0xda, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0x3f, 0x30, 0x21, 0x38, 0xc0, 0x32, 0xc1, 0xc2, 0x7f, 0x49, 0x27, 0xf9
.data
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000800741070000000040408001
	/* C1 */
	.octa 0xc00000000000c0000000000000001000
	/* C4 */
	.octa 0x4040efe4
	/* C11 */
	.octa 0x4000000050041584001ffff790c8008d
	/* C17 */
	.octa 0x0
	/* C26 */
	.octa 0x1808
	/* C29 */
	.octa 0x1808
	/* C30 */
	.octa 0x80000000000100050000000000002310
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xc00000000000c0000000000000001000
	/* C4 */
	.octa 0x4040efe4
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x4000000050041584001ffff790c8008d
	/* C17 */
	.octa 0x1f
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x1808
	/* C29 */
	.octa 0x1808
	/* C30 */
	.octa 0x80000000000100050000000000002310
initial_DDC_EL0_value:
	.octa 0xc0000000000080080000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000241d0000000040403001
final_PCC_value:
	.octa 0x200080004000241d0000000040403414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000f80470000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x82600f2f // ldr x15, [c25, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f2f // str x15, [c25, #0]
	ldr x15, =0x40403414
	mrs x25, ELR_EL1
	sub x15, x15, x25
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f9 // cvtp c25, x15
	.inst 0xc2cf4339 // scvalue c25, c25, x15
	.inst 0x8260032f // ldr c15, [c25, #0]
	.inst 0x021e01ef // add c15, c15, #1920
	.inst 0xc2c211e0 // br c15

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
