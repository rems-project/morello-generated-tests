.section text0, #alloc, #execinstr
test_start:
	.inst 0x82480bc4 // ASTR-R.RI-32 Rt:4 Rn:30 op:10 imm9:010000000 L:0 1000001001:1000001001
	.inst 0x3855101f // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:0 00:00 imm9:101010001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2dec2c2 // CVT-R.CC-C Rd:2 Cn:22 110000:110000 Cm:30 11000010110:11000010110
	.inst 0x786320df // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:010 o3:0 Rs:3 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x387d53c1 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:30 00:00 opc:101 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:00
	.zero 1004
	.inst 0x38747201 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:16 00:00 opc:111 0:0 Rs:20 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x78424810 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:16 Rn:0 10:10 imm9:000100100 0:0 opc:01 111000:111000 size:01
	.inst 0x9a9e87fe // csinc:aarch64/instrs/integer/conditional/select Rd:30 Rn:31 o2:1 0:0 cond:1000 Rm:30 011010100:011010100 op:0 sf:1
	.inst 0xc24b5c8c // LDR-C.RIB-C Ct:12 Rn:4 imm12:001011010111 L:1 110000100:110000100
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a3 // ldr c3, [x5, #1]
	.inst 0xc24008a4 // ldr c4, [x5, #2]
	.inst 0xc2400ca6 // ldr c6, [x5, #3]
	.inst 0xc24010b0 // ldr c16, [x5, #4]
	.inst 0xc24014b4 // ldr c20, [x5, #5]
	.inst 0xc24018b6 // ldr c22, [x5, #6]
	.inst 0xc2401cbe // ldr c30, [x5, #7]
	/* Set up flags and system registers */
	ldr x5, =0x4000000
	msr SPSR_EL3, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0xc0000
	msr CPACR_EL1, x5
	ldr x5, =0x0
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x4
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =initial_DDC_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4125 // msr DDC_EL1, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011e5 // ldr c5, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x15, #0xf
	and x5, x5, x15
	cmp x5, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000af // ldr c15, [x5, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24004af // ldr c15, [x5, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24008af // ldr c15, [x5, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400caf // ldr c15, [x5, #3]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc24010af // ldr c15, [x5, #4]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc24014af // ldr c15, [x5, #5]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc24018af // ldr c15, [x5, #6]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc2401caf // ldr c15, [x5, #7]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc24020af // ldr c15, [x5, #8]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc24024af // ldr c15, [x5, #9]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc24028af // ldr c15, [x5, #10]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x15, 0x80
	orr x5, x5, x15
	ldr x15, =0x920000ab
	cmp x15, x5
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001084
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f29
	ldr x1, =check_data2
	ldr x2, =0x00001f2a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
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
	ldr x0, =0x4040ffe0
	ldr x1, =check_data6
	ldr x2, =0x4040fff0
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
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.zero 2
.data
check_data1:
	.byte 0x70, 0xd2, 0x40, 0x40
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xc4, 0x0b, 0x48, 0x82, 0x1f, 0x10, 0x55, 0x38, 0xc2, 0xc2, 0xde, 0xc2, 0xdf, 0x20, 0x63, 0x78
	.byte 0xc1, 0x53, 0x7d, 0x38
.data
check_data5:
	.byte 0x01, 0x72, 0x74, 0x38, 0x10, 0x48, 0x42, 0x78, 0xfe, 0x87, 0x9e, 0x9a, 0x8c, 0x5c, 0x4b, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 16

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001fd8
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x4040d270
	/* C6 */
	.octa 0xc0000000500400040000000000001000
	/* C16 */
	.octa 0x1000
	/* C20 */
	.octa 0x80
	/* C22 */
	.octa 0x1000
	/* C30 */
	.octa 0x4017fffffffffffffe80
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001fd8
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x4040d270
	/* C6 */
	.octa 0xc0000000500400040000000000001000
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x80
	/* C22 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x400000000006001700ffffffffe00001
initial_DDC_EL1_value:
	.octa 0xd0100000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400000
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
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
	.dword 0x0000000000001080
	.dword 0x000000004040ffe0
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
