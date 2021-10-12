.section text0, #alloc, #execinstr
test_start:
	.inst 0x489f7ffa // stllrh:aarch64/instrs/memory/ordered Rt:26 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe2a4419d // ASTUR-V.RI-S Rt:29 Rn:12 op2:00 imm9:001000100 V:1 op1:10 11100010:11100010
	.inst 0x82fd5684 // ALDR-R.RRB-64 Rt:4 Rn:20 opc:01 S:1 option:010 Rm:29 1:1 L:1 100000101:100000101
	.inst 0xc2ff4be1 // ORRFLGS-C.CI-C Cd:1 Cn:31 0:0 01:01 imm8:11111010 11000010111:11000010111
	.inst 0x489f7e1e // stllrh:aarch64/instrs/memory/ordered Rt:30 Rn:16 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.zero 1004
	.inst 0xdac0142a // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:10 Rn:1 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x08df7fff // ldlarb:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x085fffa5 // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:5 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xf8be001c // ldadd:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:0 00:00 opc:000 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:11
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
	.inst 0xc240044c // ldr c12, [x2, #1]
	.inst 0xc2400850 // ldr c16, [x2, #2]
	.inst 0xc2400c54 // ldr c20, [x2, #3]
	.inst 0xc240105a // ldr c26, [x2, #4]
	.inst 0xc240145d // ldr c29, [x2, #5]
	.inst 0xc240185e // ldr c30, [x2, #6]
	/* Vector registers */
	mrs x2, cptr_el3
	bfc x2, #10, #1
	msr cptr_el3, x2
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x2, =0x0
	msr SPSR_EL3, x2
	ldr x2, =initial_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884102 // msr CSP_EL0, c2
	ldr x2, =initial_SP_EL1_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc28c4102 // msr CSP_EL1, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0x3c0000
	msr CPACR_EL1, x2
	ldr x2, =0x0
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
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011a2 // ldr c2, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc240004d // ldr c13, [x2, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240044d // ldr c13, [x2, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240084d // ldr c13, [x2, #2]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc2400c4d // ldr c13, [x2, #3]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc240104d // ldr c13, [x2, #4]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc240144d // ldr c13, [x2, #5]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc240184d // ldr c13, [x2, #6]
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	.inst 0xc2401c4d // ldr c13, [x2, #7]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc240204d // ldr c13, [x2, #8]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc240244d // ldr c13, [x2, #9]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc240284d // ldr c13, [x2, #10]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc2402c4d // ldr c13, [x2, #11]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x2, =0x0
	mov x13, v29.d[0]
	cmp x2, x13
	b.ne comparison_fail
	ldr x2, =0x0
	mov x13, v29.d[1]
	cmp x2, x13
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc298410d // mrs c13, CSP_EL0
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	ldr x2, =final_SP_EL1_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc29c410d // mrs c13, CSP_EL1
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	ldr x2, =esr_el1_dump_address
	ldr x2, [x2]
	mov x13, 0x80
	orr x2, x2, x13
	ldr x13, =0x920000ea
	cmp x13, x2
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001060
	ldr x1, =check_data2
	ldr x2, =0x00001062
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
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40406000
	ldr x1, =check_data5
	ldr x2, =0x40406008
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
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xfa, 0x7f, 0x9f, 0x48, 0x9d, 0x41, 0xa4, 0xe2, 0x84, 0x56, 0xfd, 0x82, 0xe1, 0x4b, 0xff, 0xc2
	.byte 0x1e, 0x7e, 0x9f, 0x48
.data
check_data4:
	.byte 0x2a, 0x14, 0xc0, 0xda, 0xff, 0x7f, 0xdf, 0x08, 0xa5, 0xff, 0x5f, 0x08, 0x1c, 0x00, 0xbe, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C12 */
	.octa 0x40000000200704070000000000000fcc
	/* C16 */
	.octa 0x220000000000001
	/* C20 */
	.octa 0x800000003007102700000000403fe000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0xfa00000000001060
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x4
	/* C12 */
	.octa 0x40000000200704070000000000000fcc
	/* C16 */
	.octa 0x220000000000001
	/* C20 */
	.octa 0x800000003007102700000000403fe000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1060
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0x40000000000940050080000000000001
initial_DDC_EL1_value:
	.octa 0xc00000001dfb000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400000
final_SP_EL0_value:
	.octa 0x1060
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000040400000
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
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001060
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
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x82600da2 // ldr x2, [c13, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400da2 // str x2, [c13, #0]
	ldr x2, =0x40400414
	mrs x13, ELR_EL1
	sub x2, x2, x13
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04d // cvtp c13, x2
	.inst 0xc2c241ad // scvalue c13, c13, x2
	.inst 0x826001a2 // ldr c2, [c13, #0]
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
