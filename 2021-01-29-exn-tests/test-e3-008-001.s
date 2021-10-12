.section text0, #alloc, #execinstr
test_start:
	.inst 0x9a84d15f // csel:aarch64/instrs/integer/conditional/select Rd:31 Rn:10 o2:0 0:0 cond:1101 Rm:4 011010100:011010100 op:0 sf:1
	.inst 0x3a1b03de // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:30 000000:000000 Rm:27 11010000:11010000 S:1 op:0 sf:0
	.inst 0x380aa4ff // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:7 01:01 imm9:010101010 0:0 opc:00 111000:111000 size:00
	.inst 0x8800fdae // stlxr:aarch64/instrs/memory/exclusive/single Rt:14 Rn:13 Rt2:11111 o0:1 Rs:0 0:0 L:0 0010000:0010000 size:10
	.inst 0x1ac223bf // lslv:aarch64/instrs/integer/shift/variable Rd:31 Rn:29 op2:00 0010:0010 Rm:2 0011010110:0011010110 sf:0
	.inst 0xc2d03bc0 // SCBNDS-C.CI-C Cd:0 Cn:30 1110:1110 S:0 imm6:100000 11000010110:11000010110
	.inst 0x485f7ff9 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:25 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x546fe9c6 // b_cond:aarch64/instrs/branch/conditional/cond cond:0110 0:0 imm19:0110111111101001110 01010100:01010100
	.inst 0x28430833 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:19 Rn:1 Rt2:00010 imm7:0000110 L:1 1010000:1010000 opc:00
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e7 // ldr c7, [x15, #1]
	.inst 0xc24009ed // ldr c13, [x15, #2]
	.inst 0xc2400dfb // ldr c27, [x15, #3]
	.inst 0xc24011fe // ldr c30, [x15, #4]
	/* Set up flags and system registers */
	ldr x15, =0x4000000
	msr SPSR_EL3, x15
	ldr x15, =initial_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288410f // msr CSP_EL0, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260124f // ldr c15, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	mov x18, #0xf
	and x15, x15, x18
	cmp x15, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f2 // ldr c18, [x15, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24005f2 // ldr c18, [x15, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24009f2 // ldr c18, [x15, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400df2 // ldr c18, [x15, #3]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc24011f2 // ldr c18, [x15, #4]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc24015f2 // ldr c18, [x15, #5]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc24019f2 // ldr c18, [x15, #6]
	.inst 0xc2d2a721 // chkeq c25, c18
	b.ne comparison_fail
	.inst 0xc2401df2 // ldr c18, [x15, #7]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc24021f2 // ldr c18, [x15, #8]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984112 // mrs c18, CSP_EL0
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000108c
	ldr x1, =check_data0
	ldr x2, =0x00001094
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013f4
	ldr x1, =check_data1
	ldr x2, =0x000013f8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017f0
	ldr x1, =check_data2
	ldr x2, =0x000017f2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001dfc
	ldr x1, =check_data3
	ldr x2, =0x00001dfd
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x5f, 0xd1, 0x84, 0x9a, 0xde, 0x03, 0x1b, 0x3a, 0xff, 0xa4, 0x0a, 0x38, 0xae, 0xfd, 0x00, 0x88
	.byte 0xbf, 0x23, 0xc2, 0x1a, 0xc0, 0x3b, 0xd0, 0xc2, 0xf9, 0x7f, 0x5f, 0x48, 0xc6, 0xe9, 0x6f, 0x54
	.byte 0x33, 0x08, 0x43, 0x28, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000100050000000000001074
	/* C7 */
	.octa 0x40000000000100060000000000001dfc
	/* C13 */
	.octa 0x400000000005000300000000000013f4
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x402000000000000000000000
	/* C1 */
	.octa 0x80000000000100050000000000001074
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x40000000000100060000000000001ea6
	/* C13 */
	.octa 0x400000000005000300000000000013f4
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x800000000001000500000000000017f0
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x800000000001000500000000000017f0
final_PCC_value:
	.octa 0x200080004080c09c0000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004080c09c0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_SP_EL0_value
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x40400028
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
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
