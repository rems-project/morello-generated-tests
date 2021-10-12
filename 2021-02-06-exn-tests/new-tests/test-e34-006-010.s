.section text0, #alloc, #execinstr
test_start:
	.inst 0x387f715f // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:10 00:00 opc:111 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x427fffde // ALDAR-R.R-32 Rt:30 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x881dfca5 // stlxr:aarch64/instrs/memory/exclusive/single Rt:5 Rn:5 Rt2:11111 o0:1 Rs:29 0:0 L:0 0010000:0010000 size:10
	.inst 0xc2c21381 // CHKSLD-C-C 00001:00001 Cn:28 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xa2a1801e // SWPA-CC.R-C Ct:30 Rn:0 100000:100000 Cs:1 1:1 R:0 A:1 10100010:10100010
	.zero 54252
	.inst 0xb86d02b2 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:21 00:00 opc:000 0:0 Rs:13 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x1ac4081b // udiv:aarch64/instrs/integer/arithmetic/div Rd:27 Rn:0 o1:0 00001:00001 Rm:4 0011010110:0011010110 sf:0
	.inst 0x9adf283e // asrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:1 op2:10 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0x788a4423 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:3 Rn:1 01:01 imm9:010100100 0:0 opc:10 111000:111000 size:01
	.inst 0xd4000001
	.zero 11244
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e4 // ldr c4, [x7, #2]
	.inst 0xc2400ce5 // ldr c5, [x7, #3]
	.inst 0xc24010ea // ldr c10, [x7, #4]
	.inst 0xc24014ed // ldr c13, [x7, #5]
	.inst 0xc24018f5 // ldr c21, [x7, #6]
	.inst 0xc2401cfc // ldr c28, [x7, #7]
	.inst 0xc24020fe // ldr c30, [x7, #8]
	/* Set up flags and system registers */
	ldr x7, =0x4000000
	msr SPSR_EL3, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30d5d99f
	msr SCTLR_EL1, x7
	ldr x7, =0xc0000
	msr CPACR_EL1, x7
	ldr x7, =0x4
	msr S3_0_C1_C2_2, x7 // CCTLR_EL1
	ldr x7, =0x0
	msr S3_3_C1_C2_2, x7 // CCTLR_EL0
	ldr x7, =initial_DDC_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884127 // msr DDC_EL0, c7
	ldr x7, =initial_DDC_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc28c4127 // msr DDC_EL1, c7
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601127 // ldr c7, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e4027 // msr CELR_EL3, c7
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x9, #0xf
	and x7, x7, x9
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000e9 // ldr c9, [x7, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24004e9 // ldr c9, [x7, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24008e9 // ldr c9, [x7, #2]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2400ce9 // ldr c9, [x7, #3]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc24010e9 // ldr c9, [x7, #4]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc24014e9 // ldr c9, [x7, #5]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc24018e9 // ldr c9, [x7, #6]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc2401ce9 // ldr c9, [x7, #7]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc24020e9 // ldr c9, [x7, #8]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc24024e9 // ldr c9, [x7, #9]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc24028e9 // ldr c9, [x7, #10]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402ce9 // ldr c9, [x7, #11]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc24030e9 // ldr c9, [x7, #12]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	ldr x7, =esr_el1_dump_address
	ldr x7, [x7]
	mov x9, 0x80
	orr x7, x7, x9
	ldr x9, =0x920000a1
	cmp x9, x7
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
	ldr x0, =0x00001178
	ldr x1, =check_data1
	ldr x2, =0x0000117c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001204
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f00
	ldr x1, =check_data3
	ldr x2, =0x00001f02
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040d400
	ldr x1, =check_data5
	ldr x2, =0x4040d414
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
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
	.zero 2
.data
check_data4:
	.byte 0x5f, 0x71, 0x7f, 0x38, 0xde, 0xff, 0x7f, 0x42, 0xa5, 0xfc, 0x1d, 0x88, 0x81, 0x13, 0xc2, 0xc2
	.byte 0x1e, 0x80, 0xa1, 0xa2
.data
check_data5:
	.byte 0xb2, 0x02, 0x6d, 0xb8, 0x1b, 0x08, 0xc4, 0x1a, 0x3e, 0x28, 0xdf, 0x9a, 0x23, 0x44, 0x8a, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc800000040120002ff81000000000002
	/* C1 */
	.octa 0x4000000000000000000000001d00
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000580108020000000000001000
	/* C10 */
	.octa 0xc0000000400000080000000000001000
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0x1000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x1178
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc800000040120002ff81000000000002
	/* C1 */
	.octa 0x1da4
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000580108020000000000001000
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
	.octa 0x1d00
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0xc00000000f87020700ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080006000a41d000000004040d000
final_PCC_value:
	.octa 0x200080006000a41d000000004040d414
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
	.dword 0x0000000000001200
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
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600d27 // ldr x7, [c9, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d27 // str x7, [c9, #0]
	ldr x7, =0x4040d414
	mrs x9, ELR_EL1
	sub x7, x7, x9
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e9 // cvtp c9, x7
	.inst 0xc2c74129 // scvalue c9, c9, x7
	.inst 0x82600127 // ldr c7, [c9, #0]
	.inst 0x021e00e7 // add c7, c7, #1920
	.inst 0xc2c210e0 // br c7

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
