.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8ff803d // swp:aarch64/instrs/memory/atomicops/swp Rt:29 Rn:1 100000:100000 Rs:31 1:1 R:1 A:1 111000:111000 size:11
	.inst 0xd63f0060 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:3 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 244
	.inst 0x421f7c2e // ASTLR-C.R-C Ct:14 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x6dfe442a // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:10 Rn:1 Rt2:10001 imm7:1111100 L:1 1011011:1011011 opc:01
	.inst 0xe2997812 // ALDURSW-R.RI-64 Rt:18 Rn:0 op2:10 imm9:110010111 V:0 op1:10 11100010:11100010
	.zero 48888
	.inst 0xc2c0b01f // 0xc2c0b01f
	.inst 0xf85681be // 0xf85681be
	.inst 0x485ffc3d // 0x485ffc3d
	.inst 0xd4000001
	.zero 1008
	.inst 0xd61f03a0 // 0xd61f03a0
	.zero 15356
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
	.inst 0xc2400ded // ldr c13, [x15, #3]
	.inst 0xc24011ee // ldr c14, [x15, #4]
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
	ldr x15, =0x84
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
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24005f0 // ldr c16, [x15, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24009f0 // ldr c16, [x15, #2]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400df0 // ldr c16, [x15, #3]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc24011f0 // ldr c16, [x15, #4]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc24015f0 // ldr c16, [x15, #5]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc24019f0 // ldr c16, [x15, #6]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x16, v10.d[0]
	cmp x15, x16
	b.ne comparison_fail
	ldr x15, =0x0
	mov x16, v10.d[1]
	cmp x15, x16
	b.ne comparison_fail
	ldr x15, =0x0
	mov x16, v17.d[0]
	cmp x15, x16
	b.ne comparison_fail
	ldr x15, =0x0
	mov x16, v17.d[1]
	cmp x15, x16
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x15, 0x83
	orr x16, x16, x15
	ldr x15, =0x920000a3
	cmp x15, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010e0
	ldr x1, =check_data0
	ldr x2, =0x000010f0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001108
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001210
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x404000fc
	ldr x1, =check_data4
	ldr x2, =0x40400108
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040c000
	ldr x1, =check_data5
	ldr x2, =0x4040c010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040c400
	ldr x1, =check_data6
	ldr x2, =0x4040c404
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040fff0
	ldr x1, =check_data7
	ldr x2, =0x4040fff8
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.zero 256
	.byte 0x00, 0xc0, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x3d, 0x80, 0xff, 0xf8, 0x60, 0x00, 0x3f, 0xd6
.data
check_data4:
	.byte 0x2e, 0x7c, 0x1f, 0x42, 0x2a, 0x44, 0xfe, 0x6d, 0x12, 0x78, 0x99, 0xe2
.data
check_data5:
	.byte 0x1f, 0xb0, 0xc0, 0xc2, 0xbe, 0x81, 0x56, 0xf8, 0x3d, 0xfc, 0x5f, 0x48, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0xa0, 0x03, 0x1f, 0xd6
.data
check_data7:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x76c
	/* C1 */
	.octa 0xc0000000000b00070000000000001100
	/* C3 */
	.octa 0x404000fc
	/* C13 */
	.octa 0x40410088
	/* C14 */
	.octa 0x20
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x76c
	/* C1 */
	.octa 0xc0000000000b000700000000000010e0
	/* C3 */
	.octa 0x404000fc
	/* C13 */
	.octa 0x40410088
	/* C14 */
	.octa 0x20
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xcc0000003007010700ffffffffffe663
initial_DDC_EL1_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005040c000000000004040c000
final_PCC_value:
	.octa 0x200080005040c000000000004040c010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000d00210000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 64
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f0 // cvtp c16, x15
	.inst 0xc2cf4210 // scvalue c16, c16, x15
	.inst 0x82600e0f // ldr x15, [c16, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e0f // str x15, [c16, #0]
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
	ldr x15, =0x4040c010
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
