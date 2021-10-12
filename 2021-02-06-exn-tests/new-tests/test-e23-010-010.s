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
	ldr x25, =initial_cap_values
	.inst 0xc2400323 // ldr c3, [x25, #0]
	.inst 0xc2400728 // ldr c8, [x25, #1]
	.inst 0xc2400b29 // ldr c9, [x25, #2]
	.inst 0xc2400f32 // ldr c18, [x25, #3]
	.inst 0xc2401334 // ldr c20, [x25, #4]
	.inst 0xc2401736 // ldr c22, [x25, #5]
	.inst 0xc2401b3a // ldr c26, [x25, #6]
	.inst 0xc2401f3d // ldr c29, [x25, #7]
	/* Set up flags and system registers */
	ldr x25, =0x34000000
	msr SPSR_EL3, x25
	ldr x25, =initial_SP_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4119 // msr CSP_EL1, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0xc0000
	msr CPACR_EL1, x25
	ldr x25, =0x0
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =initial_DDC_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4139 // msr DDC_EL1, c25
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011f9 // ldr c25, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e4039 // msr CELR_EL3, c25
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x15, #0x3
	and x25, x25, x15
	cmp x25, #0x3
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc240032f // ldr c15, [x25, #0]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240072f // ldr c15, [x25, #1]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc2400b2f // ldr c15, [x25, #2]
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	.inst 0xc2400f2f // ldr c15, [x25, #3]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc240132f // ldr c15, [x25, #4]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc240172f // ldr c15, [x25, #5]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc2401b2f // ldr c15, [x25, #6]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc2401f2f // ldr c15, [x25, #7]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc240232f // ldr c15, [x25, #8]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc240272f // ldr c15, [x25, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_SP_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc29c410f // mrs c15, CSP_EL1
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x15, 0x80
	orr x25, x25, x15
	ldr x15, =0x920000ea
	cmp x15, x25
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
	ldr x0, =0x0000184c
	ldr x1, =check_data1
	ldr x2, =0x0000184e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bda
	ldr x1, =check_data2
	ldr x2, =0x00001bdc
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
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
	.octa 0x48000000600400020000000000001000
	/* C18 */
	.octa 0x3c
	/* C20 */
	.octa 0xc0000000400100020000000000001000
	/* C22 */
	.octa 0x40000000602020041000000000001005
	/* C26 */
	.octa 0x3a0050000ffffffffa001
	/* C29 */
	.octa 0x4000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x5c
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x48000000600400020000000000001000
	/* C18 */
	.octa 0x3c
	/* C20 */
	.octa 0xc0000000400100020000000000001000
	/* C22 */
	.octa 0x40000000602020041000000000001005
	/* C26 */
	.octa 0x3a0050000ffffffffa001
	/* C29 */
	.octa 0x5b
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x5b
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000d01c0000000040400000
final_SP_EL1_value:
	.octa 0x5b
final_PCC_value:
	.octa 0x200080005000d01c0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000800000000040400000
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
	.dword 0x0000000000001bd0
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x82600df9 // ldr x25, [c15, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400df9 // str x25, [c15, #0]
	ldr x25, =0x40400414
	mrs x15, ELR_EL1
	sub x25, x25, x15
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32f // cvtp c15, x25
	.inst 0xc2d941ef // scvalue c15, c15, x25
	.inst 0x826001f9 // ldr c25, [c15, #0]
	.inst 0x021e0339 // add c25, c25, #1920
	.inst 0xc2c21320 // br c25

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
