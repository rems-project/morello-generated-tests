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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac7 // ldr c7, [x22, #2]
	.inst 0xc2400ec8 // ldr c8, [x22, #3]
	.inst 0xc24012ca // ldr c10, [x22, #4]
	.inst 0xc24016cb // ldr c11, [x22, #5]
	.inst 0xc2401acd // ldr c13, [x22, #6]
	.inst 0xc2401ede // ldr c30, [x22, #7]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q31, =0x1000000
	/* Set up flags and system registers */
	ldr x22, =0x4000000
	msr SPSR_EL3, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30d5d99f
	msr SCTLR_EL1, x22
	ldr x22, =0x3c0000
	msr CPACR_EL1, x22
	ldr x22, =0x0
	msr S3_0_C1_C2_2, x22 // CCTLR_EL1
	ldr x22, =0x0
	msr S3_3_C1_C2_2, x22 // CCTLR_EL0
	ldr x22, =initial_DDC_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2884136 // msr DDC_EL0, c22
	ldr x22, =0x80000000
	msr HCR_EL2, x22
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601216 // ldr c22, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc28e4036 // msr CELR_EL3, c22
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d0 // ldr c16, [x22, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24006d0 // ldr c16, [x22, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400ad0 // ldr c16, [x22, #2]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc2400ed0 // ldr c16, [x22, #3]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc24012d0 // ldr c16, [x22, #4]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc24016d0 // ldr c16, [x22, #5]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc2401ad0 // ldr c16, [x22, #6]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc2401ed0 // ldr c16, [x22, #7]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc24022d0 // ldr c16, [x22, #8]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x1000000
	mov x16, v31.d[0]
	cmp x22, x16
	b.ne comparison_fail
	ldr x22, =0x0
	mov x16, v31.d[1]
	cmp x22, x16
	b.ne comparison_fail
	/* Check system registers */
	ldr x22, =final_SP_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2984110 // mrs c16, CSP_EL0
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	ldr x22, =final_PCC_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a6c1 // chkeq c22, c16
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
	ldr x0, =0x00001288
	ldr x1, =check_data1
	ldr x2, =0x0000128c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001fe4
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
	ldr x0, =0x404003f0
	ldr x1, =check_data4
	ldr x2, =0x404003f8
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
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
	.byte 0x74, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x74, 0x00
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x01
.data
check_data3:
	.byte 0x5f, 0xd5, 0xd7, 0xe2, 0xc0, 0x53, 0xa1, 0x82, 0x1f, 0x70, 0x2a, 0x78, 0x38, 0xc5, 0xcd, 0x93
	.byte 0x7f, 0x61, 0xc8, 0xc2, 0x7d, 0x2f, 0x3f, 0x9b, 0xdf, 0x03, 0x67, 0x78, 0xdc, 0x7c, 0x58, 0x9b
	.byte 0xbf, 0x05, 0x30, 0xbd, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000000000000000000001000
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0xc000009801000d
	/* C10 */
	.octa 0x40400473
	/* C11 */
	.octa 0x44001400c0040000000000000
	/* C13 */
	.octa 0x4000000000010005ffffffffffffefdc
	/* C30 */
	.octa 0xc0000000000100050000000000001288
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000000000000000000000001000
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0xc000009801000d
	/* C10 */
	.octa 0x40400473
	/* C11 */
	.octa 0x44001400c0040000000000000
	/* C13 */
	.octa 0x4000000000010005ffffffffffffefdc
	/* C29 */
	.octa 0x40000000000000
	/* C30 */
	.octa 0xc0000000000100050000000000001288
initial_DDC_EL0_value:
	.octa 0xc0000000000080080000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x44001400c0100000098004019
final_PCC_value:
	.octa 0x20008000000100070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
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
	.dword 0x0000000000001280
	.dword 0x0000000000001fe0
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
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x020002d6 // add c22, c22, #0
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x020202d6 // add c22, c22, #128
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x020402d6 // add c22, c22, #256
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x020602d6 // add c22, c22, #384
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x020802d6 // add c22, c22, #512
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x020a02d6 // add c22, c22, #640
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x020c02d6 // add c22, c22, #768
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x020e02d6 // add c22, c22, #896
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x021002d6 // add c22, c22, #1024
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x021202d6 // add c22, c22, #1152
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x021402d6 // add c22, c22, #1280
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x021602d6 // add c22, c22, #1408
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x021802d6 // add c22, c22, #1536
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x021a02d6 // add c22, c22, #1664
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x021c02d6 // add c22, c22, #1792
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600e16 // ldr x22, [c16, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e16 // str x22, [c16, #0]
	ldr x22, =0x40400028
	mrs x16, ELR_EL1
	sub x22, x22, x16
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d0 // cvtp c16, x22
	.inst 0xc2d64210 // scvalue c16, c16, x22
	.inst 0x82600216 // ldr c22, [c16, #0]
	.inst 0x021e02d6 // add c22, c22, #1920
	.inst 0xc2c212c0 // br c22

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
