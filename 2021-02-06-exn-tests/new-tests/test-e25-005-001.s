.section text0, #alloc, #execinstr
test_start:
	.inst 0x295b6fd2 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:18 Rn:30 Rt2:11011 imm7:0110110 L:1 1010010:1010010 opc:00
	.inst 0xc2c1d3a4 // CPY-C.C-C Cd:4 Cn:29 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x7854001d // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:0 00:00 imm9:101000000 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c11237 // GCLIM-R.C-C Rd:23 Cn:17 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x7cca9008 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:8 Rn:0 00:00 imm9:010101001 0:0 opc:11 111100:111100 size:01
	.zero 33772
	.inst 0x825db7c1 // ASTRB-R.RI-B Rt:1 Rn:30 op:01 imm9:111011011 L:0 1000001001:1000001001
	.inst 0x3cc6f3ed // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:13 Rn:31 00:00 imm9:001101111 0:0 opc:11 111100:111100 size:00
	.inst 0x7801c5ac // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:13 01:01 imm9:000011100 0:0 opc:00 111000:111000 size:01
	.inst 0x381b7e7b // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:27 Rn:19 11:11 imm9:110110111 0:0 opc:00 111000:111000 size:00
	.inst 0xd4000001
	.zero 31724
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc240090c // ldr c12, [x8, #2]
	.inst 0xc2400d0d // ldr c13, [x8, #3]
	.inst 0xc2401111 // ldr c17, [x8, #4]
	.inst 0xc2401513 // ldr c19, [x8, #5]
	.inst 0xc240191e // ldr c30, [x8, #6]
	/* Set up flags and system registers */
	ldr x8, =0x4000000
	msr SPSR_EL3, x8
	ldr x8, =initial_SP_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4108 // msr CSP_EL1, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0x3c0000
	msr CPACR_EL1, x8
	ldr x8, =0x4
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011c8 // ldr c8, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010e // ldr c14, [x8, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240050e // ldr c14, [x8, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240090e // ldr c14, [x8, #2]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc2400d0e // ldr c14, [x8, #3]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc240110e // ldr c14, [x8, #4]
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	.inst 0xc240150e // ldr c14, [x8, #5]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc240190e // ldr c14, [x8, #6]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc2401d0e // ldr c14, [x8, #7]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc240210e // ldr c14, [x8, #8]
	.inst 0xc2cea761 // chkeq c27, c14
	b.ne comparison_fail
	.inst 0xc240250e // ldr c14, [x8, #9]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc240290e // ldr c14, [x8, #10]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x14, v13.d[0]
	cmp x8, x14
	b.ne comparison_fail
	ldr x8, =0x0
	mov x14, v13.d[1]
	cmp x8, x14
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc29c410e // mrs c14, CSP_EL1
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	ldr x14, =0x2000000
	cmp x14, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001004
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
	ldr x0, =0x00001070
	ldr x1, =check_data2
	ldr x2, =0x00001080
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000111b
	ldr x1, =check_data3
	ldr x2, =0x0000111c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f40
	ldr x1, =check_data4
	ldr x2, =0x00001f42
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fb8
	ldr x1, =check_data5
	ldr x2, =0x00001fb9
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
	ldr x0, =0x40408400
	ldr x1, =check_data7
	ldr x2, =0x40408414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xd2, 0x6f, 0x5b, 0x29, 0xa4, 0xd3, 0xc1, 0xc2, 0x1d, 0x00, 0x54, 0x78, 0x37, 0x12, 0xc1, 0xc2
	.byte 0x08, 0x90, 0xca, 0x7c
.data
check_data7:
	.byte 0xc1, 0xb7, 0x5d, 0x82, 0xed, 0xf3, 0xc6, 0x3c, 0xac, 0xc5, 0x01, 0x78, 0x7b, 0x7e, 0x1b, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000005f4207460000000000002000
	/* C1 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x1001
	/* C17 */
	.octa 0x1
	/* C19 */
	.octa 0x2000
	/* C30 */
	.octa 0xc0000000400101390000000000000f40
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800000005f4207460000000000002000
	/* C1 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x101d
	/* C17 */
	.octa 0x1
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x1fb7
	/* C23 */
	.octa 0xffffffffffffffff
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xc0000000400101390000000000000f40
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL1_value:
	.octa 0xc00000005fc0000100ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004800801d0000000040408000
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080004800801d0000000040408414
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
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 160
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001110
	.dword 0x0000000000001fb0
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x82600dc8 // ldr x8, [c14, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400dc8 // str x8, [c14, #0]
	ldr x8, =0x40408414
	mrs x14, ELR_EL1
	sub x8, x8, x14
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10e // cvtp c14, x8
	.inst 0xc2c841ce // scvalue c14, c14, x8
	.inst 0x826001c8 // ldr c8, [c14, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
