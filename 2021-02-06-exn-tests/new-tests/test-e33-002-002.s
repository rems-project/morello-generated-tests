.section text0, #alloc, #execinstr
test_start:
	.inst 0x82480bc4 // ASTR-R.RI-32 Rt:4 Rn:30 op:10 imm9:010000000 L:0 1000001001:1000001001
	.inst 0x3855101f // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:0 00:00 imm9:101010001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2dec2c2 // CVT-R.CC-C Rd:2 Cn:22 110000:110000 Cm:30 11000010110:11000010110
	.inst 0x786320df // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:010 o3:0 Rs:3 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x387d53c1 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:30 00:00 opc:101 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:00
	.zero 33772
	.inst 0x38747201 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:16 00:00 opc:111 0:0 Rs:20 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x78424810 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:16 Rn:0 10:10 imm9:000100100 0:0 opc:01 111000:111000 size:01
	.inst 0x9a9e87fe // csinc:aarch64/instrs/integer/conditional/select Rd:30 Rn:31 o2:1 0:0 cond:1000 Rm:30 011010100:011010100 op:0 sf:1
	.inst 0xc24b5c8c // LDR-C.RIB-C Ct:12 Rn:4 imm12:001011010111 L:1 110000100:110000100
	.inst 0xd4000001
	.zero 31724
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a3 // ldr c3, [x13, #1]
	.inst 0xc24009a4 // ldr c4, [x13, #2]
	.inst 0xc2400da6 // ldr c6, [x13, #3]
	.inst 0xc24011b0 // ldr c16, [x13, #4]
	.inst 0xc24015b4 // ldr c20, [x13, #5]
	.inst 0xc24019b6 // ldr c22, [x13, #6]
	.inst 0xc2401dbe // ldr c30, [x13, #7]
	/* Set up flags and system registers */
	ldr x13, =0x4000000
	msr SPSR_EL3, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0xc0000
	msr CPACR_EL1, x13
	ldr x13, =0x0
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =0x4
	msr S3_3_C1_C2_2, x13 // CCTLR_EL0
	ldr x13, =initial_DDC_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc288412d // msr DDC_EL0, c13
	ldr x13, =initial_DDC_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c412d // msr DDC_EL1, c13
	ldr x13, =0x80000000
	msr HCR_EL2, x13
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260114d // ldr c13, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e402d // msr CELR_EL3, c13
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x10, #0xf
	and x13, x13, x10
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001aa // ldr c10, [x13, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24005aa // ldr c10, [x13, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24009aa // ldr c10, [x13, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400daa // ldr c10, [x13, #3]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc24011aa // ldr c10, [x13, #4]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc24015aa // ldr c10, [x13, #5]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc24019aa // ldr c10, [x13, #6]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc2401daa // ldr c10, [x13, #7]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc24021aa // ldr c10, [x13, #8]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc24025aa // ldr c10, [x13, #9]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc24029aa // ldr c10, [x13, #10]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	ldr x13, =esr_el1_dump_address
	ldr x13, [x13]
	mov x10, 0x80
	orr x13, x13, x10
	ldr x10, =0x920000a9
	cmp x10, x13
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
	ldr x0, =0x00001048
	ldr x1, =check_data1
	ldr x2, =0x00001049
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011f0
	ldr x1, =check_data2
	ldr x2, =0x00001200
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001759
	ldr x1, =check_data3
	ldr x2, =0x0000175a
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001802
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0000182c
	ldr x1, =check_data5
	ldr x2, =0x0000182e
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40408400
	ldr x1, =check_data7
	ldr x2, =0x40408414
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
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
	.zero 64
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4016
.data
check_data0:
	.byte 0x80, 0xe4, 0xff, 0xff
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xc4, 0x0b, 0x48, 0x82, 0x1f, 0x10, 0x55, 0x38, 0xc2, 0xc2, 0xde, 0xc2, 0xdf, 0x20, 0x63, 0x78
	.byte 0xc1, 0x53, 0x7d, 0x38
.data
check_data7:
	.byte 0x01, 0x72, 0x74, 0x38, 0x10, 0x48, 0x42, 0x78, 0xfe, 0x87, 0x9e, 0x9a, 0x8c, 0x5c, 0x4b, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000700070000000000001808
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0xffffffffffffe480
	/* C6 */
	.octa 0xc0000000000700070000000000001800
	/* C16 */
	.octa 0x1048
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x4000014007fffffffffffffe00
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000700070000000000001808
	/* C1 */
	.octa 0x9
	/* C2 */
	.octa 0xc000000000000000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0xffffffffffffe480
	/* C6 */
	.octa 0xc0000000000700070000000000001800
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x40000000008700820000000000000001
initial_DDC_EL1_value:
	.octa 0xd0100000400c010a00ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080006000801d0000000040408000
final_PCC_value:
	.octa 0x200080006000801d0000000040408414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000011f0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x00000000000011f0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001040
	.dword 0x0000000000001800
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
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x82600d4d // ldr x13, [c10, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d4d // str x13, [c10, #0]
	ldr x13, =0x40408414
	mrs x10, ELR_EL1
	sub x13, x13, x10
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1aa // cvtp c10, x13
	.inst 0xc2cd414a // scvalue c10, c10, x13
	.inst 0x8260014d // ldr c13, [c10, #0]
	.inst 0x021e01ad // add c13, c13, #1920
	.inst 0xc2c211a0 // br c13

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
