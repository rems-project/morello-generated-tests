.section text0, #alloc, #execinstr
test_start:
	.inst 0xb86a73bf // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:111 o3:0 Rs:10 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x513ac3a0 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:29 imm12:111010110000 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xf86b63bf // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:110 o3:0 Rs:11 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x827e8e7d // ALDR-R.RI-64 Rt:29 Rn:19 op:11 imm9:111101000 L:1 1000001001:1000001001
	.inst 0xc2df8b9d // CHKSSU-C.CC-C Cd:29 Cn:28 0010:0010 opc:10 Cm:31 11000010110:11000010110
	.inst 0x385aa3de // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:30 00:00 imm9:110101010 0:0 opc:01 111000:111000 size:00
	.inst 0xc2dd6701 // CPYVALUE-C.C-C Cd:1 Cn:24 001:001 opc:11 0:0 Cm:29 11000010110:11000010110
	.inst 0xe252224a // ASTURH-R.RI-32 Rt:10 Rn:18 op2:00 imm9:100100010 V:0 op1:01 11100010:11100010
	.inst 0x62fec3a0 // LDP-C.RIBW-C Ct:0 Rn:29 Ct2:10000 imm7:1111101 L:1 011000101:011000101
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
	.inst 0xc240004a // ldr c10, [x2, #0]
	.inst 0xc240044b // ldr c11, [x2, #1]
	.inst 0xc2400852 // ldr c18, [x2, #2]
	.inst 0xc2400c53 // ldr c19, [x2, #3]
	.inst 0xc2401058 // ldr c24, [x2, #4]
	.inst 0xc240145c // ldr c28, [x2, #5]
	.inst 0xc240185d // ldr c29, [x2, #6]
	.inst 0xc2401c5e // ldr c30, [x2, #7]
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
	ldr x2, =0x4
	msr S3_3_C1_C2_2, x2 // CCTLR_EL0
	ldr x2, =initial_DDC_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884122 // msr DDC_EL0, c2
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601342 // ldr c2, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
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
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x26, #0xf
	and x2, x2, x26
	cmp x2, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc240005a // ldr c26, [x2, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240045a // ldr c26, [x2, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240085a // ldr c26, [x2, #2]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc2400c5a // ldr c26, [x2, #3]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc240105a // ldr c26, [x2, #4]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc240145a // ldr c26, [x2, #5]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc240185a // ldr c26, [x2, #6]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc2401c5a // ldr c26, [x2, #7]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc240205a // ldr c26, [x2, #8]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc240245a // ldr c26, [x2, #9]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240285a // ldr c26, [x2, #10]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc298411a // mrs c26, CSP_EL0
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001820
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fab
	ldr x1, =check_data2
	ldr x2, =0x00001fac
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40402f50
	ldr x1, =check_data4
	ldr x2, =0x40402f58
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
	.byte 0x02, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xbf, 0x73, 0x6a, 0xb8, 0xa0, 0xc3, 0x3a, 0x51, 0xbf, 0x63, 0x6b, 0xf8, 0x7d, 0x8e, 0x7e, 0x82
	.byte 0x9d, 0x8b, 0xdf, 0xc2, 0xde, 0xa3, 0x5a, 0x38, 0x01, 0x67, 0xdd, 0xc2, 0x4a, 0x22, 0x52, 0xe2
	.byte 0xa0, 0xc3, 0xfe, 0x62, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C10 */
	.octa 0x1
	/* C11 */
	.octa 0x0
	/* C18 */
	.octa 0x40000000000e001700000000000010e0
	/* C19 */
	.octa 0x80000000000720070000000040402010
	/* C24 */
	.octa 0xc001000100ffffffffffe001
	/* C28 */
	.octa 0x182f
	/* C29 */
	.octa 0xfff
	/* C30 */
	.octa 0x2000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc0010001000000000000182f
	/* C10 */
	.octa 0x1
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x40000000000e001700000000000010e0
	/* C19 */
	.octa 0x80000000000720070000000040402010
	/* C24 */
	.octa 0xc001000100ffffffffffe001
	/* C28 */
	.octa 0x182f
	/* C29 */
	.octa 0x17ff
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x810000100000000000000001
initial_DDC_EL0_value:
	.octa 0xc0100000400000010000000000006001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x810000100000000000000001
final_PCC_value:
	.octa 0x20008000000000000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001800
	.dword 0x0000000000001810
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
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x40400028
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
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
