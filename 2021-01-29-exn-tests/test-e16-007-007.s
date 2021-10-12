.section text0, #alloc, #execinstr
test_start:
	.inst 0x1adf082e // udiv:aarch64/instrs/integer/arithmetic/div Rd:14 Rn:1 o1:0 00001:00001 Rm:31 0011010110:0011010110 sf:0
	.inst 0x38cd73bd // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:29 00:00 imm9:011010111 0:0 opc:11 111000:111000 size:00
	.inst 0x908d725e // ADRP-C.IP-C Rd:30 immhi:000110101110010010 P:1 10000:10000 immlo:00 op:1
	.inst 0xe2529f3e // ALDURSH-R.RI-32 Rt:30 Rn:25 op2:11 imm9:100101001 V:0 op1:01 11100010:11100010
	.inst 0x889fffe0 // stlr:aarch64/instrs/memory/ordered Rt:0 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.zero 9196
	.inst 0xc2bd2be1 // 0xc2bd2be1
	.inst 0x78bfc1df // 0x78bfc1df
	.inst 0x1112c3de // 0x1112c3de
	.inst 0xdac008f2 // 0xdac008f2
	.inst 0xd4000001
	.zero 56296
	.inst 0x00000808
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
	.inst 0xc24001f9 // ldr c25, [x15, #0]
	.inst 0xc24005fd // ldr c29, [x15, #1]
	/* Set up flags and system registers */
	ldr x15, =0x4000000
	msr SPSR_EL3, x15
	ldr x15, =initial_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288410f // msr CSP_EL0, c15
	ldr x15, =initial_SP_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c410f // msr CSP_EL1, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x4
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x0
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
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260120f // ldr c15, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
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
	.inst 0xc24001f0 // ldr c16, [x15, #0]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24005f0 // ldr c16, [x15, #1]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc24009f0 // ldr c16, [x15, #2]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2400df0 // ldr c16, [x15, #3]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc24011f0 // ldr c16, [x15, #4]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984110 // mrs c16, CSP_EL0
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	ldr x15, =final_SP_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc29c4110 // mrs c16, CSP_EL1
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x15, 0x83
	orr x16, x16, x15
	ldr x15, =0x920000eb
	cmp x15, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
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
	ldr x0, =0x40402400
	ldr x1, =check_data3
	ldr x2, =0x40402414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040fffc
	ldr x1, =check_data4
	ldr x2, =0x4040fffe
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
	.byte 0x00, 0x00, 0x08, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00
.data
check_data0:
	.byte 0x08, 0x08
.data
check_data1:
	.byte 0x80
.data
check_data2:
	.byte 0x2e, 0x08, 0xdf, 0x1a, 0xbd, 0x73, 0xcd, 0x38, 0x5e, 0x72, 0x8d, 0x90, 0x3e, 0x9f, 0x52, 0xe2
	.byte 0xe0, 0xff, 0x9f, 0x88
.data
check_data3:
	.byte 0xe1, 0x2b, 0xbd, 0xc2, 0xdf, 0xc1, 0xbf, 0x78, 0xde, 0xc3, 0x12, 0x11, 0xf2, 0x08, 0xc0, 0xda
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.byte 0x08, 0x08

.data
.balign 16
initial_cap_values:
	/* C25 */
	.octa 0x404100d3
	/* C29 */
	.octa 0x80000000000100050000000000001f27
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x7a006000000000004fe10
	/* C14 */
	.octa 0x0
	/* C25 */
	.octa 0x404100d3
	/* C29 */
	.octa 0xffffff80
	/* C30 */
	.octa 0xcb8
initial_SP_EL0_value:
	.octa 0x8000000000000805f1ef0a00
initial_SP_EL1_value:
	.octa 0x7a0060000000000010010
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0x800000005040100200ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080006600061d0000000040402000
final_SP_EL0_value:
	.octa 0x8000000000000805f1ef0a00
final_SP_EL1_value:
	.octa 0x7a0060000000000010010
final_PCC_value:
	.octa 0x200080006600061d0000000040402414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
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
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x40402414
	mrs x16, ELR_EL1
	sub x15, x15, x16
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x8260020f // ldr c15, [c16, #0]
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
