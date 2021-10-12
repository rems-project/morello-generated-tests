.section text0, #alloc, #execinstr
test_start:
	.inst 0x3831129f // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:001 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa23fc021 // LDAPR-C.R-C Ct:1 Rn:1 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x48bd7c14 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:20 Rn:0 11111:11111 o0:0 Rs:29 1:1 L:0 0010001:0010001 size:01
	.inst 0x787802bf // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:000 o3:0 Rs:24 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c430f7 // LDPBLR-C.C-C Ct:23 Cn:7 100:100 opc:01 11000010110001000:11000010110001000
	.zero 16364
	.inst 0x1b1583ff // 0x1b1583ff
	.inst 0x35f62df4 // 0x35f62df4
	.inst 0x489f7f61 // 0x489f7f61
	.inst 0x7a1b001c // 0x7a1b001c
	.inst 0xd4000001
	.zero 49132
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
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b47 // ldr c7, [x26, #2]
	.inst 0xc2400f51 // ldr c17, [x26, #3]
	.inst 0xc2401354 // ldr c20, [x26, #4]
	.inst 0xc2401755 // ldr c21, [x26, #5]
	.inst 0xc2401b58 // ldr c24, [x26, #6]
	.inst 0xc2401f5b // ldr c27, [x26, #7]
	.inst 0xc240235d // ldr c29, [x26, #8]
	/* Set up flags and system registers */
	ldr x26, =0x0
	msr SPSR_EL3, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0xc0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x84
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260113a // ldr c26, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
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
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x9, #0x4
	and x26, x26, x9
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400349 // ldr c9, [x26, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400749 // ldr c9, [x26, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400b49 // ldr c9, [x26, #2]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2400f49 // ldr c9, [x26, #3]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2401349 // ldr c9, [x26, #4]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2401749 // ldr c9, [x26, #5]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2401b49 // ldr c9, [x26, #6]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2401f49 // ldr c9, [x26, #7]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc2402349 // ldr c9, [x26, #8]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2402749 // ldr c9, [x26, #9]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402b49 // ldr c9, [x26, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a741 // chkeq c26, c9
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
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001220
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a10
	ldr x1, =check_data3
	ldr x2, =0x00001a12
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40404000
	ldr x1, =check_data5
	ldr x2, =0x40404014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 496
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.byte 0x01, 0x40, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 2032
	.byte 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1504
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.byte 0x01, 0x40, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x9f, 0x12, 0x31, 0x38, 0x21, 0xc0, 0x3f, 0xa2, 0x14, 0x7c, 0xbd, 0x48, 0xbf, 0x02, 0x78, 0x78
	.byte 0xf7, 0x30, 0xc4, 0xc2
.data
check_data5:
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
	.octa 0x900000000000c0000000000000001200
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0xa10
	/* C24 */
	.octa 0xf800
	/* C27 */
	.octa 0x40000000000500030000000000001000
	/* C29 */
	.octa 0xff00
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x900000000000c0000000000000001200
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0xa10
	/* C23 */
	.octa 0x1000000000000000000000000
	/* C24 */
	.octa 0xf800
	/* C27 */
	.octa 0x40000000000500030000000000001000
	/* C29 */
	.octa 0xff
	/* C30 */
	.octa 0x20008000800700070000000040400014
initial_DDC_EL0_value:
	.octa 0xd0000000400010000000000000003000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000100070000000040404014
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
	.dword 0x0000000000001200
	.dword 0x0000000000001210
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x82600d3a // ldr x26, [c9, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d3a // str x26, [c9, #0]
	ldr x26, =0x40404014
	mrs x9, ELR_EL1
	sub x26, x26, x9
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b349 // cvtp c9, x26
	.inst 0xc2da4129 // scvalue c9, c9, x26
	.inst 0x8260013a // ldr c26, [c9, #0]
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
