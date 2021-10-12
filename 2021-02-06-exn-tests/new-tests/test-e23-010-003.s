.section text0, #alloc, #execinstr
test_start:
	.inst 0x38e8829e // swpb:aarch64/instrs/memory/atomicops/swp Rt:30 Rn:20 100000:100000 Rs:8 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x421ffd3d // STLR-C.R-C Ct:29 Rn:9 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x1a95357f // csinc:aarch64/instrs/integer/conditional/select Rd:31 Rn:11 o2:1 0:0 cond:0011 Rm:21 011010100:011010100 op:0 sf:0
	.inst 0xc2c1135d // GCLIM-R.C-C Rd:29 Cn:26 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xa8854ec1 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:1 Rn:22 Rt2:10011 imm7:0001010 L:0 1010001:1010001 opc:10
	.zero 1004
	.inst 0xc2c6b3fd // CLRPERM-C.CI-C Cd:29 Cn:31 100:100 perm:101 1100001011000110:1100001011000110
	.inst 0x1a9d75c1 // csinc:aarch64/instrs/integer/conditional/select Rd:1 Rn:14 o2:1 0:0 cond:0111 Rm:29 011010100:011010100 op:0 sf:0
	.inst 0x7936fc23 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:3 Rn:1 imm12:110110111111 opc:00 111001:111001 size:01
	.inst 0x7970225f // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:18 imm12:110000001000 opc:01 111001:111001 size:01
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c3 // ldr c3, [x6, #0]
	.inst 0xc24004c8 // ldr c8, [x6, #1]
	.inst 0xc24008c9 // ldr c9, [x6, #2]
	.inst 0xc2400cd2 // ldr c18, [x6, #3]
	.inst 0xc24010d4 // ldr c20, [x6, #4]
	.inst 0xc24014d6 // ldr c22, [x6, #5]
	.inst 0xc24018da // ldr c26, [x6, #6]
	.inst 0xc2401cdd // ldr c29, [x6, #7]
	/* Set up flags and system registers */
	ldr x6, =0x34000000
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4106 // msr CSP_EL1, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =initial_DDC_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4126 // msr DDC_EL1, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010a6 // ldr c6, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x5, #0x3
	and x6, x6, x5
	cmp x6, #0x3
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c5 // ldr c5, [x6, #0]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc24004c5 // ldr c5, [x6, #1]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc24008c5 // ldr c5, [x6, #2]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2400cc5 // ldr c5, [x6, #3]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc24010c5 // ldr c5, [x6, #4]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc24014c5 // ldr c5, [x6, #5]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc24018c5 // ldr c5, [x6, #6]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc2401cc5 // ldr c5, [x6, #7]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc24020c5 // ldr c5, [x6, #8]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc24024c5 // ldr c5, [x6, #9]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc29c4105 // mrs c5, CSP_EL1
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x5, 0x80
	orr x6, x6, x5
	ldr x5, =0x920000eb
	cmp x5, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001810
	ldr x1, =check_data1
	ldr x2, =0x00001812
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b80
	ldr x1, =check_data2
	ldr x2, =0x00001b82
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x9e, 0x82, 0xe8, 0x38, 0x3d, 0xfd, 0x1f, 0x42, 0x7f, 0x35, 0x95, 0x1a, 0x5d, 0x13, 0xc1, 0xc2
	.byte 0xc1, 0x4e, 0x85, 0xa8
.data
check_data4:
	.byte 0xfd, 0xb3, 0xc6, 0xc2, 0xc1, 0x75, 0x9d, 0x1a, 0x23, 0xfc, 0x36, 0x79, 0x5f, 0x22, 0x70, 0x79
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x48000000000700070000000000001000
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000403e00640000000000001000
	/* C22 */
	.octa 0x80000000000000
	/* C26 */
	.octa 0x3880700001fffffffff81
	/* C29 */
	.octa 0x4000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x2
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x48000000000700070000000000001000
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000403e00640000000000001000
	/* C22 */
	.octa 0x80000000000000
	/* C26 */
	.octa 0x3880700001fffffffff81
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x1
initial_DDC_EL1_value:
	.octa 0xc00000000003000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x20008000442000360000000040400000
final_SP_EL1_value:
	.octa 0x1
final_PCC_value:
	.octa 0x20008000442000360000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001000
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001b80
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x82600ca6 // ldr x6, [c5, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ca6 // str x6, [c5, #0]
	ldr x6, =0x40400414
	mrs x5, ELR_EL1
	sub x6, x6, x5
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c5 // cvtp c5, x6
	.inst 0xc2c640a5 // scvalue c5, c5, x6
	.inst 0x826000a6 // ldr c6, [c5, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
