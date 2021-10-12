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
	ldr x28, =initial_cap_values
	.inst 0xc2400383 // ldr c3, [x28, #0]
	.inst 0xc2400788 // ldr c8, [x28, #1]
	.inst 0xc2400b89 // ldr c9, [x28, #2]
	.inst 0xc2400f8e // ldr c14, [x28, #3]
	.inst 0xc2401392 // ldr c18, [x28, #4]
	.inst 0xc2401794 // ldr c20, [x28, #5]
	.inst 0xc2401b96 // ldr c22, [x28, #6]
	.inst 0xc2401f9a // ldr c26, [x28, #7]
	.inst 0xc240239d // ldr c29, [x28, #8]
	/* Set up flags and system registers */
	ldr x28, =0x24000000
	msr SPSR_EL3, x28
	ldr x28, =initial_SP_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28c411c // msr CSP_EL1, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0xc0000
	msr CPACR_EL1, x28
	ldr x28, =0x0
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =initial_DDC_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28c413c // msr DDC_EL1, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011fc // ldr c28, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e403c // msr CELR_EL3, c28
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x15, #0x3
	and x28, x28, x15
	cmp x28, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038f // ldr c15, [x28, #0]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240078f // ldr c15, [x28, #1]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc2400b8f // ldr c15, [x28, #2]
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	.inst 0xc2400f8f // ldr c15, [x28, #3]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc240138f // ldr c15, [x28, #4]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc240178f // ldr c15, [x28, #5]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc2401b8f // ldr c15, [x28, #6]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc2401f8f // ldr c15, [x28, #7]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc240238f // ldr c15, [x28, #8]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc240278f // ldr c15, [x28, #9]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2402b8f // ldr c15, [x28, #10]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_SP_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc29c410f // mrs c15, CSP_EL1
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	ldr x28, =esr_el1_dump_address
	ldr x28, [x28]
	mov x15, 0x80
	orr x28, x28, x15
	ldr x15, =0x920000e8
	cmp x15, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001410
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001810
	ldr x1, =check_data2
	ldr x2, =0x00001812
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001bae
	ldr x1, =check_data3
	ldr x2, =0x00001bb0
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
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x9e, 0x82, 0xe8, 0x38, 0x3d, 0xfd, 0x1f, 0x42, 0x7f, 0x35, 0x95, 0x1a, 0x5d, 0x13, 0xc1, 0xc2
	.byte 0xc1, 0x4e, 0x85, 0xa8
.data
check_data5:
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
	.octa 0x4800000040040c890000000000001400
	/* C14 */
	.octa 0x30
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0xc000000050010ffc0000000000001000
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x402c0230080000000000000
	/* C29 */
	.octa 0x4000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x30
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x4800000040040c890000000000001400
	/* C14 */
	.octa 0x30
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0xc000000050010ffc0000000000001000
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x402c0230080000000000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0xc00000000017000f0000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005200001c0000000040400000
final_SP_EL1_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080005200001c0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001400
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001ba0
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x82600dfc // ldr x28, [c15, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400dfc // str x28, [c15, #0]
	ldr x28, =0x40400414
	mrs x15, ELR_EL1
	sub x28, x28, x15
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38f // cvtp c15, x28
	.inst 0xc2dc41ef // scvalue c15, c15, x28
	.inst 0x826001fc // ldr c28, [c15, #0]
	.inst 0x021e039c // add c28, c28, #1920
	.inst 0xc2c21380 // br c28

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
