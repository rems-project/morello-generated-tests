.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c13321 // GCFLGS-R.C-C Rd:1 Cn:25 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x9bbf7dd5 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:21 Rn:14 Ra:31 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0xc2c5b3a1 // CVTP-C.R-C Cd:1 Rn:29 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c1d337 // CPY-C.C-C Cd:23 Cn:25 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xa244afdf // LDR-C.RIBW-C Ct:31 Rn:30 11:11 imm9:001001010 0:0 opc:01 10100010:10100010
	.zero 35820
	.inst 0xb8395020 // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:1 00:00 opc:101 0:0 Rs:25 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x48dfff20 // ldarh:aarch64/instrs/memory/ordered Rt:0 Rn:25 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xe2bae1a6 // ASTUR-V.RI-S Rt:6 Rn:13 op2:00 imm9:110101110 V:1 op1:10 11100010:11100010
	.inst 0x790b8fdd // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:30 imm12:001011100011 opc:00 111001:111001 size:01
	.inst 0xd4000001
	.zero 29676
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
	ldr x18, =initial_cap_values
	.inst 0xc240024d // ldr c13, [x18, #0]
	.inst 0xc2400659 // ldr c25, [x18, #1]
	.inst 0xc2400a5d // ldr c29, [x18, #2]
	.inst 0xc2400e5e // ldr c30, [x18, #3]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q6, =0x0
	/* Set up flags and system registers */
	ldr x18, =0x0
	msr SPSR_EL3, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30d5d99f
	msr SCTLR_EL1, x18
	ldr x18, =0x3c0000
	msr CPACR_EL1, x18
	ldr x18, =0x4
	msr S3_0_C1_C2_2, x18 // CCTLR_EL1
	ldr x18, =0x8
	msr S3_3_C1_C2_2, x18 // CCTLR_EL0
	ldr x18, =initial_DDC_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884132 // msr DDC_EL0, c18
	ldr x18, =initial_DDC_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc28c4132 // msr DDC_EL1, c18
	ldr x18, =0x80000000
	msr HCR_EL2, x18
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011f2 // ldr c18, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e4032 // msr CELR_EL3, c18
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024f // ldr c15, [x18, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240064f // ldr c15, [x18, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400a4f // ldr c15, [x18, #2]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc2400e4f // ldr c15, [x18, #3]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc240124f // ldr c15, [x18, #4]
	.inst 0xc2cfa6e1 // chkeq c23, c15
	b.ne comparison_fail
	.inst 0xc240164f // ldr c15, [x18, #5]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc2401a4f // ldr c15, [x18, #6]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2401e4f // ldr c15, [x18, #7]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x15, v6.d[0]
	cmp x18, x15
	b.ne comparison_fail
	ldr x18, =0x0
	mov x15, v6.d[1]
	cmp x18, x15
	b.ne comparison_fail
	/* Check system registers */
	ldr x18, =final_PCC_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	ldr x18, =esr_el1_dump_address
	ldr x18, [x18]
	mov x15, 0xc1
	orr x18, x18, x15
	ldr x15, =0x920000eb
	cmp x15, x18
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
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001402
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001418
	ldr x1, =check_data2
	ldr x2, =0x0000141c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fc8
	ldr x1, =check_data3
	ldr x2, =0x00001fcc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40408c00
	ldr x1, =check_data5
	ldr x2, =0x40408c14
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
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
	.zero 1040
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3040
.data
check_data0:
	.byte 0x18, 0x04
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x04, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x21, 0x33, 0xc1, 0xc2, 0xd5, 0x7d, 0xbf, 0x9b, 0xa1, 0xb3, 0xc5, 0xc2, 0x37, 0xd3, 0xc1, 0xc2
	.byte 0xdf, 0xaf, 0x44, 0xa2
.data
check_data5:
	.byte 0x20, 0x50, 0x39, 0xb8, 0x20, 0xff, 0xdf, 0x48, 0xa6, 0xe1, 0xba, 0xe2, 0xdd, 0x8f, 0x0b, 0x79
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C13 */
	.octa 0x4000000000010005000000000000201a
	/* C25 */
	.octa 0x400
	/* C29 */
	.octa 0x418
	/* C30 */
	.octa 0xfffffffffffffa3c
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x20008000000060000000000000000418
	/* C13 */
	.octa 0x4000000000010005000000000000201a
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x400
	/* C25 */
	.octa 0x400
	/* C29 */
	.octa 0x418
	/* C30 */
	.octa 0xfffffffffffffa3c
initial_DDC_EL0_value:
	.octa 0x80000000200707fb002c85404a6e0000
initial_DDC_EL1_value:
	.octa 0xc0000000010701030000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000841c0000000040408800
final_PCC_value:
	.octa 0x200080005000841c0000000040408c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000060000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001410
	.dword 0x0000000000001fc0
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
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02000252 // add c18, c18, #0
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02020252 // add c18, c18, #128
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02040252 // add c18, c18, #256
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02060252 // add c18, c18, #384
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02080252 // add c18, c18, #512
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x020a0252 // add c18, c18, #640
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x020c0252 // add c18, c18, #768
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x020e0252 // add c18, c18, #896
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02100252 // add c18, c18, #1024
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02120252 // add c18, c18, #1152
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02140252 // add c18, c18, #1280
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02160252 // add c18, c18, #1408
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02180252 // add c18, c18, #1536
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x021a0252 // add c18, c18, #1664
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x021c0252 // add c18, c18, #1792
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40408c14
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x021e0252 // add c18, c18, #1920
	.inst 0xc2c21240 // br c18

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
