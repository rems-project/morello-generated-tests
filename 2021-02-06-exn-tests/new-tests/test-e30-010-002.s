.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2417ebf // LDR-C.RIBW-C Ct:31 Rn:21 11:11 imm9:000010111 0:0 opc:01 10100010:10100010
	.inst 0xe2419121 // ASTURH-R.RI-32 Rt:1 Rn:9 op2:00 imm9:000011001 V:0 op1:01 11100010:11100010
	.inst 0x3978f01c // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:0 imm12:111000111100 opc:01 111001:111001 size:00
	.inst 0xda80b2b7 // csinv:aarch64/instrs/integer/conditional/select Rd:23 Rn:21 o2:0 0:0 cond:1011 Rm:0 011010100:011010100 op:1 sf:1
	.inst 0xb81380c0 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:6 00:00 imm9:100111000 0:0 opc:00 111000:111000 size:10
	.zero 1004
	.inst 0xe28eb11d // ASTUR-R.RI-32 Rt:29 Rn:8 op2:00 imm9:011101011 V:0 op1:10 11100010:11100010
	.inst 0x388c2cba // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:26 Rn:5 11:11 imm9:011000010 0:0 opc:10 111000:111000 size:00
	.inst 0x9baf6be0 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:31 Ra:26 o0:0 Rm:15 01:01 U:1 10011011:10011011
	.inst 0xe2288c3d // ALDUR-V.RI-Q Rt:29 Rn:1 op2:11 imm9:010001000 V:1 op1:00 11100010:11100010
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc2400845 // ldr c5, [x2, #2]
	.inst 0xc2400c46 // ldr c6, [x2, #3]
	.inst 0xc2401048 // ldr c8, [x2, #4]
	.inst 0xc2401449 // ldr c9, [x2, #5]
	.inst 0xc2401855 // ldr c21, [x2, #6]
	.inst 0xc2401c5d // ldr c29, [x2, #7]
	/* Set up flags and system registers */
	ldr x2, =0x0
	msr SPSR_EL3, x2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0x3c0000
	msr CPACR_EL1, x2
	ldr x2, =0x0
	msr S3_0_C1_C2_2, x2 // CCTLR_EL1
	ldr x2, =0x4
	msr S3_3_C1_C2_2, x2 // CCTLR_EL0
	ldr x2, =initial_DDC_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884122 // msr DDC_EL0, c2
	ldr x2, =initial_DDC_EL1_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc28c4122 // msr DDC_EL1, c2
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82601222 // ldr c2, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc28e4022 // msr CELR_EL3, c2
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x17, #0x9
	and x2, x2, x17
	cmp x2, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400051 // ldr c17, [x2, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400451 // ldr c17, [x2, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400851 // ldr c17, [x2, #2]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc2400c51 // ldr c17, [x2, #3]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc2401051 // ldr c17, [x2, #4]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc2401451 // ldr c17, [x2, #5]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc2401851 // ldr c17, [x2, #6]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2401c51 // ldr c17, [x2, #7]
	.inst 0xc2d1a6e1 // chkeq c23, c17
	b.ne comparison_fail
	.inst 0xc2402051 // ldr c17, [x2, #8]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc2402451 // ldr c17, [x2, #9]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	.inst 0xc2402851 // ldr c17, [x2, #10]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x2, =0x0
	mov x17, v29.d[0]
	cmp x2, x17
	b.ne comparison_fail
	ldr x2, =0x0
	mov x17, v29.d[1]
	cmp x2, x17
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984031 // mrs c17, CELR_EL1
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	ldr x2, =esr_el1_dump_address
	ldr x2, [x2]
	mov x17, 0x80
	orr x2, x2, x17
	ldr x17, =0x920000ea
	cmp x17, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001022
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000103c
	ldr x1, =check_data1
	ldr x2, =0x0000103d
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f0
	ldr x1, =check_data2
	ldr x2, =0x000010f4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001170
	ldr x1, =check_data3
	ldr x2, =0x00001180
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
	ldr x0, =0x404000f0
	ldr x1, =check_data5
	ldr x2, =0x40400100
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
	ldr x0, =0x40400fc2
	ldr x1, =check_data7
	ldr x2, =0x40400fc3
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
	.byte 0x68, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xbf, 0x7e, 0x41, 0xa2, 0x21, 0x91, 0x41, 0xe2, 0x1c, 0xf0, 0x78, 0x39, 0xb7, 0xb2, 0x80, 0xda
	.byte 0xc0, 0x80, 0x13, 0xb8
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0x1d, 0xb1, 0x8e, 0xe2, 0xba, 0x2c, 0x8c, 0x38, 0xe0, 0x6b, 0xaf, 0x9b, 0x3d, 0x8c, 0x28, 0xe2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x200
	/* C1 */
	.octa 0x40400068
	/* C5 */
	.octa 0x800000005040dfe00000000040400f00
	/* C6 */
	.octa 0x60800000000000de
	/* C8 */
	.octa 0x1005
	/* C9 */
	.octa 0x40000000000500030000000000001007
	/* C21 */
	.octa 0x1000
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40400068
	/* C5 */
	.octa 0x800000005040dfe00000000040400fc2
	/* C6 */
	.octa 0x60800000000000de
	/* C8 */
	.octa 0x1005
	/* C9 */
	.octa 0x40000000000500030000000000001007
	/* C21 */
	.octa 0x1170
	/* C23 */
	.octa 0xfffffffffffffdff
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd0100000200100070000000000000000
initial_DDC_EL1_value:
	.octa 0xc0000000000000800000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004800002d0000000040400001
final_PCC_value:
	.octa 0x200080004800002d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001020
	.dword 0x00000000000010f0
	.dword 0x0000000000001170
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
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600e22 // ldr x2, [c17, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e22 // str x2, [c17, #0]
	ldr x2, =0x40400414
	mrs x17, ELR_EL1
	sub x2, x2, x17
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b051 // cvtp c17, x2
	.inst 0xc2c24231 // scvalue c17, c17, x2
	.inst 0x82600222 // ldr c2, [c17, #0]
	.inst 0x021e0042 // add c2, c2, #1920
	.inst 0xc2c21040 // br c2

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
