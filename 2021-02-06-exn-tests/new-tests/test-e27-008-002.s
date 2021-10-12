.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2ac67e0 // ALDUR-V.RI-S Rt:0 Rn:31 op2:01 imm9:011000110 V:1 op1:10 11100010:11100010
	.inst 0xeb3d901e // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:0 imm3:100 option:100 Rm:29 01011001:01011001 S:1 op:1 sf:1
	.inst 0xf820619f // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:12 00:00 opc:110 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x085ffc30 // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:16 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xe2336d5e // ALDUR-V.RI-Q Rt:30 Rn:10 op2:11 imm9:100110110 V:1 op1:00 11100010:11100010
	.zero 1004
	.inst 0xf2973000 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1011100110000000 hw:00 100101:100101 opc:11 sf:1
	.inst 0xc2cbfbbd // SCBNDS-C.CI-S Cd:29 Cn:29 1110:1110 S:1 imm6:010111 11000010110:11000010110
	.inst 0x287307be // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:30 Rn:29 Rt2:00001 imm7:1100110 L:1 1010000:1010000 opc:00
	.inst 0x38bfc1be // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:30 Rn:13 110000:110000 Rs:11111 111000101:111000101 size:00
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc240084a // ldr c10, [x2, #2]
	.inst 0xc2400c4c // ldr c12, [x2, #3]
	.inst 0xc240104d // ldr c13, [x2, #4]
	.inst 0xc240145d // ldr c29, [x2, #5]
	/* Set up flags and system registers */
	ldr x2, =0x4000000
	msr SPSR_EL3, x2
	ldr x2, =initial_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884102 // msr CSP_EL0, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0x3c0000
	msr CPACR_EL1, x2
	ldr x2, =0x4
	msr S3_0_C1_C2_2, x2 // CCTLR_EL1
	ldr x2, =0x4
	msr S3_3_C1_C2_2, x2 // CCTLR_EL0
	ldr x2, =initial_DDC_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884122 // msr DDC_EL0, c2
	ldr x2, =initial_DDC_EL1_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc28c4122 // msr DDC_EL1, c2
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011e2 // ldr c2, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
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
	mov x15, #0xf
	and x2, x2, x15
	cmp x2, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc240004f // ldr c15, [x2, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240044f // ldr c15, [x2, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240084f // ldr c15, [x2, #2]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc2400c4f // ldr c15, [x2, #3]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc240104f // ldr c15, [x2, #4]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc240144f // ldr c15, [x2, #5]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc240184f // ldr c15, [x2, #6]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2401c4f // ldr c15, [x2, #7]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x2, =0x0
	mov x15, v0.d[0]
	cmp x2, x15
	b.ne comparison_fail
	ldr x2, =0x0
	mov x15, v0.d[1]
	cmp x2, x15
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc298410f // mrs c15, CSP_EL0
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	ldr x2, =esr_el1_dump_address
	ldr x2, [x2]
	mov x15, 0xc1
	orr x2, x2, x15
	ldr x15, =0x920000eb
	cmp x15, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001098
	ldr x1, =check_data2
	ldr x2, =0x000010a0
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
	ldr x0, =0x404000c8
	ldr x1, =check_data4
	ldr x2, =0x404000cc
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xe0, 0x67, 0xac, 0xe2, 0x1e, 0x90, 0x3d, 0xeb, 0x9f, 0x61, 0x20, 0xf8, 0x30, 0xfc, 0x5f, 0x08
	.byte 0x5e, 0x6d, 0x33, 0xe2
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x00, 0x30, 0x97, 0xf2, 0xbd, 0xfb, 0xcb, 0xc2, 0xbe, 0x07, 0x73, 0x28, 0xbe, 0xc1, 0xbf, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000000000
	/* C1 */
	.octa 0x800000003fa100050000000000001000
	/* C10 */
	.octa 0xff7ffed13bb7e29d
	/* C12 */
	.octa 0xc0000000000700070000000000001008
	/* C13 */
	.octa 0x1000
	/* C29 */
	.octa 0xc00000000000000000001100
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800000000000b980
	/* C1 */
	.octa 0x0
	/* C10 */
	.octa 0xff7ffed13bb7e29d
	/* C12 */
	.octa 0xc0000000000700070000000000001008
	/* C13 */
	.octa 0x1000
	/* C16 */
	.octa 0x0
	/* C29 */
	.octa 0xd27011000000000000001100
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x800000004000000200000000403fe000
initial_DDC_EL1_value:
	.octa 0x800000000007000100fffffffff88001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_SP_EL0_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
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
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x82600de2 // ldr x2, [c15, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400de2 // str x2, [c15, #0]
	ldr x2, =0x40400414
	mrs x15, ELR_EL1
	sub x2, x2, x15
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04f // cvtp c15, x2
	.inst 0xc2c241ef // scvalue c15, c15, x2
	.inst 0x826001e2 // ldr c2, [c15, #0]
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
