.section text0, #alloc, #execinstr
test_start:
	.inst 0xe27f943e // ALDUR-V.RI-H Rt:30 Rn:1 op2:01 imm9:111111001 V:1 op1:01 11100010:11100010
	.inst 0xe228391f // ASTUR-V.RI-Q Rt:31 Rn:8 op2:10 imm9:010000011 V:1 op1:00 11100010:11100010
	.inst 0xeb3892e0 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:23 imm3:100 option:100 Rm:24 01011001:01011001 S:1 op:1 sf:1
	.inst 0xc2c07cbf // CSEL-C.CI-C Cd:31 Cn:5 11:11 cond:0111 Cm:0 11000010110:11000010110
	.inst 0xc2c70978 // SEAL-C.CC-C Cd:24 Cn:11 0010:0010 opc:00 Cm:7 11000010110:11000010110
	.inst 0x7847b7ba // 0x7847b7ba
	.inst 0xe282afde // 0xe282afde
	.inst 0x79c92781 // 0x79c92781
	.inst 0xe24c61cf // 0xe24c61cf
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400547 // ldr c7, [x10, #1]
	.inst 0xc2400948 // ldr c8, [x10, #2]
	.inst 0xc2400d4b // ldr c11, [x10, #3]
	.inst 0xc240114e // ldr c14, [x10, #4]
	.inst 0xc240154f // ldr c15, [x10, #5]
	.inst 0xc2401957 // ldr c23, [x10, #6]
	.inst 0xc2401d58 // ldr c24, [x10, #7]
	.inst 0xc240215c // ldr c28, [x10, #8]
	.inst 0xc240255d // ldr c29, [x10, #9]
	.inst 0xc240295e // ldr c30, [x10, #10]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	ldr x10, =0x4000000
	msr SPSR_EL3, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0x3c0000
	msr CPACR_EL1, x10
	ldr x10, =0x0
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x0
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260124a // ldr c10, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	mov x18, #0xf
	and x10, x10, x18
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400152 // ldr c18, [x10, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400552 // ldr c18, [x10, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400952 // ldr c18, [x10, #2]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc2400d52 // ldr c18, [x10, #3]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc2401152 // ldr c18, [x10, #4]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc2401552 // ldr c18, [x10, #5]
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	.inst 0xc2401952 // ldr c18, [x10, #6]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401d52 // ldr c18, [x10, #7]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc2402152 // ldr c18, [x10, #8]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc2402552 // ldr c18, [x10, #9]
	.inst 0xc2d2a741 // chkeq c26, c18
	b.ne comparison_fail
	.inst 0xc2402952 // ldr c18, [x10, #10]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc2402d52 // ldr c18, [x10, #11]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2403152 // ldr c18, [x10, #12]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x18, v30.d[0]
	cmp x10, x18
	b.ne comparison_fail
	ldr x10, =0x0
	mov x18, v30.d[1]
	cmp x10, x18
	b.ne comparison_fail
	ldr x10, =0x0
	mov x18, v31.d[0]
	cmp x10, x18
	b.ne comparison_fail
	ldr x10, =0x0
	mov x18, v31.d[1]
	cmp x10, x18
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001050
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001092
	ldr x1, =check_data1
	ldr x2, =0x00001094
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010ca
	ldr x1, =check_data2
	ldr x2, =0x000010cc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013c0
	ldr x1, =check_data3
	ldr x2, =0x000013d0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000013fa
	ldr x1, =check_data4
	ldr x2, =0x000013fc
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
	ldr x0, =0x40405bfe
	ldr x1, =check_data6
	ldr x2, =0x40405c00
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 4096
.data
check_data0:
	.byte 0x16, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x3e, 0x94, 0x7f, 0xe2, 0x1f, 0x39, 0x28, 0xe2, 0xe0, 0x92, 0x38, 0xeb, 0xbf, 0x7c, 0xc0, 0xc2
	.byte 0x78, 0x09, 0xc7, 0xc2, 0xba, 0xb7, 0x47, 0x78, 0xde, 0xaf, 0x82, 0xe2, 0x81, 0x27, 0xc9, 0x79
	.byte 0xcf, 0x61, 0x4c, 0xe2, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1401
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x133d
	/* C11 */
	.octa 0x800000000000000000000000
	/* C14 */
	.octa 0x1004
	/* C15 */
	.octa 0x0
	/* C23 */
	.octa 0x4
	/* C24 */
	.octa 0xbf
	/* C28 */
	.octa 0x80000000004180060000000000000c00
	/* C29 */
	.octa 0x8000000070043c050000000040405bfe
	/* C30 */
	.octa 0x1016
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x414
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x133d
	/* C11 */
	.octa 0x800000000000000000000000
	/* C14 */
	.octa 0x1004
	/* C15 */
	.octa 0x0
	/* C23 */
	.octa 0x4
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000004180060000000000000c00
	/* C29 */
	.octa 0x8000000070043c050000000040405c79
	/* C30 */
	.octa 0x1016
initial_DDC_EL0_value:
	.octa 0xc00000000007000700ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000600270000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600270000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 160
	.dword final_cap_values + 176
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x82600e4a // ldr x10, [c18, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e4a // str x10, [c18, #0]
	ldr x10, =0x40400028
	mrs x18, ELR_EL1
	sub x10, x10, x18
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b152 // cvtp c18, x10
	.inst 0xc2ca4252 // scvalue c18, c18, x10
	.inst 0x8260024a // ldr c10, [c18, #0]
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
