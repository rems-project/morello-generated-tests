.section text0, #alloc, #execinstr
test_start:
	.inst 0xfc54dcfd // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:29 Rn:7 11:11 imm9:101001101 0:0 opc:01 111100:111100 size:11
	.inst 0xd65f03a0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:29 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 8180
	.inst 0x79a060bd // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:5 imm12:100000011000 opc:10 111001:111001 size:01
	.inst 0xc2c1a5a1 // CHKEQ-_.CC-C 00001:00001 Cn:13 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0xe28a93c4 // ASTUR-R.RI-32 Rt:4 Rn:30 op2:00 imm9:010101001 V:0 op1:10 11100010:11100010
	.zero 19448
	.inst 0xf8a013e2 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:31 00:00 opc:001 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xa2e07fbb // CASA-C.R-C Ct:27 Rn:29 11111:11111 R:0 Cs:0 1:1 L:1 1:1 10100010:10100010
	.inst 0x82678821 // ALDR-R.RI-32 Rt:1 Rn:1 op:10 imm9:001111000 L:1 1000001001:1000001001
	.inst 0xc87f5461 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:3 Rt2:10101 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xd4000001
	.zero 37868
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b03 // ldr c3, [x24, #2]
	.inst 0xc2400f05 // ldr c5, [x24, #3]
	.inst 0xc2401307 // ldr c7, [x24, #4]
	.inst 0xc240170d // ldr c13, [x24, #5]
	.inst 0xc2401b1b // ldr c27, [x24, #6]
	.inst 0xc2401f1d // ldr c29, [x24, #7]
	.inst 0xc240231e // ldr c30, [x24, #8]
	/* Set up flags and system registers */
	ldr x24, =0x4000000
	msr SPSR_EL3, x24
	ldr x24, =initial_SP_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28c4118 // msr CSP_EL1, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0x3c0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x0
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =initial_DDC_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28c4138 // msr DDC_EL1, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601158 // ldr c24, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x10, #0xf
	and x24, x24, x10
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240030a // ldr c10, [x24, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240070a // ldr c10, [x24, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400b0a // ldr c10, [x24, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400f0a // ldr c10, [x24, #3]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc240130a // ldr c10, [x24, #4]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240170a // ldr c10, [x24, #5]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc2401b0a // ldr c10, [x24, #6]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc2401f0a // ldr c10, [x24, #7]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc240230a // ldr c10, [x24, #8]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc240270a // ldr c10, [x24, #9]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2402b0a // ldr c10, [x24, #10]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x10, v29.d[0]
	cmp x24, x10
	b.ne comparison_fail
	ldr x24, =0x0
	mov x10, v29.d[1]
	cmp x24, x10
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_SP_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc29c410a // mrs c10, CSP_EL1
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	ldr x24, =esr_el1_dump_address
	ldr x24, [x24]
	mov x10, 0x80
	orr x24, x24, x10
	ldr x10, =0x920000e1
	cmp x10, x24
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
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001408
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001410
	ldr x1, =check_data2
	ldr x2, =0x00001412
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040000c
	ldr x1, =check_data4
	ldr x2, =0x40400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40401120
	ldr x1, =check_data5
	ldr x2, =0x40401128
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40401ffc
	ldr x1, =check_data6
	ldr x2, =0x40402008
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40406c00
	ldr x1, =check_data7
	ldr x2, =0x40406c14
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
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.zero 1024
	.byte 0xff, 0xff, 0x00, 0xdf, 0xff, 0xf7, 0x7f, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3040
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0xff, 0xff, 0x00, 0xdf, 0xff, 0xf7, 0x7f, 0xff
.data
check_data2:
	.byte 0x00, 0x10
.data
check_data3:
	.byte 0xfd, 0xdc, 0x54, 0xfc, 0xa0, 0x03, 0x5f, 0xd6
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0xbd, 0x60, 0xa0, 0x79, 0xa1, 0xa5, 0xc1, 0xc2, 0xc4, 0x93, 0x8a, 0xe2
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
	.octa 0x800000005002000700000000403ffe2c
	/* C3 */
	.octa 0x1000
	/* C5 */
	.octa 0x8000000040010c0200000000000003e0
	/* C7 */
	.octa 0x800000000001000700000000404011d3
	/* C13 */
	.octa 0x7fffffffaffdfff8ffffffffbfc001d3
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x40401ffc
	/* C30 */
	.octa 0x7fffffffffff58
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xff7ff7ffdf00ffff
	/* C3 */
	.octa 0x1000
	/* C5 */
	.octa 0x8000000040010c0200000000000003e0
	/* C7 */
	.octa 0x80000000000100070000000040401120
	/* C13 */
	.octa 0x7fffffffaffdfff8ffffffffbfc001d3
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x7fffffffffff58
initial_SP_EL1_value:
	.octa 0x1400
initial_DDC_EL0_value:
	.octa 0x400000002007e007007fffffffffc001
initial_DDC_EL1_value:
	.octa 0xdc000000200701070000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004c20503e0000000040406800
final_SP_EL1_value:
	.octa 0x1400
final_PCC_value:
	.octa 0x200080004c20503e0000000040406c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001000
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001400
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600d58 // ldr x24, [c10, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d58 // str x24, [c10, #0]
	ldr x24, =0x40406c14
	mrs x10, ELR_EL1
	sub x24, x24, x10
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30a // cvtp c10, x24
	.inst 0xc2d8414a // scvalue c10, c10, x24
	.inst 0x82600158 // ldr c24, [c10, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
