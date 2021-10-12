.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac01000 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:0 Rn:0 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0x2ccb15a8 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:8 Rn:13 Rt2:00101 imm7:0010110 L:1 1011001:1011001 opc:00
	.inst 0x9ac825a2 // lsrv:aarch64/instrs/integer/shift/variable Rd:2 Rn:13 op2:01 0010:0010 Rm:8 0011010110:0011010110 sf:1
	.inst 0xc2c21321 // CHKSLD-C-C 00001:00001 Cn:25 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x425f7c15 // ALDAR-C.R-C Ct:21 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x5ac001c0 // 0x5ac001c0
	.inst 0xf1161c72 // 0xf1161c72
	.inst 0x5452e22b // 0x5452e22b
	.inst 0xdac0051d // 0xdac0051d
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400703 // ldr c3, [x24, #1]
	.inst 0xc2400b0d // ldr c13, [x24, #2]
	.inst 0xc2400f19 // ldr c25, [x24, #3]
	/* Set up flags and system registers */
	ldr x24, =0x4000000
	msr SPSR_EL3, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0x3c0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x4
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f8 // ldr c24, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	mov x23, #0xf
	and x24, x24, x23
	cmp x24, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400317 // ldr c23, [x24, #0]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400717 // ldr c23, [x24, #1]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc2400b17 // ldr c23, [x24, #2]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2400f17 // ldr c23, [x24, #3]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc2401317 // ldr c23, [x24, #4]
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x23, v5.d[0]
	cmp x24, x23
	b.ne comparison_fail
	ldr x24, =0x0
	mov x23, v5.d[1]
	cmp x24, x23
	b.ne comparison_fail
	ldr x24, =0x0
	mov x23, v8.d[0]
	cmp x24, x23
	b.ne comparison_fail
	ldr x24, =0x0
	mov x23, v8.d[1]
	cmp x24, x23
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a701 // chkeq c24, c23
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
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001808
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
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x10, 0xc0, 0xda, 0xa8, 0x15, 0xcb, 0x2c, 0xa2, 0x25, 0xc8, 0x9a, 0x21, 0x13, 0xc2, 0xc2
	.byte 0x15, 0x7c, 0x5f, 0x42, 0xc0, 0x01, 0xc0, 0x5a, 0x72, 0x1c, 0x16, 0xf1, 0x2b, 0xe2, 0x52, 0x54
	.byte 0x1d, 0x05, 0xc0, 0xda, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x82f504003bbffa00
	/* C3 */
	.octa 0x4000000000000000
	/* C13 */
	.octa 0x80000000000100050000000000001800
	/* C25 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C3 */
	.octa 0x4000000000000000
	/* C13 */
	.octa 0x80000000000100050000000000001858
	/* C18 */
	.octa 0x3ffffffffffffa79
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x90000000000704050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000000000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword initial_DDC_EL0_value
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
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40400028
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
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
