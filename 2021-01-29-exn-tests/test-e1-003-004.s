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
	.inst 0xc2c273e0 // 0xc2c273e0
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b64 // ldr c4, [x27, #2]
	.inst 0xc2400f6b // ldr c11, [x27, #3]
	.inst 0xc240136e // ldr c14, [x27, #4]
	.inst 0xc2401774 // ldr c20, [x27, #5]
	.inst 0xc2401b7e // ldr c30, [x27, #6]
	/* Set up flags and system registers */
	ldr x27, =0x0
	msr SPSR_EL3, x27
	ldr x27, =initial_SP_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288411b // msr CSP_EL0, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30d5d99f
	msr SCTLR_EL1, x27
	ldr x27, =0xc0000
	msr CPACR_EL1, x27
	ldr x27, =0x0
	msr S3_0_C1_C2_2, x27 // CCTLR_EL1
	ldr x27, =0x0
	msr S3_3_C1_C2_2, x27 // CCTLR_EL0
	ldr x27, =initial_DDC_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288413b // msr DDC_EL0, c27
	ldr x27, =0x80000000
	msr HCR_EL2, x27
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010fb // ldr c27, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e403b // msr CELR_EL3, c27
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400367 // ldr c7, [x27, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400767 // ldr c7, [x27, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400b67 // ldr c7, [x27, #2]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400f67 // ldr c7, [x27, #3]
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	.inst 0xc2401367 // ldr c7, [x27, #4]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401767 // ldr c7, [x27, #5]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401b67 // ldr c7, [x27, #6]
	.inst 0xc2c7a621 // chkeq c17, c7
	b.ne comparison_fail
	.inst 0xc2401f67 // ldr c7, [x27, #7]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2402367 // ldr c7, [x27, #8]
	.inst 0xc2c7a6a1 // chkeq c21, c7
	b.ne comparison_fail
	.inst 0xc2402767 // ldr c7, [x27, #9]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2402b67 // ldr c7, [x27, #10]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402f67 // ldr c7, [x27, #11]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_SP_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984107 // mrs c7, CSP_EL0
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	ldr x7, =esr_el1_dump_address
	ldr x7, [x7]
	mov x27, 0x83
	orr x7, x7, x27
	ldr x27, =0x920000ab
	cmp x27, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001108
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001710
	ldr x1, =check_data2
	ldr x2, =0x00001720
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f40
	ldr x1, =check_data3
	ldr x2, =0x00001f60
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
	ldr x0, =0x40400184
	ldr x1, =check_data5
	ldr x2, =0x40400188
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
	ldr x0, =0x40405008
	ldr x1, =check_data7
	ldr x2, =0x4040500c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
	.zero 8
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0x9d, 0xda, 0xdc, 0xc2, 0x39, 0x18, 0x47, 0xa2, 0x75, 0x45, 0x4f, 0xb8, 0xfd, 0x87, 0xa3, 0xb9
	.byte 0xcd, 0x27, 0xe9, 0x62
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x9f, 0x38, 0xba, 0x62, 0x1d, 0xc4, 0xdf, 0x28, 0x1d, 0xfc, 0x0a, 0xc8, 0xe0, 0x73, 0xc2, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000580202010000000000001004
	/* C1 */
	.octa 0x1000
	/* C4 */
	.octa 0x4c000000000700070000000000002000
	/* C11 */
	.octa 0x40405008
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0x40010004000000800000e001
	/* C30 */
	.octa 0xca01ffdfff7e2fe1
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000580202010000000000001100
	/* C1 */
	.octa 0x1000
	/* C4 */
	.octa 0x4c000000000700070000000000001f40
	/* C10 */
	.octa 0x1
	/* C11 */
	.octa 0x404050fc
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x40010004000000800000e001
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xca01ffdfff7e2fe1
initial_SP_EL0_value:
	.octa 0x403fde00
initial_DDC_EL0_value:
	.octa 0x801000000003000700ffe0000000e001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400001
final_SP_EL0_value:
	.octa 0x403fde00
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000006500070000000040400000
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
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x0200037b // add c27, c27, #0
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x0202037b // add c27, c27, #128
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x0204037b // add c27, c27, #256
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x0206037b // add c27, c27, #384
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x0208037b // add c27, c27, #512
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x020a037b // add c27, c27, #640
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x020c037b // add c27, c27, #768
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x020e037b // add c27, c27, #896
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x0210037b // add c27, c27, #1024
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x0212037b // add c27, c27, #1152
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x0214037b // add c27, c27, #1280
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x0216037b // add c27, c27, #1408
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x0218037b // add c27, c27, #1536
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x021a037b // add c27, c27, #1664
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x021c037b // add c27, c27, #1792
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x82600cfb // ldr x27, [c7, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400cfb // str x27, [c7, #0]
	ldr x27, =0x40400414
	mrs x7, ELR_EL1
	sub x27, x27, x7
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b367 // cvtp c7, x27
	.inst 0xc2db40e7 // scvalue c7, c7, x27
	.inst 0x826000fb // ldr c27, [c7, #0]
	.inst 0x021e037b // add c27, c27, #1920
	.inst 0xc2c21360 // br c27

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
