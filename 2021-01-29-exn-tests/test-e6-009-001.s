.section text0, #alloc, #execinstr
test_start:
	.inst 0x7d77e7ab // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:11 Rn:29 imm12:110111111001 opc:01 111101:111101 size:01
	.inst 0xd5033d5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1101 11010101000000110011:11010101000000110011
	.inst 0x081fffc1 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:30 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0xe2c70da6 // ALDUR-C.RI-C Ct:6 Rn:13 op2:11 imm9:001110000 V:0 op1:11 11100010:11100010
	.inst 0x425fff7f // LDAR-C.R-C Ct:31 Rn:27 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.zero 172
	.inst 0xc2c1a4c1 // CHKEQ-_.CC-C 00001:00001 Cn:6 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0xe2eaf2be // ASTUR-V.RI-D Rt:30 Rn:21 op2:00 imm9:010101111 V:1 op1:11 11100010:11100010
	.inst 0x7861403f // stsmaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:100 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xd4000001
	.zero 816
	.inst 0xc2c250a2 // RETS-C-C 00010:00010 Cn:5 100:100 opc:10 11000010110000100:11000010110000100
	.zero 64508
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
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400465 // ldr c5, [x3, #1]
	.inst 0xc240086d // ldr c13, [x3, #2]
	.inst 0xc2400c75 // ldr c21, [x3, #3]
	.inst 0xc240107b // ldr c27, [x3, #4]
	.inst 0xc240147d // ldr c29, [x3, #5]
	.inst 0xc240187e // ldr c30, [x3, #6]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0x3c0000
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
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82601103 // ldr c3, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	mov x8, #0xf
	and x3, x3, x8
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400068 // ldr c8, [x3, #0]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400468 // ldr c8, [x3, #1]
	.inst 0xc2c8a4a1 // chkeq c5, c8
	b.ne comparison_fail
	.inst 0xc2400868 // ldr c8, [x3, #2]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc2400c68 // ldr c8, [x3, #3]
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc2401068 // ldr c8, [x3, #4]
	.inst 0xc2c8a6a1 // chkeq c21, c8
	b.ne comparison_fail
	.inst 0xc2401468 // ldr c8, [x3, #5]
	.inst 0xc2c8a761 // chkeq c27, c8
	b.ne comparison_fail
	.inst 0xc2401868 // ldr c8, [x3, #6]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2401c68 // ldr c8, [x3, #7]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x8, v11.d[0]
	cmp x3, x8
	b.ne comparison_fail
	ldr x3, =0x0
	mov x8, v11.d[1]
	cmp x3, x8
	b.ne comparison_fail
	ldr x3, =0x0
	mov x8, v30.d[0]
	cmp x3, x8
	b.ne comparison_fail
	ldr x3, =0x0
	mov x8, v30.d[1]
	cmp x3, x8
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a461 // chkeq c3, c8
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x3, 0x83
	orr x8, x8, x3
	ldr x3, =0x920000ab
	cmp x3, x8
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
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001038
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001cf4
	ldr x1, =check_data2
	ldr x2, =0x00001cf6
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x404000c0
	ldr x1, =check_data5
	ldr x2, =0x404000d0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400404
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.byte 0x01, 0x90, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x10
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xab, 0xe7, 0x77, 0x7d, 0x5f, 0x3d, 0x03, 0xd5, 0xc1, 0xff, 0x1f, 0x08, 0xa6, 0x0d, 0xc7, 0xe2
	.byte 0x7f, 0xff, 0x5f, 0x42
.data
check_data5:
	.byte 0xc1, 0xa4, 0xc1, 0xc2, 0xbe, 0xf2, 0xea, 0xe2, 0x3f, 0x40, 0x61, 0x78, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0xa2, 0x50, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc00000001007000d0000000000001000
	/* C5 */
	.octa 0x200080008007000b00000000404000c1
	/* C13 */
	.octa 0x900000000007000300000000403fff90
	/* C21 */
	.octa 0xf81
	/* C27 */
	.octa 0x80080000408011
	/* C29 */
	.octa 0x102
	/* C30 */
	.octa 0x1ffe
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xc00000001007000d0000000000001000
	/* C5 */
	.octa 0x200080008007000b00000000404000c1
	/* C6 */
	.octa 0xe2c70da6081fffc1d5033d5f7d77e7ab
	/* C13 */
	.octa 0x900000000007000300000000403fff90
	/* C21 */
	.octa 0xf81
	/* C27 */
	.octa 0x80080000408011
	/* C29 */
	.octa 0x102
	/* C30 */
	.octa 0x1ffe
initial_DDC_EL0_value:
	.octa 0xc0000000600000000000000000000001
initial_DDC_EL1_value:
	.octa 0x40000000000700030000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000d4010000000040400000
final_PCC_value:
	.octa 0x200080000007000b00000000404000d0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x404000d0
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
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
