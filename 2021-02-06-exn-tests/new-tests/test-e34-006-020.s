.section text0, #alloc, #execinstr
test_start:
	.inst 0x387f715f // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:10 00:00 opc:111 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x427fffde // ALDAR-R.R-32 Rt:30 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x881dfca5 // stlxr:aarch64/instrs/memory/exclusive/single Rt:5 Rn:5 Rt2:11111 o0:1 Rs:29 0:0 L:0 0010000:0010000 size:10
	.inst 0xc2c21381 // CHKSLD-C-C 00001:00001 Cn:28 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xa2a1801e // SWPA-CC.R-C Ct:30 Rn:0 100000:100000 Cs:1 1:1 R:0 A:1 10100010:10100010
	.zero 62444
	.inst 0xb86d02b2 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:21 00:00 opc:000 0:0 Rs:13 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x1ac4081b // udiv:aarch64/instrs/integer/arithmetic/div Rd:27 Rn:0 o1:0 00001:00001 Rm:4 0011010110:0011010110 sf:0
	.inst 0x9adf283e // asrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:1 op2:10 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0x788a4423 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:3 Rn:1 01:01 imm9:010100100 0:0 opc:10 111000:111000 size:01
	.inst 0xd4000001
	.zero 3052
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a04 // ldr c4, [x16, #2]
	.inst 0xc2400e05 // ldr c5, [x16, #3]
	.inst 0xc240120a // ldr c10, [x16, #4]
	.inst 0xc240160d // ldr c13, [x16, #5]
	.inst 0xc2401a15 // ldr c21, [x16, #6]
	.inst 0xc2401e1c // ldr c28, [x16, #7]
	.inst 0xc240221e // ldr c30, [x16, #8]
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x4
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =initial_DDC_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4130 // msr DDC_EL1, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82601050 // ldr c16, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x2, #0xf
	and x16, x16, x2
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400202 // ldr c2, [x16, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	.inst 0xc2400e02 // ldr c2, [x16, #3]
	.inst 0xc2c2a481 // chkeq c4, c2
	b.ne comparison_fail
	.inst 0xc2401202 // ldr c2, [x16, #4]
	.inst 0xc2c2a4a1 // chkeq c5, c2
	b.ne comparison_fail
	.inst 0xc2401602 // ldr c2, [x16, #5]
	.inst 0xc2c2a541 // chkeq c10, c2
	b.ne comparison_fail
	.inst 0xc2401a02 // ldr c2, [x16, #6]
	.inst 0xc2c2a5a1 // chkeq c13, c2
	b.ne comparison_fail
	.inst 0xc2401e02 // ldr c2, [x16, #7]
	.inst 0xc2c2a641 // chkeq c18, c2
	b.ne comparison_fail
	.inst 0xc2402202 // ldr c2, [x16, #8]
	.inst 0xc2c2a6a1 // chkeq c21, c2
	b.ne comparison_fail
	.inst 0xc2402602 // ldr c2, [x16, #9]
	.inst 0xc2c2a761 // chkeq c27, c2
	b.ne comparison_fail
	.inst 0xc2402a02 // ldr c2, [x16, #10]
	.inst 0xc2c2a781 // chkeq c28, c2
	b.ne comparison_fail
	.inst 0xc2402e02 // ldr c2, [x16, #11]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc2403202 // ldr c2, [x16, #12]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x2, 0x80
	orr x16, x16, x2
	ldr x2, =0x920000a1
	cmp x2, x16
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
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013f8
	ldr x1, =check_data2
	ldr x2, =0x000013fc
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
	ldr x0, =0x4040f400
	ldr x1, =check_data4
	ldr x2, =0x4040f414
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
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x5f, 0x71, 0x7f, 0x38, 0xde, 0xff, 0x7f, 0x42, 0xa5, 0xfc, 0x1d, 0x88, 0x81, 0x13, 0xc2, 0xc2
	.byte 0x1e, 0x80, 0xa1, 0xa2
.data
check_data4:
	.byte 0xb2, 0x02, 0x6d, 0xb8, 0x1b, 0x08, 0xc4, 0x1a, 0x3e, 0x28, 0xdf, 0x9a, 0x23, 0x44, 0x8a, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xcc000000500000010073bbc5cea30002
	/* C1 */
	.octa 0x1000
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000000100050000000000001008
	/* C10 */
	.octa 0xc0000000400000080000000000001000
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0x1000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x13f8
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xcc000000500000010073bbc5cea30002
	/* C1 */
	.octa 0x10a4
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000000100050000000000001008
	/* C10 */
	.octa 0xc0000000400000080000000000001000
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x1000
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000510a00000000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000e41d000000004040f000
final_PCC_value:
	.octa 0x200080005000e41d000000004040f414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x4040f414
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
