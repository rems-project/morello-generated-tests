.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c41bbc // ALIGND-C.CI-C Cd:28 Cn:29 0110:0110 U:0 imm6:001000 11000010110:11000010110
	.inst 0xb8e4601e // ldumax:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:0 00:00 opc:110 0:0 Rs:4 1:1 R:1 A:1 111000:111000 size:10
	.inst 0x887febdd // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:29 Rn:30 Rt2:11010 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0xc2d850a1 // BLR-CI-C 1:1 0000:0000 Cn:5 100:100 imm7:1000010 110000101101:110000101101
	.zero 1008
	.inst 0x82a0e2e0 // ASTR-R.RRB-32 Rt:0 Rn:23 opc:00 S:0 option:111 Rm:0 1:1 L:0 100000101:100000101
	.inst 0xc2c1d1c1 // CPY-C.C-C Cd:1 Cn:14 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xb89a3000 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:0 00:00 imm9:110100011 0:0 opc:10 111000:111000 size:10
	.inst 0xc87fe401 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:0 Rt2:11001 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xd4000001
	.zero 1004
	.inst 0x784ec021 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:1 00:00 imm9:011101100 0:0 opc:01 111000:111000 size:01
	.zero 63484
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400944 // ldr c4, [x10, #2]
	.inst 0xc2400d45 // ldr c5, [x10, #3]
	.inst 0xc2401157 // ldr c23, [x10, #4]
	.inst 0xc240155d // ldr c29, [x10, #5]
	/* Set up flags and system registers */
	ldr x10, =0x0
	msr SPSR_EL3, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0xc0000
	msr CPACR_EL1, x10
	ldr x10, =0x4
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x0
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =initial_DDC_EL1_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc28c412a // msr DDC_EL1, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260116a // ldr c10, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc28e402a // msr CELR_EL3, c10
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240014b // ldr c11, [x10, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240054b // ldr c11, [x10, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240094b // ldr c11, [x10, #2]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc2400d4b // ldr c11, [x10, #3]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc240114b // ldr c11, [x10, #4]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc240154b // ldr c11, [x10, #5]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	.inst 0xc240194b // ldr c11, [x10, #6]
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	.inst 0xc2401d4b // ldr c11, [x10, #7]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc240214b // ldr c11, [x10, #8]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc240254b // ldr c11, [x10, #9]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x11, 0x80
	orr x10, x10, x11
	ldr x11, =0x920000a1
	cmp x11, x10
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
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001028
	ldr x1, =check_data2
	ldr x2, =0x0000102c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001054
	ldr x1, =check_data3
	ldr x2, =0x00001058
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001420
	ldr x1, =check_data4
	ldr x2, =0x00001430
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400010
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
	ldr x0, =0x40400800
	ldr x1, =check_data7
	ldr x2, =0x40400804
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x87, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 960
	.byte 0x01, 0x08, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x81, 0xd0, 0x00, 0x80, 0x00, 0x20
	.zero 3024
.data
check_data0:
	.byte 0x28, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data3:
	.byte 0x87, 0x0f, 0x00, 0x00
.data
check_data4:
	.byte 0x01, 0x08, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x81, 0xd0, 0x00, 0x80, 0x00, 0x20
.data
check_data5:
	.byte 0xbc, 0x1b, 0xc4, 0xc2, 0x1e, 0x60, 0xe4, 0xb8, 0xdd, 0xeb, 0x7f, 0x88, 0xa1, 0x50, 0xd8, 0xc2
.data
check_data6:
	.byte 0xe0, 0xe2, 0xa0, 0x82, 0xc1, 0xd1, 0xc1, 0xc2, 0x00, 0x30, 0x9a, 0xb8, 0x01, 0xe4, 0x7f, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.byte 0x21, 0xc0, 0x4e, 0x78

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1028
	/* C1 */
	.octa 0x80000000480200010000000000000609
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x90100000400400090000000000001800
	/* C23 */
	.octa 0x400000002001c005ffffffffffffffd8
	/* C29 */
	.octa 0xc1010004000000000000a003
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xf87
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x90100000400400090000000000001800
	/* C23 */
	.octa 0x400000002001c005ffffffffffffffd8
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0xc1010004000000000000a000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000100070000000040400010
initial_DDC_EL0_value:
	.octa 0xc00000000003000700ffe00000000001
initial_DDC_EL1_value:
	.octa 0x800000005060008900ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004420003d0000000040400000
final_PCC_value:
	.octa 0x200080004420003d0000000040400414
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
	.dword 0x0000000000001420
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001420
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001020
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x82600d6a // ldr x10, [c11, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d6a // str x10, [c11, #0]
	ldr x10, =0x40400414
	mrs x11, ELR_EL1
	sub x10, x10, x11
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14b // cvtp c11, x10
	.inst 0xc2ca416b // scvalue c11, c11, x10
	.inst 0x8260016a // ldr c10, [c11, #0]
	.inst 0x021e014a // add c10, c10, #1920
	.inst 0xc2c21140 // br c10

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
