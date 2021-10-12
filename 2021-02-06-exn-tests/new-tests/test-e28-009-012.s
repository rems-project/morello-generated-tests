.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c41bbc // ALIGND-C.CI-C Cd:28 Cn:29 0110:0110 U:0 imm6:001000 11000010110:11000010110
	.inst 0xb8e4601e // ldumax:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:0 00:00 opc:110 0:0 Rs:4 1:1 R:1 A:1 111000:111000 size:10
	.inst 0x887febdd // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:29 Rn:30 Rt2:11010 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0xc2d850a1 // BLR-CI-C 1:1 0000:0000 Cn:5 100:100 imm7:1000010 110000101101:110000101101
	.zero 1008
	.inst 0x784ec021 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:1 00:00 imm9:011101100 0:0 opc:01 111000:111000 size:01
	.zero 45052
	.inst 0x82a0e2e0 // ASTR-R.RRB-32 Rt:0 Rn:23 opc:00 S:0 option:111 Rm:0 1:1 L:0 100000101:100000101
	.inst 0xc2c1d1c1 // CPY-C.C-C Cd:1 Cn:14 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xb89a3000 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:0 00:00 imm9:110100011 0:0 opc:10 111000:111000 size:10
	.inst 0xc87fe401 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:0 Rt2:11001 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xd4000001
	.zero 19436
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a24 // ldr c4, [x17, #2]
	.inst 0xc2400e25 // ldr c5, [x17, #3]
	.inst 0xc2401237 // ldr c23, [x17, #4]
	.inst 0xc240163d // ldr c29, [x17, #5]
	/* Set up flags and system registers */
	ldr x17, =0x0
	msr SPSR_EL3, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30d5d99f
	msr SCTLR_EL1, x17
	ldr x17, =0xc0000
	msr CPACR_EL1, x17
	ldr x17, =0x4
	msr S3_0_C1_C2_2, x17 // CCTLR_EL1
	ldr x17, =0x0
	msr S3_3_C1_C2_2, x17 // CCTLR_EL0
	ldr x17, =initial_DDC_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884131 // msr DDC_EL0, c17
	ldr x17, =initial_DDC_EL1_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc28c4131 // msr DDC_EL1, c17
	ldr x17, =0x80000000
	msr HCR_EL2, x17
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601151 // ldr c17, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e4031 // msr CELR_EL3, c17
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc240022a // ldr c10, [x17, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240062a // ldr c10, [x17, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a2a // ldr c10, [x17, #2]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc2400e2a // ldr c10, [x17, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240122a // ldr c10, [x17, #4]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc240162a // ldr c10, [x17, #5]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc2401a2a // ldr c10, [x17, #6]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2401e2a // ldr c10, [x17, #7]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc240222a // ldr c10, [x17, #8]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc240262a // ldr c10, [x17, #9]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x17, =final_PCC_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	ldr x17, =esr_el1_dump_address
	ldr x17, [x17]
	mov x10, 0x80
	orr x17, x17, x10
	ldr x10, =0x920000a1
	cmp x10, x17
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
	ldr x0, =0x00001c00
	ldr x1, =check_data1
	ldr x2, =0x00001c10
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fa4
	ldr x1, =check_data2
	ldr x2, =0x00001fa8
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
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400404
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040b400
	ldr x1, =check_data5
	ldr x2, =0x4040b414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3056
	.byte 0x00, 0x04, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 912
	.byte 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 80
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x04, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x04, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0x03, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xbc, 0x1b, 0xc4, 0xc2, 0x1e, 0x60, 0xe4, 0xb8, 0xdd, 0xeb, 0x7f, 0x88, 0xa1, 0x50, 0xd8, 0xc2
.data
check_data4:
	.byte 0x21, 0xc0, 0x4e, 0x78
.data
check_data5:
	.byte 0xe0, 0xe2, 0xa0, 0x82, 0xc1, 0xd1, 0xc1, 0xc2, 0x00, 0x30, 0x9a, 0xb8, 0x01, 0xe4, 0x7f, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1004
	/* C1 */
	.octa 0x99
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x90100000000100050000000000001fe0
	/* C23 */
	.octa 0x40000000000700040000000000000004
	/* C29 */
	.octa 0x810070fde0000001b00000001
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x3
	/* C1 */
	.octa 0x100000000000
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x90100000000100050000000000001fe0
	/* C23 */
	.octa 0x40000000000700040000000000000004
	/* C25 */
	.octa 0x1004
	/* C26 */
	.octa 0x1000
	/* C28 */
	.octa 0x810070fde0000001b00000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000080080000000040400010
initial_DDC_EL0_value:
	.octa 0xc00000005044005200ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x800000005fc00ffd00ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080007800b01d000000004040b000
final_PCC_value:
	.octa 0x200080007800b01d000000004040b414
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
	.dword 0x0000000000001c00
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001c00
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
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x02000231 // add c17, c17, #0
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x02020231 // add c17, c17, #128
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x02040231 // add c17, c17, #256
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x02060231 // add c17, c17, #384
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x02080231 // add c17, c17, #512
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x020a0231 // add c17, c17, #640
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x020c0231 // add c17, c17, #768
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x020e0231 // add c17, c17, #896
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x02100231 // add c17, c17, #1024
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x02120231 // add c17, c17, #1152
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x02140231 // add c17, c17, #1280
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x02160231 // add c17, c17, #1408
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x02180231 // add c17, c17, #1536
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x021a0231 // add c17, c17, #1664
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x021c0231 // add c17, c17, #1792
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600d51 // ldr x17, [c10, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d51 // str x17, [c10, #0]
	ldr x17, =0x4040b414
	mrs x10, ELR_EL1
	sub x17, x17, x10
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22a // cvtp c10, x17
	.inst 0xc2d1414a // scvalue c10, c10, x17
	.inst 0x82600151 // ldr c17, [c10, #0]
	.inst 0x021e0231 // add c17, c17, #1920
	.inst 0xc2c21220 // br c17

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
