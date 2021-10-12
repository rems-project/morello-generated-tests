.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8fd0021 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:1 00:00 opc:000 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x48fe7cfe // cash:aarch64/instrs/memory/atomicops/cas/single Rt:30 Rn:7 11111:11111 o0:0 Rs:30 1:1 L:1 0010001:0010001 size:01
	.inst 0x081fffe3 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:3 Rn:31 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0xb861033f // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:25 00:00 opc:000 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xe231dbe1 // ASTUR-V.RI-Q Rt:1 Rn:31 op2:10 imm9:100011101 V:1 op1:00 11100010:11100010
	.zero 1004
	.inst 0xc2c531fc // CVTP-R.C-C Rd:28 Cn:15 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2de2240 // SCBNDSE-C.CR-C Cd:0 Cn:18 000:000 opc:01 0:0 Rm:30 11000010110:11000010110
	.inst 0xd65f0000 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 11540
	.inst 0x901af1df // ADRDP-C.ID-C Rd:31 immhi:001101011110001110 P:0 10000:10000 immlo:00 op:1
	.inst 0xd4000001
	.zero 52952
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
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006e7 // ldr c7, [x23, #1]
	.inst 0xc2400aef // ldr c15, [x23, #2]
	.inst 0xc2400ef2 // ldr c18, [x23, #3]
	.inst 0xc24012f9 // ldr c25, [x23, #4]
	.inst 0xc24016fd // ldr c29, [x23, #5]
	.inst 0xc2401afe // ldr c30, [x23, #6]
	/* Set up flags and system registers */
	ldr x23, =0x4000000
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0x3c0000
	msr CPACR_EL1, x23
	ldr x23, =0x8
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x4
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012d7 // ldr c23, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	mov x22, #0xf
	and x23, x23, x22
	cmp x23, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f6 // ldr c22, [x23, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24006f6 // ldr c22, [x23, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400af6 // ldr c22, [x23, #2]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2400ef6 // ldr c22, [x23, #3]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc24012f6 // ldr c22, [x23, #4]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc24016f6 // ldr c22, [x23, #5]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2401af6 // ldr c22, [x23, #6]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2401ef6 // ldr c22, [x23, #7]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc24022f6 // ldr c22, [x23, #8]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984116 // mrs c22, CSP_EL0
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x22, 0x80
	orr x23, x23, x22
	ldr x22, =0x920000e9
	cmp x22, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001201
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001408
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
	ldr x2, =0x4040040c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40403120
	ldr x1, =check_data5
	ldr x2, =0x40403128
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
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00
.data
check_data3:
	.byte 0x21, 0x00, 0xfd, 0xf8, 0xfe, 0x7c, 0xfe, 0x48, 0xe3, 0xff, 0x1f, 0x08, 0x3f, 0x03, 0x61, 0xb8
	.byte 0xe1, 0xdb, 0x31, 0xe2
.data
check_data4:
	.byte 0xfc, 0x31, 0xc5, 0xc2, 0x40, 0x22, 0xde, 0xc2, 0x00, 0x00, 0x5f, 0xd6
.data
check_data5:
	.byte 0xdf, 0xf1, 0x1a, 0x90, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000000500070000000000001400
	/* C7 */
	.octa 0xc0000000120100070000000000001000
	/* C15 */
	.octa 0x40400120
	/* C18 */
	.octa 0x800100060000000000003000
	/* C25 */
	.octa 0xc0000000000600070000000000001000
	/* C29 */
	.octa 0x100000000000
	/* C30 */
	.octa 0xffff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xf00030000000000000003000
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0xc0000000120100070000000000001000
	/* C15 */
	.octa 0x40400120
	/* C18 */
	.octa 0x800100060000000000003000
	/* C25 */
	.octa 0xc0000000000600070000000000001000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x100000000000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x40000000088711ef0000000000001200
initial_DDC_EL0_value:
	.octa 0x440040004007fffffffffe000
initial_DDC_EL1_value:
	.octa 0x8001a0070000020028000000
initial_VBAR_EL1_value:
	.octa 0x20008000740001200000000040400001
final_SP_EL0_value:
	.octa 0x40000000088711ef0000000000001200
final_PCC_value:
	.octa 0x20008000740001200000000040403128
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000050c00160000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x82600ed7 // ldr x23, [c22, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400ed7 // str x23, [c22, #0]
	ldr x23, =0x40403128
	mrs x22, ELR_EL1
	sub x23, x23, x22
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f6 // cvtp c22, x23
	.inst 0xc2d742d6 // scvalue c22, c22, x23
	.inst 0x826002d7 // ldr c23, [c22, #0]
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
