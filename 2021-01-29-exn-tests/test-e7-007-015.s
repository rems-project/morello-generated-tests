.section text0, #alloc, #execinstr
test_start:
	.inst 0x3831129f // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:001 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa23fc021 // LDAPR-C.R-C Ct:1 Rn:1 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x48bd7c14 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:20 Rn:0 11111:11111 o0:0 Rs:29 1:1 L:0 0010001:0010001 size:01
	.inst 0x787802bf // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:000 o3:0 Rs:24 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c430f7 // LDPBLR-C.C-C Ct:23 Cn:7 100:100 opc:01 11000010110001000:11000010110001000
	.zero 44
	.inst 0x1b1583ff // 0x1b1583ff
	.inst 0x35f62df4 // 0x35f62df4
	.inst 0x489f7f61 // 0x489f7f61
	.inst 0x7a1b001c // 0x7a1b001c
	.inst 0xd4000001
	.zero 65452
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
	.inst 0xc2400967 // ldr c7, [x11, #2]
	.inst 0xc2400d71 // ldr c17, [x11, #3]
	.inst 0xc2401174 // ldr c20, [x11, #4]
	.inst 0xc2401575 // ldr c21, [x11, #5]
	.inst 0xc2401978 // ldr c24, [x11, #6]
	.inst 0xc2401d7b // ldr c27, [x11, #7]
	.inst 0xc240217d // ldr c29, [x11, #8]
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
	ldr x11, =0x84
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011ab // ldr c11, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
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
	mov x13, #0x4
	and x11, x11, x13
	cmp x11, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240016d // ldr c13, [x11, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240056d // ldr c13, [x11, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240096d // ldr c13, [x11, #2]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc2400d6d // ldr c13, [x11, #3]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc240116d // ldr c13, [x11, #4]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc240156d // ldr c13, [x11, #5]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc240196d // ldr c13, [x11, #6]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc2401d6d // ldr c13, [x11, #7]
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	.inst 0xc240216d // ldr c13, [x11, #8]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc240256d // ldr c13, [x11, #9]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240296d // ldr c13, [x11, #10]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda561 // chkeq c11, c13
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001900
	ldr x1, =check_data2
	ldr x2, =0x00001920
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
	.zero 2304
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x08, 0x00, 0x00
	.byte 0x41, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x10, 0xc0, 0x00, 0x20, 0x00, 0x80, 0x00, 0x20
	.zero 1760
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x08, 0x00, 0x00
	.byte 0x41, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x10, 0xc0, 0x00, 0x20, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.byte 0x9f, 0x12, 0x31, 0x38, 0x21, 0xc0, 0x3f, 0xa2, 0x14, 0x7c, 0xbd, 0x48, 0xbf, 0x02, 0x78, 0x78
	.byte 0xf7, 0x30, 0xc4, 0xc2
.data
check_data4:
	.byte 0xff, 0x83, 0x15, 0x1b, 0xf4, 0x2d, 0xf6, 0x35, 0x61, 0x7f, 0x9f, 0x48, 0x1c, 0x00, 0x1b, 0x7a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x100
	/* C7 */
	.octa 0x900000000000c0000000000000001900
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000600000010000000000001000
	/* C29 */
	.octa 0xffff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x900000000000c0000000000000001900
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x801000000000000000000000000
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000600000010000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000800700070000000040400014
initial_DDC_EL0_value:
	.octa 0xd0000000200710070000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080002000c0100000000040400054
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001100
	.dword 0x0000000000001900
	.dword 0x0000000000001910
	.dword initial_cap_values + 32
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
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
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x82600dab // ldr x11, [c13, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dab // str x11, [c13, #0]
	ldr x11, =0x40400054
	mrs x13, ELR_EL1
	sub x11, x11, x13
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16d // cvtp c13, x11
	.inst 0xc2cb41ad // scvalue c13, c13, x11
	.inst 0x826001ab // ldr c11, [c13, #0]
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
