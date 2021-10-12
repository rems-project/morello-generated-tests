.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2ac67e0 // ALDUR-V.RI-S Rt:0 Rn:31 op2:01 imm9:011000110 V:1 op1:10 11100010:11100010
	.inst 0xeb3d901e // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:0 imm3:100 option:100 Rm:29 01011001:01011001 S:1 op:1 sf:1
	.inst 0xf820619f // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:12 00:00 opc:110 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x085ffc30 // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:16 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xe2336d5e // ALDUR-V.RI-Q Rt:30 Rn:10 op2:11 imm9:100110110 V:1 op1:00 11100010:11100010
	.zero 33772
	.inst 0xf2973000 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1011100110000000 hw:00 100101:100101 opc:11 sf:1
	.inst 0xc2cbfbbd // SCBNDS-C.CI-S Cd:29 Cn:29 1110:1110 S:1 imm6:010111 11000010110:11000010110
	.inst 0x287307be // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:30 Rn:29 Rt2:00001 imm7:1100110 L:1 1010000:1010000 opc:00
	.inst 0x38bfc1be // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:30 Rn:13 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0xd4000001
	.zero 31724
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
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc240092a // ldr c10, [x9, #2]
	.inst 0xc2400d2c // ldr c12, [x9, #3]
	.inst 0xc240112d // ldr c13, [x9, #4]
	.inst 0xc240153d // ldr c29, [x9, #5]
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
	ldr x9, =0x3c0000
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
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012e9 // ldr c9, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x23, #0xf
	and x9, x9, x23
	cmp x9, #0x3
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400137 // ldr c23, [x9, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400537 // ldr c23, [x9, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400937 // ldr c23, [x9, #2]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2400d37 // ldr c23, [x9, #3]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401137 // ldr c23, [x9, #4]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc2401537 // ldr c23, [x9, #5]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2401937 // ldr c23, [x9, #6]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2401d37 // ldr c23, [x9, #7]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x23, v0.d[0]
	cmp x9, x23
	b.ne comparison_fail
	ldr x9, =0x0
	mov x23, v0.d[1]
	cmp x9, x23
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	ldr x9, =esr_el1_dump_address
	ldr x9, [x9]
	mov x23, 0x80
	orr x9, x9, x23
	ldr x23, =0x920000a1
	cmp x23, x9
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
	ldr x0, =0x000014d0
	ldr x1, =check_data1
	ldr x2, =0x000014d4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x40408400
	ldr x1, =check_data4
	ldr x2, =0x40408414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xe0, 0x67, 0xac, 0xe2, 0x1e, 0x90, 0x3d, 0xeb, 0x9f, 0x61, 0x20, 0xf8, 0x30, 0xfc, 0x5f, 0x08
	.byte 0x5e, 0x6d, 0x33, 0xe2
.data
check_data4:
	.byte 0x00, 0x30, 0x97, 0xf2, 0xbd, 0xfb, 0xcb, 0xc2, 0xbe, 0x07, 0x73, 0x28, 0xbe, 0xc1, 0xbf, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000000000
	/* C1 */
	.octa 0x80000000200700090000000000001000
	/* C10 */
	.octa 0xf9
	/* C12 */
	.octa 0xc0000000400000040000000000001000
	/* C13 */
	.octa 0x1ffe
	/* C29 */
	.octa 0x600070000000000001070
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800000000000b980
	/* C1 */
	.octa 0x0
	/* C10 */
	.octa 0xf9
	/* C12 */
	.octa 0xc0000000400000040000000000001000
	/* C13 */
	.octa 0x1ffe
	/* C16 */
	.octa 0x0
	/* C29 */
	.octa 0x51e010700000000000001070
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x200
initial_DDC_EL0_value:
	.octa 0x800000005600120a00ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x80000000400100020000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004800801d0000000040408000
final_SP_EL0_value:
	.octa 0x200
final_PCC_value:
	.octa 0x200080004800801d0000000040408414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x82600ee9 // ldr x9, [c23, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ee9 // str x9, [c23, #0]
	ldr x9, =0x40408414
	mrs x23, ELR_EL1
	sub x9, x9, x23
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b137 // cvtp c23, x9
	.inst 0xc2c942f7 // scvalue c23, c23, x9
	.inst 0x826002e9 // ldr c9, [c23, #0]
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
