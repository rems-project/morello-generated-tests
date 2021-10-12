.section text0, #alloc, #execinstr
test_start:
	.inst 0x3831129f // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:001 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa23fc021 // LDAPR-C.R-C Ct:1 Rn:1 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x48bd7c14 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:20 Rn:0 11111:11111 o0:0 Rs:29 1:1 L:0 0010001:0010001 size:01
	.inst 0x787802bf // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:000 o3:0 Rs:24 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c430f7 // LDPBLR-C.C-C Ct:23 Cn:7 100:100 opc:01 11000010110001000:11000010110001000
	.zero 3052
	.inst 0x1b1583ff // 0x1b1583ff
	.inst 0x35f62df4 // 0x35f62df4
	.inst 0x489f7f61 // 0x489f7f61
	.inst 0x7a1b001c // 0x7a1b001c
	.inst 0xd4000001
	.zero 62444
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae7 // ldr c7, [x23, #2]
	.inst 0xc2400ef1 // ldr c17, [x23, #3]
	.inst 0xc24012f4 // ldr c20, [x23, #4]
	.inst 0xc24016f5 // ldr c21, [x23, #5]
	.inst 0xc2401af8 // ldr c24, [x23, #6]
	.inst 0xc2401efb // ldr c27, [x23, #7]
	.inst 0xc24022fd // ldr c29, [x23, #8]
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x4
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010d7 // ldr c23, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x6, #0x4
	and x23, x23, x6
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e6 // ldr c6, [x23, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24006e6 // ldr c6, [x23, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400ae6 // ldr c6, [x23, #2]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2400ee6 // ldr c6, [x23, #3]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc24012e6 // ldr c6, [x23, #4]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc24016e6 // ldr c6, [x23, #5]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc2401ae6 // ldr c6, [x23, #6]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2401ee6 // ldr c6, [x23, #7]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc24022e6 // ldr c6, [x23, #8]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x23, 0x83
	orr x6, x6, x23
	ldr x23, =0x920000ab
	cmp x23, x6
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
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001410
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400c00
	ldr x1, =check_data3
	ldr x2, =0x40400c14
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x9f, 0x12, 0x31, 0x38, 0x21, 0xc0, 0x3f, 0xa2, 0x14, 0x7c, 0xbd, 0x48, 0xbf, 0x02, 0x78, 0x78
	.byte 0xf7, 0x30, 0xc4, 0xc2
.data
check_data3:
	.byte 0xff, 0x83, 0x15, 0x1b, 0xf4, 0x2d, 0xf6, 0x35, 0x61, 0x7f, 0x9f, 0x48, 0x1c, 0x00, 0x1b, 0x7a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400
	/* C7 */
	.octa 0x2000000000000000000000000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
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
	.octa 0x2000000000000000000000000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd0000000040704050000000000000001
initial_DDC_EL1_value:
	.octa 0x400000005002081a0000000000006001
initial_VBAR_EL1_value:
	.octa 0x200080005000041d0000000040400800
final_PCC_value:
	.octa 0x200080005000041d0000000040400c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001400
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40400c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
