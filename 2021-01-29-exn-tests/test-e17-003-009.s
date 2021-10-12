.section text0, #alloc, #execinstr
test_start:
	.inst 0x889f7c1e // stllr:aarch64/instrs/memory/ordered Rt:30 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x081ffcdd // stlxrb:aarch64/instrs/memory/exclusive/single Rt:29 Rn:6 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0x382012bf // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:001 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x429b6966 // STP-C.RIB-C Ct:6 Rn:11 Ct2:11010 imm7:0110110 L:0 010000101:010000101
	.inst 0xadb4603e // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:30 Rn:1 Rt2:11000 imm7:1101000 L:0 1011011:1011011 opc:10
	.zero 1004
	.inst 0x787f509f // 0x787f509f
	.inst 0xc2dd8bfd // 0xc2dd8bfd
	.inst 0xc2c81a3f // 0xc2c81a3f
	.inst 0x8a75d7b7 // 0x8a75d7b7
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a4 // ldr c4, [x13, #1]
	.inst 0xc24009a6 // ldr c6, [x13, #2]
	.inst 0xc2400dab // ldr c11, [x13, #3]
	.inst 0xc24011b1 // ldr c17, [x13, #4]
	.inst 0xc24015b5 // ldr c21, [x13, #5]
	.inst 0xc24019ba // ldr c26, [x13, #6]
	.inst 0xc2401dbd // ldr c29, [x13, #7]
	.inst 0xc24021be // ldr c30, [x13, #8]
	/* Set up flags and system registers */
	ldr x13, =0x0
	msr SPSR_EL3, x13
	ldr x13, =initial_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c410d // msr CSP_EL1, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0xc0000
	msr CPACR_EL1, x13
	ldr x13, =0x0
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =0x4
	msr S3_3_C1_C2_2, x13 // CCTLR_EL0
	ldr x13, =initial_DDC_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc288412d // msr DDC_EL0, c13
	ldr x13, =initial_DDC_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c412d // msr DDC_EL1, c13
	ldr x13, =0x80000000
	msr HCR_EL2, x13
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260130d // ldr c13, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e402d // msr CELR_EL3, c13
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x24, #0xf
	and x13, x13, x24
	cmp x13, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b8 // ldr c24, [x13, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24005b8 // ldr c24, [x13, #1]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc24009b8 // ldr c24, [x13, #2]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2400db8 // ldr c24, [x13, #3]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc24011b8 // ldr c24, [x13, #4]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc24015b8 // ldr c24, [x13, #5]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc24019b8 // ldr c24, [x13, #6]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc2401db8 // ldr c24, [x13, #7]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc24021b8 // ldr c24, [x13, #8]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc24025b8 // ldr c24, [x13, #9]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc29c4118 // mrs c24, CSP_EL1
	.inst 0xc2d8a5a1 // chkeq c13, c24
	b.ne comparison_fail
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a5a1 // chkeq c13, c24
	b.ne comparison_fail
	ldr x24, =esr_el1_dump_address
	ldr x24, [x24]
	mov x13, 0x0
	orr x24, x24, x13
	ldr x13, =0x1fe00000
	cmp x13, x24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001003
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001034
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x000010a0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000012ee
	ldr x1, =check_data3
	ldr x2, =0x000012ef
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
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
	.byte 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x10
.data
check_data1:
	.byte 0xff, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0xed, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04
	.byte 0x00, 0x24, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x1e, 0x7c, 0x9f, 0x88, 0xdd, 0xfc, 0x1f, 0x08, 0xbf, 0x12, 0x20, 0x38, 0x66, 0x69, 0x9b, 0x42
	.byte 0x3e, 0x60, 0xb4, 0xad
.data
check_data5:
	.byte 0x9f, 0x50, 0x7f, 0x78, 0xfd, 0x8b, 0xdd, 0xc2, 0x3f, 0x1a, 0xc8, 0xc2, 0xb7, 0xd7, 0x75, 0x8a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xe2f
	/* C4 */
	.octa 0x109c
	/* C6 */
	.octa 0x40000000000000000000000000010ed
	/* C11 */
	.octa 0xb1f
	/* C17 */
	.octa 0x8021c0270000000000010001
	/* C21 */
	.octa 0xe01
	/* C26 */
	.octa 0x8000000000000000000000002400
	/* C29 */
	.octa 0xe0010004002100000000e001
	/* C30 */
	.octa 0xff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xe2f
	/* C4 */
	.octa 0x109c
	/* C6 */
	.octa 0x40000000000000000000000000010ed
	/* C11 */
	.octa 0xb1f
	/* C17 */
	.octa 0x8021c0270000000000010001
	/* C21 */
	.octa 0xe01
	/* C23 */
	.octa 0x21000000016001
	/* C26 */
	.octa 0x8000000000000000000000002400
	/* C29 */
	.octa 0x4404004c0021000000016001
	/* C30 */
	.octa 0xff
initial_SP_EL1_value:
	.octa 0x4404004c0021000000016001
initial_DDC_EL0_value:
	.octa 0xcc0000005401020100ffffffffffffef
initial_DDC_EL1_value:
	.octa 0xc000000052010c1e00ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000001c0000000040400000
final_SP_EL1_value:
	.octa 0x8021c0270000000000010000
final_PCC_value:
	.octa 0x200080004000001c0000000040400414
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
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL1_value
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
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x82600f0d // ldr x13, [c24, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f0d // str x13, [c24, #0]
	ldr x13, =0x40400414
	mrs x24, ELR_EL1
	sub x13, x13, x24
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b8 // cvtp c24, x13
	.inst 0xc2cd4318 // scvalue c24, c24, x13
	.inst 0x8260030d // ldr c13, [c24, #0]
	.inst 0x021e01ad // add c13, c13, #1920
	.inst 0xc2c211a0 // br c13

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
