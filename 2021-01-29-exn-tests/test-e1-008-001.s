.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bd72eb // lduminb:aarch64/instrs/memory/atomicops/ld Rt:11 Rn:23 00:00 opc:111 0:0 Rs:29 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x38a343f9 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:25 Rn:31 00:00 opc:100 0:0 Rs:3 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x887f601f // ldxp:aarch64/instrs/memory/exclusive/pair Rt:31 Rn:0 Rt2:11000 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0xf2746418 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:24 Rn:0 imms:011001 immr:110100 N:1 100100:100100 opc:11 sf:1
	.inst 0xf8fe3000 // ldset:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:0 00:00 opc:011 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:11
	.inst 0xc2c02b80 // BICFLGS-C.CR-C Cd:0 Cn:28 1010:1010 opc:00 Rm:0 11000010110:11000010110
	.inst 0xa22983ae // SWP-CC.R-C Ct:14 Rn:29 100000:100000 Cs:9 1:1 R:0 A:0 10100010:10100010
	.inst 0x423f7e1c // ASTLRB-R.R-B Rt:28 Rn:16 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x382151a0 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:13 00:00 opc:101 0:0 Rs:1 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xd4000001
	.zero 65496
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
	.inst 0xc2400a23 // ldr c3, [x17, #2]
	.inst 0xc2400e29 // ldr c9, [x17, #3]
	.inst 0xc240122d // ldr c13, [x17, #4]
	.inst 0xc2401630 // ldr c16, [x17, #5]
	.inst 0xc2401a37 // ldr c23, [x17, #6]
	.inst 0xc2401e3c // ldr c28, [x17, #7]
	.inst 0xc240223d // ldr c29, [x17, #8]
	.inst 0xc240263e // ldr c30, [x17, #9]
	/* Set up flags and system registers */
	ldr x17, =0x0
	msr SPSR_EL3, x17
	ldr x17, =initial_SP_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884111 // msr CSP_EL0, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30d5d99f
	msr SCTLR_EL1, x17
	ldr x17, =0xc0000
	msr CPACR_EL1, x17
	ldr x17, =0x0
	msr S3_0_C1_C2_2, x17 // CCTLR_EL1
	ldr x17, =0x4
	msr S3_3_C1_C2_2, x17 // CCTLR_EL0
	ldr x17, =initial_DDC_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884131 // msr DDC_EL0, c17
	ldr x17, =0x80000000
	msr HCR_EL2, x17
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601351 // ldr c17, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
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
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x26, #0xf
	and x17, x17, x26
	cmp x17, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc240023a // ldr c26, [x17, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240063a // ldr c26, [x17, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a3a // ldr c26, [x17, #2]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc2400e3a // ldr c26, [x17, #3]
	.inst 0xc2daa521 // chkeq c9, c26
	b.ne comparison_fail
	.inst 0xc240123a // ldr c26, [x17, #4]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc240163a // ldr c26, [x17, #5]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc2401a3a // ldr c26, [x17, #6]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc2401e3a // ldr c26, [x17, #7]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc240223a // ldr c26, [x17, #8]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc240263a // ldr c26, [x17, #9]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc2402a3a // ldr c26, [x17, #10]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc2402e3a // ldr c26, [x17, #11]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc240323a // ldr c26, [x17, #12]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240363a // ldr c26, [x17, #13]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check system registers */
	ldr x17, =final_SP_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc298411a // mrs c26, CSP_EL0
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	ldr x17, =final_PCC_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa621 // chkeq c17, c26
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001021
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1c, 0x62, 0x08, 0x42, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xeb, 0x72, 0xbd, 0x38, 0xf9, 0x43, 0xa3, 0x38, 0x1f, 0x60, 0x7f, 0x88, 0x18, 0x64, 0x74, 0xf2
	.byte 0x00, 0x30, 0xfe, 0xf8, 0x80, 0x2b, 0xc0, 0xc2, 0xae, 0x83, 0x29, 0xa2, 0x1c, 0x7e, 0x3f, 0x42
	.byte 0xa0, 0x51, 0x21, 0x38, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x4208621c0000000000000000
	/* C13 */
	.octa 0xe
	/* C16 */
	.octa 0x40000000580000010000000000001000
	/* C23 */
	.octa 0x1
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x86000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x4208621c0000000000000000
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0xe
	/* C14 */
	.octa 0x200000000000000086000000000000
	/* C16 */
	.octa 0x40000000580000010000000000001000
	/* C23 */
	.octa 0x1
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x86000000000000
initial_SP_EL0_value:
	.octa 0x20
initial_DDC_EL0_value:
	.octa 0xdc0000000007040500ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x20
final_PCC_value:
	.octa 0x20008000010100070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
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
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x02000231 // add c17, c17, #0
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x02020231 // add c17, c17, #128
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x02040231 // add c17, c17, #256
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x02060231 // add c17, c17, #384
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x02080231 // add c17, c17, #512
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x020a0231 // add c17, c17, #640
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x020c0231 // add c17, c17, #768
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x020e0231 // add c17, c17, #896
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x02100231 // add c17, c17, #1024
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x02120231 // add c17, c17, #1152
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x02140231 // add c17, c17, #1280
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x02160231 // add c17, c17, #1408
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x02180231 // add c17, c17, #1536
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x021a0231 // add c17, c17, #1664
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
	.inst 0x021c0231 // add c17, c17, #1792
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600f51 // ldr x17, [c26, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f51 // str x17, [c26, #0]
	ldr x17, =0x40400028
	mrs x26, ELR_EL1
	sub x17, x17, x26
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b23a // cvtp c26, x17
	.inst 0xc2d1435a // scvalue c26, c26, x17
	.inst 0x82600351 // ldr c17, [c26, #0]
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
