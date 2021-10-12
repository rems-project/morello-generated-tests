.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2ddc420 // RETS-C.C-C 00000:00000 Cn:1 001:001 opc:10 1:1 Cm:29 11000010110:11000010110
	.zero 16364
	.inst 0xc2c21061 // CHKSLD-C-C 00001:00001 Cn:3 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xda805008 // csinv:aarch64/instrs/integer/conditional/select Rd:8 Rn:0 o2:0 0:0 cond:0101 Rm:0 011010100:011010100 op:1 sf:1
	.inst 0x425f7e1f // ALDAR-C.R-C Ct:31 Rn:16 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c21161 // CHKSLD-C-C 00001:00001 Cn:11 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x6c3626a3 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:3 Rn:21 Rt2:01001 imm7:1101100 L:0 1011000:1011000 opc:01
	.inst 0x782f301f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:011 o3:0 Rs:15 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x39ee1412 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:18 Rn:0 imm12:101110000101 opc:11 111001:111001 size:00
	.inst 0x5a010021 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:1 000000:000000 Rm:1 11010000:11010000 S:0 op:1 sf:0
	.inst 0xd4000001
	.zero 49132
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400883 // ldr c3, [x4, #2]
	.inst 0xc2400c8b // ldr c11, [x4, #3]
	.inst 0xc240108f // ldr c15, [x4, #4]
	.inst 0xc2401490 // ldr c16, [x4, #5]
	.inst 0xc2401895 // ldr c21, [x4, #6]
	.inst 0xc2401c9d // ldr c29, [x4, #7]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q3, =0x0
	ldr q9, =0x100000000000000
	/* Set up flags and system registers */
	ldr x4, =0x0
	msr SPSR_EL3, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0x3c0000
	msr CPACR_EL1, x4
	ldr x4, =0x0
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =0x0
	msr S3_3_C1_C2_2, x4 // CCTLR_EL0
	ldr x4, =initial_DDC_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884124 // msr DDC_EL0, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601324 // ldr c4, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc28e4024 // msr CELR_EL3, c4
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x25, #0xf
	and x4, x4, x25
	cmp x4, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400099 // ldr c25, [x4, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400499 // ldr c25, [x4, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400899 // ldr c25, [x4, #2]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2400c99 // ldr c25, [x4, #3]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2401099 // ldr c25, [x4, #4]
	.inst 0xc2d9a561 // chkeq c11, c25
	b.ne comparison_fail
	.inst 0xc2401499 // ldr c25, [x4, #5]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2401899 // ldr c25, [x4, #6]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401c99 // ldr c25, [x4, #7]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2402099 // ldr c25, [x4, #8]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc2402499 // ldr c25, [x4, #9]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x25, v3.d[0]
	cmp x4, x25
	b.ne comparison_fail
	ldr x4, =0x0
	mov x25, v3.d[1]
	cmp x4, x25
	b.ne comparison_fail
	ldr x4, =0x100000000000000
	mov x25, v9.d[0]
	cmp x4, x25
	b.ne comparison_fail
	ldr x4, =0x0
	mov x25, v9.d[1]
	cmp x4, x25
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001178
	ldr x1, =check_data0
	ldr x2, =0x00001188
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001478
	ldr x1, =check_data1
	ldr x2, =0x0000147a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffd
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40403ff0
	ldr x1, =check_data5
	ldr x2, =0x40404014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x20, 0xc4, 0xdd, 0xc2
.data
check_data5:
	.byte 0x61, 0x10, 0xc2, 0xc2, 0x08, 0x50, 0x80, 0xda, 0x1f, 0x7e, 0x5f, 0x42, 0x61, 0x11, 0xc2, 0xc2
	.byte 0xa3, 0x26, 0x36, 0x6c, 0x1f, 0x30, 0x2f, 0x78, 0x12, 0x14, 0xee, 0x39, 0x21, 0x00, 0x01, 0x5a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1478
	/* C1 */
	.octa 0x20408002480737fe0000000040403ff0
	/* C3 */
	.octa 0x0
	/* C11 */
	.octa 0x3fff800000000000000000000000
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x80100000000100050000000000001fe0
	/* C21 */
	.octa 0x1218
	/* C29 */
	.octa 0x400002000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1478
	/* C1 */
	.octa 0xffffffff
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0x1478
	/* C11 */
	.octa 0x3fff800000000000000000000000
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x80100000000100050000000000001fe0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x1218
	/* C29 */
	.octa 0x400000000000000000000000000000
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20408000480737fe0000000040404014
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000024000d0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 96
	.dword final_cap_values + 144
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600f24 // ldr x4, [c25, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400f24 // str x4, [c25, #0]
	ldr x4, =0x40404014
	mrs x25, ELR_EL1
	sub x4, x4, x25
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b099 // cvtp c25, x4
	.inst 0xc2c44339 // scvalue c25, c25, x4
	.inst 0x82600324 // ldr c4, [c25, #0]
	.inst 0x021e0084 // add c4, c4, #1920
	.inst 0xc2c21080 // br c4

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
