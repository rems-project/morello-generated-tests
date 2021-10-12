.section text0, #alloc, #execinstr
test_start:
	.inst 0xe213e3e9 // ASTURB-R.RI-32 Rt:9 Rn:31 op2:00 imm9:100111110 V:0 op1:00 11100010:11100010
	.inst 0x089f7f80 // stllrb:aarch64/instrs/memory/ordered Rt:0 Rn:28 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x38bd427d // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:19 00:00 opc:100 0:0 Rs:29 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x427ffdc2 // ALDAR-R.R-32 Rt:2 Rn:14 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xf878601d // ldumax:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:0 00:00 opc:110 0:0 Rs:24 1:1 R:1 A:0 111000:111000 size:11
	.inst 0xd4000001
	.zero 1000
	.inst 0x9b107ee6 // 0x9b107ee6
	.inst 0x28035fe1 // 0x28035fe1
	.inst 0x9bc17e3e // 0x9bc17e3e
	.inst 0xd63f00c0 // 0xd63f00c0
	.zero 64496
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
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a49 // ldr c9, [x18, #2]
	.inst 0xc2400e4e // ldr c14, [x18, #3]
	.inst 0xc2401250 // ldr c16, [x18, #4]
	.inst 0xc2401653 // ldr c19, [x18, #5]
	.inst 0xc2401a57 // ldr c23, [x18, #6]
	.inst 0xc2401e5c // ldr c28, [x18, #7]
	.inst 0xc240225d // ldr c29, [x18, #8]
	/* Set up flags and system registers */
	ldr x18, =0x0
	msr SPSR_EL3, x18
	ldr x18, =initial_SP_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884112 // msr CSP_EL0, c18
	ldr x18, =initial_SP_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc28c4112 // msr CSP_EL1, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30d5d99f
	msr SCTLR_EL1, x18
	ldr x18, =0xc0000
	msr CPACR_EL1, x18
	ldr x18, =0x0
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
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010f2 // ldr c18, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	.inst 0xc2400247 // ldr c7, [x18, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400647 // ldr c7, [x18, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400a47 // ldr c7, [x18, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400e47 // ldr c7, [x18, #3]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc2401247 // ldr c7, [x18, #4]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401647 // ldr c7, [x18, #5]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401a47 // ldr c7, [x18, #6]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc2401e47 // ldr c7, [x18, #7]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2402247 // ldr c7, [x18, #8]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2402647 // ldr c7, [x18, #9]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402a47 // ldr c7, [x18, #10]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402e47 // ldr c7, [x18, #11]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check system registers */
	ldr x18, =final_SP_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2984107 // mrs c7, CSP_EL0
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	ldr x18, =final_SP_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc29c4107 // mrs c7, CSP_EL1
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	ldr x18, =final_PCC_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	ldr x7, =esr_el1_dump_address
	ldr x7, [x7]
	mov x18, 0x83
	orr x7, x7, x18
	ldr x18, =0x920000a3
	cmp x18, x7
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
	ldr x0, =0x000019e0
	ldr x1, =check_data1
	ldr x2, =0x000019e1
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f3e
	ldr x1, =check_data2
	ldr x2, =0x00001f3f
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe8
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400410
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01
.data
check_data1:
	.byte 0x02
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x0a, 0x00, 0x00, 0x08
.data
check_data4:
	.byte 0xe9, 0xe3, 0x13, 0xe2, 0x80, 0x7f, 0x9f, 0x08, 0x7d, 0x42, 0xbd, 0x38, 0xc2, 0xfd, 0x7f, 0x42
	.byte 0x1d, 0x60, 0x78, 0xf8, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0xe6, 0x7e, 0x10, 0x9b, 0xe1, 0x5f, 0x03, 0x28, 0x3e, 0x7e, 0xc1, 0x9b, 0xc0, 0x00, 0x3f, 0xd6

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8080000000000102
	/* C1 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x800000000407c4040000000040400000
	/* C16 */
	.octa 0x10cd1a00002
	/* C19 */
	.octa 0x1000
	/* C23 */
	.octa 0x10b97ac00800000a
	/* C28 */
	.octa 0x19e0
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x8080000000000102
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xe213e3e9
	/* C6 */
	.octa 0x40400014
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x800000000407c4040000000040400000
	/* C16 */
	.octa 0x10cd1a00002
	/* C19 */
	.octa 0x1000
	/* C23 */
	.octa 0x10b97ac00800000a
	/* C28 */
	.octa 0x19e0
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x40400410
initial_SP_EL0_value:
	.octa 0x40000000400100040000000000002000
initial_SP_EL1_value:
	.octa 0x1fd0
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0x40000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000000d0000000040400000
final_SP_EL0_value:
	.octa 0x40000000400100040000000000002000
final_SP_EL1_value:
	.octa 0x1fd0
final_PCC_value:
	.octa 0x200080005000000d0000000040400018
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
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
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x02000252 // add c18, c18, #0
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x02020252 // add c18, c18, #128
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x02040252 // add c18, c18, #256
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x02060252 // add c18, c18, #384
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x02080252 // add c18, c18, #512
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x020a0252 // add c18, c18, #640
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x020c0252 // add c18, c18, #768
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x020e0252 // add c18, c18, #896
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x02100252 // add c18, c18, #1024
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x02120252 // add c18, c18, #1152
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x02140252 // add c18, c18, #1280
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x02160252 // add c18, c18, #1408
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x02180252 // add c18, c18, #1536
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x021a0252 // add c18, c18, #1664
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
	.inst 0x021c0252 // add c18, c18, #1792
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x82600cf2 // ldr x18, [c7, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cf2 // str x18, [c7, #0]
	ldr x18, =0x40400018
	mrs x7, ELR_EL1
	sub x18, x18, x7
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b247 // cvtp c7, x18
	.inst 0xc2d240e7 // scvalue c7, c7, x18
	.inst 0x826000f2 // ldr c18, [c7, #0]
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
