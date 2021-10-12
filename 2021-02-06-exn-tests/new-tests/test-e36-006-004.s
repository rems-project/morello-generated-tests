.section text0, #alloc, #execinstr
test_start:
	.inst 0x8248c40a // ASTRB-R.RI-B Rt:10 Rn:0 op:01 imm9:010001100 L:0 1000001001:1000001001
	.inst 0xb8420ad1 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:17 Rn:22 10:10 imm9:000100000 0:0 opc:01 111000:111000 size:10
	.inst 0x227f4ee0 // LDXP-C.R-C Ct:0 Rn:23 Ct2:10011 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0x289a10dd // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:29 Rn:6 Rt2:00100 imm7:0110100 L:0 1010001:1010001 opc:00
	.inst 0x889f7f3d // stllr:aarch64/instrs/memory/ordered Rt:29 Rn:25 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.zero 1004
	.inst 0x9bab59fd // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:15 Ra:22 o0:0 Rm:11 01:01 U:1 10011011:10011011
	.inst 0x3a516020 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:1 00:00 cond:0110 Rm:17 111010010:111010010 op:0 sf:0
	.inst 0xc2d8983d // ALIGND-C.CI-C Cd:29 Cn:1 0110:0110 U:0 imm6:110001 11000010110:11000010110
	.inst 0x08e67fb5 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:21 Rn:29 11111:11111 o0:0 Rs:6 1:1 L:1 0010001:0010001 size:00
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400924 // ldr c4, [x9, #2]
	.inst 0xc2400d26 // ldr c6, [x9, #3]
	.inst 0xc240112a // ldr c10, [x9, #4]
	.inst 0xc2401536 // ldr c22, [x9, #5]
	.inst 0xc2401937 // ldr c23, [x9, #6]
	.inst 0xc2401d39 // ldr c25, [x9, #7]
	.inst 0xc240213d // ldr c29, [x9, #8]
	/* Set up flags and system registers */
	ldr x9, =0x14000000
	msr SPSR_EL3, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0xc0000
	msr CPACR_EL1, x9
	ldr x9, =0x4
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x4
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =initial_DDC_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28c4129 // msr DDC_EL1, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601209 // ldr c9, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x16, #0xf
	and x9, x9, x16
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400130 // ldr c16, [x9, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400530 // ldr c16, [x9, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400930 // ldr c16, [x9, #2]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2400d30 // ldr c16, [x9, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2401130 // ldr c16, [x9, #4]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc2401530 // ldr c16, [x9, #5]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc2401930 // ldr c16, [x9, #6]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc2401d30 // ldr c16, [x9, #7]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2402130 // ldr c16, [x9, #8]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc2402530 // ldr c16, [x9, #9]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2402930 // ldr c16, [x9, #10]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	ldr x9, =esr_el1_dump_address
	ldr x9, [x9]
	mov x16, 0x80
	orr x9, x9, x16
	ldr x16, =0x920000ea
	cmp x16, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c4
	ldr x1, =check_data1
	ldr x2, =0x000010c5
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001420
	ldr x1, =check_data2
	ldr x2, =0x00001421
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
	ldr x0, =0x40400020
	ldr x1, =check_data4
	ldr x2, =0x40400024
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
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
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.zero 32
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x0a, 0xc4, 0x48, 0x82, 0xd1, 0x0a, 0x42, 0xb8, 0xe0, 0x4e, 0x7f, 0x22, 0xdd, 0x10, 0x9a, 0x28
	.byte 0x3d, 0x7f, 0x9f, 0x88
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xfd, 0x59, 0xab, 0x9b, 0x20, 0x60, 0x51, 0x3a, 0x3d, 0x98, 0xd8, 0xc2, 0xb5, 0x7f, 0xe6, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1038
	/* C1 */
	.octa 0x720070000440000100001
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x400000000000a0000000000000001000
	/* C10 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000000b00070000000040400000
	/* C23 */
	.octa 0x80100000580000020000000000001000
	/* C25 */
	.octa 0x4000000000038007bf80d24200002106
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x720070000440000100001
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000000b00070000000040400000
	/* C23 */
	.octa 0x80100000580000020000000000001000
	/* C25 */
	.octa 0x4000000000038007bf80d24200002106
	/* C29 */
	.octa 0x720070000000000000000
initial_DDC_EL0_value:
	.octa 0x400000000007000200fffffffffc0001
initial_DDC_EL1_value:
	.octa 0xc00000001807142700ffffffffffe000
initial_VBAR_EL1_value:
	.octa 0x20008000400002060000000040400000
final_PCC_value:
	.octa 0x20008000400002060000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080500670000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x00000000000010c0
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600e09 // ldr x9, [c16, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e09 // str x9, [c16, #0]
	ldr x9, =0x40400414
	mrs x16, ELR_EL1
	sub x9, x9, x16
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b130 // cvtp c16, x9
	.inst 0xc2c94210 // scvalue c16, c16, x9
	.inst 0x82600209 // ldr c9, [c16, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
