.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d4bf38 // CSEL-C.CI-C Cd:24 Cn:25 11:11 cond:1011 Cm:20 11000010110:11000010110
	.inst 0x6a5a2821 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:1 imm6:001010 Rm:26 N:0 shift:01 01010:01010 opc:11 sf:0
	.inst 0xc2c364ac // CPYVALUE-C.C-C Cd:12 Cn:5 001:001 opc:11 0:0 Cm:3 11000010110:11000010110
	.inst 0x828ad012 // ASTRB-R.RRB-B Rt:18 Rn:0 opc:00 S:1 option:110 Rm:10 0:0 L:0 100000101:100000101
	.inst 0xe250bfc0 // ALDURSH-R.RI-32 Rt:0 Rn:30 op2:11 imm9:100001011 V:0 op1:01 11100010:11100010
	.zero 9196
	.inst 0xdac009a0 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:13 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x421fffa4 // STLR-C.R-C Ct:4 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xa2a0ffed // CASL-C.R-C Ct:13 Rn:31 11111:11111 R:1 Cs:0 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c21021 // CHKSLD-C-C 00001:00001 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xd4000001
	.zero 56300
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
	.inst 0xc24009e3 // ldr c3, [x15, #2]
	.inst 0xc2400de4 // ldr c4, [x15, #3]
	.inst 0xc24011e5 // ldr c5, [x15, #4]
	.inst 0xc24015ea // ldr c10, [x15, #5]
	.inst 0xc24019ed // ldr c13, [x15, #6]
	.inst 0xc2401df2 // ldr c18, [x15, #7]
	.inst 0xc24021fa // ldr c26, [x15, #8]
	.inst 0xc24025fd // ldr c29, [x15, #9]
	.inst 0xc24029fe // ldr c30, [x15, #10]
	/* Set up flags and system registers */
	ldr x15, =0x84000000
	msr SPSR_EL3, x15
	ldr x15, =initial_SP_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c410f // msr CSP_EL1, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x4
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =initial_DDC_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c412f // msr DDC_EL1, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011cf // ldr c15, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
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
	mov x14, #0xf
	and x15, x15, x14
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001ee // ldr c14, [x15, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24005ee // ldr c14, [x15, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24009ee // ldr c14, [x15, #2]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc2400dee // ldr c14, [x15, #3]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc24011ee // ldr c14, [x15, #4]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc24015ee // ldr c14, [x15, #5]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc24019ee // ldr c14, [x15, #6]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc2401dee // ldr c14, [x15, #7]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc24021ee // ldr c14, [x15, #8]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc24025ee // ldr c14, [x15, #9]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc24029ee // ldr c14, [x15, #10]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc2402dee // ldr c14, [x15, #11]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc29c410e // mrs c14, CSP_EL1
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	ldr x15, =esr_el1_dump_address
	ldr x15, [x15]
	mov x14, 0x80
	orr x15, x15, x14
	ldr x14, =0x920000a1
	cmp x14, x15
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
	ldr x0, =0x00001d80
	ldr x1, =check_data1
	ldr x2, =0x00001d81
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ec0
	ldr x1, =check_data2
	ldr x2, =0x00001ed0
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
	ldr x0, =0x40402400
	ldr x1, =check_data4
	ldr x2, =0x40402414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
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
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.byte 0x38, 0xbf, 0xd4, 0xc2, 0x21, 0x28, 0x5a, 0x6a, 0xac, 0x64, 0xc3, 0xc2, 0x12, 0xd0, 0x8a, 0x82
	.byte 0xc0, 0xbf, 0x50, 0xe2
.data
check_data4:
	.byte 0xa0, 0x09, 0xc0, 0xda, 0xa4, 0xff, 0x1f, 0x42, 0xed, 0xff, 0xa0, 0xa2, 0x21, 0x10, 0xc2, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x100
	/* C1 */
	.octa 0xffc00000
	/* C3 */
	.octa 0x80000000000000
	/* C4 */
	.octa 0x4000000000000000000000000000
	/* C5 */
	.octa 0x100186c60080000000000000
	/* C10 */
	.octa 0x1c80
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0xfffffc00
	/* C29 */
	.octa 0x1ec0
	/* C30 */
	.octa 0x800000000000f8
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x80000000000000
	/* C4 */
	.octa 0x4000000000000000000000000000
	/* C5 */
	.octa 0x100186c60080000000000000
	/* C10 */
	.octa 0x1c80
	/* C12 */
	.octa 0x100186c60080000000000000
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0xfffffc00
	/* C29 */
	.octa 0x1ec0
	/* C30 */
	.octa 0x800000000000f8
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc0000000000200050000000000000000
initial_DDC_EL1_value:
	.octa 0xdc100000004180060080000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004800201d0000000040402000
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080004800201d0000000040402414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001007c00f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001ec0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001d80
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
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40402414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
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
