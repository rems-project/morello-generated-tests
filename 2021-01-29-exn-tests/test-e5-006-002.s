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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c3 // ldr c3, [x6, #1]
	.inst 0xc24008cd // ldr c13, [x6, #2]
	.inst 0xc2400cd9 // ldr c25, [x6, #3]
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0x3c0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x4
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601366 // ldr c6, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x27, #0xf
	and x6, x6, x27
	cmp x6, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000db // ldr c27, [x6, #0]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc24004db // ldr c27, [x6, #1]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc24008db // ldr c27, [x6, #2]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc2400cdb // ldr c27, [x6, #3]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0xc0c0c0c0
	mov x27, v5.d[0]
	cmp x6, x27
	b.ne comparison_fail
	ldr x6, =0x0
	mov x27, v5.d[1]
	cmp x6, x27
	b.ne comparison_fail
	ldr x6, =0xc0c0c0c0
	mov x27, v8.d[0]
	cmp x6, x27
	b.ne comparison_fail
	ldr x6, =0x0
	mov x27, v8.d[1]
	cmp x6, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba4c1 // chkeq c6, c27
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x6, 0x83
	orr x27, x27, x6
	ldr x6, =0x920000ab
	cmp x6, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff4
	ldr x1, =check_data0
	ldr x2, =0x00001ffc
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
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0x00, 0x00, 0x00, 0x00
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
	.octa 0xffff003b12eb
	/* C3 */
	.octa 0x4000000000000000
	/* C13 */
	.octa 0x80000000000100050000000000001ff4
	/* C25 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C3 */
	.octa 0x4000000000000000
	/* C13 */
	.octa 0x8000000000010005000000000000204c
	/* C18 */
	.octa 0x3ffffffffffffa79
	/* C25 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc001c001008080400000a000
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040401000
final_PCC_value:
	.octa 0x200080004000041d0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000401c0050000000040400000
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600f66 // ldr x6, [c27, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f66 // str x6, [c27, #0]
	ldr x6, =0x40401414
	mrs x27, ELR_EL1
	sub x6, x6, x27
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0db // cvtp c27, x6
	.inst 0xc2c6437b // scvalue c27, c27, x6
	.inst 0x82600366 // ldr c6, [c27, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
