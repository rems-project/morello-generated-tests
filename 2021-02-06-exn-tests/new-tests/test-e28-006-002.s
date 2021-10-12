.section text0, #alloc, #execinstr
test_start:
	.inst 0xb4c20a41 // cbz:aarch64/instrs/branch/conditional/compare Rt:1 imm19:1100001000001010010 op:0 011010:011010 sf:1
	.inst 0xe29417b9 // ALDUR-R.RI-32 Rt:25 Rn:29 op2:01 imm9:101000001 V:0 op1:10 11100010:11100010
	.inst 0x795ed435 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:21 Rn:1 imm12:011110110101 opc:01 111001:111001 size:01
	.inst 0xc2c4b021 // LDCT-R.R-_ Rt:1 Rn:1 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0xd453f6e0 // hlt:aarch64/instrs/system/exceptions/debug/halt 00000:00000 imm16:1001111110110111 11010100010:11010100010
	.zero 1004
	.inst 0xb85dbc04 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:4 Rn:0 11:11 imm9:111011011 0:0 opc:01 111000:111000 size:10
	.inst 0xaa9db51b // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:27 Rn:8 imm6:101101 Rm:29 N:0 shift:10 01010:01010 opc:01 sf:1
	.inst 0xc2c693ac // CLRPERM-C.CI-C Cd:12 Cn:29 100:100 perm:100 1100001011000110:1100001011000110
	.inst 0x085f7fdd // ldxrb:aarch64/instrs/memory/exclusive/single Rt:29 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xd4000001
	.zero 15304
	.inst 0xc2c2c2c2
	.zero 49184
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
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008bd // ldr c29, [x5, #2]
	.inst 0xc2400cbe // ldr c30, [x5, #3]
	/* Set up flags and system registers */
	ldr x5, =0x0
	msr SPSR_EL3, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0xc0000
	msr CPACR_EL1, x5
	ldr x5, =0x4
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x0
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
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82601225 // ldr c5, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b1 // ldr c17, [x5, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24004b1 // ldr c17, [x5, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24008b1 // ldr c17, [x5, #2]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc2400cb1 // ldr c17, [x5, #3]
	.inst 0xc2d1a581 // chkeq c12, c17
	b.ne comparison_fail
	.inst 0xc24010b1 // ldr c17, [x5, #4]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc24014b1 // ldr c17, [x5, #5]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc24018b1 // ldr c17, [x5, #6]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2401cb1 // ldr c17, [x5, #7]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984031 // mrs c17, CELR_EL1
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	ldr x17, =0x2000000
	cmp x17, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000107e
	ldr x1, =check_data0
	ldr x2, =0x0000107f
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x000010c0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f44
	ldr x1, =check_data2
	ldr x2, =0x00001f48
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fea
	ldr x1, =check_data3
	ldr x2, =0x00001fec
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
	ldr x0, =0x40403fdc
	ldr x1, =check_data6
	ldr x2, =0x40403fe0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3712
	.byte 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 144
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2
.data
check_data4:
	.byte 0x41, 0x0a, 0xc2, 0xb4, 0xb9, 0x17, 0x94, 0xe2, 0x35, 0xd4, 0x5e, 0x79, 0x21, 0xb0, 0xc4, 0xc2
	.byte 0xe0, 0xf6, 0x53, 0xd4
.data
check_data5:
	.byte 0x04, 0xbc, 0x5d, 0xb8, 0x1b, 0xb5, 0x9d, 0xaa, 0xac, 0x93, 0xc6, 0xc2, 0xdd, 0x7f, 0x5f, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0xc2, 0xc2, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40404001
	/* C1 */
	.octa 0x1080
	/* C29 */
	.octa 0x80000000000100050000000000002003
	/* C30 */
	.octa 0x107e
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40403fdc
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0xc2c2c2c2
	/* C12 */
	.octa 0x100050000000000002003
	/* C21 */
	.octa 0xc2c2
	/* C25 */
	.octa 0xc2c2c2c2
	/* C29 */
	.octa 0xc2
	/* C30 */
	.octa 0x107e
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000100140050080000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000500000110000000040400000
final_PCC_value:
	.octa 0x20008000500000110000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword 0x0000000000001090
	.dword 0x00000000000010a0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001080
	.dword 0x0000000000001090
	.dword 0x00000000000010a0
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000010b0
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
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600e25 // ldr x5, [c17, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e25 // str x5, [c17, #0]
	ldr x5, =0x40400414
	mrs x17, ELR_EL1
	sub x5, x5, x17
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b1 // cvtp c17, x5
	.inst 0xc2c54231 // scvalue c17, c17, x5
	.inst 0x82600225 // ldr c5, [c17, #0]
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
