.section text0, #alloc, #execinstr
test_start:
	.inst 0x38fe41dd // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:14 00:00 opc:100 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xa253d3dd // LDUR-C.RI-C Ct:29 Rn:30 00:00 imm9:100111101 0:0 opc:01 10100010:10100010
	.inst 0x02e0f0c0 // SUB-C.CIS-C Cd:0 Cn:6 imm12:100000111100 sh:1 A:1 00000010:00000010
	.inst 0x7826507f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:3 00:00 opc:101 o3:0 Rs:6 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x796693a1 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:29 imm12:100110100100 opc:01 111001:111001 size:01
	.zero 41964
	.inst 0x38a07024 // 0x38a07024
	.inst 0xc2d20896 // 0xc2d20896
	.inst 0xc2d2eac1 // CTHI-C.CR-C Cd:1 Cn:22 1010:1010 opc:11 Rm:18 11000010110:11000010110
	.inst 0x2c5369df // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:31 Rn:14 Rt2:11010 imm7:0100110 L:1 1011000:1011000 opc:00
	.inst 0xd4000001
	.zero 23532
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006e3 // ldr c3, [x23, #1]
	.inst 0xc2400ae6 // ldr c6, [x23, #2]
	.inst 0xc2400eee // ldr c14, [x23, #3]
	.inst 0xc24012fe // ldr c30, [x23, #4]
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0x3c0000
	msr CPACR_EL1, x23
	ldr x23, =0x4
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x4
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012b7 // ldr c23, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f5 // ldr c21, [x23, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24006f5 // ldr c21, [x23, #1]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2400af5 // ldr c21, [x23, #2]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc2400ef5 // ldr c21, [x23, #3]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc24012f5 // ldr c21, [x23, #4]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc24016f5 // ldr c21, [x23, #5]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2401af5 // ldr c21, [x23, #6]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x21, v26.d[0]
	cmp x23, x21
	b.ne comparison_fail
	ldr x23, =0x0
	mov x21, v26.d[1]
	cmp x23, x21
	b.ne comparison_fail
	ldr x23, =0x0
	mov x21, v31.d[0]
	cmp x23, x21
	b.ne comparison_fail
	ldr x23, =0x0
	mov x21, v31.d[1]
	cmp x23, x21
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	ldr x21, =esr_el1_dump_address
	ldr x21, [x21]
	mov x23, 0x83
	orr x21, x21, x23
	ldr x23, =0x920000a3
	cmp x23, x21
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
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001005
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000109c
	ldr x1, =check_data2
	ldr x2, =0x000010a4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001100
	ldr x1, =check_data3
	ldr x2, =0x00001101
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f60
	ldr x1, =check_data4
	ldr x2, =0x00001f70
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040a400
	ldr x1, =check_data6
	ldr x2, =0x4040a414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.byte 0x00, 0x20, 0x00, 0x00, 0xa6, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 240
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3664
	.byte 0xc1, 0xec, 0xff, 0xff, 0xff, 0xff, 0x7f, 0x7d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 144
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x23
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xc1, 0xec, 0xff, 0xff, 0xff, 0xff, 0x7f, 0x7d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0xdd, 0x41, 0xfe, 0x38, 0xdd, 0xd3, 0x53, 0xa2, 0xc0, 0xf0, 0xe0, 0x02, 0x7f, 0x50, 0x26, 0x78
	.byte 0xa1, 0x93, 0x66, 0x79
.data
check_data6:
	.byte 0x24, 0x70, 0xa0, 0x38, 0x96, 0x08, 0xd2, 0xc2, 0xc1, 0xea, 0xd2, 0xc2, 0xdf, 0x69, 0x53, 0x2c
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1100
	/* C3 */
	.octa 0x1000
	/* C6 */
	.octa 0xa0000080000000000000
	/* C14 */
	.octa 0x1004
	/* C30 */
	.octa 0x2023
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xa000007fffffff7c4000
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x1
	/* C6 */
	.octa 0xa0000080000000000000
	/* C14 */
	.octa 0x1004
	/* C29 */
	.octa 0x7d7fffffffffecc1
	/* C30 */
	.octa 0x2023
initial_DDC_EL0_value:
	.octa 0xc01000003ff140050080000000000001
initial_DDC_EL1_value:
	.octa 0xc00000002007000600ffffffffffc001
initial_VBAR_EL1_value:
	.octa 0x200080004000841d000000004040a000
final_PCC_value:
	.octa 0x200080004000841d000000004040a414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000408100000000000040400000
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x82600eb7 // ldr x23, [c21, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400eb7 // str x23, [c21, #0]
	ldr x23, =0x4040a414
	mrs x21, ELR_EL1
	sub x23, x23, x21
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f5 // cvtp c21, x23
	.inst 0xc2d742b5 // scvalue c21, c21, x23
	.inst 0x826002b7 // ldr c23, [c21, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
