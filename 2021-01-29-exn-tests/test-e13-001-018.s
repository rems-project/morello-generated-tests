.section text0, #alloc, #execinstr
test_start:
	.inst 0x1224d7f2 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:18 Rn:31 imms:110101 immr:100100 N:0 100100:100100 opc:00 sf:0
	.inst 0xd125a426 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:6 Rn:1 imm12:100101101001 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x889ffc64 // stlr:aarch64/instrs/memory/ordered Rt:4 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c411df // LDPBR-C.C-C Ct:31 Cn:14 100:100 opc:00 11000010110001000:11000010110001000
	.zero 1008
	.inst 0xb99e6496 // 0xb99e6496
	.inst 0xc2c6c10c // 0xc2c6c10c
	.inst 0x427f7c81 // 0x427f7c81
	.inst 0xc2c433b5 // 0xc2c433b5
	.zero 15344
	.inst 0x08017c18 // stxrb:aarch64/instrs/memory/exclusive/single Rt:24 Rn:0 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:00
	.zero 43004
	.inst 0xd4000001
	.zero 6140
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e3 // ldr c3, [x7, #1]
	.inst 0xc24008e4 // ldr c4, [x7, #2]
	.inst 0xc2400ce8 // ldr c8, [x7, #3]
	.inst 0xc24010ee // ldr c14, [x7, #4]
	.inst 0xc24014fd // ldr c29, [x7, #5]
	/* Set up flags and system registers */
	ldr x7, =0x0
	msr SPSR_EL3, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30d5d99f
	msr SCTLR_EL1, x7
	ldr x7, =0xc0000
	msr CPACR_EL1, x7
	ldr x7, =0x84
	msr S3_0_C1_C2_2, x7 // CCTLR_EL1
	ldr x7, =0x0
	msr S3_3_C1_C2_2, x7 // CCTLR_EL0
	ldr x7, =initial_DDC_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884127 // msr DDC_EL0, c7
	ldr x7, =initial_DDC_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc28c4127 // msr DDC_EL1, c7
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601147 // ldr c7, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e4027 // msr CELR_EL3, c7
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x10, #0xf
	and x7, x7, x10
	cmp x7, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000ea // ldr c10, [x7, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24004ea // ldr c10, [x7, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24008ea // ldr c10, [x7, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400cea // ldr c10, [x7, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc24010ea // ldr c10, [x7, #4]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc24014ea // ldr c10, [x7, #5]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc24018ea // ldr c10, [x7, #6]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc2401cea // ldr c10, [x7, #7]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc24020ea // ldr c10, [x7, #8]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc24024ea // ldr c10, [x7, #9]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc24028ea // ldr c10, [x7, #10]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2402cea // ldr c10, [x7, #11]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x7, 0x83
	orr x10, x10, x7
	ldr x7, =0x920000eb
	cmp x7, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001810
	ldr x1, =check_data1
	ldr x2, =0x00001830
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400410
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40404000
	ldr x1, =check_data4
	ldr x2, =0x40404004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x404041a0
	ldr x1, =check_data5
	ldr x2, =0x404041a1
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40406004
	ldr x1, =check_data6
	ldr x2, =0x40406008
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040e800
	ldr x1, =check_data7
	ldr x2, =0x4040e804
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
	.zero 16
	.byte 0x00, 0xe8, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x69, 0xe3, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x20
	.zero 2048
	.byte 0x01, 0x40, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 2000
.data
check_data0:
	.byte 0xa0, 0x41, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0xe8, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x69, 0xe3, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 16
	.byte 0x01, 0x40, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0xf2, 0xd7, 0x24, 0x12, 0x26, 0xa4, 0x25, 0xd1, 0x64, 0xfc, 0x9f, 0x88, 0xdf, 0x11, 0xc4, 0xc2
.data
check_data3:
	.byte 0x96, 0x64, 0x9e, 0xb9, 0x0c, 0xc1, 0xc6, 0xc2, 0x81, 0x7c, 0x7f, 0x42, 0xb5, 0x33, 0xc4, 0xc2
.data
check_data4:
	.byte 0x18, 0x7c, 0x01, 0x08
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 4
.data
check_data7:
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x800000004000400900000000404041a0
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000000300070000000000001810
	/* C29 */
	.octa 0x901000000f0a00060000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x800000004000400900000000404041a0
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000000300070000000000001810
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x404041a0
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x901000000f0a00060000000000001000
	/* C30 */
	.octa 0x20008000e000000d0000000040400411
initial_DDC_EL0_value:
	.octa 0x400000000017000700ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x80000000000000080000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080006000000d0000000040400001
final_PCC_value:
	.octa 0x200080004000e369000000004040e804
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008080200000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x0000000000001810
	.dword 0x0000000000001820
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
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
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600d47 // ldr x7, [c10, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d47 // str x7, [c10, #0]
	ldr x7, =0x4040e804
	mrs x10, ELR_EL1
	sub x7, x7, x10
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ea // cvtp c10, x7
	.inst 0xc2c7414a // scvalue c10, c10, x7
	.inst 0x82600147 // ldr c7, [c10, #0]
	.inst 0x021e00e7 // add c7, c7, #1920
	.inst 0xc2c210e0 // br c7

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
