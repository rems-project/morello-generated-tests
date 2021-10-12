.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2ecf3bc // ASTUR-V.RI-D Rt:28 Rn:29 op2:00 imm9:011001111 V:1 op1:11 11100010:11100010
	.inst 0xc258b4fd // LDR-C.RIB-C Ct:29 Rn:7 imm12:011000101101 L:1 110000100:110000100
	.inst 0x7848ed3d // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:29 Rn:9 11:11 imm9:010001110 0:0 opc:01 111000:111000 size:01
	.inst 0x7937901e // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:110111100100 opc:00 111001:111001 size:01
	.inst 0x02ec1bdd // SUB-C.CIS-C Cd:29 Cn:30 imm12:101100000110 sh:1 A:1 00000010:00000010
	.inst 0x789a1e5d // 0x789a1e5d
	.inst 0x227f93e1 // 0x227f93e1
	.inst 0xa23fc0c1 // 0xa23fc0c1
	.inst 0x51397a7e // 0x51397a7e
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c6 // ldr c6, [x14, #1]
	.inst 0xc24009c7 // ldr c7, [x14, #2]
	.inst 0xc2400dc9 // ldr c9, [x14, #3]
	.inst 0xc24011d2 // ldr c18, [x14, #4]
	.inst 0xc24015dd // ldr c29, [x14, #5]
	.inst 0xc24019de // ldr c30, [x14, #6]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q28, =0x4000000
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
	ldr x14, =0x3c0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x4
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260106e // ldr c14, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c3 // ldr c3, [x14, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005c3 // ldr c3, [x14, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24009c3 // ldr c3, [x14, #2]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2400dc3 // ldr c3, [x14, #3]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc24011c3 // ldr c3, [x14, #4]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc24015c3 // ldr c3, [x14, #5]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc24019c3 // ldr c3, [x14, #6]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2401dc3 // ldr c3, [x14, #7]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x4000000
	mov x3, v28.d[0]
	cmp x14, x3
	b.ne comparison_fail
	ldr x14, =0x0
	mov x3, v28.d[1]
	cmp x14, x3
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984103 // mrs c3, CSP_EL0
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a5c1 // chkeq c14, c3
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
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x0000100a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010e0
	ldr x1, =check_data2
	ldr x2, =0x000010e8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001290
	ldr x1, =check_data3
	ldr x2, =0x000012a0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001ff0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40407800
	ldr x1, =check_data6
	ldr x2, =0x40407802
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040c1c0
	ldr x1, =check_data7
	ldr x2, =0x4040c1e0
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x10
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xbc, 0xf3, 0xec, 0xe2, 0xfd, 0xb4, 0x58, 0xc2, 0x3d, 0xed, 0x48, 0x78, 0x1e, 0x90, 0x37, 0x79
	.byte 0xdd, 0x1b, 0xec, 0x02, 0x5d, 0x1e, 0x9a, 0x78, 0xe1, 0x93, 0x7f, 0x22, 0xc1, 0xc0, 0x3f, 0xa2
	.byte 0x7e, 0x7a, 0x39, 0x51, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 2
.data
check_data7:
	.zero 32

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000010005fffffffffffff440
	/* C6 */
	.octa 0x80000000000100050000000000001fe0
	/* C7 */
	.octa 0x9000000000010005ffffffffffffafc0
	/* C9 */
	.octa 0x80000000400040040000000040407772
	/* C18 */
	.octa 0x8000000040010004000000000000105f
	/* C29 */
	.octa 0x1011
	/* C30 */
	.octa 0x800720040000000004401000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x4000000000010005fffffffffffff440
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x80000000000100050000000000001fe0
	/* C7 */
	.octa 0x9000000000010005ffffffffffffafc0
	/* C9 */
	.octa 0x80000000400040040000000040407800
	/* C18 */
	.octa 0x80000000400100040000000000001000
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x901000002007a007000000004040c1c0
initial_DDC_EL0_value:
	.octa 0x400000000006000700fffffffffefcc1
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x901000002007a007000000004040c1c0
final_PCC_value:
	.octa 0x20008000000040100000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040100000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001290
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400028
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
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
