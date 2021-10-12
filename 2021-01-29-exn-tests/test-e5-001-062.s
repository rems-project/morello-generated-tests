.section text0, #alloc, #execinstr
test_start:
	.inst 0x7821323f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x0820ffa2 // casp:aarch64/instrs/memory/atomicops/cas/pair Rt:2 Rn:29 Rt2:11111 o0:1 Rs:0 1:1 L:0 0010000:0010000 sz:0 0:0
	.inst 0x38ff0196 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:12 00:00 opc:000 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x8276b7bd // ALDRB-R.RI-B Rt:29 Rn:29 op:01 imm9:101101011 L:1 1000001001:1000001001
	.inst 0x223ad1c8 // STLXP-R.CR-C Ct:8 Rn:14 Ct2:10100 1:1 Rs:26 1:1 L:0 001000100:001000100
	.zero 1004
	.inst 0xc2c611bf // 0xc2c611bf
	.inst 0xb8e46140 // 0xb8e46140
	.inst 0xa86d643d // 0xa86d643d
	.inst 0x485f7fbe // 0x485f7fbe
	.inst 0xd4000001
	.zero 64492
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa2 // ldr c2, [x21, #2]
	.inst 0xc2400ea3 // ldr c3, [x21, #3]
	.inst 0xc24012a4 // ldr c4, [x21, #4]
	.inst 0xc24016a8 // ldr c8, [x21, #5]
	.inst 0xc2401aaa // ldr c10, [x21, #6]
	.inst 0xc2401eac // ldr c12, [x21, #7]
	.inst 0xc24022ad // ldr c13, [x21, #8]
	.inst 0xc24026ae // ldr c14, [x21, #9]
	.inst 0xc2402ab1 // ldr c17, [x21, #10]
	.inst 0xc2402eb4 // ldr c20, [x21, #11]
	.inst 0xc24032bd // ldr c29, [x21, #12]
	/* Set up flags and system registers */
	ldr x21, =0x4000000
	msr SPSR_EL3, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30d5d99f
	msr SCTLR_EL1, x21
	ldr x21, =0xc0000
	msr CPACR_EL1, x21
	ldr x21, =0x0
	msr S3_0_C1_C2_2, x21 // CCTLR_EL1
	ldr x21, =0x4
	msr S3_3_C1_C2_2, x21 // CCTLR_EL0
	ldr x21, =initial_DDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884135 // msr DDC_EL0, c21
	ldr x21, =initial_DDC_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc28c4135 // msr DDC_EL1, c21
	ldr x21, =0x80000000
	msr HCR_EL2, x21
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010d5 // ldr c21, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc28e4035 // msr CELR_EL3, c21
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a6 // ldr c6, [x21, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24006a6 // ldr c6, [x21, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400aa6 // ldr c6, [x21, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400ea6 // ldr c6, [x21, #3]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc24012a6 // ldr c6, [x21, #4]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc24016a6 // ldr c6, [x21, #5]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2401aa6 // ldr c6, [x21, #6]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401ea6 // ldr c6, [x21, #7]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc24022a6 // ldr c6, [x21, #8]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc24026a6 // ldr c6, [x21, #9]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2402aa6 // ldr c6, [x21, #10]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2402ea6 // ldr c6, [x21, #11]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc24032a6 // ldr c6, [x21, #12]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc24036a6 // ldr c6, [x21, #13]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2403aa6 // ldr c6, [x21, #14]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2403ea6 // ldr c6, [x21, #15]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check system registers */
	ldr x21, =final_SP_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc29c4106 // mrs c6, CSP_EL1
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	ldr x21, =final_PCC_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x21, 0x83
	orr x6, x6, x21
	ldr x21, =0x920000e3
	cmp x21, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
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
	ldr x0, =0x00001038
	ldr x1, =check_data2
	ldr x2, =0x0000103a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000116b
	ldr x1, =check_data3
	ldr x2, =0x0000116c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001640
	ldr x1, =check_data4
	ldr x2, =0x00001642
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x40, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x38, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x38, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x40, 0x11
.data
check_data5:
	.byte 0x3f, 0x32, 0x21, 0x78, 0xa2, 0xff, 0x20, 0x08, 0x96, 0x01, 0xff, 0x38, 0xbd, 0xb7, 0x76, 0x82
	.byte 0xc8, 0xd1, 0x3a, 0x22
.data
check_data6:
	.byte 0xbf, 0x11, 0xc6, 0xc2, 0x40, 0x61, 0xe4, 0xb8, 0x3d, 0x64, 0x6d, 0xa8, 0xbe, 0x7f, 0x5f, 0x48
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1140
	/* C2 */
	.octa 0x80
	/* C3 */
	.octa 0x80
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1000
	/* C12 */
	.octa 0xc0000000000500070000000000001000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x4c000000000100050001c40000000008
	/* C17 */
	.octa 0xc000000059110e420000000000001640
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000400000080000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80
	/* C1 */
	.octa 0x1140
	/* C2 */
	.octa 0x80
	/* C3 */
	.octa 0x80
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1000
	/* C12 */
	.octa 0xc0000000000500070000000000001000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x4c000000000100050001c40000000008
	/* C17 */
	.octa 0xc000000059110e420000000000001640
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x80
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x1038
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000000080080000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400000
final_SP_EL1_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000007c00f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword initial_cap_values + 160
	.dword initial_cap_values + 192
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
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
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x020002b5 // add c21, c21, #0
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x020202b5 // add c21, c21, #128
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x020402b5 // add c21, c21, #256
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x020602b5 // add c21, c21, #384
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x020802b5 // add c21, c21, #512
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x020a02b5 // add c21, c21, #640
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x020c02b5 // add c21, c21, #768
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x020e02b5 // add c21, c21, #896
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x021002b5 // add c21, c21, #1024
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x021202b5 // add c21, c21, #1152
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x021402b5 // add c21, c21, #1280
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x021602b5 // add c21, c21, #1408
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x021802b5 // add c21, c21, #1536
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x021a02b5 // add c21, c21, #1664
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x021c02b5 // add c21, c21, #1792
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x82600cd5 // ldr x21, [c6, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400cd5 // str x21, [c6, #0]
	ldr x21, =0x40400414
	mrs x6, ELR_EL1
	sub x21, x21, x6
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a6 // cvtp c6, x21
	.inst 0xc2d540c6 // scvalue c6, c6, x21
	.inst 0x826000d5 // ldr c21, [c6, #0]
	.inst 0x021e02b5 // add c21, c21, #1920
	.inst 0xc2c212a0 // br c21

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
