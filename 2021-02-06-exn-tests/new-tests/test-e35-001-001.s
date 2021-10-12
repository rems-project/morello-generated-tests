.section text0, #alloc, #execinstr
test_start:
	.inst 0x92823f9d // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:29 imm16:0001000111111100 hw:00 100101:100101 opc:00 sf:1
	.inst 0xc2ae4bfe // ADD-C.CRI-C Cd:30 Cn:31 imm3:010 option:010 Rm:14 11000010101:11000010101
	.inst 0xe229d2d3 // ASTUR-V.RI-B Rt:19 Rn:22 op2:00 imm9:010011101 V:1 op1:00 11100010:11100010
	.inst 0xc2cf2980 // BICFLGS-C.CR-C Cd:0 Cn:12 1010:1010 opc:00 Rm:15 11000010110:11000010110
	.inst 0xdc9516e0 // ldr_lit_fpsimd:aarch64/instrs/memory/literal/simdfp Rt:0 imm19:1001010100010110111 011100:011100 opc:11
	.zero 11244
	.inst 0x78f652fe // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:23 00:00 opc:101 0:0 Rs:22 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x48fffda0 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:0 Rn:13 11111:11111 o0:1 Rs:31 1:1 L:1 0010001:0010001 size:01
	.inst 0xc85f7c0f // ldxr:aarch64/instrs/memory/exclusive/single Rt:15 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xb8941945 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:5 Rn:10 10:10 imm9:101000001 0:0 opc:10 111000:111000 size:10
	.inst 0xd4000001
	.zero 54252
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
	.inst 0xc240026a // ldr c10, [x19, #0]
	.inst 0xc240066c // ldr c12, [x19, #1]
	.inst 0xc2400a6d // ldr c13, [x19, #2]
	.inst 0xc2400e6e // ldr c14, [x19, #3]
	.inst 0xc240126f // ldr c15, [x19, #4]
	.inst 0xc2401676 // ldr c22, [x19, #5]
	.inst 0xc2401a77 // ldr c23, [x19, #6]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q19, =0x0
	/* Set up flags and system registers */
	ldr x19, =0x4000000
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884113 // msr CSP_EL0, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0x3c0000
	msr CPACR_EL1, x19
	ldr x19, =0x4
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x4
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
	ldr x1, =pcc_return_ddc_capabilities
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0x82601033 // ldr c19, [c1, #1]
	.inst 0x82602021 // ldr c1, [c1, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2c1a401 // chkeq c0, c1
	b.ne comparison_fail
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2c1a4a1 // chkeq c5, c1
	b.ne comparison_fail
	.inst 0xc2400a61 // ldr c1, [x19, #2]
	.inst 0xc2c1a541 // chkeq c10, c1
	b.ne comparison_fail
	.inst 0xc2400e61 // ldr c1, [x19, #3]
	.inst 0xc2c1a581 // chkeq c12, c1
	b.ne comparison_fail
	.inst 0xc2401261 // ldr c1, [x19, #4]
	.inst 0xc2c1a5a1 // chkeq c13, c1
	b.ne comparison_fail
	.inst 0xc2401661 // ldr c1, [x19, #5]
	.inst 0xc2c1a5c1 // chkeq c14, c1
	b.ne comparison_fail
	.inst 0xc2401a61 // ldr c1, [x19, #6]
	.inst 0xc2c1a5e1 // chkeq c15, c1
	b.ne comparison_fail
	.inst 0xc2401e61 // ldr c1, [x19, #7]
	.inst 0xc2c1a6c1 // chkeq c22, c1
	b.ne comparison_fail
	.inst 0xc2402261 // ldr c1, [x19, #8]
	.inst 0xc2c1a6e1 // chkeq c23, c1
	b.ne comparison_fail
	.inst 0xc2402661 // ldr c1, [x19, #9]
	.inst 0xc2c1a7a1 // chkeq c29, c1
	b.ne comparison_fail
	.inst 0xc2402a61 // ldr c1, [x19, #10]
	.inst 0xc2c1a7c1 // chkeq c30, c1
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x1, v19.d[0]
	cmp x19, x1
	b.ne comparison_fail
	ldr x19, =0x0
	mov x1, v19.d[1]
	cmp x19, x1
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984101 // mrs c1, CSP_EL0
	.inst 0xc2c1a661 // chkeq c19, c1
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984021 // mrs c1, CELR_EL1
	.inst 0xc2c1a661 // chkeq c19, c1
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	ldr x1, =0x2000000
	cmp x1, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a5
	ldr x1, =check_data2
	ldr x2, =0x000010a6
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f44
	ldr x1, =check_data3
	ldr x2, =0x00001f48
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
	ldr x0, =0x40402c00
	ldr x1, =check_data5
	ldr x2, =0x40402c14
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
	.zero 4096
.data
check_data0:
	.byte 0x10, 0x10
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x9d, 0x3f, 0x82, 0x92, 0xfe, 0x4b, 0xae, 0xc2, 0xd3, 0xd2, 0x29, 0xe2, 0x80, 0x29, 0xcf, 0xc2
	.byte 0xe0, 0x16, 0x95, 0xdc
.data
check_data5:
	.byte 0xfe, 0x52, 0xf6, 0x78, 0xa0, 0xfd, 0xff, 0x48, 0x0f, 0x7c, 0x5f, 0xc8, 0x45, 0x19, 0x94, 0xb8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C10 */
	.octa 0x2003
	/* C12 */
	.octa 0x800000004000000000001010
	/* C13 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x4000000000000000
	/* C22 */
	.octa 0x1008
	/* C23 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800000000000000000001010
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x2003
	/* C12 */
	.octa 0x800000004000000000001010
	/* C13 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C22 */
	.octa 0x1008
	/* C23 */
	.octa 0x1000
	/* C29 */
	.octa 0xffffffffffffee03
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x800120040000000000000000
initial_DDC_EL0_value:
	.octa 0x40000000600000000000000000000001
initial_DDC_EL1_value:
	.octa 0xc000000000230007000007ef80200001
initial_VBAR_EL1_value:
	.octa 0x200080007000241d0000000040402800
final_SP_EL0_value:
	.octa 0x800120040000000000000000
final_PCC_value:
	.octa 0x200080007000241d0000000040402c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
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
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000010a0
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
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600c33 // ldr x19, [c1, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c33 // str x19, [c1, #0]
	ldr x19, =0x40402c14
	mrs x1, ELR_EL1
	sub x19, x19, x1
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b261 // cvtp c1, x19
	.inst 0xc2d34021 // scvalue c1, c1, x19
	.inst 0x82600033 // ldr c19, [c1, #0]
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
