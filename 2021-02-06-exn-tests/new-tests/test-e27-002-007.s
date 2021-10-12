.section text0, #alloc, #execinstr
test_start:
	.inst 0x085f7fec // ldxrb:aarch64/instrs/memory/exclusive/single Rt:12 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x82a0441f // ASTR-R.RRB-64 Rt:31 Rn:0 opc:01 S:0 option:010 Rm:0 1:1 L:0 100000101:100000101
	.inst 0x35bf165f // cbnz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:1011111100010110010 op:1 011010:011010 sf:0
	.inst 0x78b261f2 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:15 00:00 opc:110 0:0 Rs:18 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xc8205839 // stxp:aarch64/instrs/memory/exclusive/pair Rt:25 Rn:1 Rt2:10110 o0:0 Rs:0 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0xc2c95900 // ALIGNU-C.CI-C Cd:0 Cn:8 0110:0110 U:1 imm6:010010 11000010110:11000010110
	.inst 0xdac0103d // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:29 Rn:1 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0x780f96dd // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:22 01:01 imm9:011111001 0:0 opc:00 111000:111000 size:01
	.inst 0x1ac00f01 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:24 o1:1 00001:00001 Rm:0 0011010110:0011010110 sf:0
	.inst 0xd4000001
	.zero 65496
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc2400848 // ldr c8, [x2, #2]
	.inst 0xc2400c4f // ldr c15, [x2, #3]
	.inst 0xc2401052 // ldr c18, [x2, #4]
	.inst 0xc2401456 // ldr c22, [x2, #5]
	/* Set up flags and system registers */
	ldr x2, =0x0
	msr SPSR_EL3, x2
	ldr x2, =initial_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884102 // msr CSP_EL0, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0xc0000
	msr CPACR_EL1, x2
	ldr x2, =0x0
	msr S3_0_C1_C2_2, x2 // CCTLR_EL1
	ldr x2, =0x0
	msr S3_3_C1_C2_2, x2 // CCTLR_EL0
	ldr x2, =initial_DDC_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884122 // msr DDC_EL0, c2
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601082 // ldr c2, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc28e4022 // msr CELR_EL3, c2
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400044 // ldr c4, [x2, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400444 // ldr c4, [x2, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400844 // ldr c4, [x2, #2]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc2400c44 // ldr c4, [x2, #3]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc2401044 // ldr c4, [x2, #4]
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	.inst 0xc2401444 // ldr c4, [x2, #5]
	.inst 0xc2c4a641 // chkeq c18, c4
	b.ne comparison_fail
	.inst 0xc2401844 // ldr c4, [x2, #6]
	.inst 0xc2c4a6c1 // chkeq c22, c4
	b.ne comparison_fail
	.inst 0xc2401c44 // ldr c4, [x2, #7]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984104 // mrs c4, CSP_EL0
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a441 // chkeq c2, c4
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f0
	ldr x1, =check_data2
	ldr x2, =0x00001100
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d10
	ldr x1, =check_data3
	ldr x2, =0x00001d11
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f20
	ldr x1, =check_data4
	ldr x2, =0x00001f22
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400028
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
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x02, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x33, 0x00
.data
check_data5:
	.byte 0xec, 0x7f, 0x5f, 0x08, 0x1f, 0x44, 0xa0, 0x82, 0x5f, 0x16, 0xbf, 0x35, 0xf2, 0x61, 0xb2, 0x78
	.byte 0x39, 0x58, 0x20, 0xc8, 0x00, 0x59, 0xc9, 0xc2, 0x3d, 0x10, 0xc0, 0xda, 0xdd, 0x96, 0x0f, 0x78
	.byte 0x01, 0x0f, 0xc0, 0x1a, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000600070000000000000808
	/* C1 */
	.octa 0x10f0
	/* C8 */
	.octa 0x81200040060000000000000
	/* C15 */
	.octa 0x1000
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x1f20
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x81200040060000000000000
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0x81200040060000000000000
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C18 */
	.octa 0x2
	/* C22 */
	.octa 0x2019
	/* C29 */
	.octa 0x33
initial_SP_EL0_value:
	.octa 0x1d10
initial_DDC_EL0_value:
	.octa 0xc0000000600400020000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x1d10
final_PCC_value:
	.octa 0x20008000000700070000000040400028
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
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001f20
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
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600c82 // ldr x2, [c4, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400c82 // str x2, [c4, #0]
	ldr x2, =0x40400028
	mrs x4, ELR_EL1
	sub x2, x2, x4
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b044 // cvtp c4, x2
	.inst 0xc2c24084 // scvalue c4, c4, x2
	.inst 0x82600082 // ldr c2, [c4, #0]
	.inst 0x021e0042 // add c2, c2, #1920
	.inst 0xc2c21040 // br c2

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
