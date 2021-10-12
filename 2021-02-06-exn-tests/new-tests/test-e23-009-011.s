.section text0, #alloc, #execinstr
test_start:
	.inst 0x694e3fde // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:30 Rn:30 Rt2:01111 imm7:0011100 L:1 1010010:1010010 opc:01
	.inst 0x885ffffe // ldaxr:aarch64/instrs/memory/exclusive/single Rt:30 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0x08b3fc1b // casb:aarch64/instrs/memory/atomicops/cas/single Rt:27 Rn:0 11111:11111 o0:1 Rs:19 1:1 L:0 0010001:0010001 size:00
	.inst 0xc8df7cf1 // ldlar:aarch64/instrs/memory/ordered Rt:17 Rn:7 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xb82c53bd // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:29 00:00 opc:101 0:0 Rs:12 1:1 R:0 A:0 111000:111000 size:10
	.zero 21484
	.inst 0xc2c213e1 // CHKSLD-C-C 00001:00001 Cn:31 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x787e503f // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:1 00:00 opc:101 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc8fdffbd // cas:aarch64/instrs/memory/atomicops/cas/single Rt:29 Rn:29 11111:11111 o0:1 Rs:29 1:1 L:1 0010001:0010001 size:11
	.inst 0x36080f3e // tbz:aarch64/instrs/branch/conditional/test Rt:30 imm14:00000001111001 b40:00001 op:0 011011:011011 b5:0
	.inst 0xd4000001
	.zero 44012
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a7 // ldr c7, [x5, #2]
	.inst 0xc2400cb3 // ldr c19, [x5, #3]
	.inst 0xc24010bb // ldr c27, [x5, #4]
	.inst 0xc24014bd // ldr c29, [x5, #5]
	.inst 0xc24018be // ldr c30, [x5, #6]
	/* Set up flags and system registers */
	ldr x5, =0x4000000
	msr SPSR_EL3, x5
	ldr x5, =initial_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884105 // msr CSP_EL0, c5
	ldr x5, =initial_SP_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4105 // msr CSP_EL1, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0xc0000
	msr CPACR_EL1, x5
	ldr x5, =0x0
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =initial_DDC_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4125 // msr DDC_EL1, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012e5 // ldr c5, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x23, #0xf
	and x5, x5, x23
	cmp x5, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b7 // ldr c23, [x5, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24004b7 // ldr c23, [x5, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24008b7 // ldr c23, [x5, #2]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2400cb7 // ldr c23, [x5, #3]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc24010b7 // ldr c23, [x5, #4]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc24014b7 // ldr c23, [x5, #5]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc24018b7 // ldr c23, [x5, #6]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2401cb7 // ldr c23, [x5, #7]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc24020b7 // ldr c23, [x5, #8]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	ldr x5, =final_SP_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc29c4117 // mrs c23, CSP_EL1
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x23, 0xc1
	orr x5, x5, x23
	ldr x23, =0x920000eb
	cmp x23, x5
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
	ldr x0, =0x000010f0
	ldr x1, =check_data1
	ldr x2, =0x000010f8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017f0
	ldr x1, =check_data2
	ldr x2, =0x000017f4
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
	ldr x0, =0x40405400
	ldr x1, =check_data5
	ldr x2, =0x40405414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040fff0
	ldr x1, =check_data6
	ldr x2, =0x4040fff8
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
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2016
	.byte 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2048
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x02, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xde, 0x3f, 0x4e, 0x69, 0xfe, 0xff, 0x5f, 0x88, 0x1b, 0xfc, 0xb3, 0x08, 0xf1, 0x7c, 0xdf, 0xc8
	.byte 0xbd, 0x53, 0x2c, 0xb8
.data
check_data5:
	.byte 0xe1, 0x13, 0xc2, 0xc2, 0x3f, 0x50, 0x7e, 0x78, 0xbd, 0xff, 0xfd, 0xc8, 0x3e, 0x0f, 0x08, 0x36
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ffe
	/* C1 */
	.octa 0x1000
	/* C7 */
	.octa 0x8000000000010005000000004040fff0
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000604120120000000000001000
	/* C30 */
	.octa 0x80000000000100050000000000001080
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ffe
	/* C1 */
	.octa 0x1000
	/* C7 */
	.octa 0x8000000000010005000000004040fff0
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x4002
initial_SP_EL0_value:
	.octa 0x800000000001000500000000000017f0
initial_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
initial_DDC_EL1_value:
	.octa 0xc0000000000500070000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000441d0000000040405000
final_SP_EL0_value:
	.octa 0x800000000001000500000000000017f0
final_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x200080004000441d0000000040405414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700030000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001ff0
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40405414
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
