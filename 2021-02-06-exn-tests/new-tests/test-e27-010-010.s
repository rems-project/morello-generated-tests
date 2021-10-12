.section text0, #alloc, #execinstr
test_start:
	.inst 0x786013bf // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:001 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x380337dd // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:30 01:01 imm9:000110011 0:0 opc:00 111000:111000 size:00
	.inst 0xd63f0040 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 496
	.inst 0xc2c5925f // CVTD-C.R-C Cd:31 Rn:18 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x427ffcbe // ALDAR-R.R-32 Rt:30 Rn:5 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.zero 508
	.inst 0x423ffe8c // ASTLR-R.R-32 Rt:12 Rn:20 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x82c1ec60 // ALDRH-R.RRB-32 Rt:0 Rn:3 opc:11 S:0 option:111 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x386c5960 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:11 10:10 S:1 option:010 Rm:12 1:1 opc:01 111000:111000 size:00
	.inst 0xc2d3a8a1 // EORFLGS-C.CR-C Cd:1 Cn:5 1010:1010 opc:10 Rm:19 11000010110:11000010110
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e2 // ldr c2, [x7, #2]
	.inst 0xc2400ce3 // ldr c3, [x7, #3]
	.inst 0xc24010e5 // ldr c5, [x7, #4]
	.inst 0xc24014eb // ldr c11, [x7, #5]
	.inst 0xc24018ec // ldr c12, [x7, #6]
	.inst 0xc2401cf2 // ldr c18, [x7, #7]
	.inst 0xc24020f4 // ldr c20, [x7, #8]
	.inst 0xc24024fd // ldr c29, [x7, #9]
	.inst 0xc24028fe // ldr c30, [x7, #10]
	/* Set up flags and system registers */
	ldr x7, =0x0
	msr SPSR_EL3, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30d5d99f
	msr SCTLR_EL1, x7
	ldr x7, =0xc0000
	msr CPACR_EL1, x7
	ldr x7, =0x0
	msr S3_0_C1_C2_2, x7 // CCTLR_EL1
	ldr x7, =0x8
	msr S3_3_C1_C2_2, x7 // CCTLR_EL0
	ldr x7, =initial_DDC_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884127 // msr DDC_EL0, c7
	ldr x7, =initial_DDC_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc28c4127 // msr DDC_EL1, c7
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012e7 // ldr c7, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e4027 // msr CELR_EL3, c7
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f7 // ldr c23, [x7, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24004f7 // ldr c23, [x7, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc24008f7 // ldr c23, [x7, #2]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400cf7 // ldr c23, [x7, #3]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc24010f7 // ldr c23, [x7, #4]
	.inst 0xc2d7a561 // chkeq c11, c23
	b.ne comparison_fail
	.inst 0xc24014f7 // ldr c23, [x7, #5]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc24018f7 // ldr c23, [x7, #6]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2401cf7 // ldr c23, [x7, #7]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc24020f7 // ldr c23, [x7, #8]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc24024f7 // ldr c23, [x7, #9]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	ldr x7, =esr_el1_dump_address
	ldr x7, [x7]
	mov x23, 0xc1
	orr x7, x7, x23
	ldr x23, =0x920000eb
	cmp x23, x7
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
	ldr x0, =0x00001524
	ldr x1, =check_data1
	ldr x2, =0x00001525
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x4040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x404001fc
	ldr x1, =check_data3
	ldr x2, =0x40400204
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
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
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
	.byte 0xff, 0x73, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff, 0x2f, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xbf, 0x13, 0x60, 0x78, 0xdd, 0x37, 0x03, 0x38, 0x40, 0x00, 0x3f, 0xd6
.data
check_data3:
	.byte 0x5f, 0x92, 0xc5, 0xc2, 0xbe, 0xfc, 0x7f, 0x42
.data
check_data4:
	.byte 0x8c, 0xfe, 0x3f, 0x42, 0x60, 0xec, 0xc1, 0x82, 0x60, 0x59, 0x6c, 0x38, 0xa1, 0xa8, 0xd3, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x31fc
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x800000006404e012000000010000a021
	/* C11 */
	.octa 0x8000000060000002ffffffffffffe001
	/* C12 */
	.octa 0x2fff
	/* C18 */
	.octa 0xe000
	/* C20 */
	.octa 0x1000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1524
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xff
	/* C2 */
	.octa 0x31fc
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x800000006404e012000000010000a021
	/* C11 */
	.octa 0x8000000060000002ffffffffffffe001
	/* C12 */
	.octa 0x2fff
	/* C18 */
	.octa 0xe000
	/* C20 */
	.octa 0x1000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x300c
initial_DDC_EL0_value:
	.octa 0xc00000000017000700ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xc00000000000c0000000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400001
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004402d0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001520
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
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x82600ee7 // ldr x7, [c23, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ee7 // str x7, [c23, #0]
	ldr x7, =0x40400414
	mrs x23, ELR_EL1
	sub x7, x7, x23
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f7 // cvtp c23, x7
	.inst 0xc2c742f7 // scvalue c23, c23, x7
	.inst 0x826002e7 // ldr c7, [c23, #0]
	.inst 0x021e00e7 // add c7, c7, #1920
	.inst 0xc2c210e0 // br c7

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
