.section text0, #alloc, #execinstr
test_start:
	.inst 0xc85ffdf2 // ldaxr:aarch64/instrs/memory/exclusive/single Rt:18 Rn:15 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xa224823d // SWP-CC.R-C Ct:29 Rn:17 100000:100000 Cs:4 1:1 R:0 A:0 10100010:10100010
	.inst 0xb81ea061 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:3 00:00 imm9:111101010 0:0 opc:00 111000:111000 size:10
	.inst 0xf89ce030 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:1 00:00 imm9:111001110 0:0 opc:10 111000:111000 size:11
	.inst 0x421fff21 // STLR-C.R-C Ct:1 Rn:25 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.zero 1004
	.inst 0x1ac42fa6 // 0x1ac42fa6
	.inst 0xbc02cf77 // 0xbc02cf77
	.inst 0x78484e1c // 0x78484e1c
	.inst 0x387d827d // 0x387d827d
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
	ldr x26, =initial_cap_values
	.inst 0xc2400341 // ldr c1, [x26, #0]
	.inst 0xc2400743 // ldr c3, [x26, #1]
	.inst 0xc2400b44 // ldr c4, [x26, #2]
	.inst 0xc2400f4f // ldr c15, [x26, #3]
	.inst 0xc2401350 // ldr c16, [x26, #4]
	.inst 0xc2401751 // ldr c17, [x26, #5]
	.inst 0xc2401b53 // ldr c19, [x26, #6]
	.inst 0xc2401f59 // ldr c25, [x26, #7]
	.inst 0xc240235b // ldr c27, [x26, #8]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q23, =0x0
	/* Set up flags and system registers */
	ldr x26, =0x0
	msr SPSR_EL3, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0x1c0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x4
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012da // ldr c26, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e403a // msr CELR_EL3, c26
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400356 // ldr c22, [x26, #0]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400756 // ldr c22, [x26, #1]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc2400b56 // ldr c22, [x26, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400f56 // ldr c22, [x26, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401356 // ldr c22, [x26, #4]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2401756 // ldr c22, [x26, #5]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc2401b56 // ldr c22, [x26, #6]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2401f56 // ldr c22, [x26, #7]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2402356 // ldr c22, [x26, #8]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc2402756 // ldr c22, [x26, #9]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2402b56 // ldr c22, [x26, #10]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2402f56 // ldr c22, [x26, #11]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2403356 // ldr c22, [x26, #12]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x22, v23.d[0]
	cmp x26, x22
	b.ne comparison_fail
	ldr x26, =0x0
	mov x22, v23.d[1]
	cmp x26, x22
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	ldr x22, =esr_el1_dump_address
	ldr x22, [x22]
	mov x26, 0x83
	orr x22, x22, x26
	ldr x26, =0x920000e3
	cmp x26, x22
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001804
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c1c
	ldr x1, =check_data3
	ldr x2, =0x00001c1e
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001eb9
	ldr x1, =check_data4
	ldr x2, =0x00001eba
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
	ldr x0, =0x40401000
	ldr x1, =check_data7
	ldr x2, =0x40401008
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa8
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0xfc
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xf2, 0xfd, 0x5f, 0xc8, 0x3d, 0x82, 0x24, 0xa2, 0x61, 0xa0, 0x1e, 0xb8, 0x30, 0xe0, 0x9c, 0xf8
	.byte 0x21, 0xff, 0x1f, 0x42
.data
check_data6:
	.byte 0xa6, 0x2f, 0xc4, 0x1a, 0x77, 0xcf, 0x02, 0xbc, 0x1c, 0x4e, 0x48, 0x78, 0x7d, 0x82, 0x7d, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xfc000000
	/* C3 */
	.octa 0x1036
	/* C4 */
	.octa 0xa8000000000000000000000000000008
	/* C15 */
	.octa 0x40401000
	/* C16 */
	.octa 0x80000000004140050000000000001b98
	/* C17 */
	.octa 0x1000
	/* C19 */
	.octa 0xc0000000000100050000000000001eb9
	/* C25 */
	.octa 0x2ffffffffffffef4
	/* C27 */
	.octa 0x400000004001000200000000000017d4
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xfc000000
	/* C3 */
	.octa 0x1036
	/* C4 */
	.octa 0xa8000000000000000000000000000008
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x40401000
	/* C16 */
	.octa 0x80000000004140050000000000001c1c
	/* C17 */
	.octa 0x1000
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0xc0000000000100050000000000001eb9
	/* C25 */
	.octa 0x2ffffffffffffef4
	/* C27 */
	.octa 0x40000000400100020000000000001800
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xdc000000201200000000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080006000e8110000000040400001
final_PCC_value:
	.octa 0x200080006000e8110000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000373100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 160
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x021e035a // add c26, c26, #1920
	.inst 0xc2c21340 // br c26

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
