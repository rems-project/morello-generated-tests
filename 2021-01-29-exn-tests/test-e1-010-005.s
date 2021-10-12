.section text0, #alloc, #execinstr
test_start:
	.inst 0x7c0c039d // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:29 Rn:28 00:00 imm9:011000000 0:0 opc:00 111100:111100 size:01
	.inst 0xc2d8431b // SCVALUE-C.CR-C Cd:27 Cn:24 000:000 opc:10 0:0 Rm:24 11000010110:11000010110
	.inst 0x82c1e014 // ALDRB-R.RRB-B Rt:20 Rn:0 opc:00 S:0 option:111 Rm:1 0:0 L:1 100000101:100000101
	.inst 0xc2de27cd // CPYTYPE-C.C-C Cd:13 Cn:30 001:001 opc:01 0:0 Cm:30 11000010110:11000010110
	.inst 0x78c9a480 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:4 01:01 imm9:010011010 0:0 opc:11 111000:111000 size:01
	.zero 1004
	.inst 0xc2dbc3bd // 0xc2dbc3bd
	.inst 0xa2120fe0 // 0xa2120fe0
	.inst 0xc2c21121 // 0xc2c21121
	.inst 0x4b5717bb // 0x4b5717bb
	.inst 0xd4000001
	.zero 64492
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
	.inst 0xc24008a4 // ldr c4, [x5, #2]
	.inst 0xc2400ca9 // ldr c9, [x5, #3]
	.inst 0xc24010b8 // ldr c24, [x5, #4]
	.inst 0xc24014bc // ldr c28, [x5, #5]
	.inst 0xc24018bd // ldr c29, [x5, #6]
	.inst 0xc2401cbe // ldr c30, [x5, #7]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x5, =0x4000000
	msr SPSR_EL3, x5
	ldr x5, =initial_SP_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4105 // msr CSP_EL1, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0x3c0000
	msr CPACR_EL1, x5
	ldr x5, =0x0
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
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82601045 // ldr c5, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
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
	mov x2, #0xf
	and x5, x5, x2
	cmp x5, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a2 // ldr c2, [x5, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc24008a2 // ldr c2, [x5, #2]
	.inst 0xc2c2a481 // chkeq c4, c2
	b.ne comparison_fail
	.inst 0xc2400ca2 // ldr c2, [x5, #3]
	.inst 0xc2c2a521 // chkeq c9, c2
	b.ne comparison_fail
	.inst 0xc24010a2 // ldr c2, [x5, #4]
	.inst 0xc2c2a5a1 // chkeq c13, c2
	b.ne comparison_fail
	.inst 0xc24014a2 // ldr c2, [x5, #5]
	.inst 0xc2c2a681 // chkeq c20, c2
	b.ne comparison_fail
	.inst 0xc24018a2 // ldr c2, [x5, #6]
	.inst 0xc2c2a701 // chkeq c24, c2
	b.ne comparison_fail
	.inst 0xc2401ca2 // ldr c2, [x5, #7]
	.inst 0xc2c2a781 // chkeq c28, c2
	b.ne comparison_fail
	.inst 0xc24020a2 // ldr c2, [x5, #8]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc24024a2 // ldr c2, [x5, #9]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x2, v29.d[0]
	cmp x5, x2
	b.ne comparison_fail
	ldr x5, =0x0
	mov x2, v29.d[1]
	cmp x5, x2
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc29c4102 // mrs c2, CSP_EL1
	.inst 0xc2c2a4a1 // chkeq c5, c2
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a4a1 // chkeq c5, c2
	b.ne comparison_fail
	ldr x2, =esr_el1_dump_address
	ldr x2, [x2]
	mov x5, 0x83
	orr x2, x2, x5
	ldr x5, =0x920000a3
	cmp x5, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c0
	ldr x1, =check_data1
	ldr x2, =0x000010c2
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
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.byte 0x00, 0x00, 0x00, 0x20, 0x0d, 0x00, 0x00, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x9d, 0x03, 0x0c, 0x7c, 0x1b, 0x43, 0xd8, 0xc2, 0x14, 0xe0, 0xc1, 0x82, 0xcd, 0x27, 0xde, 0xc2
	.byte 0x80, 0xa4, 0xc9, 0x78
.data
check_data4:
	.byte 0xbd, 0xc3, 0xdb, 0xc2, 0xe0, 0x0f, 0x12, 0xa2, 0x21, 0x11, 0xc2, 0xc2, 0xbb, 0x17, 0x57, 0x4b
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20000000000f000000d20000000
	/* C1 */
	.octa 0xffffff2e0001ffe
	/* C4 */
	.octa 0x800000004024900cff9c7ffffefea001
	/* C9 */
	.octa 0x0
	/* C24 */
	.octa 0x44000200000000020103e000
	/* C28 */
	.octa 0x40000000000080400000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x10000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x20000000000f000000d20000000
	/* C1 */
	.octa 0xffffff2e0001ffe
	/* C4 */
	.octa 0x800000004024900cff9c7ffffefea001
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x1ffffffffffffffff
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x44000200000000020103e000
	/* C28 */
	.octa 0x40000000000080400000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x10000000000000000
initial_SP_EL1_value:
	.octa 0x1e00
initial_DDC_EL0_value:
	.octa 0x800000006000000400ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x40000000000700870000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000f8540070000000040400000
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600c45 // ldr x5, [c2, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c45 // str x5, [c2, #0]
	ldr x5, =0x40400414
	mrs x2, ELR_EL1
	sub x5, x5, x2
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a2 // cvtp c2, x5
	.inst 0xc2c54042 // scvalue c2, c2, x5
	.inst 0x82600045 // ldr c5, [c2, #0]
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
