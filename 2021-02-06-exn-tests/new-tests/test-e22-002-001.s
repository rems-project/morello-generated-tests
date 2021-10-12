.section text0, #alloc, #execinstr
test_start:
	.inst 0x361ce51e // tbz:aarch64/instrs/branch/conditional/test Rt:30 imm14:10011100101000 b40:00011 op:0 011011:011011 b5:0
	.inst 0xd0b66760 // ADRP-C.IP-C Rd:0 immhi:011011001100111011 P:1 10000:10000 immlo:10 op:1
	.inst 0x82fff020 // ALDR-R.RRB-32 Rt:0 Rn:1 opc:00 S:1 option:111 Rm:31 1:1 L:1 100000101:100000101
	.inst 0x7821031f // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:24 00:00 opc:000 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xe2d947a1 // ALDUR-R.RI-64 Rt:1 Rn:29 op2:01 imm9:110010100 V:0 op1:11 11100010:11100010
	.zero 5100
	.inst 0x9bb97c1e // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:0 Ra:31 o0:0 Rm:25 01:01 U:1 10011011:10011011
	.inst 0xc2c713a9 // RRLEN-R.R-C Rd:9 Rn:29 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xc2c0274f // CPYTYPE-C.C-C Cd:15 Cn:26 001:001 opc:01 0:0 Cm:0 11000010110:11000010110
	.inst 0x885fffe1 // ldaxr:aarch64/instrs/memory/exclusive/single Rt:1 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:10
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
	ldr x27, =initial_cap_values
	.inst 0xc2400361 // ldr c1, [x27, #0]
	.inst 0xc2400778 // ldr c24, [x27, #1]
	.inst 0xc2400b7a // ldr c26, [x27, #2]
	.inst 0xc2400f7d // ldr c29, [x27, #3]
	.inst 0xc240137e // ldr c30, [x27, #4]
	/* Set up flags and system registers */
	ldr x27, =0x0
	msr SPSR_EL3, x27
	ldr x27, =initial_SP_EL1_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc28c411b // msr CSP_EL1, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30d5d99f
	msr SCTLR_EL1, x27
	ldr x27, =0xc0000
	msr CPACR_EL1, x27
	ldr x27, =0x0
	msr S3_0_C1_C2_2, x27 // CCTLR_EL1
	ldr x27, =0x0
	msr S3_3_C1_C2_2, x27 // CCTLR_EL0
	ldr x27, =initial_DDC_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288413b // msr DDC_EL0, c27
	ldr x27, =initial_DDC_EL1_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc28c413b // msr DDC_EL1, c27
	ldr x27, =0x80000000
	msr HCR_EL2, x27
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260125b // ldr c27, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc28e403b // msr CELR_EL3, c27
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400372 // ldr c18, [x27, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400772 // ldr c18, [x27, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400b72 // ldr c18, [x27, #2]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2400f72 // ldr c18, [x27, #3]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401372 // ldr c18, [x27, #4]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc2401772 // ldr c18, [x27, #5]
	.inst 0xc2d2a741 // chkeq c26, c18
	b.ne comparison_fail
	.inst 0xc2401b72 // ldr c18, [x27, #6]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2401f72 // ldr c18, [x27, #7]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_SP_EL1_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc29c4112 // mrs c18, CSP_EL1
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x18, 0x80
	orr x27, x27, x18
	ldr x18, =0x920000a8
	cmp x18, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000017f0
	ldr x1, =check_data0
	ldr x2, =0x000017f4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffc
	ldr x1, =check_data1
	ldr x2, =0x00001ffe
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
	ldr x0, =0x40400200
	ldr x1, =check_data3
	ldr x2, =0x40400204
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40401400
	ldr x1, =check_data4
	ldr x2, =0x40401414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
	.zero 4
.data
check_data1:
	.byte 0x00, 0x02
.data
check_data2:
	.byte 0x1e, 0xe5, 0x1c, 0x36, 0x60, 0x67, 0xb6, 0xd0, 0x20, 0xf0, 0xff, 0x82, 0x1f, 0x03, 0x21, 0x78
	.byte 0xa1, 0x47, 0xd9, 0xe2
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x1e, 0x7c, 0xb9, 0x9b, 0xa9, 0x13, 0xc7, 0xc2, 0x4f, 0x27, 0xc0, 0xc2, 0xe1, 0xff, 0x5f, 0x88
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000480000040000000040400200
	/* C24 */
	.octa 0x1ffc
	/* C26 */
	.octa 0x10000005c00700000000a0000001
	/* C29 */
	.octa 0x400000000000000
	/* C30 */
	.octa 0x8
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C9 */
	.octa 0x400000000000000
	/* C15 */
	.octa 0x10000005c007ffffffffffffffff
	/* C24 */
	.octa 0x1ffc
	/* C26 */
	.octa 0x10000005c00700000000a0000001
	/* C29 */
	.octa 0x400000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x17f0
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040401000
final_SP_EL1_value:
	.octa 0x17f0
final_PCC_value:
	.octa 0x200080004000041d0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040000080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001ff0
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
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0200037b // add c27, c27, #0
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0202037b // add c27, c27, #128
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0204037b // add c27, c27, #256
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0206037b // add c27, c27, #384
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0208037b // add c27, c27, #512
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x020a037b // add c27, c27, #640
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x020c037b // add c27, c27, #768
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x020e037b // add c27, c27, #896
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0210037b // add c27, c27, #1024
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0212037b // add c27, c27, #1152
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0214037b // add c27, c27, #1280
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0216037b // add c27, c27, #1408
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x0218037b // add c27, c27, #1536
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x021a037b // add c27, c27, #1664
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x021c037b // add c27, c27, #1792
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x82600e5b // ldr x27, [c18, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e5b // str x27, [c18, #0]
	ldr x27, =0x40401414
	mrs x18, ELR_EL1
	sub x27, x27, x18
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b372 // cvtp c18, x27
	.inst 0xc2db4252 // scvalue c18, c18, x27
	.inst 0x8260025b // ldr c27, [c18, #0]
	.inst 0x021e037b // add c27, c27, #1920
	.inst 0xc2c21360 // br c27

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
