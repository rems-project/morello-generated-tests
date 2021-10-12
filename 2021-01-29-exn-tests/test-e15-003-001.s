.section text0, #alloc, #execinstr
test_start:
	.inst 0xe20e53c0 // ASTURB-R.RI-32 Rt:0 Rn:30 op2:00 imm9:011100101 V:0 op1:00 11100010:11100010
	.inst 0xa2ee7c3e // CASA-C.R-C Ct:30 Rn:1 11111:11111 R:0 Cs:14 1:1 L:1 1:1 10100010:10100010
	.inst 0x7824619f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:12 00:00 opc:110 o3:0 Rs:4 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xb95f641a // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:26 Rn:0 imm12:011111011001 opc:01 111001:111001 size:10
	.inst 0x5c8ca3ce // ldr_lit_fpsimd:aarch64/instrs/memory/literal/simdfp Rt:14 imm19:1000110010100011110 011100:011100 opc:01
	.zero 1004
	.inst 0xf8832020 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:1 00:00 imm9:000110010 0:0 opc:10 111000:111000 size:11
	.inst 0xf8190081 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:4 00:00 imm9:110010000 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c0506f // GCVALUE-R.C-C Rd:15 Cn:3 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x887f27a0 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:0 Rn:29 Rt2:01001 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0xd4000001
	.zero 64492
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a04 // ldr c4, [x16, #2]
	.inst 0xc2400e0c // ldr c12, [x16, #3]
	.inst 0xc240120e // ldr c14, [x16, #4]
	.inst 0xc240161d // ldr c29, [x16, #5]
	.inst 0xc2401a1e // ldr c30, [x16, #6]
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x3c0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012b0 // ldr c16, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400215 // ldr c21, [x16, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400615 // ldr c21, [x16, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400a15 // ldr c21, [x16, #2]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc2400e15 // ldr c21, [x16, #3]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc2401215 // ldr c21, [x16, #4]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2401615 // ldr c21, [x16, #5]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc2401a15 // ldr c21, [x16, #6]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2401e15 // ldr c21, [x16, #7]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2402215 // ldr c21, [x16, #8]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	ldr x21, =esr_el1_dump_address
	ldr x21, [x21]
	mov x16, 0x83
	orr x21, x21, x16
	ldr x16, =0x920000ab
	cmp x16, x21
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
	ldr x0, =0x000010e5
	ldr x1, =check_data1
	ldr x2, =0x000010e6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001190
	ldr x1, =check_data2
	ldr x2, =0x00001198
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f40
	ldr x1, =check_data3
	ldr x2, =0x00001f48
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f64
	ldr x1, =check_data4
	ldr x2, =0x00001f68
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x08, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x18, 0x00, 0x00, 0x00, 0x40
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xc0, 0x53, 0x0e, 0xe2, 0x3e, 0x7c, 0xee, 0xa2, 0x9f, 0x61, 0x24, 0x78, 0x1a, 0x64, 0x5f, 0xb9
	.byte 0xce, 0xa3, 0x8c, 0x5c
.data
check_data6:
	.byte 0x20, 0x20, 0x83, 0xf8, 0x81, 0x00, 0x19, 0xf8, 0x6f, 0x50, 0xc0, 0xc2, 0xa0, 0x27, 0x7f, 0x88
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C4 */
	.octa 0x4000000060010ba20000000000001200
	/* C12 */
	.octa 0x100a
	/* C14 */
	.octa 0x80800000000000000000000
	/* C29 */
	.octa 0x800000005fc41eff0000000000001f40
	/* C30 */
	.octa 0x40000000180800000000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C4 */
	.octa 0x4000000060010ba20000000000001200
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x100a
	/* C14 */
	.octa 0x80800000000000000000000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x800000005fc41eff0000000000001f40
	/* C30 */
	.octa 0x40000000180800000000000000001000
initial_DDC_EL0_value:
	.octa 0xdc1000006001000100ffffffffffe000
initial_VBAR_EL1_value:
	.octa 0x200080004800008d0000000040400001
final_PCC_value:
	.octa 0x200080004800008d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404100000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 112
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
