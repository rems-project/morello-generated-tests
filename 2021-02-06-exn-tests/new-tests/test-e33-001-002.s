.section text0, #alloc, #execinstr
test_start:
	.inst 0xf80bbe77 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:23 Rn:19 11:11 imm9:010111011 0:0 opc:00 111000:111000 size:11
	.inst 0x79ad43b0 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:16 Rn:29 imm12:101101010000 opc:10 111001:111001 size:01
	.inst 0xc89ffd19 // stlr:aarch64/instrs/memory/ordered Rt:25 Rn:8 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x3819540f // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:15 Rn:0 01:01 imm9:110010101 0:0 opc:00 111000:111000 size:00
	.inst 0x38e103b1 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:17 Rn:29 00:00 opc:000 0:0 Rs:1 1:1 R:1 A:1 111000:111000 size:00
	.zero 1004
	.inst 0xb872613f // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:9 00:00 opc:110 o3:0 Rs:18 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xf81fb7dd // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:30 01:01 imm9:111111011 0:0 opc:00 111000:111000 size:11
	.inst 0x62a11692 // STP-C.RIBW-C Ct:18 Rn:20 Ct2:00101 imm7:1000010 L:0 011000101:011000101
	.inst 0xc2c003a1 // SCBNDS-C.CR-C Cd:1 Cn:29 000:000 opc:00 0:0 Rm:0 11000010110:11000010110
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e5 // ldr c5, [x7, #1]
	.inst 0xc24008e8 // ldr c8, [x7, #2]
	.inst 0xc2400ce9 // ldr c9, [x7, #3]
	.inst 0xc24010ef // ldr c15, [x7, #4]
	.inst 0xc24014f2 // ldr c18, [x7, #5]
	.inst 0xc24018f3 // ldr c19, [x7, #6]
	.inst 0xc2401cf4 // ldr c20, [x7, #7]
	.inst 0xc24020f7 // ldr c23, [x7, #8]
	.inst 0xc24024f9 // ldr c25, [x7, #9]
	.inst 0xc24028fd // ldr c29, [x7, #10]
	.inst 0xc2402cfe // ldr c30, [x7, #11]
	/* Set up flags and system registers */
	ldr x7, =0x0
	msr SPSR_EL3, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30d5d99f
	msr SCTLR_EL1, x7
	ldr x7, =0xc0000
	msr CPACR_EL1, x7
	ldr x7, =0x4
	msr S3_0_C1_C2_2, x7 // CCTLR_EL1
	ldr x7, =0x0
	msr S3_3_C1_C2_2, x7 // CCTLR_EL0
	ldr x7, =initial_DDC_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884127 // msr DDC_EL0, c7
	ldr x7, =initial_DDC_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc28c4127 // msr DDC_EL1, c7
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601367 // ldr c7, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e4027 // msr CELR_EL3, c7
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000fb // ldr c27, [x7, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24004fb // ldr c27, [x7, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc24008fb // ldr c27, [x7, #2]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc2400cfb // ldr c27, [x7, #3]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc24010fb // ldr c27, [x7, #4]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc24014fb // ldr c27, [x7, #5]
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	.inst 0xc24018fb // ldr c27, [x7, #6]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc2401cfb // ldr c27, [x7, #7]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc24020fb // ldr c27, [x7, #8]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc24024fb // ldr c27, [x7, #9]
	.inst 0xc2dba681 // chkeq c20, c27
	b.ne comparison_fail
	.inst 0xc24028fb // ldr c27, [x7, #10]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc2402cfb // ldr c27, [x7, #11]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc24030fb // ldr c27, [x7, #12]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc24034fb // ldr c27, [x7, #13]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	ldr x7, =esr_el1_dump_address
	ldr x7, [x7]
	mov x27, 0xc1
	orr x7, x7, x27
	ldr x27, =0x920000eb
	cmp x27, x7
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000016a4
	ldr x1, =check_data2
	ldr x2, =0x000016a6
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
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
	.byte 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x80, 0x00, 0x20, 0x00, 0x04, 0x04, 0x20, 0x02, 0x08, 0x80, 0x00, 0x80, 0x00
	.byte 0x40, 0x02, 0x00, 0x00, 0x00, 0x40, 0x02, 0x10, 0x80, 0x40, 0x80, 0x00, 0x02, 0x08, 0x09, 0x20
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x77, 0xbe, 0x0b, 0xf8, 0xb0, 0x43, 0xad, 0x79, 0x19, 0xfd, 0x9f, 0xc8, 0x0f, 0x54, 0x19, 0x38
	.byte 0xb1, 0x03, 0xe1, 0x38
.data
check_data4:
	.byte 0x3f, 0x61, 0x72, 0xb8, 0xdd, 0xb7, 0x1f, 0xf8, 0x92, 0x16, 0xa1, 0x62, 0xa1, 0x03, 0xc0, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1007
	/* C5 */
	.octa 0x20090802008040801002400000000240
	/* C8 */
	.octa 0x1000
	/* C9 */
	.octa 0x1004
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x800080080220040400200080000000
	/* C19 */
	.octa 0xf45
	/* C20 */
	.octa 0x1400
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x1000000000000000
	/* C29 */
	.octa 0x600010000000000000004
	/* C30 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xf9c
	/* C1 */
	.octa 0x4fa000040000000000000004
	/* C5 */
	.octa 0x20090802008040801002400000000240
	/* C8 */
	.octa 0x1000
	/* C9 */
	.octa 0x1004
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x800080080220040400200080000000
	/* C19 */
	.octa 0x1000
	/* C20 */
	.octa 0x1020
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x1000000000000000
	/* C29 */
	.octa 0x600010000000000000004
	/* C30 */
	.octa 0xffb
initial_DDC_EL0_value:
	.octa 0xc00000000007080700ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xcc000000280f00030000000000002aa3
initial_VBAR_EL1_value:
	.octa 0x20008000600004000000000040400000
final_PCC_value:
	.octa 0x20008000600004000000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000090000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001020
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001030
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
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x40400414
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021e00e7 // add c7, c7, #1920
	.inst 0xc2c210e0 // br c7

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
