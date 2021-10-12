.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2b643fe // ASTUR-V.RI-S Rt:30 Rn:31 op2:00 imm9:101100100 V:1 op1:10 11100010:11100010
	.inst 0x9bb94ffd // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:31 Ra:19 o0:0 Rm:25 01:01 U:1 10011011:10011011
	.inst 0xdac009bf // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:13 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c0b13e // GCSEAL-R.C-C Rd:30 Cn:9 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x3934a2c0 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:22 imm12:110100101000 opc:00 111001:111001 size:00
	.zero 44
	.inst 0xd4000001
	.zero 9148
	.inst 0x9bbf5437 // 0x9bbf5437
	.inst 0xf07f225c // 0xf07f225c
	.inst 0x791d941e // 0x791d941e
	.inst 0xc2ca8560 // 0xc2ca8560
	.zero 56304
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
	.inst 0xc2400609 // ldr c9, [x16, #1]
	.inst 0xc2400a0a // ldr c10, [x16, #2]
	.inst 0xc2400e0b // ldr c11, [x16, #3]
	.inst 0xc2401216 // ldr c22, [x16, #4]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =initial_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884110 // msr CSP_EL0, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x3c0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x4
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =initial_DDC_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4130 // msr DDC_EL1, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82601070 // ldr c16, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
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
	.inst 0xc2400203 // ldr c3, [x16, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400603 // ldr c3, [x16, #1]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2c3a541 // chkeq c10, c3
	b.ne comparison_fail
	.inst 0xc2400e03 // ldr c3, [x16, #3]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc2401203 // ldr c3, [x16, #4]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc2401603 // ldr c3, [x16, #5]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2401a03 // ldr c3, [x16, #6]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2401e03 // ldr c3, [x16, #7]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x3, v30.d[0]
	cmp x16, x3
	b.ne comparison_fail
	ldr x16, =0x0
	mov x3, v30.d[1]
	cmp x16, x3
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984103 // mrs c3, CSP_EL0
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x16, 0x83
	orr x3, x3, x16
	ldr x16, =0x920000eb
	cmp x16, x3
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
	ldr x0, =0x00001ffa
	ldr x1, =check_data1
	ldr x2, =0x00001ffc
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
	ldr x0, =0x40400040
	ldr x1, =check_data3
	ldr x2, =0x40400044
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40402400
	ldr x1, =check_data4
	ldr x2, =0x40402410
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.octa 0x400000000000c0000000000000001130
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x400002000000000000000000000000
	/* C11 */
	.octa 0x20408002000100050000000040400040
	/* C22 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400000000000c0000000000000001130
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x400002000000000000000000000000
	/* C11 */
	.octa 0x20408002000100050000000040400040
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x80000078003008000002b44b000
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x1
initial_SP_EL0_value:
	.octa 0x2000
initial_DDC_EL0_value:
	.octa 0x400000000007000700000000000000e1
initial_DDC_EL1_value:
	.octa 0x80000078003007fffff2d000001
initial_VBAR_EL1_value:
	.octa 0x200080004000201c0000000040402001
final_SP_EL0_value:
	.octa 0x2000
final_PCC_value:
	.octa 0x20408000000100050000000040400044
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080003ffb00070000000040400000
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
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600c70 // ldr x16, [c3, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c70 // str x16, [c3, #0]
	ldr x16, =0x40400044
	mrs x3, ELR_EL1
	sub x16, x16, x3
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b203 // cvtp c3, x16
	.inst 0xc2d04063 // scvalue c3, c3, x16
	.inst 0x82600070 // ldr c16, [c3, #0]
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
