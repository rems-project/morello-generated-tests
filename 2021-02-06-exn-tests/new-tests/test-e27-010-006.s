.section text0, #alloc, #execinstr
test_start:
	.inst 0x786013bf // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:001 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x380337dd // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:30 01:01 imm9:000110011 0:0 opc:00 111000:111000 size:00
	.inst 0xd63f0040 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 20
	.inst 0xc2c5925f // CVTD-C.R-C Cd:31 Rn:18 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x427ffcbe // ALDAR-R.R-32 Rt:30 Rn:5 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.zero 984
	.inst 0x423ffe8c // ASTLR-R.R-32 Rt:12 Rn:20 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x82c1ec60 // ALDRH-R.RRB-32 Rt:0 Rn:3 opc:11 S:0 option:111 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x386c5960 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:11 10:10 S:1 option:010 Rm:12 1:1 opc:01 111000:111000 size:00
	.inst 0xc2d3a8a1 // EORFLGS-C.CR-C Cd:1 Cn:5 1010:1010 opc:10 Rm:19 11000010110:11000010110
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2400cc3 // ldr c3, [x6, #3]
	.inst 0xc24010c5 // ldr c5, [x6, #4]
	.inst 0xc24014cb // ldr c11, [x6, #5]
	.inst 0xc24018cc // ldr c12, [x6, #6]
	.inst 0xc2401cd2 // ldr c18, [x6, #7]
	.inst 0xc24020d4 // ldr c20, [x6, #8]
	.inst 0xc24024dd // ldr c29, [x6, #9]
	.inst 0xc24028de // ldr c30, [x6, #10]
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
	ldr x6, =0x8
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =initial_DDC_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4126 // msr DDC_EL1, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601206 // ldr c6, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
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
	.inst 0xc24000d0 // ldr c16, [x6, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24004d0 // ldr c16, [x6, #1]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc24008d0 // ldr c16, [x6, #2]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400cd0 // ldr c16, [x6, #3]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc24010d0 // ldr c16, [x6, #4]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc24014d0 // ldr c16, [x6, #5]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc24018d0 // ldr c16, [x6, #6]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc2401cd0 // ldr c16, [x6, #7]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc24020d0 // ldr c16, [x6, #8]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc24024d0 // ldr c16, [x6, #9]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x16, 0x80
	orr x6, x6, x16
	ldr x16, =0x920000a1
	cmp x16, x6
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
	ldr x0, =0x00001068
	ldr x1, =check_data1
	ldr x2, =0x00001069
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fa9
	ldr x1, =check_data2
	ldr x2, =0x00001faa
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe4
	ldr x1, =check_data3
	ldr x2, =0x00001fe6
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x4040000c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400020
	ldr x1, =check_data5
	ldr x2, =0x40400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
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
	.byte 0x64, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xa8, 0xdf, 0xff, 0xff
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xbf, 0x13, 0x60, 0x78, 0xdd, 0x37, 0x03, 0x38, 0x40, 0x00, 0x3f, 0xd6
.data
check_data5:
	.byte 0x5f, 0x92, 0xc5, 0xc2, 0xbe, 0xfc, 0x7f, 0x42
.data
check_data6:
	.byte 0x8c, 0xfe, 0x3f, 0x42, 0x60, 0xec, 0xc1, 0x82, 0x60, 0x59, 0x6c, 0x38, 0xa1, 0xa8, 0xd3, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1fe4
	/* C2 */
	.octa 0x20
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x8000000060020001ff8025ab90000003
	/* C11 */
	.octa 0x8000000000050003ffffffff00004001
	/* C12 */
	.octa 0xffffdfa8
	/* C18 */
	.octa 0x81ffffffffe000
	/* C20 */
	.octa 0x1000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1068
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x20
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x8000000060020001ff8025ab90000003
	/* C11 */
	.octa 0x8000000000050003ffffffff00004001
	/* C12 */
	.octa 0xffffdfa8
	/* C18 */
	.octa 0x81ffffffffe000
	/* C20 */
	.octa 0x1000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0xc
initial_DDC_EL0_value:
	.octa 0xc0000000603200010000000000000001
initial_DDC_EL1_value:
	.octa 0xc000000000c7008e0000000000000000
initial_VBAR_EL1_value:
	.octa 0x20008000400004000000000040400001
final_PCC_value:
	.octa 0x20008000400004000000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000640100000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001060
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
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40400414
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
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
