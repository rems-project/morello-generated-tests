.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2e01a98 // CVT-C.CR-C Cd:24 Cn:20 0110:0110 0:0 0:0 Rm:0 11000010111:11000010111
	.inst 0x9a8a971f // csinc:aarch64/instrs/integer/conditional/select Rd:31 Rn:24 o2:1 0:0 cond:1001 Rm:10 011010100:011010100 op:0 sf:1
	.inst 0x78bf521b // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:27 Rn:16 00:00 opc:101 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x489f7fa0 // stllrh:aarch64/instrs/memory/ordered Rt:0 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe22fd419 // ALDUR-V.RI-B Rt:25 Rn:0 op2:01 imm9:011111101 V:1 op1:00 11100010:11100010
	.zero 1004
	.inst 0x62fc68c3 // 0x62fc68c3
	.inst 0x82fef3d9 // 0x82fef3d9
	.inst 0x381090cf // 0x381090cf
	.inst 0xc22f3015 // 0xc22f3015
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400486 // ldr c6, [x4, #1]
	.inst 0xc240088f // ldr c15, [x4, #2]
	.inst 0xc2400c90 // ldr c16, [x4, #3]
	.inst 0xc2401094 // ldr c20, [x4, #4]
	.inst 0xc2401495 // ldr c21, [x4, #5]
	.inst 0xc240189d // ldr c29, [x4, #6]
	.inst 0xc2401c9e // ldr c30, [x4, #7]
	/* Set up flags and system registers */
	ldr x4, =0x0
	msr SPSR_EL3, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0xc0000
	msr CPACR_EL1, x4
	ldr x4, =0x4
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =0x0
	msr S3_3_C1_C2_2, x4 // CCTLR_EL0
	ldr x4, =initial_DDC_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884124 // msr DDC_EL0, c4
	ldr x4, =initial_DDC_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc28c4124 // msr DDC_EL1, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82601104 // ldr c4, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc28e4024 // msr CELR_EL3, c4
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x8, #0x2
	and x4, x4, x8
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400088 // ldr c8, [x4, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400488 // ldr c8, [x4, #1]
	.inst 0xc2c8a461 // chkeq c3, c8
	b.ne comparison_fail
	.inst 0xc2400888 // ldr c8, [x4, #2]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc2400c88 // ldr c8, [x4, #3]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc2401088 // ldr c8, [x4, #4]
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	.inst 0xc2401488 // ldr c8, [x4, #5]
	.inst 0xc2c8a681 // chkeq c20, c8
	b.ne comparison_fail
	.inst 0xc2401888 // ldr c8, [x4, #6]
	.inst 0xc2c8a6a1 // chkeq c21, c8
	b.ne comparison_fail
	.inst 0xc2401c88 // ldr c8, [x4, #7]
	.inst 0xc2c8a701 // chkeq c24, c8
	b.ne comparison_fail
	.inst 0xc2402088 // ldr c8, [x4, #8]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc2402488 // ldr c8, [x4, #9]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2402888 // ldr c8, [x4, #10]
	.inst 0xc2c8a761 // chkeq c27, c8
	b.ne comparison_fail
	.inst 0xc2402c88 // ldr c8, [x4, #11]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2403088 // ldr c8, [x4, #12]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x4, 0x0
	orr x8, x8, x4
	ldr x4, =0x1fe00000
	cmp x4, x8
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
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001802
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ce0
	ldr x1, =check_data2
	ldr x2, =0x00001cf0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e89
	ldr x1, =check_data3
	ldr x2, =0x00001e8a
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f80
	ldr x1, =check_data4
	ldr x2, =0x00001fa0
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
	ldr x0, =0x4040fff8
	ldr x1, =check_data7
	ldr x2, =0x4040fffc
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
	.zero 2048
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x20, 0x60
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x02, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x02, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 32
.data
check_data5:
	.byte 0x98, 0x1a, 0xe0, 0xc2, 0x1f, 0x97, 0x8a, 0x9a, 0x1b, 0x52, 0xbf, 0x78, 0xa0, 0x7f, 0x9f, 0x48
	.byte 0x19, 0xd4, 0x2f, 0xe2
.data
check_data6:
	.byte 0xc3, 0x68, 0xfc, 0x62, 0xd9, 0xf3, 0xfe, 0x82, 0xcf, 0x90, 0x10, 0x38, 0x15, 0x30, 0x2f, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffffff6020
	/* C6 */
	.octa 0x2000
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x1800
	/* C20 */
	.octa 0x9706800700ffffffff800001
	/* C21 */
	.octa 0x20000000200000200020000000000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x8000000000010005ccccccccd9a69998
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xffffffffffff6020
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x1f80
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x1800
	/* C20 */
	.octa 0x9706800700ffffffff800001
	/* C21 */
	.octa 0x20000000200000200020000000000
	/* C24 */
	.octa 0x97068007ffffffffffff6020
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x100
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x8000000000010005ccccccccd9a69998
initial_DDC_EL0_value:
	.octa 0xc0000000000700060000000000000000
initial_DDC_EL1_value:
	.octa 0xcc000000200000000080380000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400000
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
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
	.dword 0x0000000000001f80
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 96
	.dword final_cap_values + 192
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600d04 // ldr x4, [c8, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d04 // str x4, [c8, #0]
	ldr x4, =0x40400414
	mrs x8, ELR_EL1
	sub x4, x4, x8
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b088 // cvtp c8, x4
	.inst 0xc2c44108 // scvalue c8, c8, x4
	.inst 0x82600104 // ldr c4, [c8, #0]
	.inst 0x021e0084 // add c4, c4, #1920
	.inst 0xc2c21080 // br c4

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
