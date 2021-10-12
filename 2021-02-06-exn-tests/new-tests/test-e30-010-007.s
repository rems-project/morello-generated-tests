.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2417ebf // LDR-C.RIBW-C Ct:31 Rn:21 11:11 imm9:000010111 0:0 opc:01 10100010:10100010
	.inst 0xe2419121 // ASTURH-R.RI-32 Rt:1 Rn:9 op2:00 imm9:000011001 V:0 op1:01 11100010:11100010
	.inst 0x3978f01c // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:0 imm12:111000111100 opc:01 111001:111001 size:00
	.inst 0xda80b2b7 // csinv:aarch64/instrs/integer/conditional/select Rd:23 Rn:21 o2:0 0:0 cond:1011 Rm:0 011010100:011010100 op:1 sf:1
	.inst 0xb81380c0 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:6 00:00 imm9:100111000 0:0 opc:00 111000:111000 size:10
	.zero 58348
	.inst 0xe28eb11d // ASTUR-R.RI-32 Rt:29 Rn:8 op2:00 imm9:011101011 V:0 op1:10 11100010:11100010
	.inst 0x388c2cba // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:26 Rn:5 11:11 imm9:011000010 0:0 opc:10 111000:111000 size:00
	.inst 0x9baf6be0 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:31 Ra:26 o0:0 Rm:15 01:01 U:1 10011011:10011011
	.inst 0xe2288c3d // ALDUR-V.RI-Q Rt:29 Rn:1 op2:11 imm9:010001000 V:1 op1:00 11100010:11100010
	.inst 0xd4000001
	.zero 7148
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
	ldr x30, =initial_cap_values
	.inst 0xc24003c0 // ldr c0, [x30, #0]
	.inst 0xc24007c1 // ldr c1, [x30, #1]
	.inst 0xc2400bc5 // ldr c5, [x30, #2]
	.inst 0xc2400fc6 // ldr c6, [x30, #3]
	.inst 0xc24013c8 // ldr c8, [x30, #4]
	.inst 0xc24017c9 // ldr c9, [x30, #5]
	.inst 0xc2401bd5 // ldr c21, [x30, #6]
	.inst 0xc2401fdd // ldr c29, [x30, #7]
	/* Set up flags and system registers */
	ldr x30, =0x0
	msr SPSR_EL3, x30
	ldr x30, =0x200
	msr CPTR_EL3, x30
	ldr x30, =0x30d5d99f
	msr SCTLR_EL1, x30
	ldr x30, =0x1c0000
	msr CPACR_EL1, x30
	ldr x30, =0x0
	msr S3_0_C1_C2_2, x30 // CCTLR_EL1
	ldr x30, =0x4
	msr S3_3_C1_C2_2, x30 // CCTLR_EL0
	ldr x30, =initial_DDC_EL0_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc288413e // msr DDC_EL0, c30
	ldr x30, =initial_DDC_EL1_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc28c413e // msr DDC_EL1, c30
	ldr x30, =0x80000000
	msr HCR_EL2, x30
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260127e // ldr c30, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc28e403e // msr CELR_EL3, c30
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01e // cvtp c30, x0
	.inst 0xc2df43de // scvalue c30, c30, x31
	.inst 0xc28b413e // msr DDC_EL3, c30
	ldr x30, =0x30851035
	msr SCTLR_EL3, x30
	isb
	/* Check processor flags */
	mrs x30, nzcv
	ubfx x30, x30, #28, #4
	mov x19, #0x9
	and x30, x30, x19
	cmp x30, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x30, =final_cap_values
	.inst 0xc24003d3 // ldr c19, [x30, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24007d3 // ldr c19, [x30, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400bd3 // ldr c19, [x30, #2]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc2400fd3 // ldr c19, [x30, #3]
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	.inst 0xc24013d3 // ldr c19, [x30, #4]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc24017d3 // ldr c19, [x30, #5]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc2401bd3 // ldr c19, [x30, #6]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc2401fd3 // ldr c19, [x30, #7]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc24023d3 // ldr c19, [x30, #8]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc24027d3 // ldr c19, [x30, #9]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc2402bd3 // ldr c19, [x30, #10]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x30, =0x0
	mov x19, v29.d[0]
	cmp x30, x19
	b.ne comparison_fail
	ldr x30, =0x0
	mov x19, v29.d[1]
	cmp x30, x19
	b.ne comparison_fail
	/* Check system registers */
	ldr x30, =final_PCC_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc2984033 // mrs c19, CELR_EL1
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	ldr x30, =esr_el1_dump_address
	ldr x30, [x30]
	mov x19, 0x80
	orr x30, x30, x19
	ldr x19, =0x920000e1
	cmp x19, x30
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001100
	ldr x1, =check_data0
	ldr x2, =0x00001104
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001dba
	ldr x1, =check_data1
	ldr x2, =0x00001dbc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc2
	ldr x1, =check_data2
	ldr x2, =0x00001fc3
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
	ldr x0, =0x40402d90
	ldr x1, =check_data4
	ldr x2, =0x40402da0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40408170
	ldr x1, =check_data5
	ldr x2, =0x40408180
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40408e3f
	ldr x1, =check_data6
	ldr x2, =0x40408e40
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040e400
	ldr x1, =check_data7
	ldr x2, =0x4040e414
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
	ldr x30, =0x30850030
	msr SCTLR_EL3, x30
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01e // cvtp c30, x0
	.inst 0xc2df43de // scvalue c30, c30, x31
	.inst 0xc28b413e // msr DDC_EL3, c30
	ldr x30, =0x30850030
	msr SCTLR_EL3, x30
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
	.byte 0x08, 0x2d
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xbf, 0x7e, 0x41, 0xa2, 0x21, 0x91, 0x41, 0xe2, 0x1c, 0xf0, 0x78, 0x39, 0xb7, 0xb2, 0x80, 0xda
	.byte 0xc0, 0x80, 0x13, 0xb8
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 1
.data
check_data7:
	.byte 0x1d, 0xb1, 0x8e, 0xe2, 0xba, 0x2c, 0x8c, 0x38, 0xe0, 0x6b, 0xaf, 0x9b, 0x3d, 0x8c, 0x28, 0xe2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x3
	/* C1 */
	.octa 0x80000000700220060000000040402d08
	/* C5 */
	.octa 0x1f00
	/* C6 */
	.octa 0xd3
	/* C8 */
	.octa 0x40000000004701240000000000001015
	/* C9 */
	.octa 0x40000000000100050000000000001da1
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000700220060000000040402d08
	/* C5 */
	.octa 0x1fc2
	/* C6 */
	.octa 0xd3
	/* C8 */
	.octa 0x40000000004701240000000000001015
	/* C9 */
	.octa 0x40000000000100050000000000001da1
	/* C21 */
	.octa 0x170
	/* C23 */
	.octa 0xfffffffffffffffc
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd0100000000780070000000040408000
initial_DDC_EL1_value:
	.octa 0x800000006400000400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080006800e01d000000004040e000
final_PCC_value:
	.octa 0x200080006800e01d000000004040e414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001100
	.dword 0x0000000000001db0
	.dword 0x0000000040408170
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
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x020003de // add c30, c30, #0
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x020203de // add c30, c30, #128
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x020403de // add c30, c30, #256
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x020603de // add c30, c30, #384
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x020803de // add c30, c30, #512
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x020a03de // add c30, c30, #640
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x020c03de // add c30, c30, #768
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x020e03de // add c30, c30, #896
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x021003de // add c30, c30, #1024
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x021203de // add c30, c30, #1152
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x021403de // add c30, c30, #1280
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x021603de // add c30, c30, #1408
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x021803de // add c30, c30, #1536
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x021a03de // add c30, c30, #1664
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x021c03de // add c30, c30, #1792
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x82600e7e // ldr x30, [c19, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400e7e // str x30, [c19, #0]
	ldr x30, =0x4040e414
	mrs x19, ELR_EL1
	sub x30, x30, x19
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3d3 // cvtp c19, x30
	.inst 0xc2de4273 // scvalue c19, c19, x30
	.inst 0x8260027e // ldr c30, [c19, #0]
	.inst 0x021e03de // add c30, c30, #1920
	.inst 0xc2c213c0 // br c30

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
