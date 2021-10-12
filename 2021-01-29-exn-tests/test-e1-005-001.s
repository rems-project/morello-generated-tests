.section text0, #alloc, #execinstr
test_start:
	.inst 0xe27483d2 // ASTUR-V.RI-H Rt:18 Rn:30 op2:00 imm9:101001000 V:1 op1:01 11100010:11100010
	.inst 0xe2dcefdd // ALDUR-C.RI-C Ct:29 Rn:30 op2:11 imm9:111001110 V:0 op1:11 11100010:11100010
	.inst 0x117727aa // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:10 Rn:29 imm12:110111001001 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0x827e40a0 // ALDR-C.RI-C Ct:0 Rn:5 op:00 imm9:111100100 L:1 1000001001:1000001001
	.inst 0x5067863f // ADR-C.I-C Rd:31 immhi:110011110000110001 P:0 10000:10000 immlo:10 op:0
	.inst 0xc2f243ff // BICFLGS-C.CI-C Cd:31 Cn:31 0:0 00:00 imm8:10010010 11000010111:11000010111
	.inst 0xa2feffb5 // CASAL-C.R-C Ct:21 Rn:29 11111:11111 R:1 Cs:30 1:1 L:1 1:1 10100010:10100010
	.inst 0xc2c0d0f3 // GCPERM-R.C-C Rd:19 Cn:7 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x825be825 // ASTR-R.RI-32 Rt:5 Rn:1 op:10 imm9:110111110 L:0 1000001001:1000001001
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400485 // ldr c5, [x4, #1]
	.inst 0xc2400895 // ldr c21, [x4, #2]
	.inst 0xc2400c9e // ldr c30, [x4, #3]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q18, =0x0
	/* Set up flags and system registers */
	ldr x4, =0x0
	msr SPSR_EL3, x4
	ldr x4, =initial_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884104 // msr CSP_EL0, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0x3c0000
	msr CPACR_EL1, x4
	ldr x4, =0x0
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =0x8
	msr S3_3_C1_C2_2, x4 // CCTLR_EL0
	ldr x4, =initial_DDC_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884124 // msr DDC_EL0, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012c4 // ldr c4, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e4024 // msr CELR_EL3, c4
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400096 // ldr c22, [x4, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400496 // ldr c22, [x4, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400896 // ldr c22, [x4, #2]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2400c96 // ldr c22, [x4, #3]
	.inst 0xc2d6a541 // chkeq c10, c22
	b.ne comparison_fail
	.inst 0xc2401096 // ldr c22, [x4, #4]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2401496 // ldr c22, [x4, #5]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2401896 // ldr c22, [x4, #6]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x22, v18.d[0]
	cmp x4, x22
	b.ne comparison_fail
	ldr x4, =0x0
	mov x22, v18.d[1]
	cmp x4, x22
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984116 // mrs c22, CSP_EL0
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a481 // chkeq c4, c22
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
	ldr x0, =0x0000135a
	ldr x1, =check_data1
	ldr x2, =0x0000135c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013e0
	ldr x1, =check_data2
	ldr x2, =0x000013f0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001680
	ldr x1, =check_data3
	ldr x2, =0x00001684
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ea0
	ldr x1, =check_data4
	ldr x2, =0x00001eb0
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
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
	.zero 992
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3088
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x60, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xd2, 0x83, 0x74, 0xe2, 0xdd, 0xef, 0xdc, 0xe2, 0xaa, 0x27, 0x77, 0x11, 0xa0, 0x40, 0x7e, 0x82
	.byte 0x3f, 0x86, 0x67, 0x50, 0xff, 0x43, 0xf2, 0xc2, 0xb5, 0xff, 0xfe, 0xa2, 0xf3, 0xd0, 0xc0, 0xc2
	.byte 0x25, 0xe8, 0x5b, 0x82, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000000100050000000000000f88
	/* C5 */
	.octa 0x90100000000100050000000000000060
	/* C21 */
	.octa 0x0
	/* C30 */
	.octa 0xd010000040000b010000000000001412
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40000000000100050000000000000f88
	/* C5 */
	.octa 0x90100000000100050000000000000060
	/* C10 */
	.octa 0xdca000
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
initial_DDC_EL0_value:
	.octa 0xcc000000000300070000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x200080000005004f0000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000005004f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000013e0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x82600ec4 // ldr x4, [c22, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ec4 // str x4, [c22, #0]
	ldr x4, =0x40400028
	mrs x22, ELR_EL1
	sub x4, x4, x22
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b096 // cvtp c22, x4
	.inst 0xc2c442d6 // scvalue c22, c22, x4
	.inst 0x826002c4 // ldr c4, [c22, #0]
	.inst 0x021e0084 // add c4, c4, #1920
	.inst 0xc2c21080 // br c4

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
