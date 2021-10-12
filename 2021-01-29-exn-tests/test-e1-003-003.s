.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dcda9d // ALIGNU-C.CI-C Cd:29 Cn:20 0110:0110 U:1 imm6:111001 11000010110:11000010110
	.inst 0xa2471839 // LDTR-C.RIB-C Ct:25 Rn:1 10:10 imm9:001110001 0:0 opc:01 10100010:10100010
	.inst 0xb84f4575 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:21 Rn:11 01:01 imm9:011110100 0:0 opc:01 111000:111000 size:10
	.inst 0xb9a387fd // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:31 imm12:100011100001 opc:10 111001:111001 size:10
	.inst 0x62e927cd // LDP-C.RIBW-C Ct:13 Rn:30 Ct2:01001 imm7:1010010 L:1 011000101:011000101
	.zero 1004
	.inst 0x62ba389f // 0x62ba389f
	.inst 0x28dfc41d // 0x28dfc41d
	.inst 0xc80afc1d // 0xc80afc1d
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2400c6b // ldr c11, [x3, #3]
	.inst 0xc240106e // ldr c14, [x3, #4]
	.inst 0xc2401474 // ldr c20, [x3, #5]
	.inst 0xc240187e // ldr c30, [x3, #6]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =initial_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884103 // msr CSP_EL0, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0xc0000
	msr CPACR_EL1, x3
	ldr x3, =0x0
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x0
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82601043 // ldr c3, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400062 // ldr c2, [x3, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400862 // ldr c2, [x3, #2]
	.inst 0xc2c2a481 // chkeq c4, c2
	b.ne comparison_fail
	.inst 0xc2400c62 // ldr c2, [x3, #3]
	.inst 0xc2c2a541 // chkeq c10, c2
	b.ne comparison_fail
	.inst 0xc2401062 // ldr c2, [x3, #4]
	.inst 0xc2c2a561 // chkeq c11, c2
	b.ne comparison_fail
	.inst 0xc2401462 // ldr c2, [x3, #5]
	.inst 0xc2c2a5c1 // chkeq c14, c2
	b.ne comparison_fail
	.inst 0xc2401862 // ldr c2, [x3, #6]
	.inst 0xc2c2a621 // chkeq c17, c2
	b.ne comparison_fail
	.inst 0xc2401c62 // ldr c2, [x3, #7]
	.inst 0xc2c2a681 // chkeq c20, c2
	b.ne comparison_fail
	.inst 0xc2402062 // ldr c2, [x3, #8]
	.inst 0xc2c2a6a1 // chkeq c21, c2
	b.ne comparison_fail
	.inst 0xc2402462 // ldr c2, [x3, #9]
	.inst 0xc2c2a721 // chkeq c25, c2
	b.ne comparison_fail
	.inst 0xc2402862 // ldr c2, [x3, #10]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc2402c62 // ldr c2, [x3, #11]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984102 // mrs c2, CSP_EL0
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	ldr x2, =esr_el1_dump_address
	ldr x2, [x2]
	mov x3, 0x83
	orr x2, x2, x3
	ldr x3, =0x920000a3
	cmp x3, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001044
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001140
	ldr x1, =check_data1
	ldr x2, =0x00001160
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011e4
	ldr x1, =check_data2
	ldr x2, =0x000011ec
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000012e0
	ldr x1, =check_data3
	ldr x2, =0x000012e8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f34
	ldr x1, =check_data4
	ldr x2, =0x00001f38
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
	.zero 4
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x9d, 0xda, 0xdc, 0xc2, 0x39, 0x18, 0x47, 0xa2, 0x75, 0x45, 0x4f, 0xb8, 0xfd, 0x87, 0xa3, 0xb9
	.byte 0xcd, 0x27, 0xe9, 0x62
.data
check_data6:
	.byte 0x9f, 0x38, 0xba, 0x62, 0x1d, 0xc4, 0xdf, 0x28, 0x1d, 0xfc, 0x0a, 0xc8, 0xe0, 0x73, 0xc2, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc00000004004000500000000000011e4
	/* C1 */
	.octa 0x403ff8f0
	/* C4 */
	.octa 0x4c000000002140050000000000001200
	/* C11 */
	.octa 0x1040
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0x40010001000000000000e001
	/* C30 */
	.octa 0x5f80000000000301
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc00000004004000500000000000012e0
	/* C1 */
	.octa 0x403ff8f0
	/* C4 */
	.octa 0x4c000000002140050000000000001140
	/* C10 */
	.octa 0x1
	/* C11 */
	.octa 0x1134
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x40010001000000000000e001
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0xb9a387fdb84f4575a2471839c2dcda9d
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x5f80000000000301
initial_SP_EL0_value:
	.octa 0xfffffffffffffbb0
initial_DDC_EL0_value:
	.octa 0x80100000220100070000000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000400004000000000040400001
final_SP_EL0_value:
	.octa 0xfffffffffffffbb0
final_PCC_value:
	.octa 0x20008000400004000000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
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
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
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
