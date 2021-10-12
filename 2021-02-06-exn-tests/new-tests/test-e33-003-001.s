.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2db58be // ALIGNU-C.CI-C Cd:30 Cn:5 0110:0110 U:1 imm6:110110 11000010110:11000010110
	.inst 0x82f6e3a0 // ALDR-R.RRB-32 Rt:0 Rn:29 opc:00 S:0 option:111 Rm:22 1:1 L:1 100000101:100000101
	.inst 0x38115d41 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:10 11:11 imm9:100010101 0:0 opc:00 111000:111000 size:00
	.inst 0x825e43de // ASTR-C.RI-C Ct:30 Rn:30 op:00 imm9:111100100 L:0 1000001001:1000001001
	.inst 0x428c7c00 // STP-C.RIB-C Ct:0 Rn:0 Ct2:11111 imm7:0011000 L:0 010000101:010000101
	.zero 50172
	.inst 0xfa1e03cc // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:12 Rn:30 000000:000000 Rm:30 11010000:11010000 S:1 op:1 sf:1
	.inst 0xc2c233c1 // CHKTGD-C-C 00001:00001 Cn:30 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x358655e4 // cbnz:aarch64/instrs/branch/conditional/compare Rt:4 imm19:1000011001010101111 op:1 011010:011010 sf:0
	.inst 0xd4000001
	.zero 8160
	.inst 0xd61f03c0 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:30 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 7164
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a4 // ldr c4, [x21, #1]
	.inst 0xc2400aa5 // ldr c5, [x21, #2]
	.inst 0xc2400eaa // ldr c10, [x21, #3]
	.inst 0xc24012b6 // ldr c22, [x21, #4]
	.inst 0xc24016bd // ldr c29, [x21, #5]
	/* Set up flags and system registers */
	ldr x21, =0x4000000
	msr SPSR_EL3, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30d5d99f
	msr SCTLR_EL1, x21
	ldr x21, =0xc0000
	msr CPACR_EL1, x21
	ldr x21, =0x8
	msr S3_0_C1_C2_2, x21 // CCTLR_EL1
	ldr x21, =0x4
	msr S3_3_C1_C2_2, x21 // CCTLR_EL0
	ldr x21, =initial_DDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884135 // msr DDC_EL0, c21
	ldr x21, =0x80000000
	msr HCR_EL2, x21
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601135 // ldr c21, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e4035 // msr CELR_EL3, c21
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x9, #0xf
	and x21, x21, x9
	cmp x21, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a9 // ldr c9, [x21, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24006a9 // ldr c9, [x21, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400aa9 // ldr c9, [x21, #2]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2400ea9 // ldr c9, [x21, #3]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc24012a9 // ldr c9, [x21, #4]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc24016a9 // ldr c9, [x21, #5]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2401aa9 // ldr c9, [x21, #6]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2401ea9 // ldr c9, [x21, #7]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x21, =final_PCC_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	ldr x21, =esr_el1_dump_address
	ldr x21, [x21]
	mov x9, 0x80
	orr x21, x21, x9
	ldr x9, =0x920000e8
	cmp x9, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001120
	ldr x1, =check_data0
	ldr x2, =0x00001124
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f21
	ldr x1, =check_data1
	ldr x2, =0x00001f22
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f40
	ldr x1, =check_data2
	ldr x2, =0x00001f50
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
	ldr x0, =0x4040c410
	ldr x1, =check_data4
	ldr x2, =0x4040c420
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040e400
	ldr x1, =check_data5
	ldr x2, =0x4040e404
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
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x04, 0x00, 0x08, 0x00, 0x02, 0x00, 0x00
.data
check_data3:
	.byte 0xbe, 0x58, 0xdb, 0xc2, 0xa0, 0xe3, 0xf6, 0x82, 0x41, 0x5d, 0x11, 0x38, 0xde, 0x43, 0x5e, 0x82
	.byte 0x00, 0x7c, 0x8c, 0x42
.data
check_data4:
	.byte 0xcc, 0x03, 0x1e, 0xfa, 0xc1, 0x33, 0xc2, 0xc2, 0xe4, 0x55, 0x86, 0x35, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0xc0, 0x03, 0x1f, 0xd6

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x20008000407ffc0000000200000
	/* C10 */
	.octa 0x400000005f860d90000000000000200c
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x1020
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x20008000407ffc0000000200000
	/* C10 */
	.octa 0x400000005f860d900000000000001f21
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x1020
	/* C30 */
	.octa 0x200080004070000000000000000
initial_DDC_EL0_value:
	.octa 0xc00000005fa601000000000000001000
initial_VBAR_EL1_value:
	.octa 0x200080006800c410000000004040e000
final_PCC_value:
	.octa 0x200080006800c410000000004040c420
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001f20
	.dword 0x0000000000001f40
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
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x020002b5 // add c21, c21, #0
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x020202b5 // add c21, c21, #128
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x020402b5 // add c21, c21, #256
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x020602b5 // add c21, c21, #384
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x020802b5 // add c21, c21, #512
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x020a02b5 // add c21, c21, #640
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x020c02b5 // add c21, c21, #768
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x020e02b5 // add c21, c21, #896
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x021002b5 // add c21, c21, #1024
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x021202b5 // add c21, c21, #1152
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x021402b5 // add c21, c21, #1280
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x021602b5 // add c21, c21, #1408
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x021802b5 // add c21, c21, #1536
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x021a02b5 // add c21, c21, #1664
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x021c02b5 // add c21, c21, #1792
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600d35 // ldr x21, [c9, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d35 // str x21, [c9, #0]
	ldr x21, =0x4040c420
	mrs x9, ELR_EL1
	sub x21, x21, x9
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a9 // cvtp c9, x21
	.inst 0xc2d54129 // scvalue c9, c9, x21
	.inst 0x82600135 // ldr c21, [c9, #0]
	.inst 0x021e02b5 // add c21, c21, #1920
	.inst 0xc2c212a0 // br c21

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
