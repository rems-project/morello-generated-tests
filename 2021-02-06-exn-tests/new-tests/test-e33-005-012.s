.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2d7d55f // ALDUR-R.RI-64 Rt:31 Rn:10 op2:01 imm9:101111101 V:0 op1:11 11100010:11100010
	.inst 0x82a153c0 // ASTR-R.RRB-32 Rt:0 Rn:30 opc:00 S:1 option:010 Rm:1 1:1 L:0 100000101:100000101
	.inst 0x782a701f // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:111 o3:0 Rs:10 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x93cdc538 // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:24 Rn:9 imms:110001 Rm:13 0:0 N:1 00100111:00100111 sf:1
	.inst 0xc2c8617f // SCOFF-C.CR-C Cd:31 Cn:11 000:000 opc:11 0:0 Rm:8 11000010110:11000010110
	.inst 0x9b3f2f7d // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:27 Ra:11 o0:0 Rm:31 01:01 U:0 10011011:10011011
	.inst 0x786703df // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:000 o3:0 Rs:7 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x9b587cdc // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:28 Rn:6 Ra:11111 0:0 Rm:24 10:10 U:0 10011011:10011011
	.inst 0xbd3005bf // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:31 Rn:13 imm12:110000000001 opc:00 111101:111101 size:10
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400887 // ldr c7, [x4, #2]
	.inst 0xc2400c88 // ldr c8, [x4, #3]
	.inst 0xc240108a // ldr c10, [x4, #4]
	.inst 0xc240148b // ldr c11, [x4, #5]
	.inst 0xc240188d // ldr c13, [x4, #6]
	.inst 0xc2401c9e // ldr c30, [x4, #7]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q31, =0x400000
	/* Set up flags and system registers */
	ldr x4, =0x4000000
	msr SPSR_EL3, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0x3c0000
	msr CPACR_EL1, x4
	ldr x4, =0x0
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =0x0
	msr S3_3_C1_C2_2, x4 // CCTLR_EL0
	ldr x4, =initial_DDC_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884124 // msr DDC_EL0, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601344 // ldr c4, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc28e4024 // msr CELR_EL3, c4
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240009a // ldr c26, [x4, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240049a // ldr c26, [x4, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240089a // ldr c26, [x4, #2]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc2400c9a // ldr c26, [x4, #3]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc240109a // ldr c26, [x4, #4]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc240149a // ldr c26, [x4, #5]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc240189a // ldr c26, [x4, #6]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc2401c9a // ldr c26, [x4, #7]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240209a // ldr c26, [x4, #8]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x400000
	mov x26, v31.d[0]
	cmp x4, x26
	b.ne comparison_fail
	ldr x4, =0x0
	mov x26, v31.d[1]
	cmp x4, x26
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc298411a // mrs c26, CSP_EL0
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e4
	ldr x1, =check_data1
	ldr x2, =0x000010e6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001984
	ldr x1, =check_data2
	ldr x2, =0x00001988
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400090
	ldr x1, =check_data5
	ldr x2, =0x40400098
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
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
	.byte 0x06, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x06, 0x01
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x00, 0x40, 0x00
.data
check_data4:
	.byte 0x5f, 0xd5, 0xd7, 0xe2, 0xc0, 0x53, 0xa1, 0x82, 0x1f, 0x70, 0x2a, 0x78, 0x38, 0xc5, 0xcd, 0x93
	.byte 0x7f, 0x61, 0xc8, 0xc2, 0x7d, 0x2f, 0x3f, 0x9b, 0xdf, 0x03, 0x67, 0x78, 0xdc, 0x7c, 0x58, 0x9b
	.byte 0xbf, 0x05, 0x30, 0xbd, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000300070000000000001000
	/* C1 */
	.octa 0x228
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x40400113
	/* C11 */
	.octa 0x120050000000000000000
	/* C13 */
	.octa 0x4000000000010005ffffffffffffeff4
	/* C30 */
	.octa 0xc00000000001000500000000000010e4
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000000300070000000000001000
	/* C1 */
	.octa 0x228
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x40400113
	/* C11 */
	.octa 0x120050000000000000000
	/* C13 */
	.octa 0x4000000000010005ffffffffffffeff4
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xc00000000001000500000000000010e4
initial_DDC_EL0_value:
	.octa 0xc0000000000080080000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x120058000000000000000
final_PCC_value:
	.octa 0x20008000000000000000000040400028
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
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000010e0
	.dword 0x0000000000001980
	.dword 0x0000000000001ff0
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600f44 // ldr x4, [c26, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f44 // str x4, [c26, #0]
	ldr x4, =0x40400028
	mrs x26, ELR_EL1
	sub x4, x4, x26
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b09a // cvtp c26, x4
	.inst 0xc2c4435a // scvalue c26, c26, x4
	.inst 0x82600344 // ldr c4, [c26, #0]
	.inst 0x021e0084 // add c4, c4, #1920
	.inst 0xc2c21080 // br c4

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
