.section text0, #alloc, #execinstr
test_start:
	.inst 0xa93093a0 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:29 Rt2:00100 imm7:1100001 L:0 1010010:1010010 opc:10
	.inst 0x027d6bff // ADD-C.CIS-C Cd:31 Cn:31 imm12:111101011010 sh:1 A:0 00000010:00000010
	.inst 0xb88058dd // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:29 Rn:6 10:10 imm9:000000101 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c5b000 // CVTP-C.R-C Cd:0 Rn:0 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x827ea9fd // ALDR-R.RI-32 Rt:29 Rn:15 op:10 imm9:111101010 L:1 1000001001:1000001001
	.zero 1004
	.inst 0xa90a5488 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:8 Rn:4 Rt2:10101 imm7:0010100 L:0 1010010:1010010 opc:10
	.inst 0x7818a416 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:22 Rn:0 01:01 imm9:110001010 0:0 opc:00 111000:111000 size:01
	.inst 0x1ac12449 // lsrv:aarch64/instrs/integer/shift/variable Rd:9 Rn:2 op2:01 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0xc2d743c1 // SCVALUE-C.CR-C Cd:1 Cn:30 000:000 opc:10 0:0 Rm:23 11000010110:11000010110
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400664 // ldr c4, [x19, #1]
	.inst 0xc2400a66 // ldr c6, [x19, #2]
	.inst 0xc2400e68 // ldr c8, [x19, #3]
	.inst 0xc240126f // ldr c15, [x19, #4]
	.inst 0xc2401675 // ldr c21, [x19, #5]
	.inst 0xc2401a76 // ldr c22, [x19, #6]
	.inst 0xc2401e77 // ldr c23, [x19, #7]
	.inst 0xc240227d // ldr c29, [x19, #8]
	.inst 0xc240267e // ldr c30, [x19, #9]
	/* Set up flags and system registers */
	ldr x19, =0x0
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884113 // msr CSP_EL0, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
	msr CPACR_EL1, x19
	ldr x19, =0x4
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x8
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =initial_DDC_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4133 // msr DDC_EL1, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601353 // ldr c19, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240027a // ldr c26, [x19, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240067a // ldr c26, [x19, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a7a // ldr c26, [x19, #2]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc2400e7a // ldr c26, [x19, #3]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc240127a // ldr c26, [x19, #4]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc240167a // ldr c26, [x19, #5]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc2401a7a // ldr c26, [x19, #6]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc2401e7a // ldr c26, [x19, #7]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc240227a // ldr c26, [x19, #8]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc240267a // ldr c26, [x19, #9]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2402a7a // ldr c26, [x19, #10]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc298411a // mrs c26, CSP_EL0
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	mov x26, 0x80
	orr x19, x19, x26
	ldr x26, =0x920000a8
	cmp x26, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001012
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a0
	ldr x1, =check_data2
	ldr x2, =0x000010b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
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
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.byte 0x10, 0x10, 0xc0, 0xbf, 0xff, 0xff, 0xff, 0xff, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xa0, 0x93, 0x30, 0xa9, 0xff, 0x6b, 0x7d, 0x02, 0xdd, 0x58, 0x80, 0xb8, 0x00, 0xb0, 0xc5, 0xc2
	.byte 0xfd, 0xa9, 0x7e, 0x82
.data
check_data4:
	.byte 0x88, 0x54, 0x0a, 0xa9, 0x16, 0xa4, 0x18, 0x78, 0x49, 0x24, 0xc1, 0x1a, 0xc1, 0x43, 0xd7, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffbfc01010
	/* C4 */
	.octa 0x1000
	/* C6 */
	.octa 0x101b
	/* C8 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x80000000000001
	/* C29 */
	.octa 0x10f8
	/* C30 */
	.octa 0x800100070080000000000001
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xf9a
	/* C1 */
	.octa 0x800100070080000000000001
	/* C4 */
	.octa 0x1000
	/* C6 */
	.octa 0x101b
	/* C8 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x80000000000001
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x800100070080000000000001
initial_SP_EL0_value:
	.octa 0x1000400c0000000000000
initial_DDC_EL0_value:
	.octa 0xc0000000600100020000000000000001
initial_DDC_EL1_value:
	.octa 0x40000000100500070000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004480d01d0000000040400000
final_SP_EL0_value:
	.octa 0x1000400c0000000f5a000
final_PCC_value:
	.octa 0x200080004480d01d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404400000000000040400000
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
	.dword 0x0000000000001010
	.dword 0x00000000000010a0
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600f53 // ldr x19, [c26, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f53 // str x19, [c26, #0]
	ldr x19, =0x40400414
	mrs x26, ELR_EL1
	sub x19, x19, x26
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27a // cvtp c26, x19
	.inst 0xc2d3435a // scvalue c26, c26, x19
	.inst 0x82600353 // ldr c19, [c26, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
