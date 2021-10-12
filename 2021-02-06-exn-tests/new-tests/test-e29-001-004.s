.section text0, #alloc, #execinstr
test_start:
	.inst 0xc87f0ff0 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:16 Rn:31 Rt2:00011 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xc2c187c1 // CHKSS-_.CC-C 00001:00001 Cn:30 001:001 opc:00 1:1 Cm:1 11000010110:11000010110
	.inst 0x3865626f // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:15 Rn:19 00:00 opc:110 0:0 Rs:5 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xf2edf638 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:24 imm16:0110111110110001 hw:11 100101:100101 opc:11 sf:1
	.inst 0xc2c38b9c // CHKSSU-C.CC-C Cd:28 Cn:28 0010:0010 opc:10 Cm:3 11000010110:11000010110
	.inst 0xd65f0120 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:9 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.inst 0xc2c25020 // RET-C-C 00000:00000 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.zero 33764
	.inst 0xf961fba4 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:4 Rn:29 imm12:100001111110 opc:01 111001:111001 size:11
	.inst 0xc2c193c1 // CLRTAG-C.C-C Cd:1 Cn:30 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xd4000001
	.zero 31732
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c5 // ldr c5, [x14, #1]
	.inst 0xc24009c9 // ldr c9, [x14, #2]
	.inst 0xc2400dd3 // ldr c19, [x14, #3]
	.inst 0xc24011dc // ldr c28, [x14, #4]
	.inst 0xc24015dd // ldr c29, [x14, #5]
	.inst 0xc24019de // ldr c30, [x14, #6]
	/* Set up flags and system registers */
	ldr x14, =0x4000000
	msr SPSR_EL3, x14
	ldr x14, =initial_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288410e // msr CSP_EL0, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0xc0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x8
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010ce // ldr c14, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x6, #0xf
	and x14, x14, x6
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c6 // ldr c6, [x14, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc24005c6 // ldr c6, [x14, #1]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc24009c6 // ldr c6, [x14, #2]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2400dc6 // ldr c6, [x14, #3]
	.inst 0xc2c6a4a1 // chkeq c5, c6
	b.ne comparison_fail
	.inst 0xc24011c6 // ldr c6, [x14, #4]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc24015c6 // ldr c6, [x14, #5]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc24019c6 // ldr c6, [x14, #6]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2401dc6 // ldr c6, [x14, #7]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc24021c6 // ldr c6, [x14, #8]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc24025c6 // ldr c6, [x14, #9]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc24029c6 // ldr c6, [x14, #10]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984106 // mrs c6, CSP_EL0
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001070
	ldr x1, =check_data0
	ldr x2, =0x00001078
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000015d0
	ldr x1, =check_data1
	ldr x2, =0x000015e0
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
	ldr x2, =0x4040001c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40408400
	ldr x1, =check_data4
	ldr x2, =0x4040840c
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
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
	.zero 112
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1360
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 2576
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0x01
.data
check_data3:
	.byte 0xf0, 0x0f, 0x7f, 0xc8, 0xc1, 0x87, 0xc1, 0xc2, 0x6f, 0x62, 0x65, 0x38, 0x38, 0xf6, 0xed, 0xf2
	.byte 0x9c, 0x8b, 0xc3, 0xc2, 0x20, 0x01, 0x5f, 0xd6, 0x20, 0x50, 0xc2, 0xc2
.data
check_data4:
	.byte 0xa4, 0xfb, 0x61, 0xf9, 0xc1, 0x93, 0xc1, 0xc2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20008000c00280090000000040408400
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x40400018
	/* C19 */
	.octa 0xc0000000000100050000000000001ffe
	/* C28 */
	.octa 0x80000005800f0000000060000000
	/* C29 */
	.octa 0xffffffffffffcc80
	/* C30 */
	.octa 0x412ee008001042800080c000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x412ee008001042800080c000
	/* C3 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C4 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x40400018
	/* C15 */
	.octa 0x1
	/* C16 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C19 */
	.octa 0xc0000000000100050000000000001ffe
	/* C28 */
	.octa 0x80000005800f0000000060000000
	/* C29 */
	.octa 0xffffffffffffcc80
	/* C30 */
	.octa 0x412ee008001042800080c000
initial_SP_EL0_value:
	.octa 0x800000000001000500000000000015d0
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x800000000001000500000000000015d0
final_PCC_value:
	.octa 0x2000800040028009000000004040840c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001ff0
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x82600cce // ldr x14, [c6, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400cce // str x14, [c6, #0]
	ldr x14, =0x4040840c
	mrs x6, ELR_EL1
	sub x14, x14, x6
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c6 // cvtp c6, x14
	.inst 0xc2ce40c6 // scvalue c6, c6, x14
	.inst 0x826000ce // ldr c14, [c6, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
