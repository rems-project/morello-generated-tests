.section text0, #alloc, #execinstr
test_start:
	.inst 0x38158821 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:1 10:10 imm9:101011000 0:0 opc:00 111000:111000 size:00
	.inst 0x787e10ff // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:7 00:00 opc:001 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x08137fc9 // stxrb:aarch64/instrs/memory/exclusive/single Rt:9 Rn:30 Rt2:11111 o0:0 Rs:19 0:0 L:0 0010000:0010000 size:00
	.inst 0xc2c130c0 // GCFLGS-R.C-C Rd:0 Cn:6 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x785c0bbe // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:29 10:10 imm9:111000000 0:0 opc:01 111000:111000 size:01
	.zero 50156
	.inst 0xf8bd7af1 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:17 Rn:23 10:10 S:1 option:011 Rm:29 1:1 opc:10 111000:111000 size:11
	.inst 0x78bd10ba // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:5 00:00 opc:001 0:0 Rs:29 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x489f7fe1 // stllrh:aarch64/instrs/memory/ordered Rt:1 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x4809fffd // stlxrh:aarch64/instrs/memory/exclusive/single Rt:29 Rn:31 Rt2:11111 o0:1 Rs:9 0:0 L:0 0010000:0010000 size:01
	.inst 0xd4000001
	.zero 15340
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400465 // ldr c5, [x3, #1]
	.inst 0xc2400867 // ldr c7, [x3, #2]
	.inst 0xc2400c7d // ldr c29, [x3, #3]
	.inst 0xc240107e // ldr c30, [x3, #4]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =initial_SP_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4103 // msr CSP_EL1, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0xc0000
	msr CPACR_EL1, x3
	ldr x3, =0x4
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x4
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =initial_DDC_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4123 // msr DDC_EL1, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82601043 // ldr c3, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400062 // ldr c2, [x3, #0]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2c2a4a1 // chkeq c5, c2
	b.ne comparison_fail
	.inst 0xc2400862 // ldr c2, [x3, #2]
	.inst 0xc2c2a4e1 // chkeq c7, c2
	b.ne comparison_fail
	.inst 0xc2400c62 // ldr c2, [x3, #3]
	.inst 0xc2c2a521 // chkeq c9, c2
	b.ne comparison_fail
	.inst 0xc2401062 // ldr c2, [x3, #4]
	.inst 0xc2c2a661 // chkeq c19, c2
	b.ne comparison_fail
	.inst 0xc2401462 // ldr c2, [x3, #5]
	.inst 0xc2c2a741 // chkeq c26, c2
	b.ne comparison_fail
	.inst 0xc2401862 // ldr c2, [x3, #6]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc2401c62 // ldr c2, [x3, #7]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_SP_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc29c4102 // mrs c2, CSP_EL1
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x2, 0x80
	orr x3, x3, x2
	ldr x2, =0x920000a1
	cmp x2, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010fe
	ldr x1, =check_data0
	ldr x2, =0x000010ff
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001870
	ldr x1, =check_data1
	ldr x2, =0x00001872
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001900
	ldr x1, =check_data2
	ldr x2, =0x00001902
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001980
	ldr x1, =check_data3
	ldr x2, =0x00001982
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040c400
	ldr x1, =check_data6
	ldr x2, =0x4040c414
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
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
	.zero 2304
	.byte 0x01, 0xe0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 112
	.byte 0x5e, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1648
.data
check_data0:
	.byte 0xa6
.data
check_data1:
	.byte 0xa6, 0x11
.data
check_data2:
	.byte 0x01, 0xe0
.data
check_data3:
	.byte 0x5e, 0xff
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x21, 0x88, 0x15, 0x38, 0xff, 0x10, 0x7e, 0x78, 0xc9, 0x7f, 0x13, 0x08, 0xc0, 0x30, 0xc1, 0xc2
	.byte 0xbe, 0x0b, 0x5c, 0x78
.data
check_data6:
	.byte 0xf1, 0x7a, 0xbd, 0xf8, 0xba, 0x10, 0xbd, 0x78, 0xe1, 0x7f, 0x9f, 0x48, 0xfd, 0xff, 0x09, 0x48
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x11a6
	/* C5 */
	.octa 0x180
	/* C7 */
	.octa 0x1900
	/* C29 */
	.octa 0x81
	/* C30 */
	.octa 0x1ffe
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x11a6
	/* C5 */
	.octa 0x180
	/* C7 */
	.octa 0x1900
	/* C9 */
	.octa 0x1
	/* C19 */
	.octa 0x1
	/* C26 */
	.octa 0xff5e
	/* C29 */
	.octa 0x81
	/* C30 */
	.octa 0x1ffe
initial_SP_EL1_value:
	.octa 0x70
initial_DDC_EL0_value:
	.octa 0xc0000000000700070000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000200701830000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000941d000000004040c000
final_SP_EL1_value:
	.octa 0x70
final_PCC_value:
	.octa 0x200080005000941d000000004040c414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000780000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000010f0
	.dword 0x0000000000001870
	.dword 0x0000000000001900
	.dword 0x0000000000001980
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x4040c414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
