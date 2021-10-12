.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2fbd18d // EORFLGS-C.CI-C Cd:13 Cn:12 0:0 10:10 imm8:11011110 11000010111:11000010111
	.inst 0x62bc6c03 // STP-C.RIBW-C Ct:3 Rn:0 Ct2:11011 imm7:1111000 L:0 011000101:011000101
	.inst 0xf9b3dc21 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:1 imm12:110011110111 opc:10 111001:111001 size:11
	.inst 0xda95302d // csinv:aarch64/instrs/integer/conditional/select Rd:13 Rn:1 o2:0 0:0 cond:0011 Rm:21 011010100:011010100 op:1 sf:1
	.inst 0xc22fd5c3 // STR-C.RIB-C Ct:3 Rn:14 imm12:101111110101 L:0 110000100:110000100
	.inst 0x3840353f // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:9 01:01 imm9:000000011 0:0 opc:01 111000:111000 size:00
	.inst 0x9ad72fbb // rorv:aarch64/instrs/integer/shift/variable Rd:27 Rn:29 op2:11 0010:0010 Rm:23 0011010110:0011010110 sf:1
	.inst 0x085fffaa // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:10 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
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
	.inst 0xc2400443 // ldr c3, [x2, #1]
	.inst 0xc2400849 // ldr c9, [x2, #2]
	.inst 0xc2400c4c // ldr c12, [x2, #3]
	.inst 0xc240104e // ldr c14, [x2, #4]
	.inst 0xc2401457 // ldr c23, [x2, #5]
	.inst 0xc240185b // ldr c27, [x2, #6]
	.inst 0xc2401c5d // ldr c29, [x2, #7]
	/* Set up flags and system registers */
	ldr x2, =0x4000000
	msr SPSR_EL3, x2
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
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82601382 // ldr c2, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	mov x28, #0x2
	and x2, x2, x28
	cmp x2, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc240005c // ldr c28, [x2, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240045c // ldr c28, [x2, #1]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc240085c // ldr c28, [x2, #2]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc2400c5c // ldr c28, [x2, #3]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc240105c // ldr c28, [x2, #4]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc240145c // ldr c28, [x2, #5]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc240185c // ldr c28, [x2, #6]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc2401c5c // ldr c28, [x2, #7]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc240205c // ldr c28, [x2, #8]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc298403c // mrs c28, CELR_EL1
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f80
	ldr x1, =check_data0
	ldr x2, =0x00001fa0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fc0
	ldr x1, =check_data1
	ldr x2, =0x00001fd0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff6
	ldr x1, =check_data2
	ldr x2, =0x00001ff7
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
	ldr x0, =0x4040dbff
	ldr x1, =check_data4
	ldr x2, =0x4040dc00
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
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.zero 16
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0x8d, 0xd1, 0xfb, 0xc2, 0x03, 0x6c, 0xbc, 0x62, 0x21, 0xdc, 0xb3, 0xf9
	.byte 0x2d, 0x30, 0x95, 0xda, 0xc3, 0xd5, 0x2f, 0xc2, 0x3f, 0x35, 0x40, 0x38, 0xbb, 0x2f, 0xd7, 0x9a
	.byte 0xaa, 0xff, 0x5f, 0x08, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C9 */
	.octa 0x4040dbff
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0xffffffffffff6070
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x1ff6
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1f80
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C9 */
	.octa 0x4040dc02
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0xffffffffffff6070
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x1ff6
	/* C29 */
	.octa 0x1ff6
initial_DDC_EL0_value:
	.octa 0xc8000000000004000000000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000100050000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001f80
	.dword 0x0000000000001fc0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001f90
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
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600f82 // ldr x2, [c28, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f82 // str x2, [c28, #0]
	ldr x2, =0x40400028
	mrs x28, ELR_EL1
	sub x2, x2, x28
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05c // cvtp c28, x2
	.inst 0xc2c2439c // scvalue c28, c28, x2
	.inst 0x82600382 // ldr c2, [c28, #0]
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
