.section text0, #alloc, #execinstr
test_start:
	.inst 0xf9314ddf // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:14 imm12:110001010011 opc:00 111001:111001 size:11
	.inst 0xc2d8bbf4 // SCBNDS-C.CI-C Cd:20 Cn:31 1110:1110 S:0 imm6:110001 11000010110:11000010110
	.inst 0x882ba627 // stlxp:aarch64/instrs/memory/exclusive/pair Rt:7 Rn:17 Rt2:01001 o0:1 Rs:11 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0xa2ef7fd6 // CASA-C.R-C Ct:22 Rn:30 11111:11111 R:0 Cs:15 1:1 L:1 1:1 10100010:10100010
	.inst 0xc2c21382 // BRS-C-C 00010:00010 Cn:28 100:100 opc:00 11000010110000100:11000010110000100
	.zero 16364
	.inst 0x9b1f4422 // 0x9b1f4422
	.inst 0x8251303e // 0x8251303e
	.inst 0xe25b18df // 0xe25b18df
	.inst 0x9ac8241e // 0x9ac8241e
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
	ldr x27, =initial_cap_values
	.inst 0xc2400361 // ldr c1, [x27, #0]
	.inst 0xc2400766 // ldr c6, [x27, #1]
	.inst 0xc2400b6e // ldr c14, [x27, #2]
	.inst 0xc2400f6f // ldr c15, [x27, #3]
	.inst 0xc2401371 // ldr c17, [x27, #4]
	.inst 0xc2401776 // ldr c22, [x27, #5]
	.inst 0xc2401b7c // ldr c28, [x27, #6]
	.inst 0xc2401f7e // ldr c30, [x27, #7]
	/* Set up flags and system registers */
	ldr x27, =0x0
	msr SPSR_EL3, x27
	ldr x27, =initial_SP_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288411b // msr CSP_EL0, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30d5d99f
	msr SCTLR_EL1, x27
	ldr x27, =0xc0000
	msr CPACR_EL1, x27
	ldr x27, =0x0
	msr S3_0_C1_C2_2, x27 // CCTLR_EL1
	ldr x27, =0x0
	msr S3_3_C1_C2_2, x27 // CCTLR_EL0
	ldr x27, =initial_DDC_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288413b // msr DDC_EL0, c27
	ldr x27, =0x80000000
	msr HCR_EL2, x27
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260121b // ldr c27, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc28e403b // msr CELR_EL3, c27
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400370 // ldr c16, [x27, #0]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400770 // ldr c16, [x27, #1]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400b70 // ldr c16, [x27, #2]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2400f70 // ldr c16, [x27, #3]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc2401370 // ldr c16, [x27, #4]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2401770 // ldr c16, [x27, #5]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2401b70 // ldr c16, [x27, #6]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc2401f70 // ldr c16, [x27, #7]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc2402370 // ldr c16, [x27, #8]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2402770 // ldr c16, [x27, #9]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_SP_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984110 // mrs c16, CSP_EL0
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a761 // chkeq c27, c16
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
	ldr x0, =0x00001300
	ldr x1, =check_data1
	ldr x2, =0x00001308
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ac0
	ldr x1, =check_data2
	ldr x2, =0x00001ad0
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
	ldr x0, =0x40400fb2
	ldr x1, =check_data4
	ldr x2, =0x40400fb4
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
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.byte 0xdf, 0x4d, 0x31, 0xf9, 0xf4, 0xbb, 0xd8, 0xc2, 0x27, 0xa6, 0x2b, 0x88, 0xd6, 0x7f, 0xef, 0xa2
	.byte 0x82, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x22, 0x44, 0x1f, 0x9b, 0x3e, 0x30, 0x51, 0x82, 0xdf, 0x18, 0x5b, 0xe2, 0x1e, 0x24, 0xc8, 0x9a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x48000000400012f10000000000000990
	/* C6 */
	.octa 0x8000000050b100000000000040401001
	/* C14 */
	.octa 0xffffffffffffb068
	/* C15 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C17 */
	.octa 0x1008
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x20008000000100070000000040404000
	/* C30 */
	.octa 0x4000000000000000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x48000000400012f10000000000000990
	/* C2 */
	.octa 0x1008
	/* C6 */
	.octa 0x8000000050b100000000000040401001
	/* C11 */
	.octa 0x1
	/* C14 */
	.octa 0xffffffffffffb068
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x1008
	/* C20 */
	.octa 0x403100000000000000000000
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x20008000000100070000000040404000
initial_SP_EL0_value:
	.octa 0x400500040000000000000000
initial_DDC_EL0_value:
	.octa 0xc01000004004000600ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x400500040000000000000000
final_PCC_value:
	.octa 0x20008000000100070000000040404014
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000020080000000040400000
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
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 144
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
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x0200037b // add c27, c27, #0
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x0202037b // add c27, c27, #128
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x0204037b // add c27, c27, #256
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x0206037b // add c27, c27, #384
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x0208037b // add c27, c27, #512
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x020a037b // add c27, c27, #640
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x020c037b // add c27, c27, #768
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x020e037b // add c27, c27, #896
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x0210037b // add c27, c27, #1024
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x0212037b // add c27, c27, #1152
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x0214037b // add c27, c27, #1280
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x0216037b // add c27, c27, #1408
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x0218037b // add c27, c27, #1536
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x021a037b // add c27, c27, #1664
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x021c037b // add c27, c27, #1792
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x82600e1b // ldr x27, [c16, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e1b // str x27, [c16, #0]
	ldr x27, =0x40404014
	mrs x16, ELR_EL1
	sub x27, x27, x16
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b370 // cvtp c16, x27
	.inst 0xc2db4210 // scvalue c16, c16, x27
	.inst 0x8260021b // ldr c27, [c16, #0]
	.inst 0x021e037b // add c27, c27, #1920
	.inst 0xc2c21360 // br c27

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
