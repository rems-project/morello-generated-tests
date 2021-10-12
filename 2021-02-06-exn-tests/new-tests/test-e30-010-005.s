.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2417ebf // LDR-C.RIBW-C Ct:31 Rn:21 11:11 imm9:000010111 0:0 opc:01 10100010:10100010
	.inst 0xe2419121 // ASTURH-R.RI-32 Rt:1 Rn:9 op2:00 imm9:000011001 V:0 op1:01 11100010:11100010
	.inst 0x3978f01c // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:0 imm12:111000111100 opc:01 111001:111001 size:00
	.inst 0xda80b2b7 // csinv:aarch64/instrs/integer/conditional/select Rd:23 Rn:21 o2:0 0:0 cond:1011 Rm:0 011010100:011010100 op:1 sf:1
	.inst 0xb81380c0 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:6 00:00 imm9:100111000 0:0 opc:00 111000:111000 size:10
	.zero 21484
	.inst 0xe28eb11d // ASTUR-R.RI-32 Rt:29 Rn:8 op2:00 imm9:011101011 V:0 op1:10 11100010:11100010
	.inst 0x388c2cba // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:26 Rn:5 11:11 imm9:011000010 0:0 opc:10 111000:111000 size:00
	.inst 0x9baf6be0 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:31 Ra:26 o0:0 Rm:15 01:01 U:1 10011011:10011011
	.inst 0xe2288c3d // ALDUR-V.RI-Q Rt:29 Rn:1 op2:11 imm9:010001000 V:1 op1:00 11100010:11100010
	.inst 0xd4000001
	.zero 44012
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400865 // ldr c5, [x3, #2]
	.inst 0xc2400c66 // ldr c6, [x3, #3]
	.inst 0xc2401068 // ldr c8, [x3, #4]
	.inst 0xc2401469 // ldr c9, [x3, #5]
	.inst 0xc2401875 // ldr c21, [x3, #6]
	.inst 0xc2401c7d // ldr c29, [x3, #7]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0x1c0000
	msr CPACR_EL1, x3
	ldr x3, =0x4
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x4
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =initial_DDC_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4123 // msr DDC_EL1, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601303 // ldr c3, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x24, #0x9
	and x3, x3, x24
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400078 // ldr c24, [x3, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400478 // ldr c24, [x3, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400878 // ldr c24, [x3, #2]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc2400c78 // ldr c24, [x3, #3]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2401078 // ldr c24, [x3, #4]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc2401478 // ldr c24, [x3, #5]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2401878 // ldr c24, [x3, #6]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc2401c78 // ldr c24, [x3, #7]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc2402078 // ldr c24, [x3, #8]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc2402478 // ldr c24, [x3, #9]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2402878 // ldr c24, [x3, #10]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x24, v29.d[0]
	cmp x3, x24
	b.ne comparison_fail
	ldr x3, =0x0
	mov x24, v29.d[1]
	cmp x3, x24
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x24, 0x80
	orr x3, x3, x24
	ldr x24, =0x920000eb
	cmp x24, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e1
	ldr x1, =check_data1
	ldr x2, =0x000010e2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000155c
	ldr x1, =check_data2
	ldr x2, =0x0000155e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000165f
	ldr x1, =check_data3
	ldr x2, =0x00001660
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001ff0
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
	ldr x0, =0x40405400
	ldr x1, =check_data6
	ldr x2, =0x40405414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x58, 0x1f
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xbf, 0x7e, 0x41, 0xa2, 0x21, 0x91, 0x41, 0xe2, 0x1c, 0xf0, 0x78, 0x39, 0xb7, 0xb2, 0x80, 0xda
	.byte 0xc0, 0x80, 0x13, 0xb8
.data
check_data6:
	.byte 0x1d, 0xb1, 0x8e, 0xe2, 0xba, 0x2c, 0x8c, 0x38, 0xe0, 0x6b, 0xaf, 0x9b, 0x3d, 0x8c, 0x28, 0xe2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x803
	/* C1 */
	.octa 0x80000000000100050000000000001f58
	/* C5 */
	.octa 0x101d
	/* C6 */
	.octa 0xa8
	/* C8 */
	.octa 0x40000000600200060000000000000f29
	/* C9 */
	.octa 0x40000000000100050000000000001543
	/* C21 */
	.octa 0xe80
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000000100050000000000001f58
	/* C5 */
	.octa 0x10df
	/* C6 */
	.octa 0xa8
	/* C8 */
	.octa 0x40000000600200060000000000000f29
	/* C9 */
	.octa 0x40000000000100050000000000001543
	/* C21 */
	.octa 0xff0
	/* C23 */
	.octa 0xfffffffffffff7fc
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x901000000007002700ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x800000005801000200ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000441d0000000040405000
final_PCC_value:
	.octa 0x200080004000441d0000000040405414
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
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001010
	.dword 0x0000000000001550
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600f03 // ldr x3, [c24, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f03 // str x3, [c24, #0]
	ldr x3, =0x40405414
	mrs x24, ELR_EL1
	sub x3, x3, x24
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b078 // cvtp c24, x3
	.inst 0xc2c34318 // scvalue c24, c24, x3
	.inst 0x82600303 // ldr c3, [c24, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
