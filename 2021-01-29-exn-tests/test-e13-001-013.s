.section text0, #alloc, #execinstr
test_start:
	.inst 0x1224d7f2 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:18 Rn:31 imms:110101 immr:100100 N:0 100100:100100 opc:00 sf:0
	.inst 0xd125a426 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:6 Rn:1 imm12:100101101001 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x889ffc64 // stlr:aarch64/instrs/memory/ordered Rt:4 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c411df // LDPBR-C.C-C Ct:31 Cn:14 100:100 opc:00 11000010110001000:11000010110001000
	.zero 4
	.inst 0xd4000001
	.zero 104
	.inst 0x08017c18 // stxrb:aarch64/instrs/memory/exclusive/single Rt:24 Rn:0 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:00
	.zero 50044
	.inst 0xb99e6496 // 0xb99e6496
	.inst 0xc2c6c10c // 0xc2c6c10c
	.inst 0x427f7c81 // 0x427f7c81
	.inst 0xc2c433b5 // 0xc2c433b5
	.zero 15344
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400703 // ldr c3, [x24, #1]
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2400f08 // ldr c8, [x24, #3]
	.inst 0xc240130e // ldr c14, [x24, #4]
	.inst 0xc240171d // ldr c29, [x24, #5]
	/* Set up flags and system registers */
	ldr x24, =0x0
	msr SPSR_EL3, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0xc0000
	msr CPACR_EL1, x24
	ldr x24, =0x4
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x0
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =initial_DDC_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28c4138 // msr DDC_EL1, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82601278 // ldr c24, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x19, #0xf
	and x24, x24, x19
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400313 // ldr c19, [x24, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400713 // ldr c19, [x24, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400b13 // ldr c19, [x24, #2]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2400f13 // ldr c19, [x24, #3]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc2401313 // ldr c19, [x24, #4]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc2401713 // ldr c19, [x24, #5]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc2401b13 // ldr c19, [x24, #6]
	.inst 0xc2d3a5c1 // chkeq c14, c19
	b.ne comparison_fail
	.inst 0xc2401f13 // ldr c19, [x24, #7]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2402313 // ldr c19, [x24, #8]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc2402713 // ldr c19, [x24, #9]
	.inst 0xc2d3a6c1 // chkeq c22, c19
	b.ne comparison_fail
	.inst 0xc2402b13 // ldr c19, [x24, #10]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2402f13 // ldr c19, [x24, #11]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984033 // mrs c19, CELR_EL1
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	mov x24, 0x83
	orr x19, x19, x24
	ldr x24, =0x920000eb
	cmp x24, x19
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
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f0
	ldr x1, =check_data2
	ldr x2, =0x00001110
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000118e
	ldr x1, =check_data3
	ldr x2, =0x0000118f
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400014
	ldr x1, =check_data5
	ldr x2, =0x40400018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400080
	ldr x1, =check_data6
	ldr x2, =0x40400084
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400100
	ldr x1, =check_data7
	ldr x2, =0x40400104
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x4040c400
	ldr x1, =check_data8
	ldr x2, =0x4040c410
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.zero 32
	.byte 0x14, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x03, 0xc4, 0x06, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 208
	.byte 0x81, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xc2, 0x00, 0x80, 0x00, 0x20
	.zero 3824
.data
check_data0:
	.byte 0x8e, 0x11, 0x00, 0x00
.data
check_data1:
	.zero 16
	.byte 0x14, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x03, 0xc4, 0x06, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 16
	.byte 0x81, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xc2, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xf2, 0xd7, 0x24, 0x12, 0x26, 0xa4, 0x25, 0xd1, 0x64, 0xfc, 0x9f, 0x88, 0xdf, 0x11, 0xc4, 0xc2
.data
check_data5:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0x18, 0x7c, 0x01, 0x08
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
	.octa 0x400000000007200e7080000000000000
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x8000000011c70407000000000000118e
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000000700b500000000000010f0
	/* C29 */
	.octa 0x90100000540008010000000000001010
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400000000007200e7080000000000000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x8000000011c70407000000000000118e
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000000700b500000000000010f0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x90100000540008010000000000001010
	/* C30 */
	.octa 0x200080004800c00d000000004040c410
initial_DDC_EL0_value:
	.octa 0x40000000580000020000000000000001
initial_DDC_EL1_value:
	.octa 0x800000004114d10e00000000403fc001
initial_VBAR_EL1_value:
	.octa 0x200080004800c00d000000004040c000
final_PCC_value:
	.octa 0x200080000006c4030000000040400018
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
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword 0x00000000000010f0
	.dword 0x0000000000001100
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600e78 // ldr x24, [c19, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e78 // str x24, [c19, #0]
	ldr x24, =0x40400018
	mrs x19, ELR_EL1
	sub x24, x24, x19
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b313 // cvtp c19, x24
	.inst 0xc2d84273 // scvalue c19, c19, x24
	.inst 0x82600278 // ldr c24, [c19, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
