.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2b1803a // SWPA-CC.R-C Ct:26 Rn:1 100000:100000 Cs:17 1:1 R:0 A:1 10100010:10100010
	.inst 0xbd7643bf // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:31 Rn:29 imm12:110110010000 opc:01 111101:111101 size:10
	.inst 0xc2c23142 // BLRS-C-C 00010:00010 Cn:10 100:100 opc:01 11000010110000100:11000010110000100
	.zero 228
	.inst 0x38478829 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:1 10:10 imm9:001111000 0:0 opc:01 111000:111000 size:00
	.inst 0xa2eb7e04 // CASA-C.R-C Ct:4 Rn:16 11111:11111 R:0 Cs:11 1:1 L:1 1:1 10100010:10100010
	.inst 0x384d8ba1 // 0x384d8ba1
	.inst 0x7824109f // 0x7824109f
	.inst 0xf0e858dd // 0xf0e858dd
	.inst 0x787df9b8 // 0x787df9b8
	.inst 0xd4000001
	.zero 65268
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
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e4 // ldr c4, [x15, #1]
	.inst 0xc24009ea // ldr c10, [x15, #2]
	.inst 0xc2400deb // ldr c11, [x15, #3]
	.inst 0xc24011ed // ldr c13, [x15, #4]
	.inst 0xc24015f0 // ldr c16, [x15, #5]
	.inst 0xc24019f1 // ldr c17, [x15, #6]
	.inst 0xc2401dfd // ldr c29, [x15, #7]
	/* Set up flags and system registers */
	ldr x15, =0x4000000
	msr SPSR_EL3, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0x3c0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x0
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260124f // ldr c15, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f2 // ldr c18, [x15, #0]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24005f2 // ldr c18, [x15, #1]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc24009f2 // ldr c18, [x15, #2]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2400df2 // ldr c18, [x15, #3]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc24011f2 // ldr c18, [x15, #4]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc24015f2 // ldr c18, [x15, #5]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc24019f2 // ldr c18, [x15, #6]
	.inst 0xc2d2a601 // chkeq c16, c18
	b.ne comparison_fail
	.inst 0xc2401df2 // ldr c18, [x15, #7]
	.inst 0xc2d2a621 // chkeq c17, c18
	b.ne comparison_fail
	.inst 0xc24021f2 // ldr c18, [x15, #8]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc24025f2 // ldr c18, [x15, #9]
	.inst 0xc2d2a741 // chkeq c26, c18
	b.ne comparison_fail
	.inst 0xc24029f2 // ldr c18, [x15, #10]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2402df2 // ldr c18, [x15, #11]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x18, v31.d[0]
	cmp x15, x18
	b.ne comparison_fail
	ldr x15, =0x0
	mov x18, v31.d[1]
	cmp x15, x18
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a5e1 // chkeq c15, c18
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
	ldr x0, =0x00001078
	ldr x1, =check_data1
	ldr x2, =0x00001079
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001810
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x4040000c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x404000f0
	ldr x1, =check_data5
	ldr x2, =0x4040010c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40403660
	ldr x1, =check_data6
	ldr x2, =0x40403664
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x0a, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x3a, 0x80, 0xb1, 0xa2, 0xbf, 0x43, 0x76, 0xbd, 0x42, 0x31, 0xc2, 0xc2
.data
check_data5:
	.byte 0x29, 0x88, 0x47, 0x38, 0x04, 0x7e, 0xeb, 0xa2, 0xa1, 0x8b, 0x4d, 0x38, 0x9f, 0x10, 0x24, 0x78
	.byte 0xdd, 0x58, 0xe8, 0xf0, 0xb8, 0xf9, 0x7d, 0x78, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xdc100000000100050000000000001000
	/* C4 */
	.octa 0xc000000000000000000000000000100a
	/* C10 */
	.octa 0x200080000001800500000000404000f1
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x800000003ffb0007ffffffffde1cbffc
	/* C16 */
	.octa 0xdc0000001e7180060000000000001800
	/* C17 */
	.octa 0x208000000000000000000
	/* C29 */
	.octa 0x80000000080642000000000040400020
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xa1
	/* C4 */
	.octa 0xc000000000000000000000000000100a
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x200080000001800500000000404000f1
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x800000003ffb0007ffffffffde1cbffc
	/* C16 */
	.octa 0xdc0000001e7180060000000000001800
	/* C17 */
	.octa 0x208000000000000000000
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x8000000000000000000000
	/* C29 */
	.octa 0x20008000000180050000000010f1b000
	/* C30 */
	.octa 0x2000800000070007000000004040000d
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x2000800000018005000000004040010c
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
	.dword 0x0000000000001000
	.dword 0x0000000000001800
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 176
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
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x82600e4f // ldr x15, [c18, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e4f // str x15, [c18, #0]
	ldr x15, =0x4040010c
	mrs x18, ELR_EL1
	sub x15, x15, x18
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f2 // cvtp c18, x15
	.inst 0xc2cf4252 // scvalue c18, c18, x15
	.inst 0x8260024f // ldr c15, [c18, #0]
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
