.section text0, #alloc, #execinstr
test_start:
	.inst 0x91345bad // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:13 Rn:29 imm12:110100010110 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xf255b57d // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:29 Rn:11 imms:101101 immr:010101 N:1 100100:100100 opc:11 sf:1
	.inst 0x1ad62e40 // rorv:aarch64/instrs/integer/shift/variable Rd:0 Rn:18 op2:11 0010:0010 Rm:22 0011010110:0011010110 sf:0
	.inst 0xc2d94938 // UNSEAL-C.CC-C Cd:24 Cn:9 0010:0010 opc:01 Cm:25 11000010110:11000010110
	.inst 0xe2019881 // ALDURSB-R.RI-64 Rt:1 Rn:4 op2:10 imm9:000011001 V:0 op1:00 11100010:11100010
	.zero 33772
	.inst 0x9b34fffe // 0x9b34fffe
	.inst 0xb8fe32b0 // 0xb8fe32b0
	.inst 0xfa4063ea // 0xfa4063ea
	.inst 0xc8df7c1f // 0xc8df7c1f
	.inst 0xd4000001
	.zero 31724
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
	ldr x2, =initial_cap_values
	.inst 0xc2400044 // ldr c4, [x2, #0]
	.inst 0xc2400449 // ldr c9, [x2, #1]
	.inst 0xc240084b // ldr c11, [x2, #2]
	.inst 0xc2400c52 // ldr c18, [x2, #3]
	.inst 0xc2401055 // ldr c21, [x2, #4]
	.inst 0xc2401456 // ldr c22, [x2, #5]
	.inst 0xc2401859 // ldr c25, [x2, #6]
	/* Set up flags and system registers */
	ldr x2, =0x4000000
	msr SPSR_EL3, x2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0xc0000
	msr CPACR_EL1, x2
	ldr x2, =0x0
	msr S3_0_C1_C2_2, x2 // CCTLR_EL1
	ldr x2, =0x0
	msr S3_3_C1_C2_2, x2 // CCTLR_EL0
	ldr x2, =initial_DDC_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884122 // msr DDC_EL0, c2
	ldr x2, =initial_DDC_EL1_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc28c4122 // msr DDC_EL1, c2
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601142 // ldr c2, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e4022 // msr CELR_EL3, c2
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x10, #0xf
	and x2, x2, x10
	cmp x2, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc240004a // ldr c10, [x2, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240044a // ldr c10, [x2, #1]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc240084a // ldr c10, [x2, #2]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc2400c4a // ldr c10, [x2, #3]
	.inst 0xc2caa561 // chkeq c11, c10
	b.ne comparison_fail
	.inst 0xc240104a // ldr c10, [x2, #4]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc240144a // ldr c10, [x2, #5]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc240184a // ldr c10, [x2, #6]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc2401c4a // ldr c10, [x2, #7]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc240204a // ldr c10, [x2, #8]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc240244a // ldr c10, [x2, #9]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc240284a // ldr c10, [x2, #10]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2402c4a // ldr c10, [x2, #11]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x2, 0x83
	orr x10, x10, x2
	ldr x2, =0x920000ab
	cmp x2, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
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
	ldr x0, =0x40408400
	ldr x1, =check_data2
	ldr x2, =0x40408414
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
	.byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
.data
check_data1:
	.byte 0xad, 0x5b, 0x34, 0x91, 0x7d, 0xb5, 0x55, 0xf2, 0x40, 0x2e, 0xd6, 0x1a, 0x38, 0x49, 0xd9, 0xc2
	.byte 0x81, 0x98, 0x01, 0xe2
.data
check_data2:
	.byte 0xfe, 0xff, 0x34, 0x9b, 0xb0, 0x32, 0xfe, 0xb8, 0xea, 0x63, 0x40, 0xfa, 0x1f, 0x7c, 0xdf, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x7fffffffffffe7
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x10000000000020
	/* C18 */
	.octa 0x1
	/* C21 */
	.octa 0x1000
	/* C22 */
	.octa 0x14
	/* C25 */
	.octa 0x4000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C4 */
	.octa 0x7fffffffffffe7
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x10000000000020
	/* C16 */
	.octa 0xfefefefe
	/* C18 */
	.octa 0x1
	/* C21 */
	.octa 0x1000
	/* C22 */
	.octa 0x14
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x10000000000020
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0xc0000000200180060000000040000001
initial_VBAR_EL1_value:
	.octa 0x200080005000741d0000000040408000
final_PCC_value:
	.octa 0x200080005000741d0000000040408414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200020000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
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
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600d42 // ldr x2, [c10, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d42 // str x2, [c10, #0]
	ldr x2, =0x40408414
	mrs x10, ELR_EL1
	sub x2, x2, x10
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04a // cvtp c10, x2
	.inst 0xc2c2414a // scvalue c10, c10, x2
	.inst 0x82600142 // ldr c2, [c10, #0]
	.inst 0x021e0042 // add c2, c2, #1920
	.inst 0xc2c21040 // br c2

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
