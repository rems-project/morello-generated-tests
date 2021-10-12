.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2e01a98 // CVT-C.CR-C Cd:24 Cn:20 0110:0110 0:0 0:0 Rm:0 11000010111:11000010111
	.inst 0x9a8a971f // csinc:aarch64/instrs/integer/conditional/select Rd:31 Rn:24 o2:1 0:0 cond:1001 Rm:10 011010100:011010100 op:0 sf:1
	.inst 0x78bf521b // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:27 Rn:16 00:00 opc:101 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x489f7fa0 // stllrh:aarch64/instrs/memory/ordered Rt:0 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe22fd419 // ALDUR-V.RI-B Rt:25 Rn:0 op2:01 imm9:011111101 V:1 op1:00 11100010:11100010
	.zero 19436
	.inst 0x62fc68c3 // 0x62fc68c3
	.inst 0x82fef3d9 // 0x82fef3d9
	.inst 0x381090cf // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:15 Rn:6 00:00 imm9:100001001 0:0 opc:00 111000:111000 size:00
	.inst 0xc22f3015 // STR-C.RIB-C Ct:21 Rn:0 imm12:101111001100 L:0 110000100:110000100
	.inst 0xd4000001
	.zero 46060
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
	ldr x1, =initial_cap_values
	.inst 0xc2400020 // ldr c0, [x1, #0]
	.inst 0xc2400426 // ldr c6, [x1, #1]
	.inst 0xc240082f // ldr c15, [x1, #2]
	.inst 0xc2400c30 // ldr c16, [x1, #3]
	.inst 0xc2401034 // ldr c20, [x1, #4]
	.inst 0xc2401435 // ldr c21, [x1, #5]
	.inst 0xc240183d // ldr c29, [x1, #6]
	.inst 0xc2401c3e // ldr c30, [x1, #7]
	/* Set up flags and system registers */
	ldr x1, =0x0
	msr SPSR_EL3, x1
	ldr x1, =0x200
	msr CPTR_EL3, x1
	ldr x1, =0x30d5d99f
	msr SCTLR_EL1, x1
	ldr x1, =0x3c0000
	msr CPACR_EL1, x1
	ldr x1, =0x4
	msr S3_0_C1_C2_2, x1 // CCTLR_EL1
	ldr x1, =0x0
	msr S3_3_C1_C2_2, x1 // CCTLR_EL0
	ldr x1, =initial_DDC_EL0_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc2884121 // msr DDC_EL0, c1
	ldr x1, =initial_DDC_EL1_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc28c4121 // msr DDC_EL1, c1
	ldr x1, =0x80000000
	msr HCR_EL2, x1
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011c1 // ldr c1, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e4021 // msr CELR_EL3, c1
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr DDC_EL3, c1
	ldr x1, =0x30851035
	msr SCTLR_EL3, x1
	isb
	/* Check processor flags */
	mrs x1, nzcv
	ubfx x1, x1, #28, #4
	mov x14, #0x2
	and x1, x1, x14
	cmp x1, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x1, =final_cap_values
	.inst 0xc240002e // ldr c14, [x1, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240042e // ldr c14, [x1, #1]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc240082e // ldr c14, [x1, #2]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc2400c2e // ldr c14, [x1, #3]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc240102e // ldr c14, [x1, #4]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc240142e // ldr c14, [x1, #5]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc240182e // ldr c14, [x1, #6]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc2401c2e // ldr c14, [x1, #7]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc240202e // ldr c14, [x1, #8]
	.inst 0xc2cea721 // chkeq c25, c14
	b.ne comparison_fail
	.inst 0xc240242e // ldr c14, [x1, #9]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc240282e // ldr c14, [x1, #10]
	.inst 0xc2cea761 // chkeq c27, c14
	b.ne comparison_fail
	.inst 0xc2402c2e // ldr c14, [x1, #11]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc240302e // ldr c14, [x1, #12]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check system registers */
	ldr x1, =final_PCC_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	ldr x14, =esr_el1_dump_address
	ldr x14, [x14]
	mov x1, 0x83
	orr x14, x14, x1
	ldr x1, =0x920000ab
	cmp x1, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001006
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001104
	ldr x1, =check_data1
	ldr x2, =0x00001106
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001289
	ldr x1, =check_data2
	ldr x2, =0x0000128a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001380
	ldr x1, =check_data3
	ldr x2, =0x000013a0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fd0
	ldr x1, =check_data4
	ldr x2, =0x00001fe0
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
	ldr x0, =0x40404c00
	ldr x1, =check_data6
	ldr x2, =0x40404c14
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x1, =0x30850030
	msr SCTLR_EL3, x1
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr DDC_EL3, c1
	ldr x1, =0x30850030
	msr SCTLR_EL3, x1
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
	.zero 256
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x10, 0x63
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0x98, 0x1a, 0xe0, 0xc2, 0x1f, 0x97, 0x8a, 0x9a, 0x1b, 0x52, 0xbf, 0x78, 0xa0, 0x7f, 0x9f, 0x48
	.byte 0x19, 0xd4, 0x2f, 0xe2
.data
check_data6:
	.byte 0xc3, 0x68, 0xfc, 0x62, 0xd9, 0xf3, 0xfe, 0x82, 0xcf, 0x90, 0x10, 0x38, 0x15, 0x30, 0x2f, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4c00000000040007ffffffffffff6310
	/* C6 */
	.octa 0xc00000005801008a0000000000001400
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x1104
	/* C20 */
	.octa 0x20003008700ffe00002090001
	/* C21 */
	.octa 0x200000000000000
	/* C29 */
	.octa 0x1004
	/* C30 */
	.octa 0x666666666666671c
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x4c00000000040007ffffffffffff6310
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0xc00000005801008a0000000000001380
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x1104
	/* C20 */
	.octa 0x20003008700ffe00002090001
	/* C21 */
	.octa 0x200000000000000
	/* C24 */
	.octa 0x200030087ffffffffffff6310
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x100
	/* C29 */
	.octa 0x1004
	/* C30 */
	.octa 0x666666666666671c
initial_DDC_EL0_value:
	.octa 0xc0000000410310010000000000000001
initial_DDC_EL1_value:
	.octa 0x8000000040010c7400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080005000441d0000000040404801
final_PCC_value:
	.octa 0x200080005000441d0000000040404c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000e00070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 96
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
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x02000021 // add c1, c1, #0
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x02020021 // add c1, c1, #128
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x02040021 // add c1, c1, #256
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x02060021 // add c1, c1, #384
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x02080021 // add c1, c1, #512
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x020a0021 // add c1, c1, #640
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x020c0021 // add c1, c1, #768
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x020e0021 // add c1, c1, #896
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x02100021 // add c1, c1, #1024
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x02120021 // add c1, c1, #1152
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x02140021 // add c1, c1, #1280
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x02160021 // add c1, c1, #1408
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x02180021 // add c1, c1, #1536
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x021a0021 // add c1, c1, #1664
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x021c0021 // add c1, c1, #1792
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x82600dc1 // ldr x1, [c14, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400dc1 // str x1, [c14, #0]
	ldr x1, =0x40404c14
	mrs x14, ELR_EL1
	sub x1, x1, x14
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b02e // cvtp c14, x1
	.inst 0xc2c141ce // scvalue c14, c14, x1
	.inst 0x826001c1 // ldr c1, [c14, #0]
	.inst 0x021e0021 // add c1, c1, #1920
	.inst 0xc2c21020 // br c1

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
