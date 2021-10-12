.section text0, #alloc, #execinstr
test_start:
	.inst 0xb23ff3c1 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:30 imms:111100 immr:111111 N:0 100100:100100 opc:01 sf:1
	.inst 0xc2d403bb // SCBNDS-C.CR-C Cd:27 Cn:29 000:000 opc:00 0:0 Rm:20 11000010110:11000010110
	.inst 0xb87363bf // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:110 o3:0 Rs:19 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x82de5566 // ALDRSB-R.RRB-32 Rt:6 Rn:11 opc:01 S:1 option:010 Rm:30 0:0 L:1 100000101:100000101
	.inst 0x82485bdd // ASTR-R.RI-32 Rt:29 Rn:30 op:10 imm9:010000101 L:0 1000001001:1000001001
	.inst 0x700dfccb // 0x700dfccb
	.inst 0x427ffffd // 0x427ffffd
	.inst 0x887f08fe // 0x887f08fe
	.inst 0xc2c23323 // 0xc2c23323
	.zero 92
	.inst 0xd4000001
	.zero 65404
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
	ldr x3, =initial_cap_values
	.inst 0xc2400067 // ldr c7, [x3, #0]
	.inst 0xc240046b // ldr c11, [x3, #1]
	.inst 0xc2400873 // ldr c19, [x3, #2]
	.inst 0xc2400c79 // ldr c25, [x3, #3]
	.inst 0xc240107d // ldr c29, [x3, #4]
	.inst 0xc240147e // ldr c30, [x3, #5]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =initial_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884103 // msr CSP_EL0, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0xc0000
	msr CPACR_EL1, x3
	ldr x3, =0x0
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x8c
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011c3 // ldr c3, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006e // ldr c14, [x3, #0]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240046e // ldr c14, [x3, #1]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc240086e // ldr c14, [x3, #2]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc2400c6e // ldr c14, [x3, #3]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc240106e // ldr c14, [x3, #4]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc240146e // ldr c14, [x3, #5]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc240186e // ldr c14, [x3, #6]
	.inst 0xc2cea721 // chkeq c25, c14
	b.ne comparison_fail
	.inst 0xc2401c6e // ldr c14, [x3, #7]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc240206e // ldr c14, [x3, #8]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298410e // mrs c14, CSP_EL0
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001048
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001214
	ldr x1, =check_data1
	ldr x2, =0x00001218
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001410
	ldr x1, =check_data2
	ldr x2, =0x00001414
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400080
	ldr x1, =check_data4
	ldr x2, =0x40400084
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400ff0
	ldr x1, =check_data5
	ldr x2, =0x40400ff4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40403ffe
	ldr x1, =check_data6
	ldr x2, =0x40403fff
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
	.zero 1040
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3040
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x10, 0x14, 0x00, 0x00
.data
check_data2:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xc1, 0xf3, 0x3f, 0xb2, 0xbb, 0x03, 0xd4, 0xc2, 0xbf, 0x63, 0x73, 0xb8, 0x66, 0x55, 0xde, 0x82
	.byte 0xdd, 0x5b, 0x48, 0x82, 0xcb, 0xfc, 0x0d, 0x70, 0xfd, 0xff, 0x7f, 0x42, 0xfe, 0x08, 0x7f, 0x88
	.byte 0x23, 0x33, 0xc2, 0xc2
.data
check_data4:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x1040
	/* C11 */
	.octa 0x80000000000080080000000040402ffe
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x20000000800100050000000040400080
	/* C29 */
	.octa 0x700060000000000001410
	/* C30 */
	.octa 0x40000000200700070000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xaaaaaaaaaaaabaaa
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x1040
	/* C11 */
	.octa 0x4041bfaf
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x20000000800100050000000040400080
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000800100070000000040400024
initial_SP_EL0_value:
	.octa 0x80000000000100050000000040400ff0
initial_DDC_EL0_value:
	.octa 0xc0000000001700010000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x80000000000100050000000040400ff0
final_PCC_value:
	.octa 0x20000000000100050000000040400084
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
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 96
	.dword final_cap_values + 128
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x82600dc3 // ldr x3, [c14, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400dc3 // str x3, [c14, #0]
	ldr x3, =0x40400084
	mrs x14, ELR_EL1
	sub x3, x3, x14
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06e // cvtp c14, x3
	.inst 0xc2c341ce // scvalue c14, c14, x3
	.inst 0x826001c3 // ldr c3, [c14, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
