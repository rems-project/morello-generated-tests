.section text0, #alloc, #execinstr
test_start:
	.inst 0x389c11dd // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:14 00:00 imm9:111000001 0:0 opc:10 111000:111000 size:00
	.inst 0x089ffffa // stlrb:aarch64/instrs/memory/ordered Rt:26 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xf8fe61b2 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:13 00:00 opc:110 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:11
	.inst 0xc2b9438c // ADD-C.CRI-C Cd:12 Cn:28 imm3:000 option:010 Rm:25 11000010101:11000010101
	.inst 0xc2c4903f // STCT-R.R-_ Rt:31 Rn:1 100:100 opc:00 11000010110001001:11000010110001001
	.zero 39916
	.inst 0xc8dffc1b // ldar:aarch64/instrs/memory/ordered Rt:27 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x2c7164e4 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:4 Rn:7 Rt2:11001 imm7:1100010 L:1 1011000:1011000 opc:00
	.inst 0x3879613f // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:9 00:00 opc:110 o3:0 Rs:25 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xdac00ba0 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:29 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xd4000001
	.zero 25580
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400707 // ldr c7, [x24, #1]
	.inst 0xc2400b09 // ldr c9, [x24, #2]
	.inst 0xc2400f0d // ldr c13, [x24, #3]
	.inst 0xc240130e // ldr c14, [x24, #4]
	.inst 0xc2401719 // ldr c25, [x24, #5]
	.inst 0xc2401b1a // ldr c26, [x24, #6]
	.inst 0xc2401f1c // ldr c28, [x24, #7]
	.inst 0xc240231e // ldr c30, [x24, #8]
	/* Set up flags and system registers */
	ldr x24, =0x0
	msr SPSR_EL3, x24
	ldr x24, =initial_SP_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884118 // msr CSP_EL0, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0x3c0000
	msr CPACR_EL1, x24
	ldr x24, =0x4
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x4
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =initial_DDC_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28c4138 // msr DDC_EL1, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82601298 // ldr c24, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400314 // ldr c20, [x24, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400714 // ldr c20, [x24, #1]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2400b14 // ldr c20, [x24, #2]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2400f14 // ldr c20, [x24, #3]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2401314 // ldr c20, [x24, #4]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2401714 // ldr c20, [x24, #5]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401b14 // ldr c20, [x24, #6]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2401f14 // ldr c20, [x24, #7]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc2402314 // ldr c20, [x24, #8]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc2402714 // ldr c20, [x24, #9]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc2402b14 // ldr c20, [x24, #10]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2402f14 // ldr c20, [x24, #11]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2403314 // ldr c20, [x24, #12]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x20, v4.d[0]
	cmp x24, x20
	b.ne comparison_fail
	ldr x24, =0x0
	mov x20, v4.d[1]
	cmp x24, x20
	b.ne comparison_fail
	ldr x24, =0x0
	mov x20, v25.d[0]
	cmp x24, x20
	b.ne comparison_fail
	ldr x24, =0x0
	mov x20, v25.d[1]
	cmp x24, x20
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_SP_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984114 // mrs c20, CSP_EL0
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	ldr x20, =esr_el1_dump_address
	ldr x20, [x20]
	mov x24, 0x0
	orr x20, x20, x24
	ldr x24, =0x2000000
	cmp x24, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001001
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011e0
	ldr x1, =check_data1
	ldr x2, =0x000011e8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001801
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e70
	ldr x1, =check_data3
	ldr x2, =0x00001e78
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f8c
	ldr x1, =check_data4
	ldr x2, =0x00001f94
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fc2
	ldr x1, =check_data5
	ldr x2, =0x00001fc3
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40409c00
	ldr x1, =check_data7
	ldr x2, =0x40409c14
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.zero 480
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1552
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x80
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xdd, 0x11, 0x9c, 0x38, 0xfa, 0xff, 0x9f, 0x08, 0xb2, 0x61, 0xfe, 0xf8, 0x8c, 0x43, 0xb9, 0xc2
	.byte 0x3f, 0x90, 0xc4, 0xc2
.data
check_data7:
	.byte 0x1b, 0xfc, 0xdf, 0xc8, 0xe4, 0x64, 0x71, 0x2c, 0x3f, 0x61, 0x79, 0x38, 0xa0, 0x0b, 0xc0, 0xda
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1e70
	/* C7 */
	.octa 0x2004
	/* C9 */
	.octa 0x1800
	/* C13 */
	.octa 0x11df
	/* C14 */
	.octa 0x2000
	/* C25 */
	.octa 0x40000080
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x700070000000000004400
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C7 */
	.octa 0x2004
	/* C9 */
	.octa 0x1800
	/* C12 */
	.octa 0x700070000000040004480
	/* C13 */
	.octa 0x11df
	/* C14 */
	.octa 0x2000
	/* C18 */
	.octa 0x1
	/* C25 */
	.octa 0x40000080
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x700070000000000004400
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc0000000400000010000000000000001
initial_DDC_EL1_value:
	.octa 0xc00000000007000700ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080005e00861d0000000040409800
final_SP_EL0_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080005e00861d0000000040409c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300030000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600e98 // ldr x24, [c20, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e98 // str x24, [c20, #0]
	ldr x24, =0x40409c14
	mrs x20, ELR_EL1
	sub x24, x24, x20
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b314 // cvtp c20, x24
	.inst 0xc2d84294 // scvalue c20, c20, x24
	.inst 0x82600298 // ldr c24, [c20, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
