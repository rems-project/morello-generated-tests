.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dda906 // EORFLGS-C.CR-C Cd:6 Cn:8 1010:1010 opc:10 Rm:29 11000010110:11000010110
	.inst 0x225f7f7d // LDXR-C.R-C Ct:29 Rn:27 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x9b1d03fe // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:30 Rn:31 Ra:0 o0:0 Rm:29 0011011000:0011011000 sf:1
	.inst 0xb83e513f // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:9 00:00 opc:101 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xf87d23ff // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:010 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.zero 50156
	.inst 0x425f7e40 // ALDAR-C.R-C Ct:0 Rn:18 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xe25947bd // ALDURH-R.RI-32 Rt:29 Rn:29 op2:01 imm9:110010100 V:0 op1:01 11100010:11100010
	.inst 0xd035c72e // ADRP-C.I-C Rd:14 immhi:011010111000111001 P:0 10000:10000 immlo:10 op:1
	.inst 0x5ac017fe // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:31 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xd4000001
	.zero 15340
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a8 // ldr c8, [x5, #1]
	.inst 0xc24008a9 // ldr c9, [x5, #2]
	.inst 0xc2400cb2 // ldr c18, [x5, #3]
	.inst 0xc24010bb // ldr c27, [x5, #4]
	/* Set up flags and system registers */
	ldr x5, =0x0
	msr SPSR_EL3, x5
	ldr x5, =initial_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884105 // msr CSP_EL0, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0xc0000
	msr CPACR_EL1, x5
	ldr x5, =0x8
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x4
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82601065 // ldr c5, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a3 // ldr c3, [x5, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24004a3 // ldr c3, [x5, #1]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc24008a3 // ldr c3, [x5, #2]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2400ca3 // ldr c3, [x5, #3]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc24010a3 // ldr c3, [x5, #4]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc24014a3 // ldr c3, [x5, #5]
	.inst 0xc2c3a761 // chkeq c27, c3
	b.ne comparison_fail
	.inst 0xc24018a3 // ldr c3, [x5, #6]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2401ca3 // ldr c3, [x5, #7]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984103 // mrs c3, CSP_EL0
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x3, 0xc1
	orr x5, x5, x3
	ldr x3, =0x920000eb
	cmp x3, x5
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
	ldr x0, =0x000016a0
	ldr x1, =check_data1
	ldr x2, =0x000016a4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc0
	ldr x1, =check_data2
	ldr x2, =0x00001fd0
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
	ldr x0, =0x4040c400
	ldr x1, =check_data4
	ldr x2, =0x4040c414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040fffc
	ldr x1, =check_data5
	ldr x2, =0x4040fffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.byte 0x68, 0x00, 0x41, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x80
	.zero 1680
	.byte 0x01, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2320
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 48
.data
check_data0:
	.byte 0x68, 0x00, 0x41, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data1:
	.byte 0x01, 0x00, 0x00, 0x80
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data3:
	.byte 0x06, 0xa9, 0xdd, 0xc2, 0x7d, 0x7f, 0x5f, 0x22, 0xfe, 0x03, 0x1d, 0x9b, 0x3f, 0x51, 0x3e, 0xb8
	.byte 0xff, 0x23, 0x7d, 0xf8
.data
check_data4:
	.byte 0x40, 0x7e, 0x5f, 0x42, 0xbd, 0x47, 0x59, 0xe2, 0x2e, 0xc7, 0x35, 0xd0, 0xfe, 0x17, 0xc0, 0x5a
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x16a0
	/* C18 */
	.octa 0x90000000000100050000000000001fc0
	/* C27 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x101800000000000000000000000
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x16a0
	/* C14 */
	.octa 0x6b8e8000
	/* C18 */
	.octa 0x90000000000100050000000000001fc0
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1f
initial_SP_EL0_value:
	.octa 0xff7ffffffffffff0
initial_DDC_EL0_value:
	.octa 0xd01000000006000600ffffffffc00001
initial_VBAR_EL1_value:
	.octa 0x200080005000941d000000004040c000
final_SP_EL0_value:
	.octa 0xff7ffffffffffff0
final_PCC_value:
	.octa 0x200080005000941d000000004040c414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080100000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001fc0
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001fc0
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000016a0
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x4040c414
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
