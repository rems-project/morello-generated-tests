.section text0, #alloc, #execinstr
test_start:
	.inst 0xb4c20a41 // cbz:aarch64/instrs/branch/conditional/compare Rt:1 imm19:1100001000001010010 op:0 011010:011010 sf:1
	.inst 0xe29417b9 // ALDUR-R.RI-32 Rt:25 Rn:29 op2:01 imm9:101000001 V:0 op1:10 11100010:11100010
	.inst 0x795ed435 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:21 Rn:1 imm12:011110110101 opc:01 111001:111001 size:01
	.inst 0xc2c4b021 // LDCT-R.R-_ Rt:1 Rn:1 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0xd453f6e0 // hlt:aarch64/instrs/system/exceptions/debug/halt 00000:00000 imm16:1001111110110111 11010100010:11010100010
	.zero 9196
	.inst 0xb85dbc04 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:4 Rn:0 11:11 imm9:111011011 0:0 opc:01 111000:111000 size:10
	.inst 0xaa9db51b // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:27 Rn:8 imm6:101101 Rm:29 N:0 shift:10 01010:01010 opc:01 sf:1
	.inst 0xc2c693ac // CLRPERM-C.CI-C Cd:12 Cn:29 100:100 perm:100 1100001011000110:1100001011000110
	.inst 0x085f7fdd // ldxrb:aarch64/instrs/memory/exclusive/single Rt:29 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xd4000001
	.zero 56292
	.inst 0xc2c2c2c2
	.zero 4
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a3d // ldr c29, [x17, #2]
	.inst 0xc2400e3e // ldr c30, [x17, #3]
	/* Set up flags and system registers */
	ldr x17, =0x0
	msr SPSR_EL3, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30d5d99f
	msr SCTLR_EL1, x17
	ldr x17, =0xc0000
	msr CPACR_EL1, x17
	ldr x17, =0x0
	msr S3_0_C1_C2_2, x17 // CCTLR_EL1
	ldr x17, =0x0
	msr S3_3_C1_C2_2, x17 // CCTLR_EL0
	ldr x17, =initial_DDC_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884131 // msr DDC_EL0, c17
	ldr x17, =0x80000000
	msr HCR_EL2, x17
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012d1 // ldr c17, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e4031 // msr CELR_EL3, c17
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400236 // ldr c22, [x17, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400636 // ldr c22, [x17, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400a36 // ldr c22, [x17, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400e36 // ldr c22, [x17, #3]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2401236 // ldr c22, [x17, #4]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2401636 // ldr c22, [x17, #5]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2401a36 // ldr c22, [x17, #6]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2401e36 // ldr c22, [x17, #7]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x17, =final_PCC_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	ldr x17, =esr_el1_dump_address
	ldr x17, [x17]
	ldr x22, =0x2000000
	cmp x22, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f6a
	ldr x1, =check_data1
	ldr x2, =0x00001f6c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x40402400
	ldr x1, =check_data4
	ldr x2, =0x40402414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040fff8
	ldr x1, =check_data5
	ldr x2, =0x4040fffc
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
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3872
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0x41, 0x0a, 0xc2, 0xb4, 0xb9, 0x17, 0x94, 0xe2, 0x35, 0xd4, 0x5e, 0x79, 0x21, 0xb0, 0xc4, 0xc2
	.byte 0xe0, 0xf6, 0x53, 0xd4
.data
check_data4:
	.byte 0x04, 0xbc, 0x5d, 0xb8, 0x1b, 0xb5, 0x9d, 0xaa, 0xac, 0x93, 0xc6, 0xc2, 0xdd, 0x7f, 0x5f, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0xc2, 0xc2, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000010007000000004041001d
	/* C1 */
	.octa 0x1000
	/* C29 */
	.octa 0x800000000001000500000000000010bf
	/* C30 */
	.octa 0x80000000000100050000000000001ffe
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x8000000000010007000000004040fff8
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0xc2c2c2c2
	/* C12 */
	.octa 0x1000500000000000010bf
	/* C21 */
	.octa 0xc2c2
	/* C25 */
	.octa 0xc2c2c2c2
	/* C29 */
	.octa 0xc2
	/* C30 */
	.octa 0x80000000000100050000000000001ffe
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040402001
final_PCC_value:
	.octa 0x200080004000041d0000000040402414
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
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001030
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
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x02000231 // add c17, c17, #0
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x02020231 // add c17, c17, #128
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x02040231 // add c17, c17, #256
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x02060231 // add c17, c17, #384
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x02080231 // add c17, c17, #512
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x020a0231 // add c17, c17, #640
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x020c0231 // add c17, c17, #768
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x020e0231 // add c17, c17, #896
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x02100231 // add c17, c17, #1024
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x02120231 // add c17, c17, #1152
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x02140231 // add c17, c17, #1280
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x02160231 // add c17, c17, #1408
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x02180231 // add c17, c17, #1536
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x021a0231 // add c17, c17, #1664
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x021c0231 // add c17, c17, #1792
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x82600ed1 // ldr x17, [c22, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ed1 // str x17, [c22, #0]
	ldr x17, =0x40402414
	mrs x22, ELR_EL1
	sub x17, x17, x22
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b236 // cvtp c22, x17
	.inst 0xc2d142d6 // scvalue c22, c22, x17
	.inst 0x826002d1 // ldr c17, [c22, #0]
	.inst 0x021e0231 // add c17, c17, #1920
	.inst 0xc2c21220 // br c17

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
