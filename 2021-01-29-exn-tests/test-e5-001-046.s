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
	.zero 15052
	.inst 0x00001000
	.zero 49436
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
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a62 // ldr c2, [x19, #2]
	.inst 0xc2400e63 // ldr c3, [x19, #3]
	.inst 0xc2401264 // ldr c4, [x19, #4]
	.inst 0xc2401668 // ldr c8, [x19, #5]
	.inst 0xc2401a6a // ldr c10, [x19, #6]
	.inst 0xc2401e6c // ldr c12, [x19, #7]
	.inst 0xc240226d // ldr c13, [x19, #8]
	.inst 0xc240266e // ldr c14, [x19, #9]
	.inst 0xc2402a71 // ldr c17, [x19, #10]
	.inst 0xc2402e74 // ldr c20, [x19, #11]
	.inst 0xc240327d // ldr c29, [x19, #12]
	/* Set up flags and system registers */
	ldr x19, =0x4000000
	msr SPSR_EL3, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
	msr CPACR_EL1, x19
	ldr x19, =0x4
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x4
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =initial_DDC_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4133 // msr DDC_EL1, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010b3 // ldr c19, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400265 // ldr c5, [x19, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a65 // ldr c5, [x19, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400e65 // ldr c5, [x19, #3]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc2401265 // ldr c5, [x19, #4]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2401665 // ldr c5, [x19, #5]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2401a65 // ldr c5, [x19, #6]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2401e65 // ldr c5, [x19, #7]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc2402265 // ldr c5, [x19, #8]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2402665 // ldr c5, [x19, #9]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2402a65 // ldr c5, [x19, #10]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2402e65 // ldr c5, [x19, #11]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc2403265 // ldr c5, [x19, #12]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc2403665 // ldr c5, [x19, #13]
	.inst 0xc2c5a721 // chkeq c25, c5
	b.ne comparison_fail
	.inst 0xc2403a65 // ldr c5, [x19, #14]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2403e65 // ldr c5, [x19, #15]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc29c4105 // mrs c5, CSP_EL1
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x19, 0x83
	orr x5, x5, x19
	ldr x19, =0x920000eb
	cmp x19, x5
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
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
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
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040116b
	ldr x1, =check_data4
	ldr x2, =0x4040116c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40403ee0
	ldr x1, =check_data5
	ldr x2, =0x40403ef0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x10, 0x40, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x3f, 0x32, 0x21, 0x78, 0xa2, 0xff, 0x20, 0x08, 0x96, 0x01, 0xff, 0x38, 0xbd, 0xb7, 0x76, 0x82
	.byte 0xc8, 0xd1, 0x3a, 0x22
.data
check_data3:
	.byte 0xbf, 0x11, 0xc6, 0xc2, 0x40, 0x61, 0xe4, 0xb8, 0x3d, 0x64, 0x6d, 0xa8, 0xbe, 0x7f, 0x5f, 0x48
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4010
	/* C1 */
	.octa 0x40404010
	/* C2 */
	.octa 0x200
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1000
	/* C12 */
	.octa 0xc0000000000100050000000000001ffe
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x4c00000000000085fe80000000008000
	/* C17 */
	.octa 0xc0000000000100050000000000001000
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000080080000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x200
	/* C1 */
	.octa 0x40404010
	/* C2 */
	.octa 0x200
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1000
	/* C12 */
	.octa 0xc0000000000100050000000000001ffe
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x4c00000000000085fe80000000008000
	/* C17 */
	.octa 0xc0000000000100050000000000001000
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x200
initial_DDC_EL0_value:
	.octa 0x8000000000061005000000003f800001
initial_DDC_EL1_value:
	.octa 0xc0000000000000000000000000004024
initial_VBAR_EL1_value:
	.octa 0x200080005000d81c0000000040400000
final_SP_EL1_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080005000d81c0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080740100000000040400000
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x82600cb3 // ldr x19, [c5, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cb3 // str x19, [c5, #0]
	ldr x19, =0x40400414
	mrs x5, ELR_EL1
	sub x19, x19, x5
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b265 // cvtp c5, x19
	.inst 0xc2d340a5 // scvalue c5, c5, x19
	.inst 0x826000b3 // ldr c19, [c5, #0]
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
