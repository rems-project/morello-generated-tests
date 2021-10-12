.section text0, #alloc, #execinstr
test_start:
	.inst 0xb80e31a6 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:6 Rn:13 00:00 imm9:011100011 0:0 opc:00 111000:111000 size:10
	.inst 0xc87fcd32 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:18 Rn:9 Rt2:10011 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xc2c253c2 // RETS-C-C 00010:00010 Cn:30 100:100 opc:10 11000010110000100:11000010110000100
	.zero 500
	.inst 0xd1548e07 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:7 Rn:16 imm12:010100100011 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xa2b17c24 // CAS-C.R-C Ct:4 Rn:1 11111:11111 R:0 Cs:17 1:1 L:0 1:1 10100010:10100010
	.zero 504
	.inst 0x3821727f // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:19 00:00 opc:111 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xb899ac1f // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:0 11:11 imm9:110011010 0:0 opc:10 111000:111000 size:10
	.inst 0xe25396a0 // ALDURH-R.RI-32 Rt:0 Rn:21 op2:01 imm9:100111001 V:0 op1:01 11100010:11100010
	.inst 0x786143bf // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:29 00:00 opc:100 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:01
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c4 // ldr c4, [x14, #2]
	.inst 0xc2400dc6 // ldr c6, [x14, #3]
	.inst 0xc24011c9 // ldr c9, [x14, #4]
	.inst 0xc24015cd // ldr c13, [x14, #5]
	.inst 0xc24019d5 // ldr c21, [x14, #6]
	.inst 0xc2401ddd // ldr c29, [x14, #7]
	.inst 0xc24021de // ldr c30, [x14, #8]
	/* Set up flags and system registers */
	ldr x14, =0x0
	msr SPSR_EL3, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0xc0000
	msr CPACR_EL1, x14
	ldr x14, =0x4
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x0
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =initial_DDC_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc28c412e // msr DDC_EL1, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260132e // ldr c14, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d9 // ldr c25, [x14, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24005d9 // ldr c25, [x14, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24009d9 // ldr c25, [x14, #2]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400dd9 // ldr c25, [x14, #3]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc24011d9 // ldr c25, [x14, #4]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc24015d9 // ldr c25, [x14, #5]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc24019d9 // ldr c25, [x14, #6]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2401dd9 // ldr c25, [x14, #7]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc24021d9 // ldr c25, [x14, #8]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc24025d9 // ldr c25, [x14, #9]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc24029d9 // ldr c25, [x14, #10]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	ldr x14, =esr_el1_dump_address
	ldr x14, [x14]
	mov x25, 0x80
	orr x14, x14, x25
	ldr x25, =0x920000a1
	cmp x25, x14
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
	ldr x0, =0x00001f9c
	ldr x1, =check_data1
	ldr x2, =0x00001fa0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x4040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x4040013a
	ldr x1, =check_data3
	ldr x2, =0x4040013c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400200
	ldr x1, =check_data4
	ldr x2, =0x40400208
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
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xa6, 0x31, 0x0e, 0xb8, 0x32, 0xcd, 0x7f, 0xc8, 0xc2, 0x53, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x07, 0x8e, 0x54, 0xd1, 0x24, 0x7c, 0xb1, 0xa2
.data
check_data5:
	.byte 0x7f, 0x72, 0x21, 0x38, 0x1f, 0xac, 0x99, 0xb8, 0xa0, 0x96, 0x53, 0xe2, 0xbf, 0x43, 0x61, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2002
	/* C1 */
	.octa 0xc0000000500400140000000000000104
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x1000
	/* C13 */
	.octa 0xf1d
	/* C21 */
	.octa 0x80000000000700070000000040400201
	/* C29 */
	.octa 0x1002
	/* C30 */
	.octa 0x20008000000080080000000040400201
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc0000000500400140000000000000104
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x1000
	/* C13 */
	.octa 0xf1d
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x1000
	/* C21 */
	.octa 0x80000000000700070000000040400201
	/* C29 */
	.octa 0x1002
	/* C30 */
	.octa 0x20008000000080080000000040400201
initial_DDC_EL0_value:
	.octa 0xc0000000000300070000000000000003
initial_DDC_EL1_value:
	.octa 0xc00000000003000700ffe00001e00000
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000081000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_DDC_EL0_value
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x82600f2e // ldr x14, [c25, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f2e // str x14, [c25, #0]
	ldr x14, =0x40400414
	mrs x25, ELR_EL1
	sub x14, x14, x25
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d9 // cvtp c25, x14
	.inst 0xc2ce4339 // scvalue c25, c25, x14
	.inst 0x8260032e // ldr c14, [c25, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0