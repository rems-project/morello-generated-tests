.section text0, #alloc, #execinstr
test_start:
	.inst 0xf83f43df // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:30 00:00 opc:100 0:0 Rs:31 1:1 R:0 A:0 111000:111000 size:11
	.inst 0xd274a5ec // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:12 Rn:15 imms:101001 immr:110100 N:1 100100:100100 opc:10 sf:1
	.inst 0x08dffc9f // ldarb:aarch64/instrs/memory/ordered Rt:31 Rn:4 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c1d020 // CPY-C.C-C Cd:0 Cn:1 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xd65f03a0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:29 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 16
	.inst 0xc85f7c3e // ldxr:aarch64/instrs/memory/exclusive/single Rt:30 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xda1d03f4 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:20 Rn:31 000000:000000 Rm:29 11010000:11010000 S:0 op:1 sf:1
	.inst 0xf2d247c0 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1001001000111110 hw:10 100101:100101 opc:11 sf:1
	.inst 0xeb40b000 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:0 Rn:0 imm6:101100 Rm:0 0:0 shift:01 01011:01011 S:1 op:1 sf:1
	.inst 0xd4000001
	.zero 65480
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
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006e4 // ldr c4, [x23, #1]
	.inst 0xc2400afd // ldr c29, [x23, #2]
	.inst 0xc2400efe // ldr c30, [x23, #3]
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
	ldr x23, =0xc
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82601117 // ldr c23, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	mov x8, #0xf
	and x23, x23, x8
	cmp x23, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e8 // ldr c8, [x23, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24006e8 // ldr c8, [x23, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400ae8 // ldr c8, [x23, #2]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc2400ee8 // ldr c8, [x23, #3]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc24012e8 // ldr c8, [x23, #4]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001028
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001198
	ldr x1, =check_data1
	ldr x2, =0x00001199
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013d0
	ldr x1, =check_data2
	ldr x2, =0x000013d8
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
	ldr x0, =0x40400024
	ldr x1, =check_data4
	ldr x2, =0x40400038
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xdf, 0x43, 0x3f, 0xf8, 0xec, 0xa5, 0x74, 0xd2, 0x9f, 0xfc, 0xdf, 0x08, 0x20, 0xd0, 0xc1, 0xc2
	.byte 0xa0, 0x03, 0x5f, 0xd6
.data
check_data4:
	.byte 0x3e, 0x7c, 0x5f, 0xc8, 0xf4, 0x03, 0x1d, 0xda, 0xc0, 0x47, 0xd2, 0xf2, 0x00, 0xb0, 0x40, 0xeb
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x13d0
	/* C4 */
	.octa 0x1198
	/* C29 */
	.octa 0x40400024
	/* C30 */
	.octa 0x1020
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x923e000013c7
	/* C1 */
	.octa 0x13d0
	/* C4 */
	.octa 0x1198
	/* C29 */
	.octa 0x40400024
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc0000000000600010000000007fffff1
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080000000c0000000000040400038
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600d17 // ldr x23, [c8, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d17 // str x23, [c8, #0]
	ldr x23, =0x40400038
	mrs x8, ELR_EL1
	sub x23, x23, x8
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e8 // cvtp c8, x23
	.inst 0xc2d74108 // scvalue c8, c8, x23
	.inst 0x82600117 // ldr c23, [c8, #0]
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
