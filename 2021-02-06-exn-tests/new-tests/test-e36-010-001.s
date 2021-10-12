.section text0, #alloc, #execinstr
test_start:
	.inst 0xb369bfe0 // bfm:aarch64/instrs/integer/bitfield Rd:0 Rn:31 imms:101111 immr:101001 N:1 100110:100110 opc:01 sf:1
	.inst 0x6b5e67bd // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:29 Rn:29 imm6:011001 Rm:30 0:0 shift:01 01011:01011 S:1 op:1 sf:0
	.inst 0xf2caab9c // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:28 imm16:0101010101011100 hw:10 100101:100101 opc:11 sf:1
	.inst 0x3cfc7bde // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:30 Rn:30 10:10 S:1 option:011 Rm:28 1:1 opc:11 111100:111100 size:00
	.inst 0x88dffc01 // ldar:aarch64/instrs/memory/ordered Rt:1 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.zero 1004
	.inst 0xbc583c5e // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:30 Rn:2 11:11 imm9:110000011 0:0 opc:01 111100:111100 size:10
	.inst 0x38c163a5 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:5 Rn:29 00:00 imm9:000010110 0:0 opc:11 111000:111000 size:00
	.inst 0x78f6003b // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:27 Rn:1 00:00 opc:000 0:0 Rs:22 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xc89ffe7d // stlr:aarch64/instrs/memory/ordered Rt:29 Rn:19 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
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
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b02 // ldr c2, [x24, #2]
	.inst 0xc2400f13 // ldr c19, [x24, #3]
	.inst 0xc2401316 // ldr c22, [x24, #4]
	.inst 0xc240171c // ldr c28, [x24, #5]
	.inst 0xc2401b1d // ldr c29, [x24, #6]
	.inst 0xc2401f1e // ldr c30, [x24, #7]
	/* Set up flags and system registers */
	ldr x24, =0x0
	msr SPSR_EL3, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0x3c0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
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
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011f8 // ldr c24, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
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
	mov x15, #0xf
	and x24, x24, x15
	cmp x24, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240030f // ldr c15, [x24, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240070f // ldr c15, [x24, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400b0f // ldr c15, [x24, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400f0f // ldr c15, [x24, #3]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc240130f // ldr c15, [x24, #4]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	.inst 0xc240170f // ldr c15, [x24, #5]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc2401b0f // ldr c15, [x24, #6]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc2401f0f // ldr c15, [x24, #7]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc240230f // ldr c15, [x24, #8]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc240270f // ldr c15, [x24, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x15, v30.d[0]
	cmp x24, x15
	b.ne comparison_fail
	ldr x24, =0x0
	mov x15, v30.d[1]
	cmp x24, x15
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa701 // chkeq c24, c15
	b.ne comparison_fail
	ldr x24, =esr_el1_dump_address
	ldr x24, [x24]
	mov x15, 0xc1
	orr x24, x24, x15
	ldr x15, =0x920000eb
	cmp x15, x24
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
	ldr x0, =0x00001016
	ldr x1, =check_data1
	ldr x2, =0x00001017
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040e004
	ldr x1, =check_data4
	ldr x2, =0x4040e008
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
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xe0, 0xbf, 0x69, 0xb3, 0xbd, 0x67, 0x5e, 0x6b, 0x9c, 0xab, 0xca, 0xf2, 0xde, 0x7b, 0xfc, 0x3c
	.byte 0x01, 0xfc, 0xdf, 0x88
.data
check_data3:
	.byte 0x5e, 0x3c, 0x58, 0xbc, 0xa5, 0x63, 0xc1, 0x38, 0x3b, 0x00, 0xf6, 0x78, 0x7d, 0xfe, 0x9f, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8882800001000400
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x4040e081
	/* C19 */
	.octa 0x1000
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x469000000000000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0xb96aaa4000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x8882800001000400
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x4040e004
	/* C5 */
	.octa 0x0
	/* C19 */
	.octa 0x1000
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x469555c00000000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0xb96aaa4000001000
initial_DDC_EL0_value:
	.octa 0x800000000006000600ffffffffe00001
initial_DDC_EL1_value:
	.octa 0xc00000000a2180060080000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001e0000000040400000
final_PCC_value:
	.octa 0x200080005000001e0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500400000000000040400000
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
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x82600df8 // ldr x24, [c15, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400df8 // str x24, [c15, #0]
	ldr x24, =0x40400414
	mrs x15, ELR_EL1
	sub x24, x24, x15
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30f // cvtp c15, x24
	.inst 0xc2d841ef // scvalue c15, c15, x24
	.inst 0x826001f8 // ldr c24, [c15, #0]
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
