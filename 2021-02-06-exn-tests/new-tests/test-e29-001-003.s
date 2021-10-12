.section text0, #alloc, #execinstr
test_start:
	.inst 0xc87f0ff0 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:16 Rn:31 Rt2:00011 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xc2c187c1 // CHKSS-_.CC-C 00001:00001 Cn:30 001:001 opc:00 1:1 Cm:1 11000010110:11000010110
	.inst 0x3865626f // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:15 Rn:19 00:00 opc:110 0:0 Rs:5 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xf2edf638 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:24 imm16:0110111110110001 hw:11 100101:100101 opc:11 sf:1
	.inst 0xc2c38b9c // CHKSSU-C.CC-C Cd:28 Cn:28 0010:0010 opc:10 Cm:3 11000010110:11000010110
	.inst 0xd65f0120 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:9 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.inst 0xc2c25020 // RET-C-C 00000:00000 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0xf961fba4 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:4 Rn:29 imm12:100001111110 opc:01 111001:111001 size:11
	.inst 0xc2c193c1 // CLRTAG-C.C-C Cd:1 Cn:30 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xd4000001
	.zero 64008
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 1480
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400545 // ldr c5, [x10, #1]
	.inst 0xc2400949 // ldr c9, [x10, #2]
	.inst 0xc2400d53 // ldr c19, [x10, #3]
	.inst 0xc240115c // ldr c28, [x10, #4]
	.inst 0xc240155d // ldr c29, [x10, #5]
	.inst 0xc240195e // ldr c30, [x10, #6]
	/* Set up flags and system registers */
	ldr x10, =0x4000000
	msr SPSR_EL3, x10
	ldr x10, =initial_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288410a // msr CSP_EL0, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0xc0000
	msr CPACR_EL1, x10
	ldr x10, =0x0
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x8
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260132a // ldr c10, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc28e402a // msr CELR_EL3, c10
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x25, #0xf
	and x10, x10, x25
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400159 // ldr c25, [x10, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400559 // ldr c25, [x10, #1]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2400959 // ldr c25, [x10, #2]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400d59 // ldr c25, [x10, #3]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2401159 // ldr c25, [x10, #4]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc2401559 // ldr c25, [x10, #5]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2401959 // ldr c25, [x10, #6]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401d59 // ldr c25, [x10, #7]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc2402159 // ldr c25, [x10, #8]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc2402559 // ldr c25, [x10, #9]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402959 // ldr c25, [x10, #10]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984119 // mrs c25, CSP_EL0
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001cc0
	ldr x1, =check_data0
	ldr x2, =0x00001cd0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x4040fa30
	ldr x1, =check_data3
	ldr x2, =0x4040fa38
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
	.zero 3264
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 800
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x01
.data
check_data2:
	.byte 0xf0, 0x0f, 0x7f, 0xc8, 0xc1, 0x87, 0xc1, 0xc2, 0x6f, 0x62, 0x65, 0x38, 0x38, 0xf6, 0xed, 0xf2
	.byte 0x9c, 0x8b, 0xc3, 0xc2, 0x20, 0x01, 0x5f, 0xd6, 0x20, 0x50, 0xc2, 0xc2, 0xa4, 0xfb, 0x61, 0xf9
	.byte 0xc1, 0x93, 0xc1, 0xc2, 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x200080000081c005000000004040001c
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x40400018
	/* C19 */
	.octa 0xc0000000000100050000000000001ffe
	/* C28 */
	.octa 0x100040000000000000000
	/* C29 */
	.octa 0x4040b640
	/* C30 */
	.octa 0x20071e4600820420000bc000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x20071e4600820420000bc000
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
	.octa 0x100040000000000000000
	/* C29 */
	.octa 0x4040b640
	/* C30 */
	.octa 0x20071e4600820420000bc000
initial_SP_EL0_value:
	.octa 0x80000000000100050000000000001cc0
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x80000000000100050000000000001cc0
final_PCC_value:
	.octa 0x200080000081c0050000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400028
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x021e014a // add c10, c10, #1920
	.inst 0xc2c21140 // br c10

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
