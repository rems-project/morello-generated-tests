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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e03 // ldr c3, [x16, #3]
	.inst 0xc2401204 // ldr c4, [x16, #4]
	.inst 0xc2401608 // ldr c8, [x16, #5]
	.inst 0xc2401a0a // ldr c10, [x16, #6]
	.inst 0xc2401e0c // ldr c12, [x16, #7]
	.inst 0xc240220d // ldr c13, [x16, #8]
	.inst 0xc240260e // ldr c14, [x16, #9]
	.inst 0xc2402a11 // ldr c17, [x16, #10]
	.inst 0xc2402e14 // ldr c20, [x16, #11]
	.inst 0xc240321d // ldr c29, [x16, #12]
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x4
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
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f0 // ldr c16, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	.inst 0xc2400217 // ldr c23, [x16, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400617 // ldr c23, [x16, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a17 // ldr c23, [x16, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400e17 // ldr c23, [x16, #3]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2401217 // ldr c23, [x16, #4]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2401617 // ldr c23, [x16, #5]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc2401a17 // ldr c23, [x16, #6]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2401e17 // ldr c23, [x16, #7]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2402217 // ldr c23, [x16, #8]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc2402617 // ldr c23, [x16, #9]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2402a17 // ldr c23, [x16, #10]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2402e17 // ldr c23, [x16, #11]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2403217 // ldr c23, [x16, #12]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2403617 // ldr c23, [x16, #13]
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	.inst 0xc2403a17 // ldr c23, [x16, #14]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2403e17 // ldr c23, [x16, #15]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc29c4117 // mrs c23, CSP_EL1
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x16, 0x83
	orr x23, x23, x16
	ldr x16, =0x920000eb
	cmp x16, x23
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
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001034
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000116b
	ldr x1, =check_data2
	ldr x2, =0x0000116c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000014d0
	ldr x1, =check_data3
	ldr x2, =0x000014e0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001600
	ldr x1, =check_data4
	ldr x2, =0x00001602
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f00
	ldr x1, =check_data5
	ldr x2, =0x00001f01
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x40400414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4032
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00
.data
check_data1:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x3f, 0x32, 0x21, 0x78, 0xa2, 0xff, 0x20, 0x08, 0x96, 0x01, 0xff, 0x38, 0xbd, 0xb7, 0x76, 0x82
	.byte 0xc8, 0xd1, 0x3a, 0x22
.data
check_data7:
	.byte 0xbf, 0x11, 0xc6, 0xc2, 0x40, 0x61, 0xe4, 0xb8, 0x3d, 0x64, 0x6d, 0xa8, 0xbe, 0x7f, 0x5f, 0x48
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1600
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x20000
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1030
	/* C12 */
	.octa 0xc00000005efd1efe0000000000001f00
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x4c0000006001800200800030003f81f1
	/* C17 */
	.octa 0xc00000000007000500000000000014d0
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0xc0000000400100020000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x1600
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x20000
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1030
	/* C12 */
	.octa 0xc00000005efd1efe0000000000001f00
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x4c0000006001800200800030003f81f1
	/* C17 */
	.octa 0xc00000000007000500000000000014d0
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x1600
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000000080080000000000000001
initial_DDC_EL1_value:
	.octa 0xc00000000007000000fffffffff00000
initial_VBAR_EL1_value:
	.octa 0x200080005000dc1d0000000040400000
final_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x200080005000dc1d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000410000000000000040400000
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
	.dword initial_cap_values + 176
	.dword initial_cap_values + 192
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 176
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x82600ef0 // ldr x16, [c23, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400ef0 // str x16, [c23, #0]
	ldr x16, =0x40400414
	mrs x23, ELR_EL1
	sub x16, x16, x23
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b217 // cvtp c23, x16
	.inst 0xc2d042f7 // scvalue c23, c23, x16
	.inst 0x826002f0 // ldr c16, [c23, #0]
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
