.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8204b9e // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:30 Rn:28 10:10 S:0 option:010 Rm:0 1:1 opc:00 111000:111000 size:11
	.inst 0x3c18b3bd // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:29 Rn:29 00:00 imm9:110001011 0:0 opc:00 111100:111100 size:00
	.inst 0xb10804df // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:6 imm12:001000000001 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2d143bd // SCVALUE-C.CR-C Cd:29 Cn:29 000:000 opc:10 0:0 Rm:17 11000010110:11000010110
	.inst 0x39da2adc // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:22 imm12:011010001010 opc:11 111001:111001 size:00
	.zero 1004
	.inst 0x381ba740 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:26 01:01 imm9:110111010 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c04751 // CSEAL-C.C-C Cd:17 Cn:26 001:001 opc:10 0:0 Cm:0 11000010110:11000010110
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xa2618029 // SWPL-CC.R-C Ct:9 Rn:1 100000:100000 Cs:1 1:1 R:1 A:0 10100010:10100010
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400911 // ldr c17, [x8, #2]
	.inst 0xc2400d16 // ldr c22, [x8, #3]
	.inst 0xc240111a // ldr c26, [x8, #4]
	.inst 0xc240151c // ldr c28, [x8, #5]
	.inst 0xc240191d // ldr c29, [x8, #6]
	.inst 0xc2401d1e // ldr c30, [x8, #7]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x8, =0x0
	msr SPSR_EL3, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0x3c0000
	msr CPACR_EL1, x8
	ldr x8, =0x0
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x0
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601308 // ldr c8, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x24, #0xf
	and x8, x8, x24
	cmp x8, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400118 // ldr c24, [x8, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400518 // ldr c24, [x8, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400918 // ldr c24, [x8, #2]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2400d18 // ldr c24, [x8, #3]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2401118 // ldr c24, [x8, #4]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc2401518 // ldr c24, [x8, #5]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc2401918 // ldr c24, [x8, #6]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2401d18 // ldr c24, [x8, #7]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2402118 // ldr c24, [x8, #8]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x24, v29.d[0]
	cmp x8, x24
	b.ne comparison_fail
	ldr x8, =0x0
	mov x24, v29.d[1]
	cmp x8, x24
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x24, 0x80
	orr x8, x8, x24
	ldr x24, =0x920000ab
	cmp x24, x8
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
	ldr x0, =0x0000100d
	ldr x1, =check_data1
	ldr x2, =0x0000100e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001810
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001928
	ldr x1, =check_data3
	ldr x2, =0x00001929
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
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.byte 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x60, 0x00, 0x80, 0x10, 0xcc
.data
check_data3:
	.byte 0xff
.data
check_data4:
	.byte 0x9e, 0x4b, 0x20, 0xf8, 0xbd, 0xb3, 0x18, 0x3c, 0xdf, 0x04, 0x08, 0xb1, 0xbd, 0x43, 0xd1, 0xc2
	.byte 0xdc, 0x2a, 0xda, 0x39
.data
check_data5:
	.byte 0x40, 0xa7, 0x1b, 0x38, 0x51, 0x47, 0xc0, 0xc2, 0xe0, 0x73, 0xc2, 0xc2, 0x29, 0x80, 0x61, 0xa2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C1 */
	.octa 0xcc108000600000040000000000001800
	/* C17 */
	.octa 0x800000007fe001
	/* C22 */
	.octa 0x7ffffffffff976
	/* C26 */
	.octa 0x1928
	/* C28 */
	.octa 0xffffffff00001001
	/* C29 */
	.octa 0x700070000000000001082
	/* C30 */
	.octa 0x80000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C1 */
	.octa 0xcc108000600000040000000000001800
	/* C9 */
	.octa 0x0
	/* C17 */
	.octa 0x18e2
	/* C22 */
	.octa 0x7ffffffffff976
	/* C26 */
	.octa 0x18e2
	/* C28 */
	.octa 0xffffffff00001001
	/* C29 */
	.octa 0x7000700800000007fe001
	/* C30 */
	.octa 0x80000
initial_DDC_EL0_value:
	.octa 0x400000004001000200ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x400000000007000700ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000800000000000040400000
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
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001800
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001920
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
