.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c3f8e0 // SCBNDS-C.CI-S Cd:0 Cn:7 1110:1110 S:1 imm6:000111 11000010110:11000010110
	.inst 0x786163ff // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x383e53ff // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:101 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x881efc24 // stlxr:aarch64/instrs/memory/exclusive/single Rt:4 Rn:1 Rt2:11111 o0:1 Rs:30 0:0 L:0 0010000:0010000 size:10
	.inst 0x1a9f5420 // csinc:aarch64/instrs/integer/conditional/select Rd:0 Rn:1 o2:1 0:0 cond:0101 Rm:31 011010100:011010100 op:0 sf:0
	.inst 0xe2242cd8 // ALDUR-V.RI-Q Rt:24 Rn:6 op2:11 imm9:001000010 V:1 op1:00 11100010:11100010
	.inst 0xc2c533e1 // CVTP-R.C-C Rd:1 Cn:31 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x383d833d // swpb:aarch64/instrs/memory/atomicops/swp Rt:29 Rn:25 100000:100000 Rs:29 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x384fd27e // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:19 00:00 imm9:011111101 0:0 opc:01 111000:111000 size:00
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400526 // ldr c6, [x9, #1]
	.inst 0xc2400927 // ldr c7, [x9, #2]
	.inst 0xc2400d33 // ldr c19, [x9, #3]
	.inst 0xc2401139 // ldr c25, [x9, #4]
	.inst 0xc240153d // ldr c29, [x9, #5]
	.inst 0xc240193e // ldr c30, [x9, #6]
	/* Set up flags and system registers */
	ldr x9, =0x4000000
	msr SPSR_EL3, x9
	ldr x9, =initial_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884109 // msr CSP_EL0, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0x3c0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x8
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82601389 // ldr c9, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x28, #0xf
	and x9, x9, x28
	cmp x9, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240013c // ldr c28, [x9, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240053c // ldr c28, [x9, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240093c // ldr c28, [x9, #2]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc2400d3c // ldr c28, [x9, #3]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc240113c // ldr c28, [x9, #4]
	.inst 0xc2dca661 // chkeq c19, c28
	b.ne comparison_fail
	.inst 0xc240153c // ldr c28, [x9, #5]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc240193c // ldr c28, [x9, #6]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc2401d3c // ldr c28, [x9, #7]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x28, v24.d[0]
	cmp x9, x28
	b.ne comparison_fail
	ldr x9, =0x0
	mov x28, v24.d[1]
	cmp x9, x28
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc298411c // mrs c28, CSP_EL0
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc298403c // mrs c28, CELR_EL1
	.inst 0xc2dca521 // chkeq c9, c28
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
	ldr x0, =0x00001584
	ldr x1, =check_data1
	ldr x2, =0x00001588
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f5c
	ldr x1, =check_data2
	ldr x2, =0x00001f5d
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x40403fe0
	ldr x1, =check_data5
	ldr x2, =0x40403ff0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.byte 0x85, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x80, 0x15
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xe0, 0xf8, 0xc3, 0xc2, 0xff, 0x63, 0x61, 0x78, 0xff, 0x53, 0x3e, 0x38, 0x24, 0xfc, 0x1e, 0x88
	.byte 0x20, 0x54, 0x9f, 0x1a, 0xd8, 0x2c, 0x24, 0xe2, 0xe1, 0x33, 0xc5, 0xc2, 0x3d, 0x83, 0x3d, 0x38
	.byte 0x7e, 0xd2, 0x4f, 0x38, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 16

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000400000010000000000001584
	/* C6 */
	.octa 0x40403f9e
	/* C7 */
	.octa 0x400000000000000000000000
	/* C19 */
	.octa 0x80000000000100050000000000001f01
	/* C25 */
	.octa 0xc0000000000100050000000000001f5c
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x80
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1584
	/* C1 */
	.octa 0x1000
	/* C6 */
	.octa 0x40403f9e
	/* C7 */
	.octa 0x400000000000000000000000
	/* C19 */
	.octa 0x80000000000100050000000000001f01
	/* C25 */
	.octa 0xc0000000000100050000000000001f5c
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000400000040000000000001000
initial_DDC_EL0_value:
	.octa 0x800000000003000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc0000000400000040000000000001000
final_PCC_value:
	.octa 0x20008000000080080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001f50
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600f89 // ldr x9, [c28, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f89 // str x9, [c28, #0]
	ldr x9, =0x40400028
	mrs x28, ELR_EL1
	sub x9, x9, x28
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13c // cvtp c28, x9
	.inst 0xc2c9439c // scvalue c28, c28, x9
	.inst 0x82600389 // ldr c9, [c28, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
