.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8601201 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:16 00:00 opc:001 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:11
	.inst 0xc2c0101b // GCBASE-R.C-C Rd:27 Cn:0 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x9bb77c3e // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:1 Ra:31 o0:0 Rm:23 01:01 U:1 10011011:10011011
	.inst 0x384b6093 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:19 Rn:4 00:00 imm9:010110110 0:0 opc:01 111000:111000 size:00
	.inst 0x3821629f // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:110 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa23fc11d // 0xa23fc11d
	.inst 0x695ecc3f // 0x695ecc3f
	.inst 0xc2de05a0 // 0xc2de05a0
	.inst 0x88df7f9c // 0x88df7f9c
	.inst 0xd4000001
	.zero 65496
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c4 // ldr c4, [x14, #1]
	.inst 0xc24009c8 // ldr c8, [x14, #2]
	.inst 0xc2400dcd // ldr c13, [x14, #3]
	.inst 0xc24011d0 // ldr c16, [x14, #4]
	.inst 0xc24015d4 // ldr c20, [x14, #5]
	.inst 0xc24019dc // ldr c28, [x14, #6]
	/* Set up flags and system registers */
	ldr x14, =0x0
	msr SPSR_EL3, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0xc0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x4
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260116e // ldr c14, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001cb // ldr c11, [x14, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24005cb // ldr c11, [x14, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24009cb // ldr c11, [x14, #2]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc2400dcb // ldr c11, [x14, #3]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc24011cb // ldr c11, [x14, #4]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc24015cb // ldr c11, [x14, #5]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc24019cb // ldr c11, [x14, #6]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc2401dcb // ldr c11, [x14, #7]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc24021cb // ldr c11, [x14, #8]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc24025cb // ldr c11, [x14, #9]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc24029cb // ldr c11, [x14, #10]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010b6
	ldr x1, =check_data0
	ldr x2, =0x000010b7
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001114
	ldr x1, =check_data1
	ldr x2, =0x00001115
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001120
	ldr x1, =check_data2
	ldr x2, =0x00001128
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001300
	ldr x1, =check_data3
	ldr x2, =0x00001310
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001408
	ldr x1, =check_data4
	ldr x2, =0x0000140c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000018e4
	ldr x1, =check_data5
	ldr x2, =0x000018ec
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
	.zero 272
	.byte 0x00, 0x00, 0x00, 0x00, 0xf2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0xf0, 0x17, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3792
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xf2
.data
check_data2:
	.byte 0xf0, 0x17, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x01, 0x12, 0x60, 0xf8, 0x1b, 0x10, 0xc0, 0xc2, 0x3e, 0x7c, 0xb7, 0x9b, 0x93, 0x60, 0x4b, 0x38
	.byte 0x9f, 0x62, 0x21, 0x38, 0x1d, 0xc1, 0x3f, 0xa2, 0x3f, 0xcc, 0x5e, 0x69, 0xa0, 0x05, 0xde, 0xc2
	.byte 0x9c, 0x7f, 0xdf, 0x88, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x200020000ff0200000000
	/* C4 */
	.octa 0x1000
	/* C8 */
	.octa 0x1300
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C16 */
	.octa 0x1120
	/* C20 */
	.octa 0x1114
	/* C28 */
	.octa 0x1408
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x17f0
	/* C4 */
	.octa 0x1000
	/* C8 */
	.octa 0x1300
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C16 */
	.octa 0x1120
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x1114
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc00000000000000000f8000010005001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000080080000000040400028
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
	.dword 0x0000000000001300
	.dword el1_vector_jump_cap
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x82600d6e // ldr x14, [c11, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d6e // str x14, [c11, #0]
	ldr x14, =0x40400028
	mrs x11, ELR_EL1
	sub x14, x14, x11
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cb // cvtp c11, x14
	.inst 0xc2ce416b // scvalue c11, c11, x14
	.inst 0x8260016e // ldr c14, [c11, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
