.section text0, #alloc, #execinstr
test_start:
	.inst 0x1224d7f2 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:18 Rn:31 imms:110101 immr:100100 N:0 100100:100100 opc:00 sf:0
	.inst 0xd125a426 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:6 Rn:1 imm12:100101101001 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x889ffc64 // stlr:aarch64/instrs/memory/ordered Rt:4 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c411df // LDPBR-C.C-C Ct:31 Cn:14 100:100 opc:00 11000010110001000:11000010110001000
	.zero 112
	.inst 0xd4000001
	.zero 4
	.inst 0x08017c18 // stxrb:aarch64/instrs/memory/exclusive/single Rt:24 Rn:0 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:00
	.zero 27508
	.inst 0xb99e6496 // 0xb99e6496
	.inst 0xc2c6c10c // 0xc2c6c10c
	.inst 0x427f7c81 // 0x427f7c81
	.inst 0xc2c433b5 // 0xc2c433b5
	.zero 37872
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
	.inst 0xc2400a04 // ldr c4, [x16, #2]
	.inst 0xc2400e08 // ldr c8, [x16, #3]
	.inst 0xc240120e // ldr c14, [x16, #4]
	.inst 0xc240161d // ldr c29, [x16, #5]
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x80
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
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
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010b0 // ldr c16, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	mov x5, #0xf
	and x16, x16, x5
	cmp x16, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400205 // ldr c5, [x16, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400605 // ldr c5, [x16, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a05 // ldr c5, [x16, #2]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc2400e05 // ldr c5, [x16, #3]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2401205 // ldr c5, [x16, #4]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2401605 // ldr c5, [x16, #5]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc2401a05 // ldr c5, [x16, #6]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2401e05 // ldr c5, [x16, #7]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2402205 // ldr c5, [x16, #8]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2402605 // ldr c5, [x16, #9]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc2402a05 // ldr c5, [x16, #10]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402e05 // ldr c5, [x16, #11]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x16, 0x83
	orr x5, x5, x16
	ldr x16, =0x920000eb
	cmp x16, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001210
	ldr x1, =check_data2
	ldr x2, =0x00001214
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
	ldr x0, =0x40400080
	ldr x1, =check_data4
	ldr x2, =0x40400084
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400088
	ldr x1, =check_data5
	ldr x2, =0x4040008c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x404000a0
	ldr x1, =check_data6
	ldr x2, =0x404000a1
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40401f04
	ldr x1, =check_data7
	ldr x2, =0x40401f08
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x40406c00
	ldr x1, =check_data8
	ldr x2, =0x40406c10
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
	.zero 16
	.byte 0x80, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x40, 0xc0, 0x00, 0x80, 0x00, 0x20
	.zero 32
	.byte 0x89, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x07, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 4016
.data
check_data0:
	.zero 16
	.byte 0x80, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x40, 0xc0, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 16
	.byte 0x89, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x07, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0xa0, 0x00, 0x40, 0x40
.data
check_data3:
	.byte 0xf2, 0xd7, 0x24, 0x12, 0x26, 0xa4, 0x25, 0xd1, 0x64, 0xfc, 0x9f, 0x88, 0xdf, 0x11, 0xc4, 0xc2
.data
check_data4:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0x18, 0x7c, 0x01, 0x08
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 4
.data
check_data8:
	.byte 0x96, 0x64, 0x9e, 0xb9, 0x0c, 0xc1, 0xc6, 0xc2, 0x81, 0x7c, 0x7f, 0x42, 0xb5, 0x33, 0xc4, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000207400fff00000000000000
	/* C3 */
	.octa 0x1210
	/* C4 */
	.octa 0x800000007002ff0a00000000404000a0
	/* C8 */
	.octa 0x40000
	/* C14 */
	.octa 0x90000000500110020000000000001030
	/* C29 */
	.octa 0x90100000508100000000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400000000207400fff00000000000000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1210
	/* C4 */
	.octa 0x800000007002ff0a00000000404000a0
	/* C8 */
	.octa 0x40000
	/* C12 */
	.octa 0x40000
	/* C14 */
	.octa 0x90000000500110020000000000001030
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x90100000508100000000000000001000
	/* C30 */
	.octa 0x20008000ec404c410000000040406c11
initial_DDC_EL0_value:
	.octa 0x400000000010c0000000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000400000040000000040400001
initial_VBAR_EL1_value:
	.octa 0x200080006c404c410000000040406801
final_PCC_value:
	.octa 0x20008000404000800000000040400084
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000e0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001030
	.dword 0x0000000000001040
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400084
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
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
