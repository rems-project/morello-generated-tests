.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2b813fc // ASTUR-V.RI-S Rt:28 Rn:31 op2:00 imm9:110000001 V:1 op1:10 11100010:11100010
	.inst 0xb15377df // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:30 imm12:010011011101 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x4b20ab9f // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:28 imm3:010 option:101 Rm:0 01011001:01011001 S:0 op:1 sf:0
	.inst 0xc2c710e1 // RRLEN-R.R-C Rd:1 Rn:7 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x3881fae1 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:23 10:10 imm9:000011111 0:0 opc:10 111000:111000 size:00
	.zero 12
	.inst 0xb8fd72d4 // 0xb8fd72d4
	.inst 0xd4000001
	.zero 984
	.inst 0x3a5e7824 // 0x3a5e7824
	.inst 0xe21493fd // 0xe21493fd
	.inst 0xc2dad0e0 // 0xc2dad0e0
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
	ldr x9, =initial_cap_values
	.inst 0xc2400127 // ldr c7, [x9, #0]
	.inst 0xc2400536 // ldr c22, [x9, #1]
	.inst 0xc2400937 // ldr c23, [x9, #2]
	.inst 0xc2400d3d // ldr c29, [x9, #3]
	.inst 0xc240113e // ldr c30, [x9, #4]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q28, =0x0
	/* Set up flags and system registers */
	ldr x9, =0x4000000
	msr SPSR_EL3, x9
	ldr x9, =initial_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884109 // msr CSP_EL0, c9
	ldr x9, =initial_SP_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28c4109 // msr CSP_EL1, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0x3c0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x4
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =initial_DDC_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28c4129 // msr DDC_EL1, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601329 // ldr c9, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	mov x25, #0xf
	and x9, x9, x25
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400139 // ldr c25, [x9, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400539 // ldr c25, [x9, #1]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc2400939 // ldr c25, [x9, #2]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2400d39 // ldr c25, [x9, #3]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc2401139 // ldr c25, [x9, #4]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2401539 // ldr c25, [x9, #5]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2401939 // ldr c25, [x9, #6]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x25, v28.d[0]
	cmp x9, x25
	b.ne comparison_fail
	ldr x9, =0x0
	mov x25, v28.d[1]
	cmp x9, x25
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_SP_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc29c4119 // mrs c25, CSP_EL1
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x9, 0x83
	orr x25, x25, x9
	ldr x9, =0x920000ab
	cmp x9, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017a0
	ldr x1, =check_data1
	ldr x2, =0x000017b0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f79
	ldr x1, =check_data2
	ldr x2, =0x00001f7a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fa0
	ldr x1, =check_data3
	ldr x2, =0x00001fa4
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
	ldr x0, =0x40400020
	ldr x1, =check_data5
	ldr x2, =0x40400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x4040040c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1936
	.byte 0x20, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 2128
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x20, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xfc, 0x13, 0xb8, 0xe2, 0xdf, 0x77, 0x53, 0xb1, 0x9f, 0xab, 0x20, 0x4b, 0xe1, 0x10, 0xc7, 0xc2
	.byte 0xe1, 0xfa, 0x81, 0x38
.data
check_data5:
	.byte 0xd4, 0x72, 0xfd, 0xb8, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0x24, 0x78, 0x5e, 0x3a, 0xfd, 0x93, 0x14, 0xe2, 0xe0, 0xd0, 0xda, 0xc2

.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x9010000060010fa20000000000001a40
	/* C22 */
	.octa 0x1008
	/* C23 */
	.octa 0x80000000400008047f7fffffffffffff
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1a40
	/* C7 */
	.octa 0x9010000060010fa20000000000001a40
	/* C20 */
	.octa 0x1
	/* C22 */
	.octa 0x1008
	/* C23 */
	.octa 0x80000000400008047f7fffffffffffff
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x2010
initial_SP_EL1_value:
	.octa 0x40000000000100070000000000002030
initial_DDC_EL0_value:
	.octa 0x400000005fc0000f0000000000008000
initial_DDC_EL1_value:
	.octa 0xc0000000207100070000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000000d0000000040400000
final_SP_EL1_value:
	.octa 0x40000000000100070000000000002030
final_PCC_value:
	.octa 0x20008000000000000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002007e0070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000017a0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600f29 // ldr x9, [c25, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f29 // str x9, [c25, #0]
	ldr x9, =0x40400028
	mrs x25, ELR_EL1
	sub x9, x9, x25
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b139 // cvtp c25, x9
	.inst 0xc2c94339 // scvalue c25, c25, x9
	.inst 0x82600329 // ldr c9, [c25, #0]
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
