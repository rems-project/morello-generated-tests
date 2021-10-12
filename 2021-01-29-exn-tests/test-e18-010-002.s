.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2bf7d80 // CAS-C.R-C Ct:0 Rn:12 11111:11111 R:0 Cs:31 1:1 L:0 1:1 10100010:10100010
	.inst 0x48dffdc1 // ldarh:aarch64/instrs/memory/ordered Rt:1 Rn:14 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xd3773bde // ubfm:aarch64/instrs/integer/bitfield Rd:30 Rn:30 imms:001110 immr:110111 N:1 100110:100110 opc:10 sf:1
	.inst 0xb8604a60 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:0 Rn:19 10:10 S:0 option:010 Rm:0 1:1 opc:01 111000:111000 size:10
	.inst 0xc2bdacff // ADD-C.CRI-C Cd:31 Cn:7 imm3:011 option:101 Rm:29 11000010101:11000010101
	.inst 0xc2d127c1 // 0xc2d127c1
	.inst 0x7a5b6b26 // 0x7a5b6b26
	.inst 0xc2c5b25f // 0xc2c5b25f
	.inst 0x78a13000 // 0x78a13000
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
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e7 // ldr c7, [x15, #1]
	.inst 0xc24009ec // ldr c12, [x15, #2]
	.inst 0xc2400dee // ldr c14, [x15, #3]
	.inst 0xc24011f1 // ldr c17, [x15, #4]
	.inst 0xc24015f2 // ldr c18, [x15, #5]
	.inst 0xc24019f3 // ldr c19, [x15, #6]
	.inst 0xc2401dfd // ldr c29, [x15, #7]
	/* Set up flags and system registers */
	ldr x15, =0x10000000
	msr SPSR_EL3, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x0
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012cf // ldr c15, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f6 // ldr c22, [x15, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24005f6 // ldr c22, [x15, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24009f6 // ldr c22, [x15, #2]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2400df6 // ldr c22, [x15, #3]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc24011f6 // ldr c22, [x15, #4]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc24015f6 // ldr c22, [x15, #5]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc24019f6 // ldr c22, [x15, #6]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2401df6 // ldr c22, [x15, #7]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc24021f6 // ldr c22, [x15, #8]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984116 // mrs c22, CSP_EL0
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c0
	ldr x1, =check_data1
	ldr x2, =0x000010d0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001192
	ldr x1, =check_data2
	ldr x2, =0x00001194
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	.byte 0xff, 0xff
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x80, 0x7d, 0xbf, 0xa2, 0xc1, 0xfd, 0xdf, 0x48, 0xde, 0x3b, 0x77, 0xd3, 0x60, 0x4a, 0x60, 0xb8
	.byte 0xff, 0xac, 0xbd, 0xc2, 0xc1, 0x27, 0xd1, 0xc2, 0x26, 0x6b, 0x5b, 0x7a, 0x5f, 0xb2, 0xc5, 0xc2
	.byte 0x00, 0x30, 0xa1, 0x78, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000000000000000000000001000
	/* C7 */
	.octa 0x4000c000007ffffffffe8204
	/* C12 */
	.octa 0x10c0
	/* C14 */
	.octa 0x1192
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000000001
	/* C19 */
	.octa 0xc0
	/* C29 */
	.octa 0x3064
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffffffffffffff
	/* C7 */
	.octa 0x4000c000007ffffffffe8204
	/* C12 */
	.octa 0x10c0
	/* C14 */
	.octa 0x1192
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000000001
	/* C19 */
	.octa 0xc0
	/* C29 */
	.octa 0x3064
initial_DDC_EL0_value:
	.octa 0xd0000000100702060000000000003001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x4000c0000080000000000524
final_PCC_value:
	.octa 0x20008000000100070000000040400028
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
	.dword el1_vector_jump_cap
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400028
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
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
