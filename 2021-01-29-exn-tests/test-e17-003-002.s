.section text0, #alloc, #execinstr
test_start:
	.inst 0x889f7c1e // stllr:aarch64/instrs/memory/ordered Rt:30 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x081ffcdd // stlxrb:aarch64/instrs/memory/exclusive/single Rt:29 Rn:6 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0x382012bf // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:001 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x429b6966 // STP-C.RIB-C Ct:6 Rn:11 Ct2:11010 imm7:0110110 L:0 010000101:010000101
	.inst 0xadb4603e // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:30 Rn:1 Rt2:11000 imm7:1101000 L:0 1011011:1011011 opc:10
	.zero 1004
	.inst 0x787f509f // 0x787f509f
	.inst 0xc2dd8bfd // CHKSSU-C.CC-C Cd:29 Cn:31 0010:0010 opc:10 Cm:29 11000010110:11000010110
	.inst 0xc2c81a3f // ALIGND-C.CI-C Cd:31 Cn:17 0110:0110 U:0 imm6:010000 11000010110:11000010110
	.inst 0x8a75d7b7 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:23 Rn:29 imm6:110101 Rm:21 N:1 shift:01 01010:01010 opc:00 sf:1
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400904 // ldr c4, [x8, #2]
	.inst 0xc2400d06 // ldr c6, [x8, #3]
	.inst 0xc240110b // ldr c11, [x8, #4]
	.inst 0xc2401511 // ldr c17, [x8, #5]
	.inst 0xc2401915 // ldr c21, [x8, #6]
	.inst 0xc2401d1a // ldr c26, [x8, #7]
	.inst 0xc240211d // ldr c29, [x8, #8]
	.inst 0xc240251e // ldr c30, [x8, #9]
	/* Set up flags and system registers */
	ldr x8, =0x0
	msr SPSR_EL3, x8
	ldr x8, =initial_SP_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4108 // msr CSP_EL1, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0x3c0000
	msr CPACR_EL1, x8
	ldr x8, =0x4
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x4
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601148 // ldr c8, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x10, #0xf
	and x8, x8, x10
	cmp x8, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010a // ldr c10, [x8, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240050a // ldr c10, [x8, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240090a // ldr c10, [x8, #2]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc2400d0a // ldr c10, [x8, #3]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc240110a // ldr c10, [x8, #4]
	.inst 0xc2caa561 // chkeq c11, c10
	b.ne comparison_fail
	.inst 0xc240150a // ldr c10, [x8, #5]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc240190a // ldr c10, [x8, #6]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc2401d0a // ldr c10, [x8, #7]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc240210a // ldr c10, [x8, #8]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc240250a // ldr c10, [x8, #9]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc240290a // ldr c10, [x8, #10]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc29c410a // mrs c10, CSP_EL1
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x8, 0x83
	orr x10, x10, x8
	ldr x8, =0x920000e3
	cmp x8, x10
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001404
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
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xbc, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xed, 0xaf, 0x00, 0x00, 0x00, 0xa4, 0x00, 0xac
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xff
.data
check_data4:
	.byte 0x1e, 0x7c, 0x9f, 0x88, 0xdd, 0xfc, 0x1f, 0x08, 0xbf, 0x12, 0x20, 0x38, 0x66, 0x69, 0x9b, 0x42
	.byte 0x3e, 0x60, 0xb4, 0xad
.data
check_data5:
	.byte 0x9f, 0x50, 0x7f, 0x78, 0xfd, 0x8b, 0xdd, 0xc2, 0x3f, 0x1a, 0xc8, 0xc2, 0xb7, 0xd7, 0x75, 0x8a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1400
	/* C1 */
	.octa 0x80000000000202
	/* C4 */
	.octa 0x1000
	/* C6 */
	.octa 0xbc0000000000000000000000001000
	/* C11 */
	.octa 0xcc0
	/* C17 */
	.octa 0x800000070000000000000000
	/* C21 */
	.octa 0x1800
	/* C26 */
	.octa 0xac00a4000000afed0000000000000000
	/* C29 */
	.octa 0x1001000c0000000000000001
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1400
	/* C1 */
	.octa 0x80000000000202
	/* C4 */
	.octa 0x1000
	/* C6 */
	.octa 0xbc0000000000000000000000001000
	/* C11 */
	.octa 0xcc0
	/* C17 */
	.octa 0x800000070000000000000000
	/* C21 */
	.octa 0x1800
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0xac00a4000000afed0000000000000000
	/* C29 */
	.octa 0x100030000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x100030000000000000000
initial_DDC_EL0_value:
	.octa 0xcc000000000200050000000000003f03
initial_DDC_EL1_value:
	.octa 0xc0000000000500070000000000000003
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_SP_EL1_value:
	.octa 0x800000070000000000000000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
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
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 128
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600d48 // ldr x8, [c10, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d48 // str x8, [c10, #0]
	ldr x8, =0x40400414
	mrs x10, ELR_EL1
	sub x8, x8, x10
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10a // cvtp c10, x8
	.inst 0xc2c8414a // scvalue c10, c10, x8
	.inst 0x82600148 // ldr c8, [c10, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
