.section text0, #alloc, #execinstr
test_start:
	.inst 0x08df7fd4 // ldlarb:aarch64/instrs/memory/ordered Rt:20 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xb87b835a // swp:aarch64/instrs/memory/atomicops/swp Rt:26 Rn:26 100000:100000 Rs:27 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x826e50b4 // ALDR-C.RI-C Ct:20 Rn:5 op:00 imm9:011100101 L:1 1000001001:1000001001
	.inst 0x7818c3df // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:30 00:00 imm9:110001100 0:0 opc:00 111000:111000 size:01
	.inst 0x423f7fac // ASTLRB-R.R-B Rt:12 Rn:29 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.zero 1004
	.inst 0xf82010df // 0xf82010df
	.inst 0x5a9fc57d // 0x5a9fc57d
	.inst 0xc2e89b1f // 0xc2e89b1f
	.inst 0x38530c5f // 0x38530c5f
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a65 // ldr c5, [x19, #2]
	.inst 0xc2400e66 // ldr c6, [x19, #3]
	.inst 0xc2401268 // ldr c8, [x19, #4]
	.inst 0xc2401678 // ldr c24, [x19, #5]
	.inst 0xc2401a7a // ldr c26, [x19, #6]
	.inst 0xc2401e7b // ldr c27, [x19, #7]
	.inst 0xc240227d // ldr c29, [x19, #8]
	.inst 0xc240267e // ldr c30, [x19, #9]
	/* Set up flags and system registers */
	ldr x19, =0x80000000
	msr SPSR_EL3, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
	msr CPACR_EL1, x19
	ldr x19, =0x4
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x0
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =initial_DDC_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4133 // msr DDC_EL1, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012d3 // ldr c19, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x22, #0xf
	and x19, x19, x22
	cmp x19, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400276 // ldr c22, [x19, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400676 // ldr c22, [x19, #1]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400a76 // ldr c22, [x19, #2]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2400e76 // ldr c22, [x19, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401276 // ldr c22, [x19, #4]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2401676 // ldr c22, [x19, #5]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2401a76 // ldr c22, [x19, #6]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2401e76 // ldr c22, [x19, #7]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2402276 // ldr c22, [x19, #8]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2402676 // ldr c22, [x19, #9]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402a76 // ldr c22, [x19, #10]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	ldr x22, =esr_el1_dump_address
	ldr x22, [x22]
	mov x19, 0x83
	orr x22, x22, x19
	ldr x19, =0x920000eb
	cmp x19, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001006
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001044
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001078
	ldr x1, =check_data3
	ldr x2, =0x00001079
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e60
	ldr x1, =check_data4
	ldr x2, =0x00001e70
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f3f
	ldr x1, =check_data5
	ldr x2, =0x00001f40
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
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x7b, 0xf6, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xff, 0x80, 0x7b, 0xf6, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0xff, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xd4, 0x7f, 0xdf, 0x08, 0x5a, 0x83, 0x7b, 0xb8, 0xb4, 0x50, 0x6e, 0x82, 0xdf, 0xc3, 0x18, 0x78
	.byte 0xac, 0x7f, 0x3f, 0x42
.data
check_data7:
	.byte 0xdf, 0x10, 0x20, 0xf8, 0x7d, 0xc5, 0x9f, 0x5a, 0x1f, 0x9b, 0xe8, 0xc2, 0x5f, 0x0c, 0x53, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xff00007f00
	/* C2 */
	.octa 0x200f
	/* C5 */
	.octa 0x80100000000080200000000000001010
	/* C6 */
	.octa 0x1018
	/* C8 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x1040
	/* C27 */
	.octa 0xff00
	/* C29 */
	.octa 0x800000000000000000000000
	/* C30 */
	.octa 0x1078
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xff00007f00
	/* C2 */
	.octa 0x1f3f
	/* C5 */
	.octa 0x80100000000080200000000000001010
	/* C6 */
	.octa 0x1018
	/* C8 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0xff00
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1078
initial_DDC_EL0_value:
	.octa 0xc00000000017100700ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xc0000000000900050000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080005200021d0000000040400000
final_PCC_value:
	.octa 0x200080005200021d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000060100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 64
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x40400414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
