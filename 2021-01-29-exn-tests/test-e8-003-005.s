.section text0, #alloc, #execinstr
test_start:
	.inst 0x8242bbe1 // ASTR-R.RI-32 Rt:1 Rn:31 op:10 imm9:000101011 L:0 1000001001:1000001001
	.inst 0x82502c9e // ASTR-R.RI-64 Rt:30 Rn:4 op:11 imm9:100000010 L:0 1000001001:1000001001
	.inst 0x8256667f // ASTRB-R.RI-B Rt:31 Rn:19 op:01 imm9:101100110 L:0 1000001001:1000001001
	.inst 0x38a023dc // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:30 00:00 opc:010 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x78530361 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:27 00:00 imm9:100110000 0:0 opc:01 111000:111000 size:01
	.zero 1004
	.inst 0xc2c150e1 // 0xc2c150e1
	.inst 0x3c2dc818 // 0x3c2dc818
	.inst 0xc2c133a0 // 0xc2c133a0
	.inst 0x935c3abd // 0x935c3abd
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400964 // ldr c4, [x11, #2]
	.inst 0xc2400d6d // ldr c13, [x11, #3]
	.inst 0xc2401173 // ldr c19, [x11, #4]
	.inst 0xc240157b // ldr c27, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q24, =0x0
	/* Set up flags and system registers */
	ldr x11, =0x4000000
	msr SPSR_EL3, x11
	ldr x11, =initial_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288410b // msr CSP_EL0, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0x3c0000
	msr CPACR_EL1, x11
	ldr x11, =0x0
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x4
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =initial_DDC_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c412b // msr DDC_EL1, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260124b // ldr c11, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	.inst 0xc2400172 // ldr c18, [x11, #0]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc2400572 // ldr c18, [x11, #1]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2400972 // ldr c18, [x11, #2]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2400d72 // ldr c18, [x11, #3]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc2401172 // ldr c18, [x11, #4]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc2401572 // ldr c18, [x11, #5]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x18, v24.d[0]
	cmp x11, x18
	b.ne comparison_fail
	ldr x11, =0x0
	mov x18, v24.d[1]
	cmp x11, x18
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984112 // mrs c18, CSP_EL0
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	ldr x18, =esr_el1_dump_address
	ldr x18, [x18]
	mov x11, 0x83
	orr x18, x18, x11
	ldr x11, =0x920000a3
	cmp x11, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001232
	ldr x1, =check_data1
	ldr x2, =0x00001233
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001810
	ldr x1, =check_data2
	ldr x2, =0x00001818
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000018ac
	ldr x1, =check_data3
	ldr x2, =0x000018b0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000019a8
	ldr x1, =check_data4
	ldr x2, =0x000019a9
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
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xa8, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xe1, 0xbb, 0x42, 0x82, 0x9e, 0x2c, 0x50, 0x82, 0x7f, 0x66, 0x56, 0x82, 0xdc, 0x23, 0xa0, 0x38
	.byte 0x61, 0x03, 0x53, 0x78
.data
check_data6:
	.byte 0xe1, 0x50, 0xc1, 0xc2, 0x18, 0xc8, 0x2d, 0x3c, 0xa0, 0x33, 0xc1, 0xc2, 0xbd, 0x3a, 0x5c, 0x93
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x1000
	/* C13 */
	.octa 0x1000
	/* C19 */
	.octa 0x10cc
	/* C27 */
	.octa 0x800000003097e09e0000000000000005
	/* C30 */
	.octa 0xc00000000001000500000000000019a8
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C4 */
	.octa 0x1000
	/* C13 */
	.octa 0x1000
	/* C19 */
	.octa 0x10cc
	/* C27 */
	.octa 0x800000003097e09e0000000000000005
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0xc00000000001000500000000000019a8
initial_SP_EL0_value:
	.octa 0x1800
initial_DDC_EL0_value:
	.octa 0x40000000000300070000000000000000
initial_DDC_EL1_value:
	.octa 0x400000000007000700ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000000d0000000040400000
final_SP_EL0_value:
	.octa 0x1800
final_PCC_value:
	.octa 0x200080004000000d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 80
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40400414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
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
