.section text0, #alloc, #execinstr
test_start:
	.inst 0x782f6102 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:8 00:00 opc:110 0:0 Rs:15 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x38d39460 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:3 01:01 imm9:100111001 0:0 opc:11 111000:111000 size:00
	.inst 0x227fdcbd // LDAXP-C.R-C Ct:29 Rn:5 Ct2:10111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0x6b3fa3dd // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:29 Rn:30 imm3:000 option:101 Rm:31 01011001:01011001 S:1 op:1 sf:0
	.inst 0x3c4a3db5 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:21 Rn:13 11:11 imm9:010100011 0:0 opc:01 111100:111100 size:00
	.zero 4
	.inst 0x48df7c29 // 0x48df7c29
	.inst 0xba54180a // 0xba54180a
	.inst 0xc2c21021 // 0xc2c21021
	.inst 0xd4000001
	.zero 984
	.inst 0xd65f0360 // 0xd65f0360
	.zero 64508
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
	.inst 0xc2400281 // ldr c1, [x20, #0]
	.inst 0xc2400683 // ldr c3, [x20, #1]
	.inst 0xc2400a85 // ldr c5, [x20, #2]
	.inst 0xc2400e88 // ldr c8, [x20, #3]
	.inst 0xc240128f // ldr c15, [x20, #4]
	.inst 0xc240169b // ldr c27, [x20, #5]
	.inst 0xc2401a9e // ldr c30, [x20, #6]
	/* Set up flags and system registers */
	ldr x20, =0x0
	msr SPSR_EL3, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30d5d99f
	msr SCTLR_EL1, x20
	ldr x20, =0xc0000
	msr CPACR_EL1, x20
	ldr x20, =0x0
	msr S3_0_C1_C2_2, x20 // CCTLR_EL1
	ldr x20, =0x0
	msr S3_3_C1_C2_2, x20 // CCTLR_EL0
	ldr x20, =initial_DDC_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2884134 // msr DDC_EL0, c20
	ldr x20, =0x80000000
	msr HCR_EL2, x20
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601334 // ldr c20, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	mov x25, #0xf
	and x20, x20, x25
	cmp x20, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400299 // ldr c25, [x20, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400699 // ldr c25, [x20, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400a99 // ldr c25, [x20, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400e99 // ldr c25, [x20, #3]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2401299 // ldr c25, [x20, #4]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2401699 // ldr c25, [x20, #5]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2401a99 // ldr c25, [x20, #6]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc2401e99 // ldr c25, [x20, #7]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2402299 // ldr c25, [x20, #8]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2402699 // ldr c25, [x20, #9]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc2402a99 // ldr c25, [x20, #10]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402e99 // ldr c25, [x20, #11]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x20, =final_PCC_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x20, 0x0
	orr x25, x25, x20
	ldr x20, =0x1fe00000
	cmp x20, x25
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
	ldr x0, =0x00001760
	ldr x1, =check_data1
	ldr x2, =0x00001780
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x40400018
	ldr x1, =check_data4
	ldr x2, =0x40400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400404
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040fffc
	ldr x1, =check_data6
	ldr x2, =0x4040fffe
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01, 0x00
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x02, 0x61, 0x2f, 0x78, 0x60, 0x94, 0xd3, 0x38, 0xbd, 0xdc, 0x7f, 0x22, 0xdd, 0xa3, 0x3f, 0x6b
	.byte 0xb5, 0x3d, 0x4a, 0x3c
.data
check_data4:
	.byte 0x29, 0x7c, 0xdf, 0x48, 0x0a, 0x18, 0x54, 0xba, 0x21, 0x10, 0xc2, 0xc2, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0x60, 0x03, 0x5f, 0xd6
.data
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8000000000010005000000004040fffc
	/* C3 */
	.octa 0x1ffe
	/* C5 */
	.octa 0x1760
	/* C8 */
	.octa 0x1000
	/* C15 */
	.octa 0x0
	/* C27 */
	.octa 0x40400018
	/* C30 */
	.octa 0xffffffff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x8000000000010005000000004040fffc
	/* C2 */
	.octa 0x1
	/* C3 */
	.octa 0x1f37
	/* C5 */
	.octa 0x1760
	/* C8 */
	.octa 0x1000
	/* C9 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x40400018
	/* C29 */
	.octa 0xffffffff
	/* C30 */
	.octa 0xffffffff
initial_DDC_EL0_value:
	.octa 0xd0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000000d0000000040400001
final_PCC_value:
	.octa 0x200080005000000d0000000040400028
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
	.dword initial_cap_values + 0
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword initial_DDC_EL0_value
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
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x02000294 // add c20, c20, #0
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x02020294 // add c20, c20, #128
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x02040294 // add c20, c20, #256
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x02060294 // add c20, c20, #384
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x02080294 // add c20, c20, #512
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x020a0294 // add c20, c20, #640
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x020c0294 // add c20, c20, #768
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x020e0294 // add c20, c20, #896
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x02100294 // add c20, c20, #1024
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x02120294 // add c20, c20, #1152
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x02140294 // add c20, c20, #1280
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x02160294 // add c20, c20, #1408
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x02180294 // add c20, c20, #1536
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x021a0294 // add c20, c20, #1664
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
	.inst 0x021c0294 // add c20, c20, #1792
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600f34 // ldr x20, [c25, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400f34 // str x20, [c25, #0]
	ldr x20, =0x40400028
	mrs x25, ELR_EL1
	sub x20, x20, x25
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b299 // cvtp c25, x20
	.inst 0xc2d44339 // scvalue c25, c25, x20
	.inst 0x82600334 // ldr c20, [c25, #0]
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
