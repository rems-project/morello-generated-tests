.section text0, #alloc, #execinstr
test_start:
	.inst 0x926a8420 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:1 imms:100001 immr:101010 N:1 100100:100100 opc:00 sf:1
	.inst 0x694fe3e0 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:31 Rt2:11000 imm7:0011111 L:1 1010010:1010010 opc:01
	.inst 0x826ca00c // ALDR-C.RI-C Ct:12 Rn:0 op:00 imm9:011001010 L:1 1000001001:1000001001
	.inst 0x8299e21e // ASTRB-R.RRB-B Rt:30 Rn:16 opc:00 S:0 option:111 Rm:25 0:0 L:0 100000101:100000101
	.inst 0x88007fbf // stxr:aarch64/instrs/memory/exclusive/single Rt:31 Rn:29 Rt2:11111 o0:0 Rs:0 0:0 L:0 0010000:0010000 size:10
	.zero 4200
	.inst 0x0000118c
	.zero 8060
	.inst 0x00800000
	.zero 21504
	.inst 0x9b3dfbcf // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:15 Rn:30 Ra:30 o0:1 Rm:29 01:01 U:0 10011011:10011011
	.inst 0x08dffc41 // ldarb:aarch64/instrs/memory/ordered Rt:1 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x82c1709e // ALDRB-R.RRB-B Rt:30 Rn:4 opc:00 S:1 option:011 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x2c925a3d // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:29 Rn:17 Rt2:10110 imm7:0100100 L:0 1011001:1011001 opc:00
	.inst 0xd4000001
	.zero 31724
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
	ldr x19, =initial_cap_values
	.inst 0xc2400262 // ldr c2, [x19, #0]
	.inst 0xc2400664 // ldr c4, [x19, #1]
	.inst 0xc2400a70 // ldr c16, [x19, #2]
	.inst 0xc2400e71 // ldr c17, [x19, #3]
	.inst 0xc2401279 // ldr c25, [x19, #4]
	.inst 0xc240167d // ldr c29, [x19, #5]
	.inst 0xc2401a7e // ldr c30, [x19, #6]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q22, =0x20000
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x19, =0x4000000
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884113 // msr CSP_EL0, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0x1c0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x4
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =initial_DDC_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4133 // msr DDC_EL1, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601353 // ldr c19, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240027a // ldr c26, [x19, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240067a // ldr c26, [x19, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a7a // ldr c26, [x19, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400e7a // ldr c26, [x19, #3]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc240127a // ldr c26, [x19, #4]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc240167a // ldr c26, [x19, #5]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc2401a7a // ldr c26, [x19, #6]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc2401e7a // ldr c26, [x19, #7]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc240227a // ldr c26, [x19, #8]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc240267a // ldr c26, [x19, #9]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc2402a7a // ldr c26, [x19, #10]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2402e7a // ldr c26, [x19, #11]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x20000
	mov x26, v22.d[0]
	cmp x19, x26
	b.ne comparison_fail
	ldr x19, =0x0
	mov x26, v22.d[1]
	cmp x19, x26
	b.ne comparison_fail
	ldr x19, =0x0
	mov x26, v29.d[0]
	cmp x19, x26
	b.ne comparison_fail
	ldr x19, =0x0
	mov x26, v29.d[1]
	cmp x19, x26
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc298411a // mrs c26, CSP_EL0
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	mov x26, 0x80
	orr x19, x19, x26
	ldr x26, =0x920000e1
	cmp x26, x19
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
	ldr x0, =0x000014e8
	ldr x1, =check_data1
	ldr x2, =0x000014e9
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e30
	ldr x1, =check_data2
	ldr x2, =0x00001e40
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
	ldr x0, =0x4040107c
	ldr x1, =check_data4
	ldr x2, =0x40401084
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40402ffe
	ldr x1, =check_data5
	ldr x2, =0x40402fff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40408400
	ldr x1, =check_data6
	ldr x2, =0x40408414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x20, 0x84, 0x6a, 0x92, 0xe0, 0xe3, 0x4f, 0x69, 0x0c, 0xa0, 0x6c, 0x82, 0x1e, 0xe2, 0x99, 0x82
	.byte 0xbf, 0x7f, 0x00, 0x88
.data
check_data4:
	.byte 0x8c, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0x80
.data
check_data6:
	.byte 0xcf, 0xfb, 0x3d, 0x9b, 0x41, 0xfc, 0xdf, 0x08, 0x9e, 0x70, 0xc1, 0x82, 0x3d, 0x5a, 0x92, 0x2c
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000000704040000000040402ffe
	/* C4 */
	.octa 0xf80
	/* C16 */
	.octa 0x80000000000014e4
	/* C17 */
	.octa 0x40000000000100050000000000001000
	/* C25 */
	.octa 0x8000000000000000
	/* C29 */
	.octa 0x40000000000500050000000000000001
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x118c
	/* C1 */
	.octa 0x80
	/* C2 */
	.octa 0x80000000000704040000000040402ffe
	/* C4 */
	.octa 0xf80
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x80000000000014e4
	/* C17 */
	.octa 0x40000000000100050000000000001090
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x8000000000000000
	/* C29 */
	.octa 0x40000000000500050000000000000001
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x80000000000080080000000040401000
initial_DDC_EL0_value:
	.octa 0xc0000000600000040000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000500410000000000000000003
initial_VBAR_EL1_value:
	.octa 0x200080005000541d0000000040408001
final_SP_EL0_value:
	.octa 0x80000000000080080000000040401000
final_PCC_value:
	.octa 0x200080005000541d0000000040408414
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
	.dword 0x0000000000001e30
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001e30
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000014e0
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40408414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
