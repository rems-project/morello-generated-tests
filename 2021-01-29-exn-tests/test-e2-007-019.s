.section text0, #alloc, #execinstr
test_start:
	.inst 0xb076591d // ADRP-C.I-C Rd:29 immhi:111011001011001000 P:0 10000:10000 immlo:01 op:1
	.inst 0x82804c25 // ASTRH-R.RRB-32 Rt:5 Rn:1 opc:11 S:0 option:010 Rm:0 0:0 L:0 100000101:100000101
	.inst 0xda0801bb // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:27 Rn:13 000000:000000 Rm:8 11010000:11010000 S:0 op:1 sf:1
	.inst 0x88be7ffd // cas:aarch64/instrs/memory/atomicops/cas/single Rt:29 Rn:31 11111:11111 o0:0 Rs:30 1:1 L:0 0010001:0010001 size:10
	.inst 0xc276cb4e // LDR-C.RIB-C Ct:14 Rn:26 imm12:110110110010 L:1 110000100:110000100
	.inst 0x9b21c3ff // 0x9b21c3ff
	.inst 0xba5fb327 // 0xba5fb327
	.inst 0x22c348a1 // 0x22c348a1
	.inst 0xb840517e // 0xb840517e
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e5 // ldr c5, [x15, #2]
	.inst 0xc2400deb // ldr c11, [x15, #3]
	.inst 0xc24011fa // ldr c26, [x15, #4]
	.inst 0xc24015fe // ldr c30, [x15, #5]
	/* Set up flags and system registers */
	ldr x15, =0x4000000
	msr SPSR_EL3, x15
	ldr x15, =initial_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288410f // msr CSP_EL0, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x0
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260130f // ldr c15, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e402f // msr CELR_EL3, c15
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x24, #0xf
	and x15, x15, x24
	cmp x15, #0x7
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f8 // ldr c24, [x15, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24005f8 // ldr c24, [x15, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24009f8 // ldr c24, [x15, #2]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc2400df8 // ldr c24, [x15, #3]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc24011f8 // ldr c24, [x15, #4]
	.inst 0xc2d8a5c1 // chkeq c14, c24
	b.ne comparison_fail
	.inst 0xc24015f8 // ldr c24, [x15, #5]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc24019f8 // ldr c24, [x15, #6]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc2401df8 // ldr c24, [x15, #7]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc24021f8 // ldr c24, [x15, #8]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984118 // mrs c24, CSP_EL0
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001120
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ed0
	ldr x1, =check_data2
	ldr x2, =0x00001ed4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040db20
	ldr x1, =check_data4
	ldr x2, =0x4040db30
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
	.byte 0x00, 0x10, 0xb2, 0x6c
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x1d, 0x59, 0x76, 0xb0, 0x25, 0x4c, 0x80, 0x82, 0xbb, 0x01, 0x08, 0xda, 0xfd, 0x7f, 0xbe, 0x88
	.byte 0x4e, 0xcb, 0x76, 0xc2, 0xff, 0xc3, 0x21, 0x9b, 0x27, 0xb3, 0x5f, 0xba, 0xa1, 0x48, 0xc3, 0x22
	.byte 0x7e, 0x51, 0x40, 0xb8, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 16

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20
	/* C1 */
	.octa 0xfe0
	/* C5 */
	.octa 0x80100000404001820000000000001100
	/* C11 */
	.octa 0x80000000000100050000000000001ecb
	/* C26 */
	.octa 0x80100000000608070000000040400000
	/* C30 */
	.octa 0x1100
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x20
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x80100000404001820000000000001160
	/* C11 */
	.octa 0x80000000000100050000000000001ecb
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0x80100000000608070000000040400000
	/* C29 */
	.octa 0x4000000000030007010000006cb21000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000600000010000000000001000
initial_DDC_EL0_value:
	.octa 0x400000000003000700ffffff80000008
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc0000000600000010000000000001000
final_PCC_value:
	.octa 0x20008000080500230000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080500230000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x82600f0f // ldr x15, [c24, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f0f // str x15, [c24, #0]
	ldr x15, =0x40400028
	mrs x24, ELR_EL1
	sub x15, x15, x24
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f8 // cvtp c24, x15
	.inst 0xc2cf4318 // scvalue c24, c24, x15
	.inst 0x8260030f // ldr c15, [c24, #0]
	.inst 0x021e01ef // add c15, c15, #1920
	.inst 0xc2c211e0 // br c15

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
