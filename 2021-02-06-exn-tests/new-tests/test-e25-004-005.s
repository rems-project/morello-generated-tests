.section text0, #alloc, #execinstr
test_start:
	.inst 0x38158821 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:1 10:10 imm9:101011000 0:0 opc:00 111000:111000 size:00
	.inst 0x787e10ff // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:7 00:00 opc:001 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x08137fc9 // stxrb:aarch64/instrs/memory/exclusive/single Rt:9 Rn:30 Rt2:11111 o0:0 Rs:19 0:0 L:0 0010000:0010000 size:00
	.inst 0xc2c130c0 // GCFLGS-R.C-C Rd:0 Cn:6 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x785c0bbe // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:29 10:10 imm9:111000000 0:0 opc:01 111000:111000 size:01
	.zero 1004
	.inst 0xf8bd7af1 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:17 Rn:23 10:10 S:1 option:011 Rm:29 1:1 opc:10 111000:111000 size:11
	.inst 0x78bd10ba // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:5 00:00 opc:001 0:0 Rs:29 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x489f7fe1 // stllrh:aarch64/instrs/memory/ordered Rt:1 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x4809fffd // stlxrh:aarch64/instrs/memory/exclusive/single Rt:29 Rn:31 Rt2:11111 o0:1 Rs:9 0:0 L:0 0010000:0010000 size:01
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400485 // ldr c5, [x4, #1]
	.inst 0xc2400887 // ldr c7, [x4, #2]
	.inst 0xc2400c9d // ldr c29, [x4, #3]
	.inst 0xc240109e // ldr c30, [x4, #4]
	/* Set up flags and system registers */
	ldr x4, =0x0
	msr SPSR_EL3, x4
	ldr x4, =initial_SP_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc28c4104 // msr CSP_EL1, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0xc0000
	msr CPACR_EL1, x4
	ldr x4, =0x0
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =0x4
	msr S3_3_C1_C2_2, x4 // CCTLR_EL0
	ldr x4, =initial_DDC_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884124 // msr DDC_EL0, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601164 // ldr c4, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc28e4024 // msr CELR_EL3, c4
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008b // ldr c11, [x4, #0]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240048b // ldr c11, [x4, #1]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc240088b // ldr c11, [x4, #2]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc2400c8b // ldr c11, [x4, #3]
	.inst 0xc2cba521 // chkeq c9, c11
	b.ne comparison_fail
	.inst 0xc240108b // ldr c11, [x4, #4]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc240148b // ldr c11, [x4, #5]
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	.inst 0xc240188b // ldr c11, [x4, #6]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc2401c8b // ldr c11, [x4, #7]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_SP_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc29c410b // mrs c11, CSP_EL1
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	ldr x4, =esr_el1_dump_address
	ldr x4, [x4]
	mov x11, 0x80
	orr x4, x4, x11
	ldr x11, =0x920000a1
	cmp x11, x4
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
	ldr x0, =0x00001068
	ldr x1, =check_data1
	ldr x2, =0x00001069
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001081
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017f0
	ldr x1, =check_data3
	ldr x2, =0x000017f2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001dfc
	ldr x1, =check_data4
	ldr x2, =0x00001dfe
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
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
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
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
	.byte 0xff, 0x3f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3552
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xbf, 0x20, 0x00, 0x00
	.zero 512
.data
check_data0:
	.byte 0xff, 0x2f
.data
check_data1:
	.byte 0x90
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x90, 0x10
.data
check_data4:
	.byte 0xbe, 0x20
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
	.octa 0x1090
	/* C5 */
	.octa 0xc0000000000100050000000000001dfc
	/* C7 */
	.octa 0xf80
	/* C29 */
	.octa 0x20001
	/* C30 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1090
	/* C5 */
	.octa 0xc0000000000100050000000000001dfc
	/* C7 */
	.octa 0xf80
	/* C9 */
	.octa 0x1
	/* C19 */
	.octa 0x1
	/* C26 */
	.octa 0x20bf
	/* C29 */
	.octa 0x20001
	/* C30 */
	.octa 0x1000
initial_SP_EL1_value:
	.octa 0x400000000001000500000000000017f0
initial_DDC_EL0_value:
	.octa 0xc0000000001f00250000000000007f23
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400001
final_SP_EL1_value:
	.octa 0x400000000001000500000000000017f0
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000680800000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001060
	.dword 0x00000000000017f0
	.dword 0x0000000000001df0
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600d64 // ldr x4, [c11, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d64 // str x4, [c11, #0]
	ldr x4, =0x40400414
	mrs x11, ELR_EL1
	sub x4, x4, x11
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08b // cvtp c11, x4
	.inst 0xc2c4416b // scvalue c11, c11, x4
	.inst 0x82600164 // ldr c4, [c11, #0]
	.inst 0x021e0084 // add c4, c4, #1920
	.inst 0xc2c21080 // br c4

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
