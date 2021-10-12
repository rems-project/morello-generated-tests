.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dcda9d // ALIGNU-C.CI-C Cd:29 Cn:20 0110:0110 U:1 imm6:111001 11000010110:11000010110
	.inst 0xa2471839 // LDTR-C.RIB-C Ct:25 Rn:1 10:10 imm9:001110001 0:0 opc:01 10100010:10100010
	.inst 0xb84f4575 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:21 Rn:11 01:01 imm9:011110100 0:0 opc:01 111000:111000 size:10
	.inst 0xb9a387fd // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:31 imm12:100011100001 opc:10 111001:111001 size:10
	.inst 0x62e927cd // LDP-C.RIBW-C Ct:13 Rn:30 Ct2:01001 imm7:1010010 L:1 011000101:011000101
	.inst 0x62ba389f // 0x62ba389f
	.inst 0x28dfc41d // 0x28dfc41d
	.inst 0xc80afc1d // 0xc80afc1d
	.inst 0xc2c273e0 // 0xc2c273e0
	.inst 0xd4000001
	.zero 65496
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
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae4 // ldr c4, [x23, #2]
	.inst 0xc2400eeb // ldr c11, [x23, #3]
	.inst 0xc24012ee // ldr c14, [x23, #4]
	.inst 0xc24016f4 // ldr c20, [x23, #5]
	.inst 0xc2401afe // ldr c30, [x23, #6]
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
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
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010b7 // ldr c23, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e5 // ldr c5, [x23, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24006e5 // ldr c5, [x23, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400ae5 // ldr c5, [x23, #2]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2400ee5 // ldr c5, [x23, #3]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc24012e5 // ldr c5, [x23, #4]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc24016e5 // ldr c5, [x23, #5]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2401ae5 // ldr c5, [x23, #6]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2401ee5 // ldr c5, [x23, #7]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc24022e5 // ldr c5, [x23, #8]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc24026e5 // ldr c5, [x23, #9]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc2402ae5 // ldr c5, [x23, #10]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2402ee5 // ldr c5, [x23, #11]
	.inst 0xc2c5a721 // chkeq c25, c5
	b.ne comparison_fail
	.inst 0xc24032e5 // ldr c5, [x23, #12]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc24036e5 // ldr c5, [x23, #13]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984105 // mrs c5, CSP_EL0
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x0000100c
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
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001108
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001150
	ldr x1, =check_data3
	ldr x2, =0x00001170
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001794
	ldr x1, =check_data4
	ldr x2, =0x00001798
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f00
	ldr x1, =check_data5
	ldr x2, =0x00001f10
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
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
	.zero 12
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0x9d, 0xda, 0xdc, 0xc2, 0x39, 0x18, 0x47, 0xa2, 0x75, 0x45, 0x4f, 0xb8, 0xfd, 0x87, 0xa3, 0xb9
	.byte 0xcd, 0x27, 0xe9, 0x62, 0x9f, 0x38, 0xba, 0x62, 0x1d, 0xc4, 0xdf, 0x28, 0x1d, 0xfc, 0x0a, 0xc8
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1004
	/* C1 */
	.octa 0x17f0
	/* C4 */
	.octa 0x1210
	/* C11 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0x32007000100080001e001
	/* C30 */
	.octa 0x1300
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1100
	/* C1 */
	.octa 0x17f0
	/* C4 */
	.octa 0x1150
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x1
	/* C11 */
	.octa 0x10f4
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x32007000100080001e001
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1020
initial_SP_EL0_value:
	.octa 0xfffffffffffff410
initial_DDC_EL0_value:
	.octa 0xcc1000000006001700ffffffffe00001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xfffffffffffff410
final_PCC_value:
	.octa 0x20008000200520070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200520070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword 0x0000000000001030
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
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
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x40400028
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
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
