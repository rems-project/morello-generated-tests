.section text0, #alloc, #execinstr
test_start:
	.inst 0x42f432e2 // LDP-C.RIB-C Ct:2 Rn:23 Ct2:01100 imm7:1101000 L:1 010000101:010000101
	.inst 0x3d0e1afe // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:30 Rn:23 imm12:001110000110 opc:00 111101:111101 size:00
	.inst 0x385dfbbe // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:29 10:10 imm9:111011111 0:0 opc:01 111000:111000 size:00
	.inst 0xc2d01fe1 // CSEL-C.CI-C Cd:1 Cn:31 11:11 cond:0001 Cm:16 11000010110:11000010110
	.inst 0xc2e118a0 // CVT-C.CR-C Cd:0 Cn:5 0110:0110 0:0 0:0 Rm:1 11000010111:11000010111
	.inst 0xd61f0020 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.inst 0x39677880 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:4 imm12:100111011110 opc:01 111001:111001 size:00
	.inst 0x9aca2e05 // rorv:aarch64/instrs/integer/shift/variable Rd:5 Rn:16 op2:11 0010:0010 Rm:10 0011010110:0011010110 sf:1
	.inst 0x9b1b872f // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:15 Rn:25 Ra:1 o0:1 Rm:27 0011011000:0011011000 sf:1
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
	ldr x3, =initial_cap_values
	.inst 0xc2400064 // ldr c4, [x3, #0]
	.inst 0xc2400465 // ldr c5, [x3, #1]
	.inst 0xc240086a // ldr c10, [x3, #2]
	.inst 0xc2400c70 // ldr c16, [x3, #3]
	.inst 0xc2401077 // ldr c23, [x3, #4]
	.inst 0xc240147d // ldr c29, [x3, #5]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x3, =0x40000000
	msr SPSR_EL3, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0x3c0000
	msr CPACR_EL1, x3
	ldr x3, =0x0
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x0
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601343 // ldr c3, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x26, #0x4
	and x3, x3, x26
	cmp x3, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240007a // ldr c26, [x3, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240047a // ldr c26, [x3, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240087a // ldr c26, [x3, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400c7a // ldr c26, [x3, #3]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc240107a // ldr c26, [x3, #4]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc240147a // ldr c26, [x3, #5]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc240187a // ldr c26, [x3, #6]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc2401c7a // ldr c26, [x3, #7]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc240207a // ldr c26, [x3, #8]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc240247a // ldr c26, [x3, #9]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240287a // ldr c26, [x3, #10]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x26, v30.d[0]
	cmp x3, x26
	b.ne comparison_fail
	ldr x3, =0x0
	mov x26, v30.d[1]
	cmp x3, x26
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x000010a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001586
	ldr x1, =check_data1
	ldr x2, =0x00001587
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x4040fffe
	ldr x1, =check_data4
	ldr x2, =0x4040ffff
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
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
	.zero 32
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xe2, 0x32, 0xf4, 0x42, 0xfe, 0x1a, 0x0e, 0x3d, 0xbe, 0xfb, 0x5d, 0x38, 0xe1, 0x1f, 0xd0, 0xc2
	.byte 0xa0, 0x18, 0xe1, 0xc2, 0x20, 0x00, 0x1f, 0xd6, 0x80, 0x78, 0x67, 0x39, 0x05, 0x2e, 0xca, 0x9a
	.byte 0x2f, 0x87, 0x1b, 0x9b, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x1620
	/* C5 */
	.octa 0x8007886f0000000040400000
	/* C10 */
	.octa 0x1
	/* C16 */
	.octa 0x40400018
	/* C23 */
	.octa 0x1200
	/* C29 */
	.octa 0x4041001f
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40400018
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x1620
	/* C5 */
	.octa 0x2020000c
	/* C10 */
	.octa 0x1
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x40400018
	/* C23 */
	.octa 0x1200
	/* C29 */
	.octa 0x4041001f
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd0000000000100050000000000000001
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
	.dword 0x0000000000001080
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001080
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001090
	.dword 0x0000000000001580
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600f43 // ldr x3, [c26, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f43 // str x3, [c26, #0]
	ldr x3, =0x40400028
	mrs x26, ELR_EL1
	sub x3, x3, x26
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07a // cvtp c26, x3
	.inst 0xc2c3435a // scvalue c26, c26, x3
	.inst 0x82600343 // ldr c3, [c26, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
