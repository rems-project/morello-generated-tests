.section text0, #alloc, #execinstr
test_start:
	.inst 0x42e8e000 // LDP-C.RIB-C Ct:0 Rn:0 Ct2:11000 imm7:1010001 L:1 010000101:010000101
	.inst 0xa26181de // SWPL-CC.R-C Ct:30 Rn:14 100000:100000 Cs:1 1:1 R:1 A:0 10100010:10100010
	.inst 0x78fd229f // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:20 00:00 opc:010 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x225ffc48 // LDAXR-C.R-C Ct:8 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x787fbbe1 // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:31 10:10 S:1 option:101 Rm:31 1:1 opc:01 111000:111000 size:01
	.zero 1004
	.inst 0xe257d89f // ALDURSH-R.RI-64 Rt:31 Rn:4 op2:10 imm9:101111101 V:0 op1:01 11100010:11100010
	.inst 0x38293146 // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:6 Rn:10 00:00 opc:011 0:0 Rs:9 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xc2c1d0be // CPY-C.C-C Cd:30 Cn:5 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x427f7f1f // ALDARB-R.R-B Rt:31 Rn:24 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
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
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2400de4 // ldr c4, [x15, #3]
	.inst 0xc24011e9 // ldr c9, [x15, #4]
	.inst 0xc24015ea // ldr c10, [x15, #5]
	.inst 0xc24019ee // ldr c14, [x15, #6]
	.inst 0xc2401df4 // ldr c20, [x15, #7]
	.inst 0xc24021fd // ldr c29, [x15, #8]
	/* Set up flags and system registers */
	ldr x15, =0x4000000
	msr SPSR_EL3, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =initial_DDC_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c412f // msr DDC_EL1, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260106f // ldr c15, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
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
	.inst 0xc24001e3 // ldr c3, [x15, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005e3 // ldr c3, [x15, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24009e3 // ldr c3, [x15, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400de3 // ldr c3, [x15, #3]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc24011e3 // ldr c3, [x15, #4]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc24015e3 // ldr c3, [x15, #5]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc24019e3 // ldr c3, [x15, #6]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2401de3 // ldr c3, [x15, #7]
	.inst 0xc2c3a541 // chkeq c10, c3
	b.ne comparison_fail
	.inst 0xc24021e3 // ldr c3, [x15, #8]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc24025e3 // ldr c3, [x15, #9]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc24029e3 // ldr c3, [x15, #10]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc2402de3 // ldr c3, [x15, #11]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	ldr x15, =esr_el1_dump_address
	ldr x15, [x15]
	ldr x3, =0x2000000
	cmp x3, x15
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
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x00001019
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001110
	ldr x1, =check_data2
	ldr x2, =0x00001130
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000177e
	ldr x1, =check_data3
	ldr x2, =0x00001780
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000019e0
	ldr x1, =check_data4
	ldr x2, =0x000019f0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 272
	.byte 0x09, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3792
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x21, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
	.byte 0x09, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x00, 0xe0, 0xe8, 0x42, 0xde, 0x81, 0x61, 0xa2, 0x9f, 0x22, 0xfd, 0x78, 0x48, 0xfc, 0x5f, 0x22
	.byte 0xe1, 0xbb, 0x7f, 0x78
.data
check_data6:
	.byte 0x9f, 0xd8, 0x57, 0xe2, 0x46, 0x31, 0x29, 0x38, 0xbe, 0xd0, 0xc1, 0xc2, 0x1f, 0x7f, 0x7f, 0x42
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90100000000500070000000000001400
	/* C1 */
	.octa 0x21000008000000000000000000
	/* C2 */
	.octa 0x801000000002000000000000000019e0
	/* C4 */
	.octa 0x1801
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0xc0000000000100050000000000001018
	/* C14 */
	.octa 0xcc000000000700070000000000001000
	/* C20 */
	.octa 0xc0000000000300070000000000001008
	/* C29 */
	.octa 0x1800
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x21000008000000000000000000
	/* C2 */
	.octa 0x801000000002000000000000000019e0
	/* C4 */
	.octa 0x1801
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0xc0000000000100050000000000001018
	/* C14 */
	.octa 0xcc000000000700070000000000001000
	/* C20 */
	.octa 0xc0000000000300070000000000001008
	/* C24 */
	.octa 0x1009
	/* C29 */
	.octa 0x1800
initial_DDC_EL1_value:
	.octa 0x800000001007020f00ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080005000d6050000000040400001
final_PCC_value:
	.octa 0x200080005000d6050000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000086f1070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001110
	.dword 0x00000000000019e0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001110
	.dword 0x00000000000019e0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001120
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
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400414
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
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
