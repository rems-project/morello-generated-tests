.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2b643fe // ASTUR-V.RI-S Rt:30 Rn:31 op2:00 imm9:101100100 V:1 op1:10 11100010:11100010
	.inst 0x9bb94ffd // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:31 Ra:19 o0:0 Rm:25 01:01 U:1 10011011:10011011
	.inst 0xdac009bf // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:13 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c0b13e // GCSEAL-R.C-C Rd:30 Cn:9 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x3934a2c0 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:22 imm12:110100101000 opc:00 111001:111001 size:00
	.zero 32748
	.inst 0xd4000001
	.zero 25596
	.inst 0x9bbf5437 // 0x9bbf5437
	.inst 0xf07f225c // 0xf07f225c
	.inst 0x791d941e // 0x791d941e
	.inst 0xc2ca8560 // 0xc2ca8560
	.zero 7152
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
	.inst 0xc24005e9 // ldr c9, [x15, #1]
	.inst 0xc24009ea // ldr c10, [x15, #2]
	.inst 0xc2400deb // ldr c11, [x15, #3]
	.inst 0xc24011f6 // ldr c22, [x15, #4]
	.inst 0xc24015fc // ldr c28, [x15, #5]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q30, =0x0
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
	ldr x15, =0x3c0000
	msr CPACR_EL1, x15
	ldr x15, =0x10
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x4
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010cf // ldr c15, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
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
	.inst 0xc24001e6 // ldr c6, [x15, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24005e6 // ldr c6, [x15, #1]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc24009e6 // ldr c6, [x15, #2]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2400de6 // ldr c6, [x15, #3]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc24011e6 // ldr c6, [x15, #4]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc24015e6 // ldr c6, [x15, #5]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc24019e6 // ldr c6, [x15, #6]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2401de6 // ldr c6, [x15, #7]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x6, v30.d[0]
	cmp x15, x6
	b.ne comparison_fail
	ldr x15, =0x0
	mov x6, v30.d[1]
	cmp x15, x6
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984106 // mrs c6, CSP_EL0
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x15, 0x83
	orr x6, x6, x15
	ldr x15, =0x920000eb
	cmp x15, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f64
	ldr x1, =check_data0
	ldr x2, =0x00001f68
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffc
	ldr x1, =check_data1
	ldr x2, =0x00001ffe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40408000
	ldr x1, =check_data3
	ldr x2, =0x40408004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040e400
	ldr x1, =check_data4
	ldr x2, =0x4040e410
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
	.zero 4
.data
check_data1:
	.byte 0x01, 0x00
.data
check_data2:
	.byte 0xfe, 0x43, 0xb6, 0xe2, 0xfd, 0x4f, 0xb9, 0x9b, 0xbf, 0x09, 0xc0, 0xda, 0x3e, 0xb1, 0xc0, 0xc2
	.byte 0xc0, 0xa2, 0x34, 0x39
.data
check_data3:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.byte 0x37, 0x54, 0xbf, 0x9b, 0x5c, 0x22, 0x7f, 0xf0, 0x1e, 0x94, 0x1d, 0x79, 0x60, 0x85, 0xca, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000180060000000000001132
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x400002000000000000000000000000
	/* C11 */
	.octa 0x20408002000100050000000040408000
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x100004007000000005420c001
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000000000180060000000000001132
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x400002000000000000000000000000
	/* C11 */
	.octa 0x20408002000100050000000040408000
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x1000040070000000152657000
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x1
initial_SP_EL0_value:
	.octa 0x2000
initial_DDC_EL0_value:
	.octa 0x40000000000600000000000008000001
initial_VBAR_EL1_value:
	.octa 0x200080007000e20c000000004040e001
final_SP_EL0_value:
	.octa 0x2000
final_PCC_value:
	.octa 0x20408000000100050000000040408004
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600470000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x82600ccf // ldr x15, [c6, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ccf // str x15, [c6, #0]
	ldr x15, =0x40408004
	mrs x6, ELR_EL1
	sub x15, x15, x6
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e6 // cvtp c6, x15
	.inst 0xc2cf40c6 // scvalue c6, c6, x15
	.inst 0x826000cf // ldr c15, [c6, #0]
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
