.section text0, #alloc, #execinstr
test_start:
	.inst 0xfc54dcfd // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:29 Rn:7 11:11 imm9:101001101 0:0 opc:01 111100:111100 size:11
	.inst 0xd65f03a0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:29 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.inst 0x79a060bd // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:5 imm12:100000011000 opc:10 111001:111001 size:01
	.inst 0xc2c1a5a1 // CHKEQ-_.CC-C 00001:00001 Cn:13 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0xe28a93c4 // ASTUR-R.RI-32 Rt:4 Rn:30 op2:00 imm9:010101001 V:0 op1:10 11100010:11100010
	.zero 1004
	.inst 0xf8a013e2 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:31 00:00 opc:001 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xa2e07fbb // CASA-C.R-C Ct:27 Rn:29 11111:11111 R:0 Cs:0 1:1 L:1 1:1 10100010:10100010
	.inst 0x82678821 // ALDR-R.RI-32 Rt:1 Rn:1 op:10 imm9:001111000 L:1 1000001001:1000001001
	.inst 0xc87f5461 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:3 Rt2:10101 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400923 // ldr c3, [x9, #2]
	.inst 0xc2400d25 // ldr c5, [x9, #3]
	.inst 0xc2401127 // ldr c7, [x9, #4]
	.inst 0xc240152d // ldr c13, [x9, #5]
	.inst 0xc240193b // ldr c27, [x9, #6]
	.inst 0xc2401d3d // ldr c29, [x9, #7]
	.inst 0xc240213e // ldr c30, [x9, #8]
	/* Set up flags and system registers */
	ldr x9, =0x4000000
	msr SPSR_EL3, x9
	ldr x9, =initial_SP_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28c4109 // msr CSP_EL1, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0x3c0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x0
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =initial_DDC_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28c4129 // msr DDC_EL1, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011e9 // ldr c9, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x15, #0xf
	and x9, x9, x15
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240012f // ldr c15, [x9, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240052f // ldr c15, [x9, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240092f // ldr c15, [x9, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400d2f // ldr c15, [x9, #3]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc240112f // ldr c15, [x9, #4]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc240152f // ldr c15, [x9, #5]
	.inst 0xc2cfa4e1 // chkeq c7, c15
	b.ne comparison_fail
	.inst 0xc240192f // ldr c15, [x9, #6]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc2401d2f // ldr c15, [x9, #7]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc240212f // ldr c15, [x9, #8]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc240252f // ldr c15, [x9, #9]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc240292f // ldr c15, [x9, #10]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x15, v29.d[0]
	cmp x9, x15
	b.ne comparison_fail
	ldr x9, =0x0
	mov x15, v29.d[1]
	cmp x9, x15
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_SP_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc29c410f // mrs c15, CSP_EL1
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	ldr x9, =esr_el1_dump_address
	ldr x9, [x9]
	mov x15, 0x80
	orr x9, x9, x15
	ldr x15, =0x920000ea
	cmp x15, x9
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
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001032
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001050
	ldr x1, =check_data2
	ldr x2, =0x00001058
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001ff0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff8
	ldr x1, =check_data5
	ldr x2, =0x00001ffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x40400414
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
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.byte 0xff, 0xff, 0xff, 0x73, 0x00, 0x00, 0xff, 0xb8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
	.byte 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4032
.data
check_data0:
	.byte 0xff, 0xff, 0xff, 0x73, 0x00, 0x00, 0xff, 0xb8
.data
check_data1:
	.byte 0x00, 0x18
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0xfd, 0xdc, 0x54, 0xfc, 0xa0, 0x03, 0x5f, 0xd6, 0xbd, 0x60, 0xa0, 0x79, 0xa1, 0xa5, 0xc1, 0xc2
	.byte 0xc4, 0x93, 0x8a, 0xe2
.data
check_data7:
	.byte 0xe2, 0x13, 0xa0, 0xf8, 0xbb, 0x7f, 0xe0, 0xa2, 0x21, 0x88, 0x67, 0x82, 0x61, 0x54, 0x7f, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000000100050000000000001e18
	/* C3 */
	.octa 0x1fe0
	/* C5 */
	.octa 0x80000000000300060000000000000000
	/* C7 */
	.octa 0x80000000000100070000000000001103
	/* C13 */
	.octa 0x7ffffffffffefffaffffffffffffe1e7
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x40400008
	/* C30 */
	.octa 0x34bbbbe033fdfb8
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xb8ff000073ffffff
	/* C3 */
	.octa 0x1fe0
	/* C5 */
	.octa 0x80000000000300060000000000000000
	/* C7 */
	.octa 0x80000000000100070000000000001050
	/* C13 */
	.octa 0x7ffffffffffefffaffffffffffffe1e7
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x1800
	/* C30 */
	.octa 0x34bbbbe033fdfb8
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0x400000004100700100022220000b6000
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080006000001d0000000040400000
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080006000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100798070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40400414
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
