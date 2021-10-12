.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac01000 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:0 Rn:0 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0x2ccb15a8 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:8 Rn:13 Rt2:00101 imm7:0010110 L:1 1011001:1011001 opc:00
	.inst 0x9ac825a2 // lsrv:aarch64/instrs/integer/shift/variable Rd:2 Rn:13 op2:01 0010:0010 Rm:8 0011010110:0011010110 sf:1
	.inst 0xc2c21321 // CHKSLD-C-C 00001:00001 Cn:25 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x425f7c15 // ALDAR-C.R-C Ct:21 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.zero 5100
	.inst 0x5ac001c0 // 0x5ac001c0
	.inst 0xf1161c72 // 0xf1161c72
	.inst 0x5452e22b // 0x5452e22b
	.inst 0xdac0051d // 0xdac0051d
	.inst 0xd4000001
	.zero 60396
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
	.inst 0xc2400663 // ldr c3, [x19, #1]
	.inst 0xc2400a6d // ldr c13, [x19, #2]
	.inst 0xc2400e79 // ldr c25, [x19, #3]
	/* Set up flags and system registers */
	ldr x19, =0x4000000
	msr SPSR_EL3, x19
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
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601133 // ldr c19, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
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
	mov x9, #0xf
	and x19, x19, x9
	cmp x19, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400269 // ldr c9, [x19, #0]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2400669 // ldr c9, [x19, #1]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc2400a69 // ldr c9, [x19, #2]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2400e69 // ldr c9, [x19, #3]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0xc0c0c0c0
	mov x9, v5.d[0]
	cmp x19, x9
	b.ne comparison_fail
	ldr x19, =0x0
	mov x9, v5.d[1]
	cmp x19, x9
	b.ne comparison_fail
	ldr x19, =0xc0c0c0c0
	mov x9, v8.d[0]
	cmp x19, x9
	b.ne comparison_fail
	ldr x19, =0x0
	mov x9, v8.d[1]
	cmp x19, x9
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	ldr x9, =esr_el1_dump_address
	ldr x9, [x9]
	mov x19, 0x83
	orr x9, x9, x19
	ldr x19, =0x920000ab
	cmp x19, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001014
	ldr x1, =check_data0
	ldr x2, =0x0000101c
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
	ldr x0, =0x40401400
	ldr x1, =check_data2
	ldr x2, =0x40401414
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0x00, 0x00, 0x00, 0x00
	.zero 4064
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
	.octa 0x4f9ba1bf6babff00
	/* C3 */
	.octa 0x4000000000000000
	/* C13 */
	.octa 0x80000000000100050000000000001014
	/* C25 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C3 */
	.octa 0x4000000000000000
	/* C13 */
	.octa 0x8000000000010005000000000000106c
	/* C18 */
	.octa 0x3ffffffffffffa79
	/* C25 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x0
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040401000
final_PCC_value:
	.octa 0x200080004000041d0000000040401414
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
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40401414
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
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
