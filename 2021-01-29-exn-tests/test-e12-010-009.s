.section text0, #alloc, #execinstr
test_start:
	.inst 0x386033ba // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:29 00:00 opc:011 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x82705d21 // ALDR-R.RI-64 Rt:1 Rn:9 op:11 imm9:100000101 L:1 1000001001:1000001001
	.inst 0x225f7e5e // LDXR-C.R-C Ct:30 Rn:18 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xe219f7bf // ALDURB-R.RI-32 Rt:31 Rn:29 op2:01 imm9:110011111 V:0 op1:00 11100010:11100010
	.inst 0xa2e383b8 // SWPAL-CC.R-C Ct:24 Rn:29 100000:100000 Cs:3 1:1 R:1 A:1 10100010:10100010
	.inst 0x78cb4bc5 // 0x78cb4bc5
	.inst 0x787d337e // 0x787d337e
	.inst 0xfc54769e // 0xfc54769e
	.inst 0x782003bf // 0x782003bf
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e3 // ldr c3, [x23, #1]
	.inst 0xc2400ae9 // ldr c9, [x23, #2]
	.inst 0xc2400ef2 // ldr c18, [x23, #3]
	.inst 0xc24012f4 // ldr c20, [x23, #4]
	.inst 0xc24016fb // ldr c27, [x23, #5]
	.inst 0xc2401afd // ldr c29, [x23, #6]
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0x3c0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x0
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601157 // ldr c23, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002ea // ldr c10, [x23, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24006ea // ldr c10, [x23, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400aea // ldr c10, [x23, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400eea // ldr c10, [x23, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc24012ea // ldr c10, [x23, #4]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc24016ea // ldr c10, [x23, #5]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc2401aea // ldr c10, [x23, #6]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc2401eea // ldr c10, [x23, #7]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc24022ea // ldr c10, [x23, #8]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc24026ea // ldr c10, [x23, #9]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc2402aea // ldr c10, [x23, #10]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2402eea // ldr c10, [x23, #11]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x1400
	mov x10, v30.d[0]
	cmp x23, x10
	b.ne comparison_fail
	ldr x23, =0x0
	mov x10, v30.d[1]
	cmp x23, x10
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa6e1 // chkeq c23, c10
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
	ldr x0, =0x000014b4
	ldr x1, =check_data1
	ldr x2, =0x000014b6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017df
	ldr x1, =check_data2
	ldr x2, =0x000017e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001828
	ldr x1, =check_data3
	ldr x2, =0x00001830
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001840
	ldr x1, =check_data4
	ldr x2, =0x00001850
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.byte 0x00, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2096
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1968
.data
check_data0:
	.byte 0x00, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x18, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data5:
	.byte 0xba, 0x33, 0x60, 0x38, 0x21, 0x5d, 0x70, 0x82, 0x5e, 0x7e, 0x5f, 0x22, 0xbf, 0xf7, 0x19, 0xe2
	.byte 0xb8, 0x83, 0xe3, 0xa2, 0xc5, 0x4b, 0xcb, 0x78, 0x7e, 0x33, 0x7d, 0x78, 0x9e, 0x76, 0x54, 0xfc
	.byte 0xbf, 0x03, 0x20, 0x78, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C9 */
	.octa 0x80000000600100000000000000001000
	/* C18 */
	.octa 0x1000
	/* C20 */
	.octa 0x1000
	/* C27 */
	.octa 0x1848
	/* C29 */
	.octa 0x80000000200700070000000000001840
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x80000000600100000000000000001000
	/* C18 */
	.octa 0x1000
	/* C20 */
	.octa 0xf47
	/* C24 */
	.octa 0x20000000000000000000
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x1848
	/* C29 */
	.octa 0x80000000200700070000000000001840
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd81000000003000700ffe00000ffe001
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
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 64
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
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
