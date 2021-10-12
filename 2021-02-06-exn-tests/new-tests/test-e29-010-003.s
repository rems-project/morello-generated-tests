.section text0, #alloc, #execinstr
test_start:
	.inst 0x227f971d // LDAXP-C.R-C Ct:29 Rn:24 Ct2:00101 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0x783e01b0 // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:13 00:00 opc:000 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xc2c23021 // CHKTGD-C-C 00001:00001 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xb8ba1341 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:26 00:00 opc:001 0:0 Rs:26 1:1 R:0 A:1 111000:111000 size:10
	.inst 0x421ffe01 // STLR-C.R-C Ct:1 Rn:16 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.zero 1004
	.inst 0xc2c9da01 // ALIGNU-C.CI-C Cd:1 Cn:16 0110:0110 U:1 imm6:010011 11000010110:11000010110
	.inst 0xc2c21220 // BR-C-C 00000:00000 Cn:17 100:100 opc:00 11000010110000100:11000010110000100
	.zero 26376
	.inst 0xacd307d7 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:23 Rn:30 Rt2:00001 imm7:0100110 L:1 1011001:1011001 opc:10
	.inst 0x9b35041f // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:0 Ra:1 o0:0 Rm:21 01:01 U:0 10011011:10011011
	.inst 0xd4000001
	.zero 38116
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
	.inst 0xc240046d // ldr c13, [x3, #1]
	.inst 0xc2400871 // ldr c17, [x3, #2]
	.inst 0xc2400c78 // ldr c24, [x3, #3]
	.inst 0xc240107a // ldr c26, [x3, #4]
	.inst 0xc240147e // ldr c30, [x3, #5]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0x3c0000
	msr CPACR_EL1, x3
	ldr x3, =0x0
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x4
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
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
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc2400c68 // ldr c8, [x3, #3]
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	.inst 0xc2401068 // ldr c8, [x3, #4]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc2401468 // ldr c8, [x3, #5]
	.inst 0xc2c8a701 // chkeq c24, c8
	b.ne comparison_fail
	.inst 0xc2401868 // ldr c8, [x3, #6]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2401c68 // ldr c8, [x3, #7]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2402068 // ldr c8, [x3, #8]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x8, v1.d[0]
	cmp x3, x8
	b.ne comparison_fail
	ldr x3, =0x0
	mov x8, v1.d[1]
	cmp x3, x8
	b.ne comparison_fail
	ldr x3, =0x0
	mov x8, v23.d[0]
	cmp x3, x8
	b.ne comparison_fail
	ldr x3, =0x0
	mov x8, v23.d[1]
	cmp x3, x8
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a461 // chkeq c3, c8
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x8, 0x80
	orr x3, x3, x8
	ldr x8, =0x920000e1
	cmp x8, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001802
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001890
	ldr x1, =check_data3
	ldr x2, =0x000018b0
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
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400408
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40406b10
	ldr x1, =check_data6
	ldr x2, =0x40406b1c
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
	.zero 16
	.byte 0x8e, 0x58, 0xf6, 0x71, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2016
	.byte 0x15, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x8c, 0x48, 0xf6, 0x71
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0xa5, 0x2e
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0x1d, 0x97, 0x7f, 0x22, 0xb0, 0x01, 0x3e, 0x78, 0x21, 0x30, 0xc2, 0xc2, 0x41, 0x13, 0xba, 0xb8
	.byte 0x01, 0xfe, 0x1f, 0x42
.data
check_data5:
	.byte 0x01, 0xda, 0xc9, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
check_data6:
	.byte 0xd7, 0x07, 0xd3, 0xac, 0x1f, 0x04, 0x35, 0x9b, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C13 */
	.octa 0x17f2
	/* C17 */
	.octa 0x20008000a04ee00e0000000040406b11
	/* C24 */
	.octa 0x1012
	/* C26 */
	.octa 0x1002
	/* C30 */
	.octa 0x80000000111300070000000000001890
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x80000
	/* C5 */
	.octa 0x0
	/* C13 */
	.octa 0x17f2
	/* C16 */
	.octa 0x1615
	/* C17 */
	.octa 0x20008000a04ee00e0000000040406b11
	/* C24 */
	.octa 0x1012
	/* C26 */
	.octa 0x1002
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000111300070000000000001af0
initial_DDC_EL0_value:
	.octa 0xd00000005e92000e00ffffffffffe801
initial_VBAR_EL1_value:
	.octa 0x200080004c00f4210000000040400000
final_PCC_value:
	.octa 0x20008000204ee00e0000000040406b1c
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
	.dword 0x0000000000001030
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001030
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword 0x0000000000001800
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
	ldr x3, =0x40406b1c
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
