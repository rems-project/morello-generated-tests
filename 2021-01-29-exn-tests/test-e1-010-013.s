.section text0, #alloc, #execinstr
test_start:
	.inst 0x7c0c039d // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:29 Rn:28 00:00 imm9:011000000 0:0 opc:00 111100:111100 size:01
	.inst 0xc2d8431b // SCVALUE-C.CR-C Cd:27 Cn:24 000:000 opc:10 0:0 Rm:24 11000010110:11000010110
	.inst 0x82c1e014 // ALDRB-R.RRB-B Rt:20 Rn:0 opc:00 S:0 option:111 Rm:1 0:0 L:1 100000101:100000101
	.inst 0xc2de27cd // CPYTYPE-C.C-C Cd:13 Cn:30 001:001 opc:01 0:0 Cm:30 11000010110:11000010110
	.inst 0x78c9a480 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:4 01:01 imm9:010011010 0:0 opc:11 111000:111000 size:01
	.inst 0xc2dbc3bd // 0xc2dbc3bd
	.inst 0xa2120fe0 // 0xa2120fe0
	.inst 0xc2c21121 // 0xc2c21121
	.inst 0x4b5717bb // 0x4b5717bb
	.inst 0xd4000001
	.zero 65496
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
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a64 // ldr c4, [x19, #2]
	.inst 0xc2400e69 // ldr c9, [x19, #3]
	.inst 0xc2401278 // ldr c24, [x19, #4]
	.inst 0xc240167c // ldr c28, [x19, #5]
	.inst 0xc2401a7d // ldr c29, [x19, #6]
	.inst 0xc2401e7e // ldr c30, [x19, #7]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x19, =0x4000000
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884113 // msr CSP_EL0, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0x3c0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x0
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010f3 // ldr c19, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	mov x7, #0xf
	and x19, x19, x7
	cmp x19, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400267 // ldr c7, [x19, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400667 // ldr c7, [x19, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400a67 // ldr c7, [x19, #2]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400e67 // ldr c7, [x19, #3]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401267 // ldr c7, [x19, #4]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401667 // ldr c7, [x19, #5]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2401a67 // ldr c7, [x19, #6]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2401e67 // ldr c7, [x19, #7]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402267 // ldr c7, [x19, #8]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402667 // ldr c7, [x19, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x7, v29.d[0]
	cmp x19, x7
	b.ne comparison_fail
	ldr x19, =0x0
	mov x7, v29.d[1]
	cmp x19, x7
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984107 // mrs c7, CSP_EL0
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010c0
	ldr x1, =check_data0
	ldr x2, =0x000010c2
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001210
	ldr x1, =check_data1
	ldr x2, =0x00001220
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400040
	ldr x1, =check_data3
	ldr x2, =0x40400042
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x9d, 0x03, 0x0c, 0x7c, 0x1b, 0x43, 0xd8, 0xc2, 0x14, 0xe0, 0xc1, 0x82, 0xcd, 0x27, 0xde, 0xc2
	.byte 0x80, 0xa4, 0xc9, 0x78, 0xbd, 0xc3, 0xdb, 0xc2, 0xe0, 0x0f, 0x12, 0xa2, 0x21, 0x11, 0xc2, 0xc2
	.byte 0xbb, 0x17, 0x57, 0x4b, 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000
	/* C1 */
	.octa 0x40000000
	/* C4 */
	.octa 0x80000000000504030000000040400040
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0x795070000000000048001
	/* C28 */
	.octa 0x40000000000700030000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x70000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40000000
	/* C4 */
	.octa 0x800000000005040300000000404000da
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C13 */
	.octa 0x7ffffffffffffffff
	/* C20 */
	.octa 0x9d
	/* C24 */
	.octa 0x795070000000000048001
	/* C28 */
	.octa 0x40000000000700030000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x70000000000000000
initial_SP_EL0_value:
	.octa 0x40000000000100070000000000002010
initial_DDC_EL0_value:
	.octa 0x800000004002d00200000000403fa001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x40000000000100070000000000001210
final_PCC_value:
	.octa 0x200080000047c0070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000047c0070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40400028
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
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
