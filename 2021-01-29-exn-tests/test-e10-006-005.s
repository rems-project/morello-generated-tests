.section text0, #alloc, #execinstr
test_start:
	.inst 0x38a00376 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:27 00:00 opc:000 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xdac007b9 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:25 Rn:29 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xdac0143f // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:31 Rn:1 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x78107824 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:4 Rn:1 10:10 imm9:100000111 0:0 opc:00 111000:111000 size:01
	.inst 0xe2c3d07e // ASTUR-R.RI-64 Rt:30 Rn:3 op2:00 imm9:000111101 V:0 op1:11 11100010:11100010
	.zero 1004
	.inst 0x782d60bf // 0x782d60bf
	.inst 0xe24a2c17 // 0xe24a2c17
	.inst 0xb789c64d // 0xb789c64d
	.inst 0xa25ecaa5 // 0xa25ecaa5
	.inst 0xd4000001
	.zero 64492
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
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b03 // ldr c3, [x24, #2]
	.inst 0xc2400f04 // ldr c4, [x24, #3]
	.inst 0xc2401305 // ldr c5, [x24, #4]
	.inst 0xc240170d // ldr c13, [x24, #5]
	.inst 0xc2401b15 // ldr c21, [x24, #6]
	.inst 0xc2401f1b // ldr c27, [x24, #7]
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
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601158 // ldr c24, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240030a // ldr c10, [x24, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240070a // ldr c10, [x24, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400b0a // ldr c10, [x24, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400f0a // ldr c10, [x24, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc240130a // ldr c10, [x24, #4]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240170a // ldr c10, [x24, #5]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc2401b0a // ldr c10, [x24, #6]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc2401f0a // ldr c10, [x24, #7]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc240230a // ldr c10, [x24, #8]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc240270a // ldr c10, [x24, #9]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x24, 0x83
	orr x10, x10, x24
	ldr x24, =0x920000e3
	cmp x24, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c8
	ldr x1, =check_data1
	ldr x2, =0x000010ca
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f08
	ldr x1, =check_data2
	ldr x2, =0x00001f0a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
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
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.byte 0xdb, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00
	.zero 16
.data
check_data0:
	.byte 0x01, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00
.data
check_data4:
	.byte 0x76, 0x03, 0xa0, 0x38, 0xb9, 0x07, 0xc0, 0xda, 0x3f, 0x14, 0xc0, 0xda, 0x24, 0x78, 0x10, 0x78
	.byte 0x7e, 0xd0, 0xc3, 0xe2
.data
check_data5:
	.byte 0xbf, 0x60, 0x2d, 0x78, 0x17, 0x2c, 0x4a, 0xe2, 0x4d, 0xc6, 0x89, 0xb7, 0xa5, 0xca, 0x5e, 0xa2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1026
	/* C1 */
	.octa 0x2001
	/* C3 */
	.octa 0x4000000040240000007fffffffffffc4
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0xc0000000580100040000000000001000
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0x90000000000100050000000000002120
	/* C27 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1026
	/* C1 */
	.octa 0x2001
	/* C3 */
	.octa 0x4000000040240000007fffffffffffc4
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x101000000000000000000000000
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0x90000000000100050000000000002120
	/* C22 */
	.octa 0xdb
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc00000000007000700ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x80000000000080080000000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000400000010000000040400001
final_PCC_value:
	.octa 0x20008000400000010000000040400414
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
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 96
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
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40400414
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
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
