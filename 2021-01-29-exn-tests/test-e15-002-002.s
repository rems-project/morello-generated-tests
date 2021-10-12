.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c803be // SCBNDS-C.CR-C Cd:30 Cn:29 000:000 opc:00 0:0 Rm:8 11000010110:11000010110
	.inst 0x82449952 // ASTR-R.RI-32 Rt:18 Rn:10 op:10 imm9:001001001 L:0 1000001001:1000001001
	.inst 0x2234d81f // STLXP-R.CR-C Ct:31 Rn:0 Ct2:10110 1:1 Rs:20 1:1 L:0 001000100:001000100
	.inst 0xb820525f // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:18 00:00 opc:101 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xd458bb20 // hlt:aarch64/instrs/system/exceptions/debug/halt 00000:00000 imm16:1100010111011001 11010100010:11010100010
	.zero 1004
	.inst 0x085fffa2 // 0x85fffa2
	.inst 0xc2c21021 // 0xc2c21021
	.inst 0xb87c03df // 0xb87c03df
	.inst 0xc85f7fc1 // 0xc85f7fc1
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008ca // ldr c10, [x6, #2]
	.inst 0xc2400cd2 // ldr c18, [x6, #3]
	.inst 0xc24010d6 // ldr c22, [x6, #4]
	.inst 0xc24014dc // ldr c28, [x6, #5]
	.inst 0xc24018dd // ldr c29, [x6, #6]
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x4
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x4
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
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601326 // ldr c6, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x25, #0xf
	and x6, x6, x25
	cmp x6, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d9 // ldr c25, [x6, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24004d9 // ldr c25, [x6, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24008d9 // ldr c25, [x6, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400cd9 // ldr c25, [x6, #3]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc24010d9 // ldr c25, [x6, #4]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc24014d9 // ldr c25, [x6, #5]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc24018d9 // ldr c25, [x6, #6]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc2401cd9 // ldr c25, [x6, #7]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc24020d9 // ldr c25, [x6, #8]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x6, 0x0
	orr x25, x25, x6
	ldr x6, =0x2000000
	cmp x6, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001150
	ldr x1, =check_data1
	ldr x2, =0x00001154
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001408
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.byte 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1008
	.byte 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3056
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data2:
	.byte 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xbe, 0x03, 0xc8, 0xc2, 0x52, 0x99, 0x44, 0x82, 0x1f, 0xd8, 0x34, 0x22, 0x5f, 0x52, 0x20, 0xb8
	.byte 0x20, 0xbb, 0x58, 0xd4
.data
check_data4:
	.byte 0xa2, 0xff, 0x5f, 0x08, 0x21, 0x10, 0xc2, 0xc2, 0xdf, 0x03, 0x7c, 0xb8, 0xc1, 0x7f, 0x5f, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000300070000000000001000
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x102c
	/* C18 */
	.octa 0xc0000000000080080000000000001000
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x2000000700070000000000001400
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000000000300070000000000001000
	/* C1 */
	.octa 0x40
	/* C2 */
	.octa 0x40
	/* C10 */
	.octa 0x102c
	/* C18 */
	.octa 0xc0000000000080080000000000001000
	/* C20 */
	.octa 0x1
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x2000000700070000000000001400
initial_DDC_EL0_value:
	.octa 0x40000000000180050080000000000001
initial_DDC_EL1_value:
	.octa 0xc00000005484000000ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080005000e01d0000000040400000
final_PCC_value:
	.octa 0x200080005000e01d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020140050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 64
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400414
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
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
