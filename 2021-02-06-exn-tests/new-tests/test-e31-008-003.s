.section text0, #alloc, #execinstr
test_start:
	.inst 0xb88584ff // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:7 01:01 imm9:001011000 0:0 opc:10 111000:111000 size:10
	.inst 0x5a97e061 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:3 o2:0 0:0 cond:1110 Rm:23 011010100:011010100 op:1 sf:0
	.inst 0xb35c099d // bfm:aarch64/instrs/integer/bitfield Rd:29 Rn:12 imms:000010 immr:011100 N:1 100110:100110 opc:01 sf:1
	.inst 0xc2c25183 // RETR-C-C 00011:00011 Cn:12 100:100 opc:10 11000010110000100:11000010110000100
	.zero 240
	.inst 0x785af55e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:10 01:01 imm9:110101111 0:0 opc:01 111000:111000 size:01
	.zero 2812
	.inst 0xc2c1c01e // CVT-R.CC-C Rd:30 Cn:0 110000:110000 Cm:1 11000010110:11000010110
	.inst 0x225f7c24 // LDXR-C.R-C Ct:4 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xa215c3ef // STUR-C.RI-C Ct:15 Rn:31 00:00 imm9:101011100 0:0 opc:00 10100010:10100010
	.inst 0xc2f5981d // SUBS-R.CC-C Rd:29 Cn:0 100110:100110 Cm:21 11000010111:11000010111
	.inst 0xd4000001
	.zero 62444
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
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400663 // ldr c3, [x19, #1]
	.inst 0xc2400a67 // ldr c7, [x19, #2]
	.inst 0xc2400e6a // ldr c10, [x19, #3]
	.inst 0xc240126c // ldr c12, [x19, #4]
	.inst 0xc240166f // ldr c15, [x19, #5]
	.inst 0xc2401a75 // ldr c21, [x19, #6]
	/* Set up flags and system registers */
	ldr x19, =0x0
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4113 // msr CSP_EL1, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =initial_RDDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28b4333 // msr RDDC_EL0, c19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
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
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601253 // ldr c19, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x18, #0xf
	and x19, x19, x18
	cmp x19, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400272 // ldr c18, [x19, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400672 // ldr c18, [x19, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400a72 // ldr c18, [x19, #2]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2400e72 // ldr c18, [x19, #3]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc2401272 // ldr c18, [x19, #4]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc2401672 // ldr c18, [x19, #5]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401a72 // ldr c18, [x19, #6]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2401e72 // ldr c18, [x19, #7]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2402272 // ldr c18, [x19, #8]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2402672 // ldr c18, [x19, #9]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2402a72 // ldr c18, [x19, #10]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc29c4112 // mrs c18, CSP_EL1
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	mov x18, 0x80
	orr x19, x19, x18
	ldr x18, =0x920000a9
	cmp x18, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001804
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f60
	ldr x1, =check_data2
	ldr x2, =0x00001f70
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400100
	ldr x1, =check_data4
	ldr x2, =0x40400104
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400c00
	ldr x1, =check_data5
	ldr x2, =0x40400c14
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
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x02, 0x00, 0x02, 0x08, 0x00, 0x08, 0x00, 0x00, 0x08, 0x01
.data
check_data3:
	.byte 0xff, 0x84, 0x85, 0xb8, 0x61, 0xe0, 0x97, 0x5a, 0x9d, 0x09, 0x5c, 0xb3, 0x83, 0x51, 0xc2, 0xc2
.data
check_data4:
	.byte 0x5e, 0xf5, 0x5a, 0x78
.data
check_data5:
	.byte 0x1e, 0xc0, 0xc1, 0xc2, 0x24, 0x7c, 0x5f, 0x22, 0xef, 0xc3, 0x15, 0xa2, 0x1d, 0x98, 0xf5, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8
	/* C3 */
	.octa 0x100c
	/* C7 */
	.octa 0x1000
	/* C10 */
	.octa 0x80000000000000
	/* C12 */
	.octa 0x20000000c40100210000000040400100
	/* C15 */
	.octa 0x1080000080008020002400000000000
	/* C21 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x8
	/* C1 */
	.octa 0x100c
	/* C3 */
	.octa 0x100c
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x1058
	/* C10 */
	.octa 0x80000000000000
	/* C12 */
	.octa 0x20000000c40100210000000040400100
	/* C15 */
	.octa 0x1080000080008020002400000000000
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x8
initial_SP_EL1_value:
	.octa 0x2000
initial_RDDC_EL0_value:
	.octa 0x800700000000000000000000
initial_DDC_EL0_value:
	.octa 0x800000001007040600ffffffffffc001
initial_DDC_EL1_value:
	.octa 0xcc1000005f8000040000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080005000041e0000000040400800
final_SP_EL1_value:
	.octa 0x2000
final_PCC_value:
	.octa 0x200080005000041e0000000040400c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000024700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_RDDC_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001010
	.dword 0x0000000000001f60
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600e53 // ldr x19, [c18, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e53 // str x19, [c18, #0]
	ldr x19, =0x40400c14
	mrs x18, ELR_EL1
	sub x19, x19, x18
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b272 // cvtp c18, x19
	.inst 0xc2d34252 // scvalue c18, c18, x19
	.inst 0x82600253 // ldr c19, [c18, #0]
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
