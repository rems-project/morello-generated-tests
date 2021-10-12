.section text0, #alloc, #execinstr
test_start:
	.inst 0x786642bf // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:21 00:00 opc:100 0:0 Rs:6 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xe2fa9405 // ALDUR-V.RI-D Rt:5 Rn:0 op2:01 imm9:110101001 V:1 op1:11 11100010:11100010
	.inst 0x883a5ff0 // stxp:aarch64/instrs/memory/exclusive/pair Rt:16 Rn:31 Rt2:10111 o0:0 Rs:26 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0x621203ad // STNP-C.RIB-C Ct:13 Rn:29 Ct2:00000 imm7:0100100 L:0 011000100:011000100
	.inst 0x6c214bc5 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:5 Rn:30 Rt2:10010 imm7:1000010 L:0 1011000:1011000 opc:01
	.zero 1004
	.inst 0x1a9e43eb // 0x1a9e43eb
	.inst 0xc2ed9b9e // 0xc2ed9b9e
	.inst 0x3847ed5d // 0x3847ed5d
	.inst 0x82c0e381 // ALDRB-R.RRB-B Rt:1 Rn:28 opc:00 S:0 option:111 Rm:0 0:0 L:1 100000101:100000101
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c6 // ldr c6, [x14, #1]
	.inst 0xc24009ca // ldr c10, [x14, #2]
	.inst 0xc2400dcd // ldr c13, [x14, #3]
	.inst 0xc24011d5 // ldr c21, [x14, #4]
	.inst 0xc24015dc // ldr c28, [x14, #5]
	.inst 0xc24019dd // ldr c29, [x14, #6]
	.inst 0xc2401dde // ldr c30, [x14, #7]
	/* Set up flags and system registers */
	ldr x14, =0x80000000
	msr SPSR_EL3, x14
	ldr x14, =initial_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288410e // msr CSP_EL0, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0x3c0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x0
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =initial_DDC_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc28c412e // msr DDC_EL1, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260110e // ldr c14, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x8, #0xf
	and x14, x14, x8
	cmp x14, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c8 // ldr c8, [x14, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24005c8 // ldr c8, [x14, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc24009c8 // ldr c8, [x14, #2]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc2400dc8 // ldr c8, [x14, #3]
	.inst 0xc2c8a541 // chkeq c10, c8
	b.ne comparison_fail
	.inst 0xc24011c8 // ldr c8, [x14, #4]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc24015c8 // ldr c8, [x14, #5]
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc24019c8 // ldr c8, [x14, #6]
	.inst 0xc2c8a6a1 // chkeq c21, c8
	b.ne comparison_fail
	.inst 0xc2401dc8 // ldr c8, [x14, #7]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc24021c8 // ldr c8, [x14, #8]
	.inst 0xc2c8a781 // chkeq c28, c8
	b.ne comparison_fail
	.inst 0xc24025c8 // ldr c8, [x14, #9]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc24029c8 // ldr c8, [x14, #10]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x8, v5.d[0]
	cmp x14, x8
	b.ne comparison_fail
	ldr x14, =0x0
	mov x8, v5.d[1]
	cmp x14, x8
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984108 // mrs c8, CSP_EL0
	.inst 0xc2c8a5c1 // chkeq c14, c8
	b.ne comparison_fail
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a5c1 // chkeq c14, c8
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x14, 0x83
	orr x8, x8, x14
	ldr x14, =0x920000e3
	cmp x14, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010fe
	ldr x1, =check_data0
	ldr x2, =0x000010ff
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001220
	ldr x1, =check_data1
	ldr x2, =0x00001228
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001330
	ldr x1, =check_data2
	ldr x2, =0x00001350
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001802
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fb0
	ldr x1, =check_data4
	ldr x2, =0x00001fb8
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
	ldr x0, =0x40404407
	ldr x1, =check_data7
	ldr x2, =0x40404408
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
	.zero 2048
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 16
	.byte 0x07, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data3:
	.byte 0x08, 0x00
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xbf, 0x42, 0x66, 0x78, 0x05, 0x94, 0xfa, 0xe2, 0xf0, 0x5f, 0x3a, 0x88, 0xad, 0x03, 0x12, 0x62
	.byte 0xc5, 0x4b, 0x21, 0x6c
.data
check_data6:
	.byte 0xeb, 0x43, 0x9e, 0x1a, 0x9e, 0x9b, 0xed, 0xc2, 0x5d, 0xed, 0x47, 0x38, 0x81, 0xe3, 0xc0, 0x82
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000000000000000000002007
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x1080
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0x1800
	/* C28 */
	.octa 0x80000000080740170000000040402400
	/* C29 */
	.octa 0x10f0
	/* C30 */
	.octa 0x80000000000204
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000000000000000000002007
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x10fe
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0x1800
	/* C26 */
	.octa 0x1
	/* C28 */
	.octa 0x80000000080740170000000040402400
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1
initial_SP_EL0_value:
	.octa 0x1220
initial_DDC_EL0_value:
	.octa 0xcc000000000a00060000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000000500070000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004000001e0000000040400000
final_SP_EL0_value:
	.octa 0x1220
final_PCC_value:
	.octa 0x200080004000001e0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 128
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x82600d0e // ldr x14, [c8, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d0e // str x14, [c8, #0]
	ldr x14, =0x40400414
	mrs x8, ELR_EL1
	sub x14, x14, x8
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c8 // cvtp c8, x14
	.inst 0xc2ce4108 // scvalue c8, c8, x14
	.inst 0x8260010e // ldr c14, [c8, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
