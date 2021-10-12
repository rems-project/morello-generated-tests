.section text0, #alloc, #execinstr
test_start:
	.inst 0xf82603df // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:000 o3:0 Rs:6 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c353de // SEAL-C.CI-C Cd:30 Cn:30 100:100 form:10 11000010110000110:11000010110000110
	.inst 0x54ebd607 // b_cond:aarch64/instrs/branch/conditional/cond cond:0111 0:0 imm19:1110101111010110000 01010100:01010100
	.inst 0xf8ed53af // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:15 Rn:29 00:00 opc:101 0:0 Rs:13 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x3d7c1dfe // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:30 Rn:15 imm12:111100000111 opc:01 111101:111101 size:00
	.zero 4
	.inst 0xf8bddb5f // 0xf8bddb5f
	.inst 0xd4000001
	.zero 992
	.inst 0x2224a131 // 0x2224a131
	.inst 0xc8df7fb3 // 0xc8df7fb3
	.inst 0xc2c21003 // 0xc2c21003
	.zero 64500
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
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400446 // ldr c6, [x2, #1]
	.inst 0xc2400848 // ldr c8, [x2, #2]
	.inst 0xc2400c49 // ldr c9, [x2, #3]
	.inst 0xc240104d // ldr c13, [x2, #4]
	.inst 0xc2401451 // ldr c17, [x2, #5]
	.inst 0xc240185d // ldr c29, [x2, #6]
	.inst 0xc2401c5e // ldr c30, [x2, #7]
	/* Set up flags and system registers */
	ldr x2, =0x14000000
	msr SPSR_EL3, x2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0xc0000
	msr CPACR_EL1, x2
	ldr x2, =0x4
	msr S3_0_C1_C2_2, x2 // CCTLR_EL1
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
	mov x10, #0x1
	and x2, x2, x10
	cmp x2, #0x1
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
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc2400c4a // ldr c10, [x2, #3]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc240104a // ldr c10, [x2, #4]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc240144a // ldr c10, [x2, #5]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc240184a // ldr c10, [x2, #6]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc2401c4a // ldr c10, [x2, #7]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc240204a // ldr c10, [x2, #8]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc240244a // ldr c10, [x2, #9]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc240284a // ldr c10, [x2, #10]
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
	mov x2, 0x0
	orr x10, x10, x2
	ldr x2, =0x1fe00000
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
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400018
	ldr x1, =check_data3
	ldr x2, =0x40400020
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x4040040c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.zero 2048
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data2:
	.byte 0xdf, 0x03, 0x26, 0xf8, 0xde, 0x53, 0xc3, 0xc2, 0x07, 0xd6, 0xeb, 0x54, 0xaf, 0x53, 0xed, 0xf8
	.byte 0xfe, 0x1d, 0x7c, 0x3d
.data
check_data3:
	.byte 0x5f, 0xdb, 0xbd, 0xf8, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.byte 0x31, 0xa1, 0x24, 0x22, 0xb3, 0x7f, 0xdf, 0xc8, 0x03, 0x10, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000800044c400050000000040400018
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x4000000000000000000000000000
	/* C9 */
	.octa 0x4c000000008180060000000000001000
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000100050000000000001800
	/* C30 */
	.octa 0xc0000000206100070000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x2000800044c400050000000040400018
	/* C4 */
	.octa 0x1
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x4000000000000000000000000000
	/* C9 */
	.octa 0x4c000000008180060000000000001000
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x8000000000000001
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x8000000000000001
	/* C29 */
	.octa 0xc0000000000100050000000000001800
	/* C30 */
	.octa 0xc0000001206100070000000000001000
initial_DDC_EL1_value:
	.octa 0x100060000000000000000
initial_VBAR_EL1_value:
	.octa 0x20008000500001050000000040400001
final_PCC_value:
	.octa 0x2000800044c400050000000040400020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
	ldr x2, =0x40400020
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
