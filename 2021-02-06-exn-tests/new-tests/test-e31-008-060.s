.section text0, #alloc, #execinstr
test_start:
	.inst 0xb88584ff // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:7 01:01 imm9:001011000 0:0 opc:10 111000:111000 size:10
	.inst 0x5a97e061 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:3 o2:0 0:0 cond:1110 Rm:23 011010100:011010100 op:1 sf:0
	.inst 0xb35c099d // bfm:aarch64/instrs/integer/bitfield Rd:29 Rn:12 imms:000010 immr:011100 N:1 100110:100110 opc:01 sf:1
	.inst 0xc2c25183 // RETR-C-C 00011:00011 Cn:12 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x785af55e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:10 01:01 imm9:110101111 0:0 opc:01 111000:111000 size:01
	.zero 35820
	.inst 0xc2c1c01e // CVT-R.CC-C Rd:30 Cn:0 110000:110000 Cm:1 11000010110:11000010110
	.inst 0x225f7c24 // LDXR-C.R-C Ct:4 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xa215c3ef // STUR-C.RI-C Ct:15 Rn:31 00:00 imm9:101011100 0:0 opc:00 10100010:10100010
	.inst 0xc2f5981d // SUBS-R.CC-C Rd:29 Cn:0 100110:100110 Cm:21 11000010111:11000010111
	.inst 0xd4000001
	.zero 29676
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
	.inst 0xc24004a3 // ldr c3, [x5, #1]
	.inst 0xc24008a7 // ldr c7, [x5, #2]
	.inst 0xc2400caa // ldr c10, [x5, #3]
	.inst 0xc24010ac // ldr c12, [x5, #4]
	.inst 0xc24014af // ldr c15, [x5, #5]
	.inst 0xc24018b5 // ldr c21, [x5, #6]
	/* Set up flags and system registers */
	ldr x5, =0x0
	msr SPSR_EL3, x5
	ldr x5, =initial_SP_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4105 // msr CSP_EL1, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0xc0000
	msr CPACR_EL1, x5
	ldr x5, =0x4
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x4
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =initial_DDC_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4125 // msr DDC_EL1, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601325 // ldr c5, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	mov x25, #0xf
	and x5, x5, x25
	cmp x5, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b9 // ldr c25, [x5, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24004b9 // ldr c25, [x5, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24008b9 // ldr c25, [x5, #2]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2400cb9 // ldr c25, [x5, #3]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc24010b9 // ldr c25, [x5, #4]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc24014b9 // ldr c25, [x5, #5]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc24018b9 // ldr c25, [x5, #6]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2401cb9 // ldr c25, [x5, #7]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc24020b9 // ldr c25, [x5, #8]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc24024b9 // ldr c25, [x5, #9]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc24028b9 // ldr c25, [x5, #10]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc29c4119 // mrs c25, CSP_EL1
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x25, 0xc1
	orr x5, x5, x25
	ldr x25, =0x920000eb
	cmp x25, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011c4
	ldr x1, =check_data1
	ldr x2, =0x000011c8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f70
	ldr x1, =check_data2
	ldr x2, =0x00001f80
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
	ldr x0, =0x40408c00
	ldr x1, =check_data4
	ldr x2, =0x40408c14
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
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x80
.data
check_data3:
	.byte 0xff, 0x84, 0x85, 0xb8, 0x61, 0xe0, 0x97, 0x5a, 0x9d, 0x09, 0x5c, 0xb3, 0x83, 0x51, 0xc2, 0xc2
	.byte 0x5e, 0xf5, 0x5a, 0x78
.data
check_data4:
	.byte 0x1e, 0xc0, 0xc1, 0xc2, 0x24, 0x7c, 0x5f, 0x22, 0xef, 0xc3, 0x15, 0xa2, 0x1d, 0x98, 0xf5, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1
	/* C3 */
	.octa 0x100c
	/* C7 */
	.octa 0x1002
	/* C10 */
	.octa 0x80000000380120170000fffffffffffc
	/* C12 */
	.octa 0x20000000902100070000000040400011
	/* C15 */
	.octa 0x80000020000000000400800000000000
	/* C21 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x100c
	/* C3 */
	.octa 0x100c
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x105a
	/* C10 */
	.octa 0x80000000380120170000fffffffffffc
	/* C12 */
	.octa 0x20000000902100070000000040400011
	/* C15 */
	.octa 0x80000020000000000400800000000000
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x1
initial_SP_EL1_value:
	.octa 0x2000
initial_DDC_EL0_value:
	.octa 0x80000000400901c200ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xcc100000400200140000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000841c0000000040408800
final_SP_EL1_value:
	.octa 0x2000
final_PCC_value:
	.octa 0x200080005000841c0000000040408c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500100000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001020
	.dword 0x0000000000001f70
	.dword 0
final_tag_unset_locations:
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
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600f25 // ldr x5, [c25, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400f25 // str x5, [c25, #0]
	ldr x5, =0x40408c14
	mrs x25, ELR_EL1
	sub x5, x5, x25
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b9 // cvtp c25, x5
	.inst 0xc2c54339 // scvalue c25, c25, x5
	.inst 0x82600325 // ldr c5, [c25, #0]
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
