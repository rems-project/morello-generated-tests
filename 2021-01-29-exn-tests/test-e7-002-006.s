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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400506 // ldr c6, [x8, #1]
	.inst 0xc2400907 // ldr c7, [x8, #2]
	.inst 0xc2400d09 // ldr c9, [x8, #3]
	.inst 0xc2401112 // ldr c18, [x8, #4]
	.inst 0xc240151d // ldr c29, [x8, #5]
	.inst 0xc240191e // ldr c30, [x8, #6]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q28, =0x81818004000100
	/* Set up flags and system registers */
	ldr x8, =0x4000000
	msr SPSR_EL3, x8
	ldr x8, =initial_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884108 // msr CSP_EL0, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0x3c0000
	msr CPACR_EL1, x8
	ldr x8, =0x0
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x4
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012c8 // ldr c8, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400116 // ldr c22, [x8, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400516 // ldr c22, [x8, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400916 // ldr c22, [x8, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400d16 // ldr c22, [x8, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401116 // ldr c22, [x8, #4]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2401516 // ldr c22, [x8, #5]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401916 // ldr c22, [x8, #6]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2401d16 // ldr c22, [x8, #7]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x81818004000100
	mov x22, v28.d[0]
	cmp x8, x22
	b.ne comparison_fail
	ldr x8, =0x0
	mov x22, v28.d[1]
	cmp x8, x22
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984116 // mrs c22, CSP_EL0
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000012e0
	ldr x1, =check_data0
	ldr x2, =0x000012f0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001300
	ldr x1, =check_data1
	ldr x2, =0x00001308
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001420
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c00
	ldr x1, =check_data3
	ldr x2, =0x00001c02
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
	ldr x0, =0x404000c2
	ldr x1, =check_data5
	ldr x2, =0x404000c4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040e3a2
	ldr x1, =check_data6
	ldr x2, =0x4040e3a4
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.zero 1024
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x01, 0x00, 0x00, 0x00
	.zero 3056
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x01, 0x00, 0x04, 0x80, 0x81, 0x81, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x01, 0x00, 0x00, 0x00
	.zero 16
.data
check_data3:
	.byte 0x01, 0x00
.data
check_data4:
	.byte 0xbc, 0xf3, 0xec, 0xe2, 0xfd, 0xb4, 0x58, 0xc2, 0x3d, 0xed, 0x48, 0x78, 0x1e, 0x90, 0x37, 0x79
	.byte 0xdd, 0x1b, 0xec, 0x02, 0x5d, 0x1e, 0x9a, 0x78, 0xe1, 0x93, 0x7f, 0x22, 0xc1, 0xc0, 0x3f, 0xa2
	.byte 0x7e, 0x7a, 0x39, 0x51, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000000038
	/* C6 */
	.octa 0x90100000600108020000000000001400
	/* C7 */
	.octa 0x9000000000010005ffffffffffffb010
	/* C9 */
	.octa 0x80000000400100040000000040400034
	/* C18 */
	.octa 0x800000002007e007000000004040e401
	/* C29 */
	.octa 0x1231
	/* C30 */
	.octa 0x120000000000000000001
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000000038
	/* C1 */
	.octa 0x1100000000000000000000000
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x90100000600108020000000000001400
	/* C7 */
	.octa 0x9000000000010005ffffffffffffb010
	/* C9 */
	.octa 0x800000004001000400000000404000c2
	/* C18 */
	.octa 0x800000002007e007000000004040e3a2
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x90000000600100020000000000001400
initial_DDC_EL0_value:
	.octa 0x400000001007000400ffffffffff0000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x90000000600100020000000000001400
final_PCC_value:
	.octa 0x2000800001a140050000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800001a140050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000012e0
	.dword 0x0000000000001400
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x40400028
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
