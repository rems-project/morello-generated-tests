.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0a421 // CHKEQ-_.CC-C 00001:00001 Cn:1 001:001 opc:01 1:1 Cm:0 11000010110:11000010110
	.inst 0xc2c5d340 // CVTDZ-C.R-C Cd:0 Rn:26 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xb83d403f // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:1 00:00 opc:100 0:0 Rs:29 1:1 R:0 A:0 111000:111000 size:10
	.inst 0xb83f131f // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:24 00:00 opc:001 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x6b01f021 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:1 imm6:111100 Rm:1 0:0 shift:00 01011:01011 S:1 op:1 sf:0
	.zero 17388
	.inst 0xe20033ff // ASTURB-R.RI-32 Rt:31 Rn:31 op2:00 imm9:000000011 V:0 op1:00 11100010:11100010
	.inst 0xc83dafff // stlxp:aarch64/instrs/memory/exclusive/pair Rt:31 Rn:31 Rt2:01011 o0:1 Rs:29 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0xa257dbe1 // LDTR-C.RIB-C Ct:1 Rn:31 10:10 imm9:101111101 0:0 opc:01 10100010:10100010
	.inst 0x38bf83fe // swpb:aarch64/instrs/memory/atomicops/swp Rt:30 Rn:31 100000:100000 Rs:31 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xd4000001
	.zero 48108
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b38 // ldr c24, [x25, #2]
	.inst 0xc2400f3a // ldr c26, [x25, #3]
	.inst 0xc240133d // ldr c29, [x25, #4]
	/* Set up flags and system registers */
	ldr x25, =0x0
	msr SPSR_EL3, x25
	ldr x25, =initial_SP_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4119 // msr CSP_EL1, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0xc0000
	msr CPACR_EL1, x25
	ldr x25, =0x0
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0x4
	msr S3_3_C1_C2_2, x25 // CCTLR_EL0
	ldr x25, =initial_DDC_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884139 // msr DDC_EL0, c25
	ldr x25, =initial_DDC_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4139 // msr DDC_EL1, c25
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82601239 // ldr c25, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc28e4039 // msr CELR_EL3, c25
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x17, #0xf
	and x25, x25, x17
	cmp x25, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400331 // ldr c17, [x25, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400731 // ldr c17, [x25, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400b31 // ldr c17, [x25, #2]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc2400f31 // ldr c17, [x25, #3]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc2401331 // ldr c17, [x25, #4]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2401731 // ldr c17, [x25, #5]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_SP_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc29c4111 // mrs c17, CSP_EL1
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984031 // mrs c17, CELR_EL1
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	ldr x17, =0x2000000
	cmp x17, x25
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
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x000010f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001910
	ldr x1, =check_data2
	ldr x2, =0x00001920
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40404400
	ldr x1, =check_data4
	ldr x2, =0x40404414
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
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
	.byte 0x01, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 208
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 3856
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x21, 0xa4, 0xc0, 0xc2, 0x40, 0xd3, 0xc5, 0xc2, 0x3f, 0x40, 0x3d, 0xb8, 0x1f, 0x13, 0x3f, 0xb8
	.byte 0x21, 0xf0, 0x01, 0x6b
.data
check_data4:
	.byte 0xff, 0x33, 0x00, 0xe2, 0xff, 0xaf, 0x3d, 0xc8, 0xe1, 0xdb, 0x57, 0xa2, 0xfe, 0x83, 0xbf, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1000
	/* C24 */
	.octa 0x1000
	/* C26 */
	.octa 0xc0000000000000
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc00000000006000700c0000000000000
	/* C1 */
	.octa 0x101800000000000000000000000
	/* C24 */
	.octa 0x1000
	/* C26 */
	.octa 0xc0000000000000
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0xd0000000000100050000000000001910
initial_DDC_EL0_value:
	.octa 0xc0000000000600070000000000000002
initial_DDC_EL1_value:
	.octa 0x40000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004414041d0000000040404001
final_SP_EL1_value:
	.octa 0xd0000000000100050000000000001910
final_PCC_value:
	.octa 0x200080004414041d0000000040404414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004020c0210000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010e0
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x00000000000010e0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001910
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600e39 // ldr x25, [c17, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400e39 // str x25, [c17, #0]
	ldr x25, =0x40404414
	mrs x17, ELR_EL1
	sub x25, x25, x17
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b331 // cvtp c17, x25
	.inst 0xc2d94231 // scvalue c17, c17, x25
	.inst 0x82600239 // ldr c25, [c17, #0]
	.inst 0x021e0339 // add c25, c25, #1920
	.inst 0xc2c21320 // br c25

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
