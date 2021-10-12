.section text0, #alloc, #execinstr
test_start:
	.inst 0xb861ebff // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:31 Rn:31 10:10 S:0 option:111 Rm:1 1:1 opc:01 111000:111000 size:10
	.inst 0x9b3c827f // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:19 Ra:0 o0:1 Rm:28 01:01 U:0 10011011:10011011
	.inst 0x421ffedf // STLR-C.R-C Ct:31 Rn:22 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2df400c // SCVALUE-C.CR-C Cd:12 Cn:0 000:000 opc:10 0:0 Rm:31 11000010110:11000010110
	.inst 0xe2253a48 // ASTUR-V.RI-Q Rt:8 Rn:18 op2:10 imm9:001010011 V:1 op1:00 11100010:11100010
	.zero 1004
	.inst 0xc2c6b006 // CLRPERM-C.CI-C Cd:6 Cn:0 100:100 perm:101 1100001011000110:1100001011000110
	.inst 0x02a56fdb // SUB-C.CIS-C Cd:27 Cn:30 imm12:100101011011 sh:0 A:1 00000010:00000010
	.inst 0x089fffbf // stlrb:aarch64/instrs/memory/ordered Rt:31 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x516e54be // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:5 imm12:101110010101 sh:1 0:0 10001:10001 S:0 op:1 sf:0
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009f2 // ldr c18, [x15, #2]
	.inst 0xc2400df6 // ldr c22, [x15, #3]
	.inst 0xc24011fd // ldr c29, [x15, #4]
	.inst 0xc24015fe // ldr c30, [x15, #5]
	/* Set up flags and system registers */
	ldr x15, =0x4000000
	msr SPSR_EL3, x15
	ldr x15, =initial_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288410f // msr CSP_EL0, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0x3c0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x0
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =initial_DDC_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c412f // msr DDC_EL1, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260108f // ldr c15, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc28e402f // msr CELR_EL3, c15
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e4 // ldr c4, [x15, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24005e4 // ldr c4, [x15, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc24009e4 // ldr c4, [x15, #2]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2400de4 // ldr c4, [x15, #3]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc24011e4 // ldr c4, [x15, #4]
	.inst 0xc2c4a641 // chkeq c18, c4
	b.ne comparison_fail
	.inst 0xc24015e4 // ldr c4, [x15, #5]
	.inst 0xc2c4a6c1 // chkeq c22, c4
	b.ne comparison_fail
	.inst 0xc24019e4 // ldr c4, [x15, #6]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2401de4 // ldr c4, [x15, #7]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984104 // mrs c4, CSP_EL0
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	ldr x15, =esr_el1_dump_address
	ldr x15, [x15]
	mov x4, 0x80
	orr x15, x15, x4
	ldr x4, =0x920000eb
	cmp x4, x15
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
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400400
	ldr x1, =check_data2
	ldr x2, =0x40400414
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
	.zero 16
.data
check_data1:
	.byte 0xff, 0xeb, 0x61, 0xb8, 0x7f, 0x82, 0x3c, 0x9b, 0xdf, 0xfe, 0x1f, 0x42, 0x0c, 0x40, 0xdf, 0xc2
	.byte 0x48, 0x3a, 0x25, 0xe2
.data
check_data2:
	.byte 0x06, 0xb0, 0xc6, 0xc2, 0xdb, 0x6f, 0xa5, 0x02, 0xbf, 0xff, 0x9f, 0x08, 0xbe, 0x54, 0x6e, 0x51
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400360020080000062034000
	/* C1 */
	.octa 0xfbfffffff0beef00
	/* C18 */
	.octa 0x7fffffffffffad
	/* C22 */
	.octa 0x400000005401042c0000000000001000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x40007a0070000000000400000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400360020080000062034000
	/* C1 */
	.octa 0xfbfffffff0beef00
	/* C6 */
	.octa 0x400360020080000062034000
	/* C12 */
	.octa 0x400360020000000000000000
	/* C18 */
	.octa 0x7fffffffffffad
	/* C22 */
	.octa 0x400000005401042c0000000000001000
	/* C27 */
	.octa 0x40007a00700000000003ff6a5
	/* C29 */
	.octa 0x1000
initial_SP_EL0_value:
	.octa 0x8000000004030006040000000f412100
initial_DDC_EL0_value:
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0x400000000207030f00ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x20008000500000290000000040400000
final_SP_EL0_value:
	.octa 0x8000000004030006040000000f412100
final_PCC_value:
	.octa 0x20008000500000290000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100180050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x82600c8f // ldr x15, [c4, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c8f // str x15, [c4, #0]
	ldr x15, =0x40400414
	mrs x4, ELR_EL1
	sub x15, x15, x4
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e4 // cvtp c4, x15
	.inst 0xc2cf4084 // scvalue c4, c4, x15
	.inst 0x8260008f // ldr c15, [c4, #0]
	.inst 0x021e01ef // add c15, c15, #1920
	.inst 0xc2c211e0 // br c15

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
