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
	.zero 49128
	.inst 0xc0c0c0c0
	.inst 0xc0c0c0c0
	.inst 0xc0c0c0c0
	.inst 0xc0c0c0c0
	.zero 16352
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400683 // ldr c3, [x20, #1]
	.inst 0xc2400a8d // ldr c13, [x20, #2]
	.inst 0xc2400e99 // ldr c25, [x20, #3]
	/* Set up flags and system registers */
	ldr x20, =0x4000000
	msr SPSR_EL3, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30d5d99f
	msr SCTLR_EL1, x20
	ldr x20, =0x3c0000
	msr CPACR_EL1, x20
	ldr x20, =0x0
	msr S3_0_C1_C2_2, x20 // CCTLR_EL1
	ldr x20, =0x4
	msr S3_3_C1_C2_2, x20 // CCTLR_EL0
	ldr x20, =initial_DDC_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2884134 // msr DDC_EL0, c20
	ldr x20, =0x80000000
	msr HCR_EL2, x20
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601214 // ldr c20, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc28e4034 // msr CELR_EL3, c20
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x16, #0xf
	and x20, x20, x16
	cmp x20, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400290 // ldr c16, [x20, #0]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400690 // ldr c16, [x20, #1]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc2400a90 // ldr c16, [x20, #2]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc2400e90 // ldr c16, [x20, #3]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc2401290 // ldr c16, [x20, #4]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0xc0c0c0c0
	mov x16, v5.d[0]
	cmp x20, x16
	b.ne comparison_fail
	ldr x20, =0x0
	mov x16, v5.d[1]
	cmp x20, x16
	b.ne comparison_fail
	ldr x20, =0xc0c0c0c0
	mov x16, v8.d[0]
	cmp x20, x16
	b.ne comparison_fail
	ldr x20, =0x0
	mov x16, v8.d[1]
	cmp x20, x16
	b.ne comparison_fail
	/* Check system registers */
	ldr x20, =final_PCC_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001034
	ldr x1, =check_data0
	ldr x2, =0x0000103c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x4040c010
	ldr x1, =check_data2
	ldr x2, =0x4040c020
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
	.zero 48
	.byte 0x00, 0x00, 0x00, 0x00, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0x00, 0x00, 0x00, 0x00
	.zero 4032
.data
check_data0:
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0
.data
check_data1:
	.byte 0x00, 0x10, 0xc0, 0xda, 0xa8, 0x15, 0xcb, 0x2c, 0xa2, 0x25, 0xc8, 0x9a, 0x21, 0x13, 0xc2, 0xc2
	.byte 0x15, 0x7c, 0x5f, 0x42, 0xc0, 0x01, 0xc0, 0x5a, 0x72, 0x1c, 0x16, 0xf1, 0x2b, 0xe2, 0x52, 0x54
	.byte 0x1d, 0x05, 0xc0, 0xda, 0x01, 0x00, 0x00, 0xd4
.data
check_data2:
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2049ed00fe6febaf
	/* C3 */
	.octa 0x4000000000000000
	/* C13 */
	.octa 0x80000000000100050000000000001034
	/* C25 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C3 */
	.octa 0x4000000000000000
	/* C13 */
	.octa 0x8000000000010005000000000000108c
	/* C18 */
	.octa 0x3ffffffffffffa79
	/* C21 */
	.octa 0xc0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0
	/* C25 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x901000004000c00e0000000040410001
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
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
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
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02000294 // add c20, c20, #0
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02020294 // add c20, c20, #128
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02040294 // add c20, c20, #256
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02060294 // add c20, c20, #384
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02080294 // add c20, c20, #512
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x020a0294 // add c20, c20, #640
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x020c0294 // add c20, c20, #768
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x020e0294 // add c20, c20, #896
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02100294 // add c20, c20, #1024
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02120294 // add c20, c20, #1152
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02140294 // add c20, c20, #1280
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02160294 // add c20, c20, #1408
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02180294 // add c20, c20, #1536
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x021a0294 // add c20, c20, #1664
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x021c0294 // add c20, c20, #1792
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400028
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x021e0294 // add c20, c20, #1920
	.inst 0xc2c21280 // br c20

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
