.section text0, #alloc, #execinstr
test_start:
	.inst 0x38826f3e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:25 11:11 imm9:000100110 0:0 opc:10 111000:111000 size:00
	.inst 0x1ac10d0c // sdiv:aarch64/instrs/integer/arithmetic/div Rd:12 Rn:8 o1:1 00001:00001 Rm:1 0011010110:0011010110 sf:0
	.inst 0xba5f73c8 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1000 0:0 Rn:30 00:00 cond:0111 Rm:31 111010010:111010010 op:0 sf:1
	.inst 0x1b1df7c1 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:1 Rn:30 Ra:29 o0:1 Rm:29 0011011000:0011011000 sf:0
	.inst 0xc2c493d8 // STCT-R.R-_ Rt:24 Rn:30 100:100 opc:00 11000010110001001:11000010110001001
	.zero 1004
	.inst 0x8257f42f // ASTRB-R.RI-B Rt:15 Rn:1 op:01 imm9:101111111 L:0 1000001001:1000001001
	.inst 0xf8be811e // swp:aarch64/instrs/memory/atomicops/swp Rt:30 Rn:8 100000:100000 Rs:30 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xe2ca3fb5 // ALDUR-C.RI-C Ct:21 Rn:29 op2:11 imm9:010100011 V:0 op1:11 11100010:11100010
	.inst 0xe210d7bd // ALDURB-R.RI-32 Rt:29 Rn:29 op2:01 imm9:100001101 V:0 op1:00 11100010:11100010
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006e8 // ldr c8, [x23, #1]
	.inst 0xc2400aef // ldr c15, [x23, #2]
	.inst 0xc2400ef9 // ldr c25, [x23, #3]
	.inst 0xc24012fd // ldr c29, [x23, #4]
	/* Set up flags and system registers */
	ldr x23, =0x10000000
	msr SPSR_EL3, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x0
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012d7 // ldr c23, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x22, #0xf
	and x23, x23, x22
	cmp x23, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f6 // ldr c22, [x23, #0]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24006f6 // ldr c22, [x23, #1]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2400af6 // ldr c22, [x23, #2]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2400ef6 // ldr c22, [x23, #3]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc24012f6 // ldr c22, [x23, #4]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc24016f6 // ldr c22, [x23, #5]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2401af6 // ldr c22, [x23, #6]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2401ef6 // ldr c22, [x23, #7]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	ldr x22, =esr_el1_dump_address
	ldr x22, [x22]
	mov x23, 0x0
	orr x22, x22, x23
	ldr x23, =0x2000000
	cmp x23, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000119a
	ldr x1, =check_data0
	ldr x2, =0x0000119b
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001330
	ldr x1, =check_data1
	ldr x2, =0x00001340
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000140c
	ldr x1, =check_data2
	ldr x2, =0x0000140d
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x3e, 0x6f, 0x82, 0x38, 0x0c, 0x0d, 0xc1, 0x1a, 0xc8, 0x73, 0x5f, 0xba, 0xc1, 0xf7, 0x1d, 0x1b
	.byte 0xd8, 0x93, 0xc4, 0xc2
.data
check_data6:
	.byte 0x2f, 0xf4, 0x57, 0x82, 0x1e, 0x81, 0xbe, 0xf8, 0xb5, 0x3f, 0xca, 0xe2, 0xbd, 0xd7, 0x10, 0xe2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0xc0000000000100050000000000001ff0
	/* C15 */
	.octa 0x0
	/* C25 */
	.octa 0x1fd8
	/* C29 */
	.octa 0x128d
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x128d
	/* C8 */
	.octa 0xc0000000000100050000000000001ff0
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x1ffe
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0xd0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400001
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001330
	.dword initial_cap_values + 16
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40400414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
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
