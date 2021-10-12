.section text0, #alloc, #execinstr
test_start:
	.inst 0x38a00376 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:27 00:00 opc:000 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xdac007b9 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:25 Rn:29 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xdac0143f // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:31 Rn:1 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x78107824 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:4 Rn:1 10:10 imm9:100000111 0:0 opc:00 111000:111000 size:01
	.inst 0xe2c3d07e // ASTUR-R.RI-64 Rt:30 Rn:3 op2:00 imm9:000111101 V:0 op1:11 11100010:11100010
	.inst 0x782d60bf // 0x782d60bf
	.inst 0xe24a2c17 // 0xe24a2c17
	.inst 0xb789c64d // 0xb789c64d
	.zero 14532
	.inst 0xa25ecaa5 // 0xa25ecaa5
	.inst 0xd4000001
	.zero 50964
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400963 // ldr c3, [x11, #2]
	.inst 0xc2400d64 // ldr c4, [x11, #3]
	.inst 0xc2401165 // ldr c5, [x11, #4]
	.inst 0xc240156d // ldr c13, [x11, #5]
	.inst 0xc2401975 // ldr c21, [x11, #6]
	.inst 0xc2401d7b // ldr c27, [x11, #7]
	.inst 0xc240217e // ldr c30, [x11, #8]
	/* Set up flags and system registers */
	ldr x11, =0x0
	msr SPSR_EL3, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0xc0000
	msr CPACR_EL1, x11
	ldr x11, =0x0
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x0
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260112b // ldr c11, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e402b // msr CELR_EL3, c11
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400169 // ldr c9, [x11, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400569 // ldr c9, [x11, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400969 // ldr c9, [x11, #2]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2400d69 // ldr c9, [x11, #3]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2401169 // ldr c9, [x11, #4]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2401569 // ldr c9, [x11, #5]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc2401969 // ldr c9, [x11, #6]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2401d69 // ldr c9, [x11, #7]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2402169 // ldr c9, [x11, #8]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2402569 // ldr c9, [x11, #9]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2402969 // ldr c9, [x11, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001038
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000019c0
	ldr x1, =check_data1
	ldr x2, =0x000019c1
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f08
	ldr x1, =check_data2
	ldr x2, =0x00001f0a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fc0
	ldr x1, =check_data3
	ldr x2, =0x00001fd0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x404008a2
	ldr x1, =check_data5
	ldr x2, =0x404008a4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x404038e4
	ldr x1, =check_data6
	ldr x2, =0x404038ec
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
	.zero 2496
	.byte 0x2a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1584
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x01, 0x20
.data
check_data1:
	.byte 0x2a
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x76, 0x03, 0xa0, 0x38, 0xb9, 0x07, 0xc0, 0xda, 0x3f, 0x14, 0xc0, 0xda, 0x24, 0x78, 0x10, 0x78
	.byte 0x7e, 0xd0, 0xc3, 0xe2, 0xbf, 0x60, 0x2d, 0x78, 0x17, 0x2c, 0x4a, 0xe2, 0x4d, 0xc6, 0x89, 0xb7
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xa5, 0xca, 0x5e, 0xa2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000200020000000040400800
	/* C1 */
	.octa 0x2001
	/* C3 */
	.octa 0x400000000006000f0000000000000ffb
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x103e
	/* C13 */
	.octa 0x2000000000001
	/* C21 */
	.octa 0x2100
	/* C27 */
	.octa 0x19c0
	/* C30 */
	.octa 0x2001080000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000200020000000040400800
	/* C1 */
	.octa 0x2001
	/* C3 */
	.octa 0x400000000006000f0000000000000ffb
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C13 */
	.octa 0x2000000000001
	/* C21 */
	.octa 0x2100
	/* C22 */
	.octa 0x2a
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x19c0
	/* C30 */
	.octa 0x2001080000000000
initial_DDC_EL0_value:
	.octa 0xc000000060010ffc0000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080000000800800000000404038ec
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
	.dword 0x0000000000001fc0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x404038ec
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x021e016b // add c11, c11, #1920
	.inst 0xc2c21160 // br c11

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
