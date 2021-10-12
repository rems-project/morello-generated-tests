.section text0, #alloc, #execinstr
test_start:
	.inst 0xc85ffdf2 // ldaxr:aarch64/instrs/memory/exclusive/single Rt:18 Rn:15 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xa224823d // SWP-CC.R-C Ct:29 Rn:17 100000:100000 Cs:4 1:1 R:0 A:0 10100010:10100010
	.inst 0xb81ea061 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:3 00:00 imm9:111101010 0:0 opc:00 111000:111000 size:10
	.inst 0xf89ce030 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:1 00:00 imm9:111001110 0:0 opc:10 111000:111000 size:11
	.inst 0x421fff21 // STLR-C.R-C Ct:1 Rn:25 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.zero 1004
	.inst 0x1ac42fa6 // 0x1ac42fa6
	.inst 0xbc02cf77 // 0xbc02cf77
	.inst 0x78484e1c // 0x78484e1c
	.inst 0x387d827d // swpb:aarch64/instrs/memory/atomicops/swp Rt:29 Rn:19 100000:100000 Rs:29 1:1 R:1 A:0 111000:111000 size:00
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c3 // ldr c3, [x14, #1]
	.inst 0xc24009c4 // ldr c4, [x14, #2]
	.inst 0xc2400dcf // ldr c15, [x14, #3]
	.inst 0xc24011d0 // ldr c16, [x14, #4]
	.inst 0xc24015d1 // ldr c17, [x14, #5]
	.inst 0xc24019d3 // ldr c19, [x14, #6]
	.inst 0xc2401dd9 // ldr c25, [x14, #7]
	.inst 0xc24021db // ldr c27, [x14, #8]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q23, =0x0
	/* Set up flags and system registers */
	ldr x14, =0x0
	msr SPSR_EL3, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0x1c0000
	msr CPACR_EL1, x14
	ldr x14, =0x4
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x4
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =initial_DDC_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc28c412e // msr DDC_EL1, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012ae // ldr c14, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d5 // ldr c21, [x14, #0]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24005d5 // ldr c21, [x14, #1]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc24009d5 // ldr c21, [x14, #2]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc2400dd5 // ldr c21, [x14, #3]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc24011d5 // ldr c21, [x14, #4]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc24015d5 // ldr c21, [x14, #5]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc24019d5 // ldr c21, [x14, #6]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2401dd5 // ldr c21, [x14, #7]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc24021d5 // ldr c21, [x14, #8]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc24025d5 // ldr c21, [x14, #9]
	.inst 0xc2d5a721 // chkeq c25, c21
	b.ne comparison_fail
	.inst 0xc24029d5 // ldr c21, [x14, #10]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2402dd5 // ldr c21, [x14, #11]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc24031d5 // ldr c21, [x14, #12]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x21, v23.d[0]
	cmp x14, x21
	b.ne comparison_fail
	ldr x14, =0x0
	mov x21, v23.d[1]
	cmp x14, x21
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	ldr x21, =esr_el1_dump_address
	ldr x21, [x21]
	mov x14, 0x83
	orr x21, x21, x14
	ldr x14, =0x920000eb
	cmp x14, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001034
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f8
	ldr x1, =check_data2
	ldr x2, =0x000010fa
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001304
	ldr x1, =check_data3
	ldr x2, =0x00001305
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001340
	ldr x1, =check_data4
	ldr x2, =0x00001350
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff0
	ldr x1, =check_data5
	ldr x2, =0x00001ff4
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
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x40400414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
	.zero 832
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 3248
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb9
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0xf2, 0xfd, 0x5f, 0xc8, 0x3d, 0x82, 0x24, 0xa2, 0x61, 0xa0, 0x1e, 0xb8, 0x30, 0xe0, 0x9c, 0xf8
	.byte 0x21, 0xff, 0x1f, 0x42
.data
check_data7:
	.byte 0xa6, 0x2f, 0xc4, 0x1a, 0x77, 0xcf, 0x02, 0xbc, 0x1c, 0x4e, 0x48, 0x78, 0x7d, 0x82, 0x7d, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x2006
	/* C4 */
	.octa 0xb9000000000000000000000000000000
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0x1074
	/* C17 */
	.octa 0x1340
	/* C19 */
	.octa 0x1304
	/* C25 */
	.octa 0xff7fffffffffffd5
	/* C27 */
	.octa 0x1004
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x2006
	/* C4 */
	.octa 0xb9000000000000000000000000000000
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0x10f8
	/* C17 */
	.octa 0x1340
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x1304
	/* C25 */
	.octa 0xff7fffffffffffd5
	/* C27 */
	.octa 0x1030
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xdc0000000009400500bb8003fff1e000
initial_DDC_EL1_value:
	.octa 0xc00000000000c0000000000000000000
initial_VBAR_EL1_value:
	.octa 0x20008000510004000000000040400000
final_PCC_value:
	.octa 0x20008000510004000000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000e0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001340
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400414
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
