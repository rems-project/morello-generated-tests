.section text0, #alloc, #execinstr
test_start:
	.inst 0xb88584ff // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:7 01:01 imm9:001011000 0:0 opc:10 111000:111000 size:10
	.inst 0x5a97e061 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:3 o2:0 0:0 cond:1110 Rm:23 011010100:011010100 op:1 sf:0
	.inst 0xb35c099d // bfm:aarch64/instrs/integer/bitfield Rd:29 Rn:12 imms:000010 immr:011100 N:1 100110:100110 opc:01 sf:1
	.inst 0xc2c25183 // RETR-C-C 00011:00011 Cn:12 100:100 opc:10 11000010110000100:11000010110000100
	.zero 16384
	.inst 0x785af55e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:10 01:01 imm9:110101111 0:0 opc:01 111000:111000 size:01
	.zero 33772
	.inst 0xc2c1c01e // CVT-R.CC-C Rd:30 Cn:0 110000:110000 Cm:1 11000010110:11000010110
	.inst 0x225f7c24 // LDXR-C.R-C Ct:4 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xa215c3ef // STUR-C.RI-C Ct:15 Rn:31 00:00 imm9:101011100 0:0 opc:00 10100010:10100010
	.inst 0xc2f5981d // SUBS-R.CC-C Rd:29 Cn:0 100110:100110 Cm:21 11000010111:11000010111
	.inst 0xd4000001
	.zero 15340
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400603 // ldr c3, [x16, #1]
	.inst 0xc2400a07 // ldr c7, [x16, #2]
	.inst 0xc2400e0a // ldr c10, [x16, #3]
	.inst 0xc240120c // ldr c12, [x16, #4]
	.inst 0xc240160f // ldr c15, [x16, #5]
	.inst 0xc2401a15 // ldr c21, [x16, #6]
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =initial_SP_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4110 // msr CSP_EL1, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =initial_RDDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28b4330 // msr RDDC_EL0, c16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x4
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x4
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =initial_DDC_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4130 // msr DDC_EL1, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82601230 // ldr c16, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x17, #0xf
	and x16, x16, x17
	cmp x16, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400211 // ldr c17, [x16, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400611 // ldr c17, [x16, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400a11 // ldr c17, [x16, #2]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2400e11 // ldr c17, [x16, #3]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc2401211 // ldr c17, [x16, #4]
	.inst 0xc2d1a4e1 // chkeq c7, c17
	b.ne comparison_fail
	.inst 0xc2401611 // ldr c17, [x16, #5]
	.inst 0xc2d1a541 // chkeq c10, c17
	b.ne comparison_fail
	.inst 0xc2401a11 // ldr c17, [x16, #6]
	.inst 0xc2d1a581 // chkeq c12, c17
	b.ne comparison_fail
	.inst 0xc2401e11 // ldr c17, [x16, #7]
	.inst 0xc2d1a5e1 // chkeq c15, c17
	b.ne comparison_fail
	.inst 0xc2402211 // ldr c17, [x16, #8]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2402611 // ldr c17, [x16, #9]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402a11 // ldr c17, [x16, #10]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc29c4111 // mrs c17, CSP_EL1
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984031 // mrs c17, CELR_EL1
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x17, 0x80
	orr x16, x16, x17
	ldr x17, =0x920000a1
	cmp x17, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
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
	ldr x0, =0x40404010
	ldr x1, =check_data4
	ldr x2, =0x40404014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040c400
	ldr x1, =check_data5
	ldr x2, =0x4040c414
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
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x40, 0x00, 0x00
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
	.octa 0x1
	/* C3 */
	.octa 0xc
	/* C7 */
	.octa 0x1000
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x200000008017400f0000000040404010
	/* C15 */
	.octa 0x4000800000000000000000000000
	/* C21 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0xc
	/* C3 */
	.octa 0xc
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x1058
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x200000008017400f0000000040404010
	/* C15 */
	.octa 0x4000800000000000000000000000
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x1
initial_SP_EL1_value:
	.octa 0x1000
initial_RDDC_EL0_value:
	.octa 0x80000000600280010080800000006001
initial_DDC_EL0_value:
	.octa 0x800000000013000700ffe00000040000
initial_DDC_EL1_value:
	.octa 0xd8000000400010040000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000941d000000004040c000
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080005000941d000000004040c414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300040000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_RDDC_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001f60
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001010
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600e30 // ldr x16, [c17, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e30 // str x16, [c17, #0]
	ldr x16, =0x4040c414
	mrs x17, ELR_EL1
	sub x16, x16, x17
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b211 // cvtp c17, x16
	.inst 0xc2d04231 // scvalue c17, c17, x16
	.inst 0x82600230 // ldr c16, [c17, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
