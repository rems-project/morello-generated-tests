.section text0, #alloc, #execinstr
test_start:
	.inst 0x889f7c1e // stllr:aarch64/instrs/memory/ordered Rt:30 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x081ffcdd // stlxrb:aarch64/instrs/memory/exclusive/single Rt:29 Rn:6 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0x382012bf // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:001 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x429b6966 // STP-C.RIB-C Ct:6 Rn:11 Ct2:11010 imm7:0110110 L:0 010000101:010000101
	.inst 0xadb4603e // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:30 Rn:1 Rt2:11000 imm7:1101000 L:0 1011011:1011011 opc:10
	.zero 52204
	.inst 0x787f509f // 0x787f509f
	.inst 0xc2dd8bfd // 0xc2dd8bfd
	.inst 0xc2c81a3f // 0xc2c81a3f
	.inst 0x8a75d7b7 // 0x8a75d7b7
	.inst 0xd4000001
	.zero 13292
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2400c66 // ldr c6, [x3, #3]
	.inst 0xc240106b // ldr c11, [x3, #4]
	.inst 0xc2401471 // ldr c17, [x3, #5]
	.inst 0xc2401875 // ldr c21, [x3, #6]
	.inst 0xc2401c7a // ldr c26, [x3, #7]
	.inst 0xc240207d // ldr c29, [x3, #8]
	.inst 0xc240247e // ldr c30, [x3, #9]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =initial_SP_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4103 // msr CSP_EL1, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0x3c0000
	msr CPACR_EL1, x3
	ldr x3, =0x4
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x4
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =initial_DDC_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4123 // msr DDC_EL1, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011a3 // ldr c3, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x13, #0xf
	and x3, x3, x13
	cmp x3, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006d // ldr c13, [x3, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240046d // ldr c13, [x3, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240086d // ldr c13, [x3, #2]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc2400c6d // ldr c13, [x3, #3]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc240106d // ldr c13, [x3, #4]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240146d // ldr c13, [x3, #5]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc240186d // ldr c13, [x3, #6]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc2401c6d // ldr c13, [x3, #7]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc240206d // ldr c13, [x3, #8]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc240246d // ldr c13, [x3, #9]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240286d // ldr c13, [x3, #10]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_SP_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc29c410d // mrs c13, CSP_EL1
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	ldr x13, =esr_el1_dump_address
	ldr x13, [x13]
	mov x3, 0x83
	orr x13, x13, x3
	ldr x3, =0x920000e3
	cmp x3, x13
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001081
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001114
	ldr x1, =check_data2
	ldr x2, =0x00001115
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001370
	ldr x1, =check_data3
	ldr x2, =0x00001390
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
	ldr x0, =0x4040cc00
	ldr x1, =check_data5
	ldr x2, =0x4040cc14
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
	.zero 272
	.byte 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3808
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x03
.data
check_data3:
	.byte 0x7c, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data4:
	.byte 0x1e, 0x7c, 0x9f, 0x88, 0xdd, 0xfc, 0x1f, 0x08, 0xbf, 0x12, 0x20, 0x38, 0x66, 0x69, 0x9b, 0x42
	.byte 0x3e, 0x60, 0xb4, 0xad
.data
check_data5:
	.byte 0x9f, 0x50, 0x7f, 0x78, 0xfd, 0x8b, 0xdd, 0xc2, 0x3f, 0x1a, 0xc8, 0xc2, 0xb7, 0xd7, 0x75, 0x8a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xefc
	/* C1 */
	.octa 0x1fe
	/* C4 */
	.octa 0x1386
	/* C6 */
	.octa 0xf7c
	/* C11 */
	.octa 0xf0c
	/* C17 */
	.octa 0x8001c0070000000000000001
	/* C21 */
	.octa 0x1010
	/* C26 */
	.octa 0x1000000000000
	/* C29 */
	.octa 0x3002600fffffffffe0001
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xefc
	/* C1 */
	.octa 0x1fe
	/* C4 */
	.octa 0x1386
	/* C6 */
	.octa 0xf7c
	/* C11 */
	.octa 0xf0c
	/* C17 */
	.octa 0x8001c0070000000000000001
	/* C21 */
	.octa 0x1010
	/* C23 */
	.octa 0x7bdd8dcffd0001
	/* C26 */
	.octa 0x1000000000000
	/* C29 */
	.octa 0x12045007bdd8dcffd0001
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x12045007bdd8dcffd0001
initial_DDC_EL0_value:
	.octa 0xcc00000053e201040000000000000000
initial_DDC_EL1_value:
	.octa 0xc0000000288020000000400060f30000
initial_VBAR_EL1_value:
	.octa 0x200080006000c01d000000004040c800
final_SP_EL1_value:
	.octa 0x8001c0070000000000000000
final_PCC_value:
	.octa 0x200080006000c01d000000004040cc14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000029900070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_SP_EL1_value
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x4040cc14
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
