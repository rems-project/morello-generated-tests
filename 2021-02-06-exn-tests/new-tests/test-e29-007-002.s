.section text0, #alloc, #execinstr
test_start:
	.inst 0x08dffda1 // ldarb:aarch64/instrs/memory/ordered Rt:1 Rn:13 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x382b62df // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:110 o3:0 Rs:11 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa20f941e // STR-C.RIAW-C Ct:30 Rn:0 01:01 imm9:011111001 0:0 opc:00 10100010:10100010
	.inst 0x387d33bf // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:011 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc87f8bea // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:10 Rn:31 Rt2:00010 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.zero 1004
	.inst 0x382172c9 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:22 00:00 opc:111 0:0 Rs:1 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x3a1e0341 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:26 000000:000000 Rm:30 11010000:11010000 S:1 op:0 sf:0
	.inst 0x629d6be2 // STP-C.RIBW-C Ct:2 Rn:31 Ct2:11010 imm7:0111010 L:0 011000101:011000101
	.inst 0xb811ad5c // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:28 Rn:10 11:11 imm9:100011010 0:0 opc:00 111000:111000 size:10
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400aea // ldr c10, [x23, #2]
	.inst 0xc2400eeb // ldr c11, [x23, #3]
	.inst 0xc24012ed // ldr c13, [x23, #4]
	.inst 0xc24016f6 // ldr c22, [x23, #5]
	.inst 0xc2401afa // ldr c26, [x23, #6]
	.inst 0xc2401efc // ldr c28, [x23, #7]
	.inst 0xc24022fd // ldr c29, [x23, #8]
	.inst 0xc24026fe // ldr c30, [x23, #9]
	/* Set up flags and system registers */
	ldr x23, =0x4000000
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =initial_SP_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4117 // msr CSP_EL1, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82601077 // ldr c23, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x3, #0xf
	and x23, x23, x3
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e3 // ldr c3, [x23, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24006e3 // ldr c3, [x23, #1]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400ae3 // ldr c3, [x23, #2]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2400ee3 // ldr c3, [x23, #3]
	.inst 0xc2c3a541 // chkeq c10, c3
	b.ne comparison_fail
	.inst 0xc24012e3 // ldr c3, [x23, #4]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc24016e3 // ldr c3, [x23, #5]
	.inst 0xc2c3a5a1 // chkeq c13, c3
	b.ne comparison_fail
	.inst 0xc2401ae3 // ldr c3, [x23, #6]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc2401ee3 // ldr c3, [x23, #7]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc24022e3 // ldr c3, [x23, #8]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc24026e3 // ldr c3, [x23, #9]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402ae3 // ldr c3, [x23, #10]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984103 // mrs c3, CSP_EL0
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	ldr x23, =final_SP_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc29c4103 // mrs c3, CSP_EL1
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x3, 0x80
	orr x23, x23, x3
	ldr x3, =0x920000a8
	cmp x3, x23
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
	ldr x0, =0x00001296
	ldr x1, =check_data1
	ldr x2, =0x00001297
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000131c
	ldr x1, =check_data2
	ldr x2, =0x00001320
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013c0
	ldr x1, =check_data3
	ldr x2, =0x000013e0
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
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x10, 0x00
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0xa1, 0xfd, 0xdf, 0x08, 0xdf, 0x62, 0x2b, 0x38, 0x1e, 0x94, 0x0f, 0xa2, 0xbf, 0x33, 0x7d, 0x38
	.byte 0xea, 0x8b, 0x7f, 0xc8
.data
check_data5:
	.byte 0xc9, 0x72, 0x21, 0x38, 0x41, 0x03, 0x1e, 0x3a, 0xe2, 0x6b, 0x9d, 0x62, 0x5c, 0xad, 0x11, 0xb8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x48000000540208040000000000001000
	/* C2 */
	.octa 0x0
	/* C10 */
	.octa 0x1402
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x80000000400401010000000000001296
	/* C22 */
	.octa 0xc00000005202000b0000000000001000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x100000
	/* C29 */
	.octa 0xc0000000500400020000000000001000
	/* C30 */
	.octa 0x4000000000000080003000000040
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x48000000540208040000000000001f90
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x40
	/* C10 */
	.octa 0x131c
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x80000000400401010000000000001296
	/* C22 */
	.octa 0xc00000005202000b0000000000001000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x100000
	/* C29 */
	.octa 0xc0000000500400020000000000001000
	/* C30 */
	.octa 0x4000000000000080003000000040
initial_SP_EL0_value:
	.octa 0x800000000000c0
initial_SP_EL1_value:
	.octa 0x1020
initial_DDC_EL1_value:
	.octa 0xcc0000000007000f0000000000006001
initial_VBAR_EL1_value:
	.octa 0x20008000500001010000000040400000
final_SP_EL0_value:
	.octa 0x800000000000c0
final_SP_EL1_value:
	.octa 0x13c0
final_PCC_value:
	.octa 0x20008000500001010000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x00000000000013c0
	.dword 0x00000000000013d0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001310
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400414
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
