.section text0, #alloc, #execinstr
test_start:
	.inst 0x48df7ce0 // ldlarh:aarch64/instrs/memory/ordered Rt:0 Rn:7 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xb9073329 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:9 Rn:25 imm12:000111001100 opc:00 111001:111001 size:10
	.inst 0xaa804020 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:1 imm6:010000 Rm:0 N:0 shift:10 01010:01010 opc:01 sf:1
	.inst 0xc2c153c1 // CFHI-R.C-C Rd:1 Cn:30 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x3814f4fd // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:7 01:01 imm9:101001111 0:0 opc:00 111000:111000 size:00
	.inst 0x28e4dc08 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:8 Rn:0 Rt2:10111 imm7:1001001 L:1 1010001:1010001 opc:00
	.inst 0xb8128f90 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:16 Rn:28 11:11 imm9:100101000 0:0 opc:00 111000:111000 size:10
	.inst 0xb868539f // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:28 00:00 opc:101 o3:0 Rs:8 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x0b3d2660 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:19 imm3:001 option:001 Rm:29 01011001:01011001 S:0 op:0 sf:0
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c7 // ldr c7, [x6, #1]
	.inst 0xc24008c9 // ldr c9, [x6, #2]
	.inst 0xc2400cd0 // ldr c16, [x6, #3]
	.inst 0xc24010d9 // ldr c25, [x6, #4]
	.inst 0xc24014dc // ldr c28, [x6, #5]
	.inst 0xc24018dd // ldr c29, [x6, #6]
	/* Set up flags and system registers */
	ldr x6, =0x0
	msr SPSR_EL3, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x0
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82601226 // ldr c6, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d1 // ldr c17, [x6, #0]
	.inst 0xc2d1a4e1 // chkeq c7, c17
	b.ne comparison_fail
	.inst 0xc24004d1 // ldr c17, [x6, #1]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc24008d1 // ldr c17, [x6, #2]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc2400cd1 // ldr c17, [x6, #3]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc2d1a6e1 // chkeq c23, c17
	b.ne comparison_fail
	.inst 0xc24014d1 // ldr c17, [x6, #5]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc24018d1 // ldr c17, [x6, #6]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	.inst 0xc2401cd1 // ldr c17, [x6, #7]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984031 // mrs c17, CELR_EL1
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001022
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001138
	ldr x1, =check_data1
	ldr x2, =0x0000113c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001328
	ldr x1, =check_data2
	ldr x2, =0x0000132c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff4
	ldr x1, =check_data3
	ldr x2, =0x00001ffc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400028
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
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xe0, 0x7c, 0xdf, 0x48, 0x29, 0x33, 0x07, 0xb9, 0x20, 0x40, 0x80, 0xaa, 0xc1, 0x53, 0xc1, 0xc2
	.byte 0xfd, 0xf4, 0x14, 0x38, 0x08, 0xdc, 0xe4, 0x28, 0x90, 0x8f, 0x12, 0xb8, 0x9f, 0x53, 0x68, 0xb8
	.byte 0x60, 0x26, 0x3d, 0x0b, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1ff4
	/* C7 */
	.octa 0x1020
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x1
	/* C25 */
	.octa 0xa08
	/* C28 */
	.octa 0x1400
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C7 */
	.octa 0xf6f
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x1
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0xa08
	/* C28 */
	.octa 0x1328
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000080080000000040400028
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
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001020
	.dword 0x0000000000001130
	.dword 0x0000000000001320
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
