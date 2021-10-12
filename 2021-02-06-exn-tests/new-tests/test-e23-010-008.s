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
	ldr x24, =initial_cap_values
	.inst 0xc2400303 // ldr c3, [x24, #0]
	.inst 0xc2400708 // ldr c8, [x24, #1]
	.inst 0xc2400b09 // ldr c9, [x24, #2]
	.inst 0xc2400f0e // ldr c14, [x24, #3]
	.inst 0xc2401312 // ldr c18, [x24, #4]
	.inst 0xc2401714 // ldr c20, [x24, #5]
	.inst 0xc2401b16 // ldr c22, [x24, #6]
	.inst 0xc2401f1a // ldr c26, [x24, #7]
	.inst 0xc240231d // ldr c29, [x24, #8]
	/* Set up flags and system registers */
	ldr x24, =0x24000000
	msr SPSR_EL3, x24
	ldr x24, =initial_SP_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28c4118 // msr CSP_EL1, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0xc0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =initial_DDC_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28c4138 // msr DDC_EL1, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x0, =pcc_return_ddc_capabilities
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0x82601018 // ldr c24, [c0, #1]
	.inst 0x82602000 // ldr c0, [c0, #2]
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
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x0, #0x3
	and x24, x24, x0
	cmp x24, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2c0a421 // chkeq c1, c0
	b.ne comparison_fail
	.inst 0xc2400700 // ldr c0, [x24, #1]
	.inst 0xc2c0a461 // chkeq c3, c0
	b.ne comparison_fail
	.inst 0xc2400b00 // ldr c0, [x24, #2]
	.inst 0xc2c0a501 // chkeq c8, c0
	b.ne comparison_fail
	.inst 0xc2400f00 // ldr c0, [x24, #3]
	.inst 0xc2c0a521 // chkeq c9, c0
	b.ne comparison_fail
	.inst 0xc2401300 // ldr c0, [x24, #4]
	.inst 0xc2c0a5c1 // chkeq c14, c0
	b.ne comparison_fail
	.inst 0xc2401700 // ldr c0, [x24, #5]
	.inst 0xc2c0a641 // chkeq c18, c0
	b.ne comparison_fail
	.inst 0xc2401b00 // ldr c0, [x24, #6]
	.inst 0xc2c0a681 // chkeq c20, c0
	b.ne comparison_fail
	.inst 0xc2401f00 // ldr c0, [x24, #7]
	.inst 0xc2c0a6c1 // chkeq c22, c0
	b.ne comparison_fail
	.inst 0xc2402300 // ldr c0, [x24, #8]
	.inst 0xc2c0a741 // chkeq c26, c0
	b.ne comparison_fail
	.inst 0xc2402700 // ldr c0, [x24, #9]
	.inst 0xc2c0a7a1 // chkeq c29, c0
	b.ne comparison_fail
	.inst 0xc2402b00 // ldr c0, [x24, #10]
	.inst 0xc2c0a7c1 // chkeq c30, c0
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_SP_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc29c4100 // mrs c0, CSP_EL1
	.inst 0xc2c0a701 // chkeq c24, c0
	b.ne comparison_fail
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984020 // mrs c0, CELR_EL1
	.inst 0xc2c0a701 // chkeq c24, c0
	b.ne comparison_fail
	ldr x24, =esr_el1_dump_address
	ldr x24, [x24]
	mov x0, 0x80
	orr x24, x24, x0
	ldr x0, =0x920000e9
	cmp x0, x24
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
	ldr x0, =0x00001600
	ldr x1, =check_data1
	ldr x2, =0x00001610
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
	ldr x0, =0x00001c06
	ldr x1, =check_data3
	ldr x2, =0x00001c08
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
	.octa 0x48000000000100070000000000001600
	/* C14 */
	.octa 0x88
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000580000010000000000001000
	/* C22 */
	.octa 0x20000000000000000000000000
	/* C26 */
	.octa 0x380470000000000000003
	/* C29 */
	.octa 0x4000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x88
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x48000000000100070000000000001600
	/* C14 */
	.octa 0x88
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000580000010000000000001000
	/* C22 */
	.octa 0x20000000000000000000000000
	/* C26 */
	.octa 0x380470000000000000003
	/* C29 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
initial_DDC_EL1_value:
	.octa 0xc00000004004082c00ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x20008000500000150000000040400000
final_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x20008000500000150000000040400414
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
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001600
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001c00
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
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600c18 // ldr x24, [c0, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c18 // str x24, [c0, #0]
	ldr x24, =0x40400414
	mrs x0, ELR_EL1
	sub x24, x24, x0
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b300 // cvtp c0, x24
	.inst 0xc2d84000 // scvalue c0, c0, x24
	.inst 0x82600018 // ldr c24, [c0, #0]
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
