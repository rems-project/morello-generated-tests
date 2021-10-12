.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23201 // CHKTGD-C-C 00001:00001 Cn:16 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c06801 // ORRFLGS-C.CR-C Cd:1 Cn:0 1010:1010 opc:01 Rm:0 11000010110:11000010110
	.inst 0x131254e1 // sbfm:aarch64/instrs/integer/bitfield Rd:1 Rn:7 imms:010101 immr:010010 N:0 100110:100110 opc:00 sf:0
	.inst 0x69e8e5dd // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:29 Rn:14 Rt2:11001 imm7:1010001 L:1 1010011:1010011 opc:01
	.inst 0x887f9bd2 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:18 Rn:30 Rt2:00110 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.zero 7148
	.inst 0x5a81c34c // 0x5a81c34c
	.inst 0x8254b3e5 // 0x8254b3e5
	.inst 0xc2e1199d // 0xc2e1199d
	.inst 0xc2df6bc3 // ORRFLGS-C.CR-C Cd:3 Cn:30 1010:1010 opc:01 Rm:31 11000010110:11000010110
	.inst 0xd4000001
	.zero 58348
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c5 // ldr c5, [x6, #1]
	.inst 0xc24008ce // ldr c14, [x6, #2]
	.inst 0xc2400cd0 // ldr c16, [x6, #3]
	.inst 0xc24010de // ldr c30, [x6, #4]
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4106 // msr CSP_EL1, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601246 // ldr c6, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x18, #0xf
	and x6, x6, x18
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d2 // ldr c18, [x6, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24004d2 // ldr c18, [x6, #1]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc24008d2 // ldr c18, [x6, #2]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2400cd2 // ldr c18, [x6, #3]
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	.inst 0xc24010d2 // ldr c18, [x6, #4]
	.inst 0xc2d2a601 // chkeq c16, c18
	b.ne comparison_fail
	.inst 0xc24014d2 // ldr c18, [x6, #5]
	.inst 0xc2d2a721 // chkeq c25, c18
	b.ne comparison_fail
	.inst 0xc24018d2 // ldr c18, [x6, #6]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc29c4112 // mrs c18, CSP_EL1
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	ldr x18, =esr_el1_dump_address
	ldr x18, [x18]
	mov x6, 0x83
	orr x18, x18, x6
	ldr x6, =0x920000ab
	cmp x6, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000014b0
	ldr x1, =check_data0
	ldr x2, =0x000014c0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40401c00
	ldr x1, =check_data2
	ldr x2, =0x40401c14
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40403f80
	ldr x1, =check_data3
	ldr x2, =0x40403f88
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
.data
check_data1:
	.byte 0x01, 0x32, 0xc2, 0xc2, 0x01, 0x68, 0xc0, 0xc2, 0xe1, 0x54, 0x12, 0x13, 0xdd, 0xe5, 0xe8, 0x69
	.byte 0xd2, 0x9b, 0x7f, 0x88
.data
check_data2:
	.byte 0x4c, 0xc3, 0x81, 0x5a, 0xe5, 0xb3, 0x54, 0x82, 0x9d, 0x19, 0xe1, 0xc2, 0xc3, 0x6b, 0xdf, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C14 */
	.octa 0x8000000000010005000000004040403c
	/* C16 */
	.octa 0x0
	/* C30 */
	.octa 0x800000007006e006ff800000003ce005
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x800000007006e006ff800000003ce005
	/* C5 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000040403f80
	/* C16 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x800000007006e006ff800000003ce005
initial_SP_EL1_value:
	.octa 0x40000000000300070000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004000141d0000000040401800
final_SP_EL1_value:
	.octa 0x40000000000300070000000000000000
final_PCC_value:
	.octa 0x200080004000141d0000000040401c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200520060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_SP_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600e46 // ldr x6, [c18, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e46 // str x6, [c18, #0]
	ldr x6, =0x40401c14
	mrs x18, ELR_EL1
	sub x6, x6, x18
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d2 // cvtp c18, x6
	.inst 0xc2c64252 // scvalue c18, c18, x6
	.inst 0x82600246 // ldr c6, [c18, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
