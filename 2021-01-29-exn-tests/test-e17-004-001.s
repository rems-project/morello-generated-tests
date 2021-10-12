.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac00049 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:9 Rn:2 101101011000000000000:101101011000000000000 sf:1
	.inst 0xa2bf7c3e // CAS-C.R-C Ct:30 Rn:1 11111:11111 R:0 Cs:31 1:1 L:0 1:1 10100010:10100010
	.inst 0xd503395f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1001 11010101000000110011:11010101000000110011
	.inst 0xc2c21000 // BR-C-C 00000:00000 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.zero 48
	.inst 0xa2fd835f // SWPAL-CC.R-C Ct:31 Rn:26 100000:100000 Cs:29 1:1 R:1 A:1 10100010:10100010
	.inst 0x292295e1 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:1 Rn:15 Rt2:00101 imm7:1000101 L:0 1010010:1010010 opc:00
	.inst 0x9a8140d5 // csel:aarch64/instrs/integer/conditional/select Rd:21 Rn:6 o2:0 0:0 cond:0100 Rm:1 011010100:011010100 op:0 sf:1
	.inst 0x398663a0 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:29 imm12:000110011000 opc:10 111001:111001 size:00
	.inst 0xd4000001
	.zero 16300
	.inst 0xc2c213a0 // BR-C-C 00000:00000 Cn:29 100:100 opc:00 11000010110000100:11000010110000100
	.zero 49148
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
	.inst 0xc2400965 // ldr c5, [x11, #2]
	.inst 0xc2400d6f // ldr c15, [x11, #3]
	.inst 0xc240117a // ldr c26, [x11, #4]
	.inst 0xc240157d // ldr c29, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
	/* Set up flags and system registers */
	ldr x11, =0x84000000
	msr SPSR_EL3, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0xc0000
	msr CPACR_EL1, x11
	ldr x11, =0x0
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x4
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260118b // ldr c11, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
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
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x12, #0x8
	and x11, x11, x12
	cmp x11, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240016c // ldr c12, [x11, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240056c // ldr c12, [x11, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240096c // ldr c12, [x11, #2]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc2400d6c // ldr c12, [x11, #3]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc240116c // ldr c12, [x11, #4]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc240156c // ldr c12, [x11, #5]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc240196c // ldr c12, [x11, #6]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca561 // chkeq c11, c12
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
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001160
	ldr x1, =check_data2
	ldr x2, =0x00001170
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400040
	ldr x1, =check_data4
	ldr x2, =0x40400054
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x404001d8
	ldr x1, =check_data5
	ldr x2, =0x404001d9
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40404000
	ldr x1, =check_data6
	ldr x2, =0x40404004
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
	.zero 352
	.byte 0x01, 0x01, 0x20, 0x10, 0x01, 0x04, 0x01, 0x01, 0x01, 0x01, 0x04, 0x01, 0x01, 0x01, 0x02, 0x01
	.zero 3728
.data
check_data0:
	.byte 0x40, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0xc0, 0x00, 0x20
.data
check_data1:
	.byte 0x60, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x01, 0x01, 0x20, 0x10, 0x01, 0x04, 0x01, 0x01, 0x01, 0x01, 0x04, 0x01, 0x01, 0x01, 0x02, 0x01
.data
check_data3:
	.byte 0x49, 0x00, 0xc0, 0xda, 0x3e, 0x7c, 0xbf, 0xa2, 0x5f, 0x39, 0x03, 0xd5, 0x00, 0x10, 0xc2, 0xc2
.data
check_data4:
	.byte 0x5f, 0x83, 0xfd, 0xa2, 0xe1, 0x95, 0x22, 0x29, 0xd5, 0x40, 0x81, 0x9a, 0xa0, 0x63, 0x86, 0x39
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xa0, 0x13, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000a2a900070000000040404000
	/* C1 */
	.octa 0xd8000000000300070000000000001160
	/* C5 */
	.octa 0x0
	/* C15 */
	.octa 0x110c
	/* C26 */
	.octa 0x1000
	/* C29 */
	.octa 0x2000c000800000000000000040400040
	/* C30 */
	.octa 0x4000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xd8000000000300070000000000001160
	/* C5 */
	.octa 0x0
	/* C15 */
	.octa 0x110c
	/* C26 */
	.octa 0x1000
	/* C29 */
	.octa 0x2000c000800000000000000040400040
	/* C30 */
	.octa 0x4000000000000000000000000000
initial_DDC_EL0_value:
	.octa 0xd81000000003000600ffc00000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x2000c000000000000000000040400054
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000005100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 96
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
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x82600d8b // ldr x11, [c12, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d8b // str x11, [c12, #0]
	ldr x11, =0x40400054
	mrs x12, ELR_EL1
	sub x11, x11, x12
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16c // cvtp c12, x11
	.inst 0xc2cb418c // scvalue c12, c12, x11
	.inst 0x8260018b // ldr c11, [c12, #0]
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
