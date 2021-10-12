.section text0, #alloc, #execinstr
test_start:
	.inst 0x22202c3b // STXP-R.CR-C Ct:27 Rn:1 Ct2:01011 0:0 Rs:0 1:1 L:0 001000100:001000100
	.inst 0x6d8f8bc0 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:0 Rn:30 Rt2:00010 imm7:0011111 L:0 1011011:1011011 opc:01
	.inst 0xc2c252e2 // RETS-C-C 00010:00010 Cn:23 100:100 opc:10 11000010110000100:11000010110000100
	.zero 500
	.inst 0x3916aa9f // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:20 imm12:010110101010 opc:00 111001:111001 size:00
	.inst 0xc2c267fe // CPYVALUE-C.C-C Cd:30 Cn:31 001:001 opc:11 0:0 Cm:2 11000010110:11000010110
	.inst 0xa8510d8d // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:13 Rn:12 Rt2:00011 imm7:0100010 L:1 1010000:1010000 opc:10
	.inst 0x2d6f62b1 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:17 Rn:21 Rt2:11000 imm7:1011110 L:1 1011010:1011010 opc:00
	.inst 0x3a464b46 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0110 0:0 Rn:26 10:10 cond:0100 imm5:00110 111010010:111010010 op:0 sf:0
	.inst 0xb860529f // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:101 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xd4000001
	.zero 64996
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
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc240060b // ldr c11, [x16, #1]
	.inst 0xc2400a0c // ldr c12, [x16, #2]
	.inst 0xc2400e14 // ldr c20, [x16, #3]
	.inst 0xc2401215 // ldr c21, [x16, #4]
	.inst 0xc2401617 // ldr c23, [x16, #5]
	.inst 0xc2401a1b // ldr c27, [x16, #6]
	.inst 0xc2401e1e // ldr c30, [x16, #7]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q0, =0x0
	ldr q2, =0x800000000
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x3c0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
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
	cmp x16, #0x6
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
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc2401211 // ldr c17, [x16, #4]
	.inst 0xc2d1a581 // chkeq c12, c17
	b.ne comparison_fail
	.inst 0xc2401611 // ldr c17, [x16, #5]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc2401a11 // ldr c17, [x16, #6]
	.inst 0xc2d1a681 // chkeq c20, c17
	b.ne comparison_fail
	.inst 0xc2401e11 // ldr c17, [x16, #7]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2402211 // ldr c17, [x16, #8]
	.inst 0xc2d1a6e1 // chkeq c23, c17
	b.ne comparison_fail
	.inst 0xc2402611 // ldr c17, [x16, #9]
	.inst 0xc2d1a761 // chkeq c27, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x17, v0.d[0]
	cmp x16, x17
	b.ne comparison_fail
	ldr x16, =0x0
	mov x17, v0.d[1]
	cmp x16, x17
	b.ne comparison_fail
	ldr x16, =0x800000000
	mov x17, v2.d[0]
	cmp x16, x17
	b.ne comparison_fail
	ldr x16, =0x0
	mov x17, v2.d[1]
	cmp x16, x17
	b.ne comparison_fail
	ldr x16, =0x0
	mov x17, v17.d[0]
	cmp x16, x17
	b.ne comparison_fail
	ldr x16, =0x0
	mov x17, v17.d[1]
	cmp x16, x17
	b.ne comparison_fail
	ldr x16, =0x0
	mov x17, v24.d[0]
	cmp x16, x17
	b.ne comparison_fail
	ldr x16, =0x0
	mov x17, v24.d[1]
	cmp x16, x17
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984031 // mrs c17, CELR_EL1
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001200
	ldr x1, =check_data0
	ldr x2, =0x00001210
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000138c
	ldr x1, =check_data1
	ldr x2, =0x00001394
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017f8
	ldr x1, =check_data2
	ldr x2, =0x00001808
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001dae
	ldr x1, =check_data3
	ldr x2, =0x00001daf
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x4040000c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400200
	ldr x1, =check_data5
	ldr x2, =0x4040021c
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
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x3b, 0x2c, 0x20, 0x22, 0xc0, 0x8b, 0x8f, 0x6d, 0xe2, 0x52, 0xc2, 0xc2
.data
check_data5:
	.byte 0x9f, 0xaa, 0x16, 0x39, 0xfe, 0x67, 0xc2, 0xc2, 0x8d, 0x0d, 0x51, 0xa8, 0xb1, 0x62, 0x6f, 0x2d
	.byte 0x46, 0x4b, 0x46, 0x3a, 0x9f, 0x52, 0x60, 0xb8, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1a60
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x800000001c0d000300000000000010f0
	/* C20 */
	.octa 0xc0000000040703e70000000000001804
	/* C21 */
	.octa 0x800000004001080a0000000000001414
	/* C23 */
	.octa 0x20008000000100070000000040400201
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x1700
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x1a60
	/* C3 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x800000001c0d000300000000000010f0
	/* C13 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000040703e70000000000001804
	/* C21 */
	.octa 0x800000004001080a0000000000001414
	/* C23 */
	.octa 0x20008000000100070000000040400201
	/* C27 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x4c000000001f00390000000000000003
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x2000800000010007000000004040021c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200020000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000017f0
	.dword 0x0000000000001800
	.dword 0x0000000000001da0
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
	ldr x16, =0x4040021c
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
