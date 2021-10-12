.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2f1b3c9 // EORFLGS-C.CI-C Cd:9 Cn:30 0:0 10:10 imm8:10001101 11000010111:11000010111
	.inst 0x787ee89e // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:4 10:10 S:0 option:111 Rm:30 1:1 opc:01 111000:111000 size:01
	.inst 0xb8159d9e // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:12 11:11 imm9:101011001 0:0 opc:00 111000:111000 size:10
	.inst 0xc2dd03ec // SCBNDS-C.CR-C Cd:12 Cn:31 000:000 opc:00 0:0 Rm:29 11000010110:11000010110
	.inst 0x380d7f86 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:6 Rn:28 11:11 imm9:011010111 0:0 opc:00 111000:111000 size:00
	.zero 3052
	.inst 0xb83741bf // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:13 00:00 opc:100 o3:0 Rs:23 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2c511be // CVTD-R.C-C Rd:30 Cn:13 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x786163ff // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xb5b88d9d // cbnz:aarch64/instrs/branch/conditional/compare Rt:29 imm19:1011100010001101100 op:1 011010:011010 sf:1
	.inst 0xd4000001
	.zero 62444
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
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e4 // ldr c4, [x15, #1]
	.inst 0xc24009ec // ldr c12, [x15, #2]
	.inst 0xc2400ded // ldr c13, [x15, #3]
	.inst 0xc24011f7 // ldr c23, [x15, #4]
	.inst 0xc24015fc // ldr c28, [x15, #5]
	.inst 0xc24019fd // ldr c29, [x15, #6]
	.inst 0xc2401dfe // ldr c30, [x15, #7]
	/* Set up flags and system registers */
	ldr x15, =0x0
	msr SPSR_EL3, x15
	ldr x15, =initial_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288410f // msr CSP_EL0, c15
	ldr x15, =initial_SP_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c410f // msr CSP_EL1, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x4
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
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260128f // ldr c15, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
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
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x20, #0xf
	and x15, x15, x20
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f4 // ldr c20, [x15, #0]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24005f4 // ldr c20, [x15, #1]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc24009f4 // ldr c20, [x15, #2]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2400df4 // ldr c20, [x15, #3]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc24011f4 // ldr c20, [x15, #4]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc24015f4 // ldr c20, [x15, #5]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc24019f4 // ldr c20, [x15, #6]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2401df4 // ldr c20, [x15, #7]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc24021f4 // ldr c20, [x15, #8]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984114 // mrs c20, CSP_EL0
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	ldr x15, =final_SP_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc29c4114 // mrs c20, CSP_EL1
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	ldr x15, =esr_el1_dump_address
	ldr x15, [x15]
	mov x20, 0x80
	orr x15, x15, x20
	ldr x20, =0x920000ea
	cmp x20, x15
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
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001006
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000015e4
	ldr x1, =check_data2
	ldr x2, =0x000015e8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000161c
	ldr x1, =check_data3
	ldr x2, =0x00001620
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
	ldr x0, =0x40400c00
	ldr x1, =check_data5
	ldr x2, =0x40400c14
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1488
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2576
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x01, 0x00
.data
check_data2:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xc9, 0xb3, 0xf1, 0xc2, 0x9e, 0xe8, 0x7e, 0x78, 0x9e, 0x9d, 0x15, 0xb8, 0xec, 0x03, 0xdd, 0xc2
	.byte 0x86, 0x7f, 0x0d, 0x38
.data
check_data5:
	.byte 0xbf, 0x41, 0x37, 0xb8, 0xbe, 0x11, 0xc5, 0xc2, 0xff, 0x63, 0x61, 0x78, 0x9d, 0x8d, 0xb8, 0xb5
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x7e0
	/* C12 */
	.octa 0x16c3
	/* C13 */
	.octa 0x15e0
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0xc000000000000f28
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x100000000000000000000000820
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x7e0
	/* C9 */
	.octa 0x100000000008d00000000000820
	/* C12 */
	.octa 0xc00000000000000000000000
	/* C13 */
	.octa 0x15e0
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0xc000000000000f28
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x800100050000000000000000
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc0000000200708060000000000000000
initial_DDC_EL1_value:
	.octa 0xc00000005de0000400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x20008000500004110000000040400800
final_SP_EL0_value:
	.octa 0x800100050000000000000000
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x20008000500004110000000040400c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500100000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000015e0
	.dword 0x0000000000001610
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
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400c14
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
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
