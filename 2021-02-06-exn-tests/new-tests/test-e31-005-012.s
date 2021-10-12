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
	ldr x26, =initial_cap_values
	.inst 0xc2400344 // ldr c4, [x26, #0]
	.inst 0xc2400745 // ldr c5, [x26, #1]
	.inst 0xc2400b4a // ldr c10, [x26, #2]
	.inst 0xc2400f50 // ldr c16, [x26, #3]
	.inst 0xc2401357 // ldr c23, [x26, #4]
	.inst 0xc240175d // ldr c29, [x26, #5]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x26, =0x40000000
	msr SPSR_EL3, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0x3c0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x0
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260117a // ldr c26, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc28e403a // msr CELR_EL3, c26
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x11, #0x4
	and x26, x26, x11
	cmp x26, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034b // ldr c11, [x26, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240074b // ldr c11, [x26, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400b4b // ldr c11, [x26, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400f4b // ldr c11, [x26, #3]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc240134b // ldr c11, [x26, #4]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc240174b // ldr c11, [x26, #5]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc2401b4b // ldr c11, [x26, #6]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc2401f4b // ldr c11, [x26, #7]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc240234b // ldr c11, [x26, #8]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc240274b // ldr c11, [x26, #9]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc2402b4b // ldr c11, [x26, #10]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x11, v30.d[0]
	cmp x26, x11
	b.ne comparison_fail
	ldr x26, =0x0
	mov x11, v30.d[1]
	cmp x26, x11
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000016d0
	ldr x1, =check_data0
	ldr x2, =0x000016f0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001bd6
	ldr x1, =check_data1
	ldr x2, =0x00001bd7
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
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
	.octa 0x300070000e00000000001
	/* C10 */
	.octa 0x1
	/* C16 */
	.octa 0x40400018
	/* C23 */
	.octa 0x1850
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
	.octa 0x1850
	/* C29 */
	.octa 0x4041001f
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
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
	.dword 0x00000000000016d0
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x00000000000016d0
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000016e0
	.dword 0x0000000000001bd0
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x82600d7a // ldr x26, [c11, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d7a // str x26, [c11, #0]
	ldr x26, =0x40400028
	mrs x11, ELR_EL1
	sub x26, x26, x11
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34b // cvtp c11, x26
	.inst 0xc2da416b // scvalue c11, c11, x26
	.inst 0x8260017a // ldr c26, [c11, #0]
	.inst 0x021e035a // add c26, c26, #1920
	.inst 0xc2c21340 // br c26

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
