.section text0, #alloc, #execinstr
test_start:
	.inst 0x1adf082e // udiv:aarch64/instrs/integer/arithmetic/div Rd:14 Rn:1 o1:0 00001:00001 Rm:31 0011010110:0011010110 sf:0
	.inst 0x38cd73bd // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:29 00:00 imm9:011010111 0:0 opc:11 111000:111000 size:00
	.inst 0x908d725e // ADRP-C.IP-C Rd:30 immhi:000110101110010010 P:1 10000:10000 immlo:00 op:1
	.inst 0xe2529f3e // ALDURSH-R.RI-32 Rt:30 Rn:25 op2:11 imm9:100101001 V:0 op1:01 11100010:11100010
	.inst 0x889fffe0 // stlr:aarch64/instrs/memory/ordered Rt:0 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.zero 17388
	.inst 0xc2bd2be1 // 0xc2bd2be1
	.inst 0x78bfc1df // 0x78bfc1df
	.inst 0x1112c3de // 0x1112c3de
	.inst 0xdac008f2 // 0xdac008f2
	.inst 0xd4000001
	.zero 48108
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
	ldr x6, =initial_cap_values
	.inst 0xc24000d9 // ldr c25, [x6, #0]
	.inst 0xc24004dd // ldr c29, [x6, #1]
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884106 // msr CSP_EL0, c6
	ldr x6, =initial_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4106 // msr CSP_EL1, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x4
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x0
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =initial_DDC_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4126 // msr DDC_EL1, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x0, =pcc_return_ddc_capabilities
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0x82601006 // ldr c6, [c0, #1]
	.inst 0x82602000 // ldr c0, [c0, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc2c0a421 // chkeq c1, c0
	b.ne comparison_fail
	.inst 0xc24004c0 // ldr c0, [x6, #1]
	.inst 0xc2c0a5c1 // chkeq c14, c0
	b.ne comparison_fail
	.inst 0xc24008c0 // ldr c0, [x6, #2]
	.inst 0xc2c0a721 // chkeq c25, c0
	b.ne comparison_fail
	.inst 0xc2400cc0 // ldr c0, [x6, #3]
	.inst 0xc2c0a7a1 // chkeq c29, c0
	b.ne comparison_fail
	.inst 0xc24010c0 // ldr c0, [x6, #4]
	.inst 0xc2c0a7c1 // chkeq c30, c0
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984100 // mrs c0, CSP_EL0
	.inst 0xc2c0a4c1 // chkeq c6, c0
	b.ne comparison_fail
	ldr x6, =final_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc29c4100 // mrs c0, CSP_EL1
	.inst 0xc2c0a4c1 // chkeq c6, c0
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984020 // mrs c0, CELR_EL1
	.inst 0xc2c0a4c1 // chkeq c6, c0
	b.ne comparison_fail
	ldr x0, =esr_el1_dump_address
	ldr x0, [x0]
	mov x6, 0x83
	orr x0, x0, x6
	ldr x6, =0x920000eb
	cmp x6, x0
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000107e
	ldr x1, =check_data0
	ldr x2, =0x0000107f
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000132c
	ldr x1, =check_data1
	ldr x2, =0x0000132e
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
	ldr x0, =0x40404400
	ldr x1, =check_data3
	ldr x2, =0x40404414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00
	.zero 672
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x08, 0x00, 0x00
	.zero 3280
.data
check_data0:
	.byte 0x40
.data
check_data1:
	.byte 0x08, 0x08
.data
check_data2:
	.byte 0x2e, 0x08, 0xdf, 0x1a, 0xbd, 0x73, 0xcd, 0x38, 0x5e, 0x72, 0x8d, 0x90, 0x3e, 0x9f, 0x52, 0xe2
	.byte 0xe0, 0xff, 0x9f, 0x88
.data
check_data3:
	.byte 0xe1, 0x2b, 0xbd, 0xc2, 0xdf, 0xc1, 0xbf, 0x78, 0xde, 0xc3, 0x12, 0x11, 0xf2, 0x08, 0xc0, 0xda
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C25 */
	.octa 0x1403
	/* C29 */
	.octa 0x80000000600100020000000000000fa7
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x320060100000000000000
	/* C14 */
	.octa 0x0
	/* C25 */
	.octa 0x1403
	/* C29 */
	.octa 0x40
	/* C30 */
	.octa 0xcb8
initial_SP_EL0_value:
	.octa 0x20
initial_SP_EL1_value:
	.octa 0x3200600ffffffffffff00
initial_DDC_EL0_value:
	.octa 0x8000000010070f070000000000000001
initial_DDC_EL1_value:
	.octa 0x8000000002060101000000003800e003
initial_VBAR_EL1_value:
	.octa 0x200080005000200d0000000040404000
final_SP_EL0_value:
	.octa 0x20
final_SP_EL1_value:
	.octa 0x3200600ffffffffffff00
final_PCC_value:
	.octa 0x200080005000200d0000000040404414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002007c00f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600c06 // ldr x6, [c0, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c06 // str x6, [c0, #0]
	ldr x6, =0x40404414
	mrs x0, ELR_EL1
	sub x6, x6, x0
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c0 // cvtp c0, x6
	.inst 0xc2c64000 // scvalue c0, c0, x6
	.inst 0x82600006 // ldr c6, [c0, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
