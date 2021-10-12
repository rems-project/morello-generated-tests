.section text0, #alloc, #execinstr
test_start:
	.inst 0x82c9dc13 // ALDRH-R.RRB-32 Rt:19 Rn:0 opc:11 S:1 option:110 Rm:9 0:0 L:1 100000101:100000101
	.inst 0x82519c4e // ASTR-R.RI-64 Rt:14 Rn:2 op:11 imm9:100011001 L:0 1000001001:1000001001
	.inst 0x386600bf // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:5 00:00 opc:000 0:0 Rs:6 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x8244e641 // ASTRB-R.RI-B Rt:1 Rn:18 op:01 imm9:001001110 L:0 1000001001:1000001001
	.inst 0xe29b17fe // ALDUR-R.RI-32 Rt:30 Rn:31 op2:01 imm9:110110001 V:0 op1:10 11100010:11100010
	.zero 1004
	.inst 0x7854742e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:14 Rn:1 01:01 imm9:101000111 0:0 opc:01 111000:111000 size:01
	.inst 0x38be0383 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:28 00:00 opc:000 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x785b10a0 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:5 00:00 imm9:110110001 0:0 opc:01 111000:111000 size:01
	.inst 0xf8428fc1 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:30 11:11 imm9:000101000 0:0 opc:01 111000:111000 size:11
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a82 // ldr c2, [x20, #2]
	.inst 0xc2400e85 // ldr c5, [x20, #3]
	.inst 0xc2401286 // ldr c6, [x20, #4]
	.inst 0xc2401689 // ldr c9, [x20, #5]
	.inst 0xc2401a8e // ldr c14, [x20, #6]
	.inst 0xc2401e92 // ldr c18, [x20, #7]
	.inst 0xc240229c // ldr c28, [x20, #8]
	.inst 0xc240269e // ldr c30, [x20, #9]
	/* Set up flags and system registers */
	ldr x20, =0x0
	msr SPSR_EL3, x20
	ldr x20, =initial_SP_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2884114 // msr CSP_EL0, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30d5d99f
	msr SCTLR_EL1, x20
	ldr x20, =0xc0000
	msr CPACR_EL1, x20
	ldr x20, =0x4
	msr S3_0_C1_C2_2, x20 // CCTLR_EL1
	ldr x20, =0x4
	msr S3_3_C1_C2_2, x20 // CCTLR_EL0
	ldr x20, =initial_DDC_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2884134 // msr DDC_EL0, c20
	ldr x20, =initial_DDC_EL1_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc28c4134 // msr DDC_EL1, c20
	ldr x20, =0x80000000
	msr HCR_EL2, x20
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010f4 // ldr c20, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400287 // ldr c7, [x20, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400687 // ldr c7, [x20, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400a87 // ldr c7, [x20, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400e87 // ldr c7, [x20, #3]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2401287 // ldr c7, [x20, #4]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc2401687 // ldr c7, [x20, #5]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc2401a87 // ldr c7, [x20, #6]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401e87 // ldr c7, [x20, #7]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2402287 // ldr c7, [x20, #8]
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	.inst 0xc2402687 // ldr c7, [x20, #9]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2402a87 // ldr c7, [x20, #10]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402e87 // ldr c7, [x20, #11]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check system registers */
	ldr x20, =final_SP_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984107 // mrs c7, CSP_EL0
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	ldr x20, =final_PCC_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	ldr x20, =esr_el1_dump_address
	ldr x20, [x20]
	mov x7, 0x80
	orr x20, x20, x7
	ldr x7, =0x920000ab
	cmp x7, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001001
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001014
	ldr x1, =check_data1
	ldr x2, =0x00001016
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001030
	ldr x1, =check_data2
	ldr x2, =0x00001038
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000104e
	ldr x1, =check_data3
	ldr x2, =0x0000104f
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001110
	ldr x1, =check_data4
	ldr x2, =0x00001118
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000017b2
	ldr x1, =check_data5
	ldr x2, =0x000017b4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001800
	ldr x1, =check_data6
	ldr x2, =0x00001801
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00001900
	ldr x1, =check_data7
	ldr x2, =0x00001902
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x40400000
	ldr x1, =check_data8
	ldr x2, =0x40400014
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	ldr x0, =0x40400400
	ldr x1, =check_data9
	ldr x2, =0x40400414
check_data_loop9:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop9
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
	.zero 2048
	.byte 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 2
.data
check_data8:
	.byte 0x13, 0xdc, 0xc9, 0x82, 0x4e, 0x9c, 0x51, 0x82, 0xbf, 0x00, 0x66, 0x38, 0x41, 0xe6, 0x44, 0x82
	.byte 0xfe, 0x17, 0x9b, 0xe2
.data
check_data9:
	.byte 0x2e, 0x74, 0x54, 0x78, 0x83, 0x03, 0xbe, 0x38, 0xa0, 0x10, 0x5b, 0x78, 0xc1, 0x8f, 0x42, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000200700270000000000001000
	/* C1 */
	.octa 0x1100
	/* C2 */
	.octa 0x400000004000007c0000000000000848
	/* C5 */
	.octa 0x1001
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0xa
	/* C14 */
	.octa 0x100000000000000
	/* C18 */
	.octa 0x40000000020500060000000000001000
	/* C28 */
	.octa 0x1000
	/* C30 */
	.octa 0x808
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400000004000007c0000000000000848
	/* C3 */
	.octa 0xf8
	/* C5 */
	.octa 0x1001
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0xa
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x40000000020500060000000000001000
	/* C19 */
	.octa 0x0
	/* C28 */
	.octa 0x1000
	/* C30 */
	.octa 0x830
initial_SP_EL0_value:
	.octa 0x100000000000010
initial_DDC_EL0_value:
	.octa 0xc00000000001000700df00800080e001
initial_DDC_EL1_value:
	.octa 0xc00000004002080000ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_SP_EL0_value:
	.octa 0x100000000000010
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000420000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001040
	.dword 0x0000000000001110
	.dword 0x0000000000001800
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
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x02000294 // add c20, c20, #0
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x02020294 // add c20, c20, #128
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x02040294 // add c20, c20, #256
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x02060294 // add c20, c20, #384
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x02080294 // add c20, c20, #512
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x020a0294 // add c20, c20, #640
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x020c0294 // add c20, c20, #768
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x020e0294 // add c20, c20, #896
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x02100294 // add c20, c20, #1024
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x02120294 // add c20, c20, #1152
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x02140294 // add c20, c20, #1280
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x02160294 // add c20, c20, #1408
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x02180294 // add c20, c20, #1536
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x021a0294 // add c20, c20, #1664
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
	.inst 0x021c0294 // add c20, c20, #1792
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x82600cf4 // ldr x20, [c7, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cf4 // str x20, [c7, #0]
	ldr x20, =0x40400414
	mrs x7, ELR_EL1
	sub x20, x20, x7
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b287 // cvtp c7, x20
	.inst 0xc2d440e7 // scvalue c7, c7, x20
	.inst 0x826000f4 // ldr c20, [c7, #0]
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
