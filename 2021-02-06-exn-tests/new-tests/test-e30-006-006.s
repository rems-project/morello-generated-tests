.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dda906 // EORFLGS-C.CR-C Cd:6 Cn:8 1010:1010 opc:10 Rm:29 11000010110:11000010110
	.inst 0x225f7f7d // LDXR-C.R-C Ct:29 Rn:27 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x9b1d03fe // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:30 Rn:31 Ra:0 o0:0 Rm:29 0011011000:0011011000 sf:1
	.inst 0xb83e513f // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:9 00:00 opc:101 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xf87d23ff // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:010 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x425f7e40 // ALDAR-C.R-C Ct:0 Rn:18 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xe25947bd // ALDURH-R.RI-32 Rt:29 Rn:29 op2:01 imm9:110010100 V:0 op1:01 11100010:11100010
	.inst 0xd035c72e // ADRP-C.I-C Rd:14 immhi:011010111000111001 P:0 10000:10000 immlo:10 op:1
	.inst 0x5ac017fe // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:31 op:1 10110101100000000010:10110101100000000010 sf:0
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e8 // ldr c8, [x23, #1]
	.inst 0xc2400ae9 // ldr c9, [x23, #2]
	.inst 0xc2400ef2 // ldr c18, [x23, #3]
	.inst 0xc24012fb // ldr c27, [x23, #4]
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0xc
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601157 // ldr c23, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002ea // ldr c10, [x23, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24006ea // ldr c10, [x23, #1]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc2400aea // ldr c10, [x23, #2]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc2400eea // ldr c10, [x23, #3]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc24012ea // ldr c10, [x23, #4]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc24016ea // ldr c10, [x23, #5]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc2401aea // ldr c10, [x23, #6]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2401eea // ldr c10, [x23, #7]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc298410a // mrs c10, CSP_EL0
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001e00
	ldr x1, =check_data1
	ldr x2, =0x00001e10
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
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
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.byte 0x61, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
	.byte 0x78, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x80
	.zero 496
.data
check_data0:
	.byte 0x19, 0x00, 0x40, 0x80, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x78, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x06, 0xa9, 0xdd, 0xc2, 0x7d, 0x7f, 0x5f, 0x22, 0xfe, 0x03, 0x1d, 0x9b, 0x3f, 0x51, 0x3e, 0xb8
	.byte 0xff, 0x23, 0x7d, 0xf8, 0x40, 0x7e, 0x5f, 0x42, 0xbd, 0x47, 0x59, 0xe2, 0x2e, 0xc7, 0x35, 0xd0
	.byte 0xfe, 0x17, 0xc0, 0x5a, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x1000
	/* C18 */
	.octa 0x90100000000100050000000000001fe0
	/* C27 */
	.octa 0x1e00
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x1000
	/* C14 */
	.octa 0xabce6000
	/* C18 */
	.octa 0x90100000000100050000000000001fe0
	/* C27 */
	.octa 0x1e00
	/* C29 */
	.octa 0x513f
	/* C30 */
	.octa 0x1f
initial_SP_EL0_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xd0100000380300070000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x20008000000080080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001e00
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001e00
	.dword 0x0000000000001fe0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600d57 // ldr x23, [c10, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d57 // str x23, [c10, #0]
	ldr x23, =0x40400028
	mrs x10, ELR_EL1
	sub x23, x23, x10
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ea // cvtp c10, x23
	.inst 0xc2d7414a // scvalue c10, c10, x23
	.inst 0x82600157 // ldr c23, [c10, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
