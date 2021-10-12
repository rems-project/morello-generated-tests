.section text0, #alloc, #execinstr
test_start:
	.inst 0x82a1e01e // ASTR-R.RRB-32 Rt:30 Rn:0 opc:00 S:0 option:111 Rm:1 1:1 L:0 100000101:100000101
	.inst 0x78ae23e1 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:31 00:00 opc:010 0:0 Rs:14 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x9bdd7ea1 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:21 Ra:11111 0:0 Rm:29 10:10 U:1 10011011:10011011
	.inst 0x085f7dbd // ldxrb:aarch64/instrs/memory/exclusive/single Rt:29 Rn:13 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xc2f629e3 // ORRFLGS-C.CI-C Cd:3 Cn:15 0:0 01:01 imm8:10110001 11000010111:11000010111
	.inst 0xc2dc4921 // UNSEAL-C.CC-C Cd:1 Cn:9 0010:0010 opc:01 Cm:28 11000010110:11000010110
	.inst 0x787d6014 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:20 Rn:0 00:00 opc:110 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc2df083d // SEAL-C.CC-C Cd:29 Cn:1 0010:0010 opc:00 Cm:31 11000010110:11000010110
	.inst 0xf86800df // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:000 o3:0 Rs:8 1:1 R:1 A:0 00:00 V:0 111:111 size:11
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a06 // ldr c6, [x16, #2]
	.inst 0xc2400e08 // ldr c8, [x16, #3]
	.inst 0xc2401209 // ldr c9, [x16, #4]
	.inst 0xc240160d // ldr c13, [x16, #5]
	.inst 0xc2401a0e // ldr c14, [x16, #6]
	.inst 0xc2401e0f // ldr c15, [x16, #7]
	.inst 0xc240221c // ldr c28, [x16, #8]
	.inst 0xc240261e // ldr c30, [x16, #9]
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =initial_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884110 // msr CSP_EL0, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601150 // ldr c16, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240020a // ldr c10, [x16, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240060a // ldr c10, [x16, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a0a // ldr c10, [x16, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400e0a // ldr c10, [x16, #3]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc240120a // ldr c10, [x16, #4]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc240160a // ldr c10, [x16, #5]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc2401a0a // ldr c10, [x16, #6]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc2401e0a // ldr c10, [x16, #7]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc240220a // ldr c10, [x16, #8]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc240260a // ldr c10, [x16, #9]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc2402a0a // ldr c10, [x16, #10]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc2402e0a // ldr c10, [x16, #11]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc240320a // ldr c10, [x16, #12]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc298410a // mrs c10, CSP_EL0
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa601 // chkeq c16, c10
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001042
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001780
	ldr x1, =check_data2
	ldr x2, =0x00001788
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001801
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.zero 64
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4016
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x10
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x1e, 0xe0, 0xa1, 0x82, 0xe1, 0x23, 0xae, 0x78, 0xa1, 0x7e, 0xdd, 0x9b, 0xbd, 0x7d, 0x5f, 0x08
	.byte 0xe3, 0x29, 0xf6, 0xc2, 0x21, 0x49, 0xdc, 0xc2, 0x14, 0x60, 0x7d, 0x78, 0x3d, 0x08, 0xdf, 0xc2
	.byte 0xdf, 0x00, 0x68, 0xf8, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000400100040000000000001040
	/* C1 */
	.octa 0xffffffffffffffc0
	/* C6 */
	.octa 0x1780
	/* C8 */
	.octa 0x20000000
	/* C9 */
	.octa 0x800000000000000000000000
	/* C13 */
	.octa 0x1800
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C28 */
	.octa 0x10000004006d00600117ef64001d007
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000000400100040000000000001040
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x3fff80000000b100000000000000
	/* C6 */
	.octa 0x1780
	/* C8 */
	.octa 0x20000000
	/* C9 */
	.octa 0x800000000000000000000000
	/* C13 */
	.octa 0x1800
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C20 */
	.octa 0x1000
	/* C28 */
	.octa 0x10000004006d00600117ef64001d007
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc0000000000100060000000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x20008000500000000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 160
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600d50 // ldr x16, [c10, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d50 // str x16, [c10, #0]
	ldr x16, =0x40400028
	mrs x10, ELR_EL1
	sub x16, x16, x10
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20a // cvtp c10, x16
	.inst 0xc2d0414a // scvalue c10, c10, x16
	.inst 0x82600150 // ldr c16, [c10, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
