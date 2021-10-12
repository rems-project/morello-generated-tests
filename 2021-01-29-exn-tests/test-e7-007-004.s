.section text0, #alloc, #execinstr
test_start:
	.inst 0x3831129f // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:001 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa23fc021 // LDAPR-C.R-C Ct:1 Rn:1 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x48bd7c14 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:20 Rn:0 11111:11111 o0:0 Rs:29 1:1 L:0 0010001:0010001 size:01
	.inst 0x787802bf // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:000 o3:0 Rs:24 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c430f7 // LDPBLR-C.C-C Ct:23 Cn:7 100:100 opc:01 11000010110001000:11000010110001000
	.zero 1004
	.inst 0x1b1583ff // 0x1b1583ff
	.inst 0x35f62df4 // 0x35f62df4
	.inst 0x489f7f61 // 0x489f7f61
	.inst 0x7a1b001c // 0x7a1b001c
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
	.inst 0xc2400a07 // ldr c7, [x16, #2]
	.inst 0xc2400e11 // ldr c17, [x16, #3]
	.inst 0xc2401214 // ldr c20, [x16, #4]
	.inst 0xc2401615 // ldr c21, [x16, #5]
	.inst 0xc2401a18 // ldr c24, [x16, #6]
	.inst 0xc2401e1b // ldr c27, [x16, #7]
	.inst 0xc240221d // ldr c29, [x16, #8]
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x4
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
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
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x23, #0x4
	and x16, x16, x23
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400217 // ldr c23, [x16, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400617 // ldr c23, [x16, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a17 // ldr c23, [x16, #2]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2400e17 // ldr c23, [x16, #3]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401217 // ldr c23, [x16, #4]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2401617 // ldr c23, [x16, #5]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc2401a17 // ldr c23, [x16, #6]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc2401e17 // ldr c23, [x16, #7]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2402217 // ldr c23, [x16, #8]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x16, 0x83
	orr x23, x23, x16
	ldr x16, =0x920000ab
	cmp x16, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001005
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
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001102
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001400
	ldr x1, =check_data3
	ldr x2, =0x00001402
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffc
	ldr x1, =check_data4
	ldr x2, =0x00001ffe
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
	.byte 0x00, 0x00, 0x00, 0x00, 0xf7, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xf7
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x9f, 0x12, 0x31, 0x38, 0x21, 0xc0, 0x3f, 0xa2, 0x14, 0x7c, 0xbd, 0x48, 0xbf, 0x02, 0x78, 0x78
	.byte 0xf7, 0x30, 0xc4, 0xc2
.data
check_data6:
	.byte 0xff, 0x83, 0x15, 0x1b, 0xf4, 0x2d, 0xf6, 0x35, 0x61, 0x7f, 0x9f, 0x48, 0x1c, 0x00, 0x1b, 0x7a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x3fc
	/* C1 */
	.octa 0xc
	/* C7 */
	.octa 0x8000000001070009ffc010e4003a0001
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0xfc
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000000100050000000000001ffc
	/* C29 */
	.octa 0xffff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x3fc
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x8000000001070009ffc010e4003a0001
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0xfc
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000000100050000000000001ffc
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd00000004006100400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400001
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000402400000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 32
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 112
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
