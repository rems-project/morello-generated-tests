.section text0, #alloc, #execinstr
test_start:
	.inst 0x7d77e7ab // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:11 Rn:29 imm12:110111111001 opc:01 111101:111101 size:01
	.inst 0xd5033d5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1101 11010101000000110011:11010101000000110011
	.inst 0x081fffc1 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:30 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0xe2c70da6 // ALDUR-C.RI-C Ct:6 Rn:13 op2:11 imm9:001110000 V:0 op1:11 11100010:11100010
	.inst 0x425fff7f // LDAR-C.R-C Ct:31 Rn:27 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c250a2 // 0xc2c250a2
	.zero 32752
	.inst 0xc2c1a4c1 // 0xc2c1a4c1
	.inst 0xe2eaf2be // 0xe2eaf2be
	.inst 0x7861403f // 0x7861403f
	.inst 0xd4000001
	.zero 32744
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
	.inst 0xc24006e5 // ldr c5, [x23, #1]
	.inst 0xc2400aed // ldr c13, [x23, #2]
	.inst 0xc2400ef5 // ldr c21, [x23, #3]
	.inst 0xc24012fb // ldr c27, [x23, #4]
	.inst 0xc24016fd // ldr c29, [x23, #5]
	.inst 0xc2401afe // ldr c30, [x23, #6]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0x3c0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x4
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601337 // ldr c23, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	mov x25, #0xf
	and x23, x23, x25
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f9 // ldr c25, [x23, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24006f9 // ldr c25, [x23, #1]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2400af9 // ldr c25, [x23, #2]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc2400ef9 // ldr c25, [x23, #3]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc24012f9 // ldr c25, [x23, #4]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc24016f9 // ldr c25, [x23, #5]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc2401af9 // ldr c25, [x23, #6]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2401ef9 // ldr c25, [x23, #7]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x25, v11.d[0]
	cmp x23, x25
	b.ne comparison_fail
	ldr x23, =0x0
	mov x25, v11.d[1]
	cmp x23, x25
	b.ne comparison_fail
	ldr x23, =0x0
	mov x25, v30.d[0]
	cmp x23, x25
	b.ne comparison_fail
	ldr x23, =0x0
	mov x25, v30.d[1]
	cmp x23, x25
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a6e1 // chkeq c23, c25
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
	ldr x0, =0x000010b0
	ldr x1, =check_data1
	ldr x2, =0x000010b8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001870
	ldr x1, =check_data2
	ldr x2, =0x00001880
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e40
	ldr x1, =check_data3
	ldr x2, =0x00001e50
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffd
	ldr x1, =check_data4
	ldr x2, =0x00001ffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40408008
	ldr x1, =check_data6
	ldr x2, =0x40408018
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x404093f2
	ldr x1, =check_data7
	ldr x2, =0x404093f4
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.byte 0x01, 0x90, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3632
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x02, 0x01, 0x00, 0x00
	.zero 432
.data
check_data0:
	.byte 0x00, 0x10
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x02, 0x01, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xab, 0xe7, 0x77, 0x7d, 0x5f, 0x3d, 0x03, 0xd5, 0xc1, 0xff, 0x1f, 0x08, 0xa6, 0x0d, 0xc7, 0xe2
	.byte 0x7f, 0xff, 0x5f, 0x42, 0xa2, 0x50, 0xc2, 0xc2
.data
check_data6:
	.byte 0xc1, 0xa4, 0xc1, 0xc2, 0xbe, 0xf2, 0xea, 0xe2, 0x3f, 0x40, 0x61, 0x78, 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000
	/* C5 */
	.octa 0x200080008007800f0000000040408008
	/* C13 */
	.octa 0x90000000000100050000000000001800
	/* C21 */
	.octa 0x40000000000100050000000000001001
	/* C27 */
	.octa 0x1e40
	/* C29 */
	.octa 0x40407800
	/* C30 */
	.octa 0x1ffd
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1000
	/* C5 */
	.octa 0x200080008007800f0000000040408008
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x90000000000100050000000000001800
	/* C21 */
	.octa 0x40000000000100050000000000001001
	/* C27 */
	.octa 0x1e40
	/* C29 */
	.octa 0x40407800
	/* C30 */
	.octa 0x1ffd
initial_DDC_EL0_value:
	.octa 0xd0000000000200020000000100180000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080000007800f0000000040408018
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001e40
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_DDC_EL0_value
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
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40408018
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
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
