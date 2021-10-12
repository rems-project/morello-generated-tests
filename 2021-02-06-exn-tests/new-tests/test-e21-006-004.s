.section text0, #alloc, #execinstr
test_start:
	.inst 0x38ce87dd // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:30 01:01 imm9:011101000 0:0 opc:11 111000:111000 size:00
	.inst 0x2b208c36 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:22 Rn:1 imm3:011 option:100 Rm:0 01011001:01011001 S:1 op:0 sf:0
	.inst 0xe247940c // ALDURH-R.RI-32 Rt:12 Rn:0 op2:01 imm9:001111001 V:0 op1:01 11100010:11100010
	.inst 0xeb1b9f20 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:0 Rn:25 imm6:100111 Rm:27 0:0 shift:00 01011:01011 S:1 op:1 sf:1
	.inst 0x38ca921c // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:28 Rn:16 00:00 imm9:010101001 0:0 opc:11 111000:111000 size:00
	.zero 35820
	.inst 0xc2c1123d // GCLIM-R.C-C Rd:29 Cn:17 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x225f7c41 // LDXR-C.R-C Ct:1 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x78419024 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:4 Rn:1 00:00 imm9:000011001 0:0 opc:01 111000:111000 size:01
	.inst 0x08dffc00 // ldarb:aarch64/instrs/memory/ordered Rt:0 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xd4000001
	.zero 29676
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400742 // ldr c2, [x26, #1]
	.inst 0xc2400b50 // ldr c16, [x26, #2]
	.inst 0xc2400f51 // ldr c17, [x26, #3]
	.inst 0xc2401359 // ldr c25, [x26, #4]
	.inst 0xc240175b // ldr c27, [x26, #5]
	.inst 0xc2401b5e // ldr c30, [x26, #6]
	/* Set up flags and system registers */
	ldr x26, =0x4000000
	msr SPSR_EL3, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0xc0000
	msr CPACR_EL1, x26
	ldr x26, =0x4
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x4
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =initial_DDC_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc28c413a // msr DDC_EL1, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260127a // ldr c26, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc28e403a // msr CELR_EL3, c26
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x19, #0xf
	and x26, x26, x19
	cmp x26, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400353 // ldr c19, [x26, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400753 // ldr c19, [x26, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400b53 // ldr c19, [x26, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400f53 // ldr c19, [x26, #3]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc2401353 // ldr c19, [x26, #4]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc2401753 // ldr c19, [x26, #5]
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	.inst 0xc2401b53 // ldr c19, [x26, #6]
	.inst 0xc2d3a621 // chkeq c17, c19
	b.ne comparison_fail
	.inst 0xc2401f53 // ldr c19, [x26, #7]
	.inst 0xc2d3a721 // chkeq c25, c19
	b.ne comparison_fail
	.inst 0xc2402353 // ldr c19, [x26, #8]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc2402753 // ldr c19, [x26, #9]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2402b53 // ldr c19, [x26, #10]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984033 // mrs c19, CELR_EL1
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	ldr x26, =esr_el1_dump_address
	ldr x26, [x26]
	mov x19, 0xc1
	orr x26, x26, x19
	ldr x19, =0x920000eb
	cmp x19, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000107c
	ldr x1, =check_data1
	ldr x2, =0x0000107e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001226
	ldr x1, =check_data2
	ldr x2, =0x00001227
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe2
	ldr x1, =check_data3
	ldr x2, =0x00001fe4
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
	ldr x0, =0x40408c00
	ldr x1, =check_data5
	ldr x2, =0x40408c14
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
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
	.byte 0xc9, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xc9, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xdd, 0x87, 0xce, 0x38, 0x36, 0x8c, 0x20, 0x2b, 0x0c, 0x94, 0x47, 0xe2, 0x20, 0x9f, 0x1b, 0xeb
	.byte 0x1c, 0x92, 0xca, 0x38
.data
check_data5:
	.byte 0x3d, 0x12, 0xc1, 0xc2, 0x41, 0x7c, 0x5f, 0x22, 0x24, 0x90, 0x41, 0x78, 0x00, 0xfc, 0xdf, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1003
	/* C2 */
	.octa 0x1000
	/* C16 */
	.octa 0x80000000200120077fffffffffffff55
	/* C17 */
	.octa 0x4004e00c0000000000000001
	/* C25 */
	.octa 0xffff800000001000
	/* C27 */
	.octa 0x1ffff00
	/* C30 */
	.octa 0x80000000000100050000000000001226
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc9
	/* C1 */
	.octa 0x1fc9
	/* C2 */
	.octa 0x1000
	/* C4 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x80000000200120077fffffffffffff55
	/* C17 */
	.octa 0x4004e00c0000000000000001
	/* C25 */
	.octa 0xffff800000001000
	/* C27 */
	.octa 0x1ffff00
	/* C29 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x8000000000010005000000000000130e
initial_DDC_EL0_value:
	.octa 0x800000005082000000ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x800000000006000200fffffffc00e000
initial_VBAR_EL1_value:
	.octa 0x200080004000860d0000000040408800
final_PCC_value:
	.octa 0x200080004000860d0000000040408c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004080c1010000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword final_cap_values + 160
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x82600e7a // ldr x26, [c19, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e7a // str x26, [c19, #0]
	ldr x26, =0x40408c14
	mrs x19, ELR_EL1
	sub x26, x26, x19
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b353 // cvtp c19, x26
	.inst 0xc2da4273 // scvalue c19, c19, x26
	.inst 0x8260027a // ldr c26, [c19, #0]
	.inst 0x021e035a // add c26, c26, #1920
	.inst 0xc2c21340 // br c26

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
