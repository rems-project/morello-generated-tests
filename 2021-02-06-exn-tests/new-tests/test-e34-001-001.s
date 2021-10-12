.section text0, #alloc, #execinstr
test_start:
	.inst 0xfc54dcfd // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:29 Rn:7 11:11 imm9:101001101 0:0 opc:01 111100:111100 size:11
	.inst 0xd65f03a0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:29 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.inst 0x79a060bd // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:5 imm12:100000011000 opc:10 111001:111001 size:01
	.inst 0xc2c1a5a1 // CHKEQ-_.CC-C 00001:00001 Cn:13 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0xe28a93c4 // ASTUR-R.RI-32 Rt:4 Rn:30 op2:00 imm9:010101001 V:0 op1:10 11100010:11100010
	.zero 25580
	.inst 0xf8a013e2 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:31 00:00 opc:001 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xa2e07fbb // CASA-C.R-C Ct:27 Rn:29 11111:11111 R:0 Cs:0 1:1 L:1 1:1 10100010:10100010
	.inst 0x82678821 // ALDR-R.RI-32 Rt:1 Rn:1 op:10 imm9:001111000 L:1 1000001001:1000001001
	.inst 0xc87f5461 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:3 Rt2:10101 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xd4000001
	.zero 34088
	.inst 0x00001000
	.zero 5824
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c3 // ldr c3, [x6, #2]
	.inst 0xc2400cc5 // ldr c5, [x6, #3]
	.inst 0xc24010c7 // ldr c7, [x6, #4]
	.inst 0xc24014cd // ldr c13, [x6, #5]
	.inst 0xc24018db // ldr c27, [x6, #6]
	.inst 0xc2401cdd // ldr c29, [x6, #7]
	.inst 0xc24020de // ldr c30, [x6, #8]
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4106 // msr CSP_EL1, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0x3c0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x4
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =initial_DDC_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4126 // msr DDC_EL1, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601166 // ldr c6, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x11, #0xf
	and x6, x6, x11
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000cb // ldr c11, [x6, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24004cb // ldr c11, [x6, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24008cb // ldr c11, [x6, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400ccb // ldr c11, [x6, #3]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc24010cb // ldr c11, [x6, #4]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc24014cb // ldr c11, [x6, #5]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc24018cb // ldr c11, [x6, #6]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc2401ccb // ldr c11, [x6, #7]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc24020cb // ldr c11, [x6, #8]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc24024cb // ldr c11, [x6, #9]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc24028cb // ldr c11, [x6, #10]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x11, v29.d[0]
	cmp x6, x11
	b.ne comparison_fail
	ldr x6, =0x0
	mov x11, v29.d[1]
	cmp x6, x11
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc29c410b // mrs c11, CSP_EL1
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x11, 0x80
	orr x6, x6, x11
	ldr x11, =0x920000e8
	cmp x11, x6
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
	ldr x0, =0x000017f8
	ldr x1, =check_data1
	ldr x2, =0x000017fc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
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
	ldr x0, =0x40406400
	ldr x1, =check_data4
	ldr x2, =0x40406414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040a350
	ldr x1, =check_data5
	ldr x2, =0x4040a358
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040e93c
	ldr x1, =check_data6
	ldr x2, =0x4040e93e
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
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.byte 0x00, 0xfe, 0xfe, 0xff, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0xff, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xfd, 0xdc, 0x54, 0xfc, 0xa0, 0x03, 0x5f, 0xd6, 0xbd, 0x60, 0xa0, 0x79, 0xa1, 0xa5, 0xc1, 0xc2
	.byte 0xc4, 0x93, 0x8a, 0xe2
.data
check_data4:
	.byte 0xe2, 0x13, 0xa0, 0xf8, 0xbb, 0x7f, 0xe0, 0xa2, 0x21, 0x88, 0x67, 0x82, 0x61, 0x54, 0x7f, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x00, 0x10

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfefe00
	/* C1 */
	.octa 0x800000000801c0050000000000001618
	/* C3 */
	.octa 0x1fe0
	/* C5 */
	.octa 0x8000000000010005000000004040d90c
	/* C7 */
	.octa 0x8000000000010006000000004040a403
	/* C13 */
	.octa 0x7ffffffff7fe3ffaffffffffffffe9e7
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x40400008
	/* C30 */
	.octa 0x7fffffffffff57
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x20ff000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x20fffefe00
	/* C3 */
	.octa 0x1fe0
	/* C5 */
	.octa 0x8000000000010005000000004040d90c
	/* C7 */
	.octa 0x8000000000010006000000004040a350
	/* C13 */
	.octa 0x7ffffffff7fe3ffaffffffffffffe9e7
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x7fffffffffff57
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0x300070000000000000000
initial_DDC_EL1_value:
	.octa 0xcc000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000441d0000000040406000
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080004000441d0000000040406414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000426c0030000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 128
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600d66 // ldr x6, [c11, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d66 // str x6, [c11, #0]
	ldr x6, =0x40406414
	mrs x11, ELR_EL1
	sub x6, x6, x11
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cb // cvtp c11, x6
	.inst 0xc2c6416b // scvalue c11, c11, x6
	.inst 0x82600166 // ldr c6, [c11, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
