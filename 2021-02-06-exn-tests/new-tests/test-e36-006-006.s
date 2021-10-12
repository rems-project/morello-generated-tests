.section text0, #alloc, #execinstr
test_start:
	.inst 0x8248c40a // ASTRB-R.RI-B Rt:10 Rn:0 op:01 imm9:010001100 L:0 1000001001:1000001001
	.inst 0xb8420ad1 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:17 Rn:22 10:10 imm9:000100000 0:0 opc:01 111000:111000 size:10
	.inst 0x227f4ee0 // LDXP-C.R-C Ct:0 Rn:23 Ct2:10011 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0x289a10dd // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:29 Rn:6 Rt2:00100 imm7:0110100 L:0 1010001:1010001 opc:00
	.inst 0x889f7f3d // stllr:aarch64/instrs/memory/ordered Rt:29 Rn:25 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.zero 1004
	.inst 0x9bab59fd // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:15 Ra:22 o0:0 Rm:11 01:01 U:1 10011011:10011011
	.inst 0x3a516020 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:1 00:00 cond:0110 Rm:17 111010010:111010010 op:0 sf:0
	.inst 0xc2d8983d // ALIGND-C.CI-C Cd:29 Cn:1 0110:0110 U:0 imm6:110001 11000010110:11000010110
	.inst 0x08e67fb5 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:21 Rn:29 11111:11111 o0:0 Rs:6 1:1 L:1 0010001:0010001 size:00
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
	ldr x30, =initial_cap_values
	.inst 0xc24003c0 // ldr c0, [x30, #0]
	.inst 0xc24007c1 // ldr c1, [x30, #1]
	.inst 0xc2400bc4 // ldr c4, [x30, #2]
	.inst 0xc2400fc6 // ldr c6, [x30, #3]
	.inst 0xc24013ca // ldr c10, [x30, #4]
	.inst 0xc24017d6 // ldr c22, [x30, #5]
	.inst 0xc2401bd7 // ldr c23, [x30, #6]
	.inst 0xc2401fd9 // ldr c25, [x30, #7]
	.inst 0xc24023dd // ldr c29, [x30, #8]
	/* Set up flags and system registers */
	ldr x30, =0x14000000
	msr SPSR_EL3, x30
	ldr x30, =0x200
	msr CPTR_EL3, x30
	ldr x30, =0x30d5d99f
	msr SCTLR_EL1, x30
	ldr x30, =0xc0000
	msr CPACR_EL1, x30
	ldr x30, =0x4
	msr S3_0_C1_C2_2, x30 // CCTLR_EL1
	ldr x30, =0x4
	msr S3_3_C1_C2_2, x30 // CCTLR_EL0
	ldr x30, =initial_DDC_EL0_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc288413e // msr DDC_EL0, c30
	ldr x30, =initial_DDC_EL1_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc28c413e // msr DDC_EL1, c30
	ldr x30, =0x80000000
	msr HCR_EL2, x30
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260135e // ldr c30, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc28e403e // msr CELR_EL3, c30
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01e // cvtp c30, x0
	.inst 0xc2df43de // scvalue c30, c30, x31
	.inst 0xc28b413e // msr DDC_EL3, c30
	ldr x30, =0x30851035
	msr SCTLR_EL3, x30
	isb
	/* Check processor flags */
	mrs x30, nzcv
	ubfx x30, x30, #28, #4
	mov x26, #0xf
	and x30, x30, x26
	cmp x30, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x30, =final_cap_values
	.inst 0xc24003da // ldr c26, [x30, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24007da // ldr c26, [x30, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400bda // ldr c26, [x30, #2]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc2400fda // ldr c26, [x30, #3]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc24013da // ldr c26, [x30, #4]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc24017da // ldr c26, [x30, #5]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc2401bda // ldr c26, [x30, #6]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc2401fda // ldr c26, [x30, #7]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc24023da // ldr c26, [x30, #8]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc24027da // ldr c26, [x30, #9]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc2402bda // ldr c26, [x30, #10]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	/* Check system registers */
	ldr x30, =final_PCC_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	ldr x30, =esr_el1_dump_address
	ldr x30, [x30]
	mov x26, 0x80
	orr x30, x30, x26
	ldr x26, =0x920000e1
	cmp x26, x30
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010dc
	ldr x1, =check_data1
	ldr x2, =0x000010dd
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	ldr x30, =0x30850030
	msr SCTLR_EL3, x30
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01e // cvtp c30, x0
	.inst 0xc2df43de // scvalue c30, c30, x31
	.inst 0xc28b413e // msr DDC_EL3, c30
	ldr x30, =0x30850030
	msr SCTLR_EL3, x30
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
	.byte 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x0a, 0xc4, 0x48, 0x82, 0xd1, 0x0a, 0x42, 0xb8, 0xe0, 0x4e, 0x7f, 0x22, 0xdd, 0x10, 0x9a, 0x28
	.byte 0x3d, 0x7f, 0x9f, 0x88
.data
check_data3:
	.byte 0xfd, 0x59, 0xab, 0x9b, 0x20, 0x60, 0x51, 0x3a, 0x3d, 0x98, 0xd8, 0xc2, 0xb5, 0x7f, 0xe6, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1050
	/* C1 */
	.octa 0x40010004000000000000e001
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x400000002001c0050000000000001000
	/* C10 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000000100070000000000000fe0
	/* C23 */
	.octa 0x80100000000100050000000000001000
	/* C25 */
	.octa 0x400000005004d008ff80000000000301
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40
	/* C1 */
	.octa 0x40010004000000000000e001
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C17 */
	.octa 0x40
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000000100070000000000000fe0
	/* C23 */
	.octa 0x80100000000100050000000000001000
	/* C25 */
	.octa 0x400000005004d008ff80000000000301
	/* C29 */
	.octa 0x400100040000000000000000
initial_DDC_EL0_value:
	.octa 0x400000003f83000700ffe00024020023
initial_DDC_EL1_value:
	.octa 0xc0000000200710070000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700010000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x00000000000010d0
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
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x020003de // add c30, c30, #0
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x020203de // add c30, c30, #128
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x020403de // add c30, c30, #256
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x020603de // add c30, c30, #384
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x020803de // add c30, c30, #512
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x020a03de // add c30, c30, #640
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x020c03de // add c30, c30, #768
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x020e03de // add c30, c30, #896
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x021003de // add c30, c30, #1024
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x021203de // add c30, c30, #1152
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x021403de // add c30, c30, #1280
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x021603de // add c30, c30, #1408
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x021803de // add c30, c30, #1536
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x021a03de // add c30, c30, #1664
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x021c03de // add c30, c30, #1792
	.inst 0xc2c213c0 // br c30
	.balign 128
	ldr x30, =esr_el1_dump_address
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x82600f5e // ldr x30, [c26, #0]
	cbnz x30, #28
	mrs x30, ESR_EL1
	.inst 0x82400f5e // str x30, [c26, #0]
	ldr x30, =0x40400414
	mrs x26, ELR_EL1
	sub x30, x30, x26
	cbnz x30, #8
	smc 0
	ldr x30, =initial_VBAR_EL1_value
	.inst 0xc2c5b3da // cvtp c26, x30
	.inst 0xc2de435a // scvalue c26, c26, x30
	.inst 0x8260035e // ldr c30, [c26, #0]
	.inst 0x021e03de // add c30, c30, #1920
	.inst 0xc2c213c0 // br c30

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
