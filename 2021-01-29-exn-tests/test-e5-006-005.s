.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac01000 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:0 Rn:0 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0x2ccb15a8 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:8 Rn:13 Rt2:00101 imm7:0010110 L:1 1011001:1011001 opc:00
	.inst 0x9ac825a2 // lsrv:aarch64/instrs/integer/shift/variable Rd:2 Rn:13 op2:01 0010:0010 Rm:8 0011010110:0011010110 sf:1
	.inst 0xc2c21321 // CHKSLD-C-C 00001:00001 Cn:25 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x425f7c15 // ALDAR-C.R-C Ct:21 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.zero 46060
	.inst 0x5ac001c0 // 0x5ac001c0
	.inst 0xf1161c72 // 0xf1161c72
	.inst 0x5452e22b // 0x5452e22b
	.inst 0xdac0051d // 0xdac0051d
	.inst 0xd4000001
	.zero 19436
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
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e3 // ldr c3, [x23, #1]
	.inst 0xc2400aed // ldr c13, [x23, #2]
	.inst 0xc2400ef9 // ldr c25, [x23, #3]
	/* Set up flags and system registers */
	ldr x23, =0x4000000
	msr SPSR_EL3, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0x3c0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x4
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012d7 // ldr c23, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x22, #0xf
	and x23, x23, x22
	cmp x23, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f6 // ldr c22, [x23, #0]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc24006f6 // ldr c22, [x23, #1]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2400af6 // ldr c22, [x23, #2]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2400ef6 // ldr c22, [x23, #3]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0xc0c0c0c0
	mov x22, v5.d[0]
	cmp x23, x22
	b.ne comparison_fail
	ldr x23, =0x0
	mov x22, v5.d[1]
	cmp x23, x22
	b.ne comparison_fail
	ldr x23, =0xc0c0c0c0
	mov x22, v8.d[0]
	cmp x23, x22
	b.ne comparison_fail
	ldr x23, =0x0
	mov x22, v8.d[1]
	cmp x23, x22
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	ldr x22, =esr_el1_dump_address
	ldr x22, [x22]
	mov x23, 0x83
	orr x22, x22, x23
	ldr x23, =0x920000a3
	cmp x23, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x00001088
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x4040b400
	ldr x1, =check_data2
	ldr x2, =0x4040b414
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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
	.zero 128
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0
.data
check_data1:
	.byte 0x00, 0x10, 0xc0, 0xda, 0xa8, 0x15, 0xcb, 0x2c, 0xa2, 0x25, 0xc8, 0x9a, 0x21, 0x13, 0xc2, 0xc2
	.byte 0x15, 0x7c, 0x5f, 0x42
.data
check_data2:
	.byte 0xc0, 0x01, 0xc0, 0x5a, 0x72, 0x1c, 0x16, 0xf1, 0x2b, 0xe2, 0x52, 0x54, 0x1d, 0x05, 0xc0, 0xda
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x200093e7af86a74f
	/* C3 */
	.octa 0x800
	/* C13 */
	.octa 0x80000000200060000000000000001080
	/* C25 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C3 */
	.octa 0x800
	/* C13 */
	.octa 0x800000002000600000000000000010d8
	/* C18 */
	.octa 0x279
	/* C25 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x800000000001c4870080000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000a41d000000004040b000
final_PCC_value:
	.octa 0x200080004000a41d000000004040b414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword initial_DDC_EL0_value
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
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x4040b414
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
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
