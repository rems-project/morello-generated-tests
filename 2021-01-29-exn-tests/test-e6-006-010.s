.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2e01a98 // CVT-C.CR-C Cd:24 Cn:20 0110:0110 0:0 0:0 Rm:0 11000010111:11000010111
	.inst 0x9a8a971f // csinc:aarch64/instrs/integer/conditional/select Rd:31 Rn:24 o2:1 0:0 cond:1001 Rm:10 011010100:011010100 op:0 sf:1
	.inst 0x78bf521b // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:27 Rn:16 00:00 opc:101 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x489f7fa0 // stllrh:aarch64/instrs/memory/ordered Rt:0 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe22fd419 // ALDUR-V.RI-B Rt:25 Rn:0 op2:01 imm9:011111101 V:1 op1:00 11100010:11100010
	.zero 1004
	.inst 0x62fc68c3 // 0x62fc68c3
	.inst 0x82fef3d9 // 0x82fef3d9
	.inst 0x381090cf // 0x381090cf
	.inst 0xc22f3015 // 0xc22f3015
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
	.inst 0xc2400566 // ldr c6, [x11, #1]
	.inst 0xc240096f // ldr c15, [x11, #2]
	.inst 0xc2400d70 // ldr c16, [x11, #3]
	.inst 0xc2401174 // ldr c20, [x11, #4]
	.inst 0xc2401575 // ldr c21, [x11, #5]
	.inst 0xc240197d // ldr c29, [x11, #6]
	.inst 0xc2401d7e // ldr c30, [x11, #7]
	/* Set up flags and system registers */
	ldr x11, =0x0
	msr SPSR_EL3, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0x1c0000
	msr CPACR_EL1, x11
	ldr x11, =0x4
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x0
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
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260126b // ldr c11, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
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
	mov x19, #0x2
	and x11, x11, x19
	cmp x11, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400173 // ldr c19, [x11, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400573 // ldr c19, [x11, #1]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2400973 // ldr c19, [x11, #2]
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	.inst 0xc2400d73 // ldr c19, [x11, #3]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2401173 // ldr c19, [x11, #4]
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	.inst 0xc2401573 // ldr c19, [x11, #5]
	.inst 0xc2d3a681 // chkeq c20, c19
	b.ne comparison_fail
	.inst 0xc2401973 // ldr c19, [x11, #6]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc2401d73 // ldr c19, [x11, #7]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc2402173 // ldr c19, [x11, #8]
	.inst 0xc2d3a721 // chkeq c25, c19
	b.ne comparison_fail
	.inst 0xc2402573 // ldr c19, [x11, #9]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2402973 // ldr c19, [x11, #10]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc2402d73 // ldr c19, [x11, #11]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2403173 // ldr c19, [x11, #12]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984033 // mrs c19, CELR_EL1
	.inst 0xc2d3a561 // chkeq c11, c19
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	mov x11, 0x0
	orr x19, x19, x11
	ldr x11, =0x1fe00000
	cmp x11, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001050
	ldr x1, =check_data1
	ldr x2, =0x00001052
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bf8
	ldr x1, =check_data2
	ldr x2, =0x00001bfc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d20
	ldr x1, =check_data3
	ldr x2, =0x00001d30
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e89
	ldr x1, =check_data4
	ldr x2, =0x00001e8a
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f80
	ldr x1, =check_data5
	ldr x2, =0x00001fa0
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
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x60, 0x60
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 32
.data
check_data6:
	.byte 0x98, 0x1a, 0xe0, 0xc2, 0x1f, 0x97, 0x8a, 0x9a, 0x1b, 0x52, 0xbf, 0x78, 0xa0, 0x7f, 0x9f, 0x48
	.byte 0x19, 0xd4, 0x2f, 0xe2
.data
check_data7:
	.byte 0xc3, 0x68, 0xfc, 0x62, 0xd9, 0xf3, 0xfe, 0x82, 0xcf, 0x90, 0x10, 0x38, 0x15, 0x30, 0x2f, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffffff6060
	/* C6 */
	.octa 0x2000
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x1000
	/* C20 */
	.octa 0x10002800b0080000000000000
	/* C21 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x1050
	/* C30 */
	.octa 0x80000000000500070000000000000598
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xffffffffffff6060
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x1f80
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x1000
	/* C20 */
	.octa 0x10002800b0080000000000000
	/* C21 */
	.octa 0x4000000000000000000000000000
	/* C24 */
	.octa 0x10002800bffffffffffff6060
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x100
	/* C29 */
	.octa 0x1050
	/* C30 */
	.octa 0x80000000000500070000000000000598
initial_DDC_EL0_value:
	.octa 0xc0000000000400060000000000000001
initial_DDC_EL1_value:
	.octa 0xd80000000006000100fffffff8000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001f90
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword final_cap_values + 192
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
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x82600e6b // ldr x11, [c19, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e6b // str x11, [c19, #0]
	ldr x11, =0x40400414
	mrs x19, ELR_EL1
	sub x11, x11, x19
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b173 // cvtp c19, x11
	.inst 0xc2cb4273 // scvalue c19, c19, x11
	.inst 0x8260026b // ldr c11, [c19, #0]
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
