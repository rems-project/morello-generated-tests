.section text0, #alloc, #execinstr
test_start:
	.inst 0x1224d7f2 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:18 Rn:31 imms:110101 immr:100100 N:0 100100:100100 opc:00 sf:0
	.inst 0xd125a426 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:6 Rn:1 imm12:100101101001 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x889ffc64 // stlr:aarch64/instrs/memory/ordered Rt:4 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c411df // LDPBR-C.C-C Ct:31 Cn:14 100:100 opc:00 11000010110001000:11000010110001000
	.zero 16
	.inst 0x08017c18 // stxrb:aarch64/instrs/memory/exclusive/single Rt:24 Rn:0 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:00
	.zero 988
	.inst 0xb99e6496 // 0xb99e6496
	.inst 0xc2c6c10c // 0xc2c6c10c
	.inst 0x427f7c81 // 0x427f7c81
	.inst 0xc2c433b5 // 0xc2c433b5
	.zero 31760
	.inst 0xd4000001
	.zero 32732
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400663 // ldr c3, [x19, #1]
	.inst 0xc2400a64 // ldr c4, [x19, #2]
	.inst 0xc2400e68 // ldr c8, [x19, #3]
	.inst 0xc240126e // ldr c14, [x19, #4]
	.inst 0xc240167d // ldr c29, [x19, #5]
	/* Set up flags and system registers */
	ldr x19, =0x0
	msr SPSR_EL3, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x0
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =initial_DDC_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4133 // msr DDC_EL1, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011f3 // ldr c19, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x15, #0xf
	and x19, x19, x15
	cmp x19, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026f // ldr c15, [x19, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240066f // ldr c15, [x19, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400a6f // ldr c15, [x19, #2]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc2400e6f // ldr c15, [x19, #3]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc240126f // ldr c15, [x19, #4]
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	.inst 0xc240166f // ldr c15, [x19, #5]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc2401a6f // ldr c15, [x19, #6]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc2401e6f // ldr c15, [x19, #7]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc240226f // ldr c15, [x19, #8]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc240266f // ldr c15, [x19, #9]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc2402a6f // ldr c15, [x19, #10]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2402e6f // ldr c15, [x19, #11]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	ldr x15, =esr_el1_dump_address
	ldr x15, [x15]
	mov x19, 0x83
	orr x15, x15, x19
	ldr x19, =0x920000eb
	cmp x19, x15
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001060
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fd0
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
	ldr x2, =0x40400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400020
	ldr x1, =check_data4
	ldr x2, =0x40400024
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
	ldr x0, =0x40408020
	ldr x1, =check_data6
	ldr x2, =0x40408024
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040c200
	ldr x1, =check_data7
	ldr x2, =0x4040c201
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x4040e064
	ldr x1, =check_data8
	ldr x2, =0x4040e068
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.zero 80
	.byte 0x21, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0xa4, 0xc2, 0x02, 0xc1, 0x00, 0x80, 0x00, 0x20
	.zero 3968
	.byte 0x20, 0x80, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x04, 0x80, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x20
	.zero 16
.data
check_data0:
	.byte 0x00, 0xc2, 0x40, 0x40
.data
check_data1:
	.zero 16
	.byte 0x21, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0xa4, 0xc2, 0x02, 0xc1, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 16
	.byte 0x20, 0x80, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x04, 0x80, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.byte 0xf2, 0xd7, 0x24, 0x12, 0x26, 0xa4, 0x25, 0xd1, 0x64, 0xfc, 0x9f, 0x88, 0xdf, 0x11, 0xc4, 0xc2
.data
check_data4:
	.byte 0x18, 0x7c, 0x01, 0x08
.data
check_data5:
	.byte 0x96, 0x64, 0x9e, 0xb9, 0x0c, 0xc1, 0xc6, 0xc2, 0x81, 0x7c, 0x7f, 0x42, 0xb5, 0x33, 0xc4, 0xc2
.data
check_data6:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 1
.data
check_data8:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000080000000000000
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x800000000101c005000000004040c200
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000000300070000000000001040
	/* C29 */
	.octa 0x90100000000100050000000000001fd0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800000000080000000000000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x800000000101c005000000004040c200
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000000300070000000000001040
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x90100000000100050000000000001fd0
	/* C30 */
	.octa 0x200080005000d40d0000000040400410
initial_DDC_EL0_value:
	.octa 0x40000000000500070000000000000003
initial_DDC_EL1_value:
	.octa 0x800000004024e034000000004040c001
initial_VBAR_EL1_value:
	.octa 0x200080005000d40d0000000040400000
final_PCC_value:
	.octa 0x20008000400080040000000040408024
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080100000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001040
	.dword 0x0000000000001050
	.dword 0x0000000000001fd0
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x82600df3 // ldr x19, [c15, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400df3 // str x19, [c15, #0]
	ldr x19, =0x40408024
	mrs x15, ELR_EL1
	sub x19, x19, x15
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26f // cvtp c15, x19
	.inst 0xc2d341ef // scvalue c15, c15, x19
	.inst 0x826001f3 // ldr c19, [c15, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
