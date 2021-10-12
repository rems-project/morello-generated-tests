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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400667 // ldr c7, [x19, #1]
	.inst 0xc2400a68 // ldr c8, [x19, #2]
	.inst 0xc2400e6b // ldr c11, [x19, #3]
	.inst 0xc240126e // ldr c14, [x19, #4]
	.inst 0xc240166f // ldr c15, [x19, #5]
	.inst 0xc2401a77 // ldr c23, [x19, #6]
	.inst 0xc2401e78 // ldr c24, [x19, #7]
	.inst 0xc240227c // ldr c28, [x19, #8]
	.inst 0xc240267d // ldr c29, [x19, #9]
	.inst 0xc2402a7e // ldr c30, [x19, #10]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	ldr x19, =0x4000000
	msr SPSR_EL3, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0x3c0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x0
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601333 // ldr c19, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x25, #0xf
	and x19, x19, x25
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400279 // ldr c25, [x19, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400679 // ldr c25, [x19, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400a79 // ldr c25, [x19, #2]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc2400e79 // ldr c25, [x19, #3]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2401279 // ldr c25, [x19, #4]
	.inst 0xc2d9a561 // chkeq c11, c25
	b.ne comparison_fail
	.inst 0xc2401679 // ldr c25, [x19, #5]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc2401a79 // ldr c25, [x19, #6]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2401e79 // ldr c25, [x19, #7]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2402279 // ldr c25, [x19, #8]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc2402679 // ldr c25, [x19, #9]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc2402a79 // ldr c25, [x19, #10]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc2402e79 // ldr c25, [x19, #11]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2403279 // ldr c25, [x19, #12]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x25, v30.d[0]
	cmp x19, x25
	b.ne comparison_fail
	ldr x19, =0x0
	mov x25, v30.d[1]
	cmp x19, x25
	b.ne comparison_fail
	ldr x19, =0x0
	mov x25, v31.d[0]
	cmp x19, x25
	b.ne comparison_fail
	ldr x19, =0x0
	mov x25, v31.d[1]
	cmp x19, x25
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a661 // chkeq c19, c25
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001050
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010c8
	ldr x1, =check_data3
	ldr x2, =0x000010ca
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000010fa
	ldr x1, =check_data4
	ldr x2, =0x000010fc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001492
	ldr x1, =check_data5
	ldr x2, =0x00001494
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.zero 16
.data
check_data2:
	.byte 0x16, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x3e, 0x94, 0x7f, 0xe2, 0x1f, 0x39, 0x28, 0xe2, 0xe0, 0x92, 0x38, 0xeb, 0xbf, 0x7c, 0xc0, 0xc2
	.byte 0x78, 0x09, 0xc7, 0xc2, 0xba, 0xb7, 0x47, 0x78, 0xde, 0xaf, 0x82, 0xe2, 0x81, 0x27, 0xc9, 0x79
	.byte 0xcf, 0x61, 0x4c, 0xe2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1101
	/* C7 */
	.octa 0x2000000400200010040000000000001
	/* C8 */
	.octa 0xf8d
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x1002
	/* C15 */
	.octa 0x0
	/* C23 */
	.octa 0x48
	/* C24 */
	.octa 0xfb
	/* C28 */
	.octa 0x800000005c0704970000000000001000
	/* C29 */
	.octa 0x800000000047000b0000000000001000
	/* C30 */
	.octa 0x1016
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x98
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x2000000400200010040000000000001
	/* C8 */
	.octa 0xf8d
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x1002
	/* C15 */
	.octa 0x0
	/* C23 */
	.octa 0x48
	/* C24 */
	.octa 0x800000000000000000000000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x800000005c0704970000000000001000
	/* C29 */
	.octa 0x800000000047000b000000000000107b
	/* C30 */
	.octa 0x1016
initial_DDC_EL0_value:
	.octa 0xcc00000039fb000700ffe0000000e001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000004600070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004600070000000040400000
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
	.dword initial_cap_values + 160
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword final_cap_values + 192
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600f33 // ldr x19, [c25, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f33 // str x19, [c25, #0]
	ldr x19, =0x40400028
	mrs x25, ELR_EL1
	sub x19, x19, x25
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b279 // cvtp c25, x19
	.inst 0xc2d34339 // scvalue c25, c25, x19
	.inst 0x82600333 // ldr c19, [c25, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
