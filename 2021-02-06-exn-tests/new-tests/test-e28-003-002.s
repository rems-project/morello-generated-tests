.section text0, #alloc, #execinstr
test_start:
	.inst 0x02263c1e // ADD-C.CIS-C Cd:30 Cn:0 imm12:100110001111 sh:0 A:0 00000010:00000010
	.inst 0x485ffce0 // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:0 Rn:7 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xc2dd407d // SCVALUE-C.CR-C Cd:29 Cn:3 000:000 opc:10 0:0 Rm:29 11000010110:11000010110
	.inst 0xc8f97e05 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:5 Rn:16 11111:11111 o0:0 Rs:25 1:1 L:1 0010001:0010001 size:11
	.inst 0x387deb1d // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:29 Rn:24 10:10 S:0 option:111 Rm:29 1:1 opc:01 111000:111000 size:00
	.zero 1004
	.inst 0xb833401f // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:100 o3:0 Rs:19 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xb86910ff // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:7 00:00 opc:001 o3:0 Rs:9 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x622c93bf // STNP-C.RIB-C Ct:31 Rn:29 Ct2:00100 imm7:1011001 L:0 011000100:011000100
	.inst 0xc2c0703e // GCOFF-R.C-C Rd:30 Cn:1 100:100 opc:011 1100001011000000:1100001011000000
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae3 // ldr c3, [x23, #2]
	.inst 0xc2400ee4 // ldr c4, [x23, #3]
	.inst 0xc24012e7 // ldr c7, [x23, #4]
	.inst 0xc24016e9 // ldr c9, [x23, #5]
	.inst 0xc2401af0 // ldr c16, [x23, #6]
	.inst 0xc2401ef3 // ldr c19, [x23, #7]
	.inst 0xc24022f8 // ldr c24, [x23, #8]
	.inst 0xc24026f9 // ldr c25, [x23, #9]
	.inst 0xc2402afd // ldr c29, [x23, #10]
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x4
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x0
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82601397 // ldr c23, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002fc // ldr c28, [x23, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24006fc // ldr c28, [x23, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400afc // ldr c28, [x23, #2]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc2400efc // ldr c28, [x23, #3]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc24012fc // ldr c28, [x23, #4]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc24016fc // ldr c28, [x23, #5]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc2401afc // ldr c28, [x23, #6]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc2401efc // ldr c28, [x23, #7]
	.inst 0xc2dca661 // chkeq c19, c28
	b.ne comparison_fail
	.inst 0xc24022fc // ldr c28, [x23, #8]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc24026fc // ldr c28, [x23, #9]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc2402afc // ldr c28, [x23, #10]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc2402efc // ldr c28, [x23, #11]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc298403c // mrs c28, CELR_EL1
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x28, 0xc1
	orr x23, x23, x28
	ldr x28, =0x920000eb
	cmp x28, x23
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
	ldr x0, =0x00001dd0
	ldr x1, =check_data1
	ldr x2, =0x00001df0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.byte 0x00, 0x10, 0x00, 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
	.byte 0x00, 0x00, 0x10, 0x40, 0x10, 0x02, 0x02, 0x20, 0x10, 0x02, 0x04, 0x00, 0x08, 0x08, 0x00, 0x20
.data
check_data2:
	.byte 0x1e, 0x3c, 0x26, 0x02, 0xe0, 0xfc, 0x5f, 0x48, 0x7d, 0x40, 0xdd, 0xc2, 0x05, 0x7e, 0xf9, 0xc8
	.byte 0x1d, 0xeb, 0x7d, 0x38
.data
check_data3:
	.byte 0x1f, 0x40, 0x33, 0xb8, 0xff, 0x10, 0x69, 0xb8, 0xbf, 0x93, 0x2c, 0x62, 0x3e, 0x70, 0xc0, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x7c007007ffffffffffa00
	/* C1 */
	.octa 0x400000000000000000000000
	/* C3 */
	.octa 0x760070080000000014001
	/* C4 */
	.octa 0x20000808000402102002021040100000
	/* C7 */
	.octa 0x1000
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x1000
	/* C19 */
	.octa 0x1000000
	/* C24 */
	.octa 0xfbffffffffffdfc0
	/* C25 */
	.octa 0xffffffff7effefff
	/* C29 */
	.octa 0x2040
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x400000000000000000000000
	/* C3 */
	.octa 0x760070080000000014001
	/* C4 */
	.octa 0x20000808000402102002021040100000
	/* C7 */
	.octa 0x1000
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x1000
	/* C19 */
	.octa 0x1000000
	/* C24 */
	.octa 0xfbffffffffffdfc0
	/* C25 */
	.octa 0x81001000
	/* C29 */
	.octa 0x760070000000000002040
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc0000000000200030000000000000000
initial_DDC_EL1_value:
	.octa 0xcc000000600200000000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001de0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001dd0
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600f97 // ldr x23, [c28, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f97 // str x23, [c28, #0]
	ldr x23, =0x40400414
	mrs x28, ELR_EL1
	sub x23, x23, x28
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fc // cvtp c28, x23
	.inst 0xc2d7439c // scvalue c28, c28, x23
	.inst 0x82600397 // ldr c23, [c28, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
