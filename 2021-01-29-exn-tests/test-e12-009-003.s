.section text0, #alloc, #execinstr
test_start:
	.inst 0x089ffc19 // stlrb:aarch64/instrs/memory/ordered Rt:25 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xa247b000 // LDUR-C.RI-C Ct:0 Rn:0 00:00 imm9:001111011 0:0 opc:01 10100010:10100010
	.inst 0x1a000161 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:11 000000:000000 Rm:0 11010000:11010000 S:0 op:0 sf:0
	.inst 0x089f7cc6 // stllrb:aarch64/instrs/memory/ordered Rt:6 Rn:6 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x380cf60b // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:11 Rn:16 01:01 imm9:011001111 0:0 opc:00 111000:111000 size:00
	.inst 0x3818419e // 0x3818419e
	.inst 0xc2c2ba1d // 0xc2c2ba1d
	.inst 0xc2d650a0 // 0xc2d650a0
	.zero 32
	.inst 0xc2c1102e // 0xc2c1102e
	.inst 0xd4000001
	.zero 65464
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
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400465 // ldr c5, [x3, #1]
	.inst 0xc2400866 // ldr c6, [x3, #2]
	.inst 0xc2400c6b // ldr c11, [x3, #3]
	.inst 0xc240106c // ldr c12, [x3, #4]
	.inst 0xc2401470 // ldr c16, [x3, #5]
	.inst 0xc2401879 // ldr c25, [x3, #6]
	.inst 0xc2401c7e // ldr c30, [x3, #7]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0xc0000
	msr CPACR_EL1, x3
	ldr x3, =0x0
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x0
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601343 // ldr c3, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
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
	.inst 0xc240007a // ldr c26, [x3, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240047a // ldr c26, [x3, #1]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc240087a // ldr c26, [x3, #2]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc2400c7a // ldr c26, [x3, #3]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc240107a // ldr c26, [x3, #4]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc240147a // ldr c26, [x3, #5]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc240187a // ldr c26, [x3, #6]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc2401c7a // ldr c26, [x3, #7]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc240207a // ldr c26, [x3, #8]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240247a // ldr c26, [x3, #9]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001003
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001005
	ldr x1, =check_data1
	ldr x2, =0x00001006
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001090
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001180
	ldr x1, =check_data3
	ldr x2, =0x00001190
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001384
	ldr x1, =check_data4
	ldr x2, =0x00001385
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001a46
	ldr x1, =check_data5
	ldr x2, =0x00001a47
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400020
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400040
	ldr x1, =check_data7
	ldr x2, =0x40400048
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x02, 0x00, 0x00, 0x00
	.zero 240
	.byte 0x40, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 3696
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x02, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x40, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x46
.data
check_data6:
	.byte 0x19, 0xfc, 0x9f, 0x08, 0x00, 0xb0, 0x47, 0xa2, 0x61, 0x01, 0x00, 0x1a, 0xc6, 0x7c, 0x9f, 0x08
	.byte 0x0b, 0xf6, 0x0c, 0x38, 0x9e, 0x41, 0x18, 0x38, 0x1d, 0xba, 0xc2, 0xc2, 0xa0, 0x50, 0xd6, 0xc2
.data
check_data7:
	.byte 0x2e, 0x10, 0xc1, 0xc2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1005
	/* C5 */
	.octa 0x90000000000400020000000000000e60
	/* C6 */
	.octa 0x1a46
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x1400
	/* C16 */
	.octa 0x1002
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x2800000000000000000000000
	/* C5 */
	.octa 0x90000000000400020000000000000e60
	/* C6 */
	.octa 0x1a46
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x1400
	/* C14 */
	.octa 0xffffffffffffffff
	/* C16 */
	.octa 0x10d1
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x50d610d100000000000010d1
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd0000000000500070000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000100070000000040400048
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword 0x0000000000001180
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400048
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
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
