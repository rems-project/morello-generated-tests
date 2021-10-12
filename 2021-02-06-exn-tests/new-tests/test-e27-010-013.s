.section text0, #alloc, #execinstr
test_start:
	.inst 0x786013bf // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:001 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x380337dd // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:30 01:01 imm9:000110011 0:0 opc:00 111000:111000 size:00
	.inst 0xd63f0040 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 16372
	.inst 0xc2c5925f // CVTD-C.R-C Cd:31 Rn:18 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x427ffcbe // ALDAR-R.R-32 Rt:30 Rn:5 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x423ffe8c // ASTLR-R.R-32 Rt:12 Rn:20 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x82c1ec60 // ALDRH-R.RRB-32 Rt:0 Rn:3 opc:11 S:0 option:111 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x386c5960 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:11 10:10 S:1 option:010 Rm:12 1:1 opc:01 111000:111000 size:00
	.inst 0xc2d3a8a1 // EORFLGS-C.CR-C Cd:1 Cn:5 1010:1010 opc:10 Rm:19 11000010110:11000010110
	.inst 0xd4000001
	.zero 49124
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac2 // ldr c2, [x22, #2]
	.inst 0xc2400ec3 // ldr c3, [x22, #3]
	.inst 0xc24012c5 // ldr c5, [x22, #4]
	.inst 0xc24016cb // ldr c11, [x22, #5]
	.inst 0xc2401acc // ldr c12, [x22, #6]
	.inst 0xc2401ed2 // ldr c18, [x22, #7]
	.inst 0xc24022d4 // ldr c20, [x22, #8]
	.inst 0xc24026dd // ldr c29, [x22, #9]
	.inst 0xc2402ade // ldr c30, [x22, #10]
	/* Set up flags and system registers */
	ldr x22, =0x0
	msr SPSR_EL3, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30d5d99f
	msr SCTLR_EL1, x22
	ldr x22, =0xc0000
	msr CPACR_EL1, x22
	ldr x22, =0x0
	msr S3_0_C1_C2_2, x22 // CCTLR_EL1
	ldr x22, =0x8
	msr S3_3_C1_C2_2, x22 // CCTLR_EL0
	ldr x22, =initial_DDC_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2884136 // msr DDC_EL0, c22
	ldr x22, =0x80000000
	msr HCR_EL2, x22
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82601396 // ldr c22, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc28e4036 // msr CELR_EL3, c22
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002dc // ldr c28, [x22, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24006dc // ldr c28, [x22, #1]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400adc // ldr c28, [x22, #2]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc2400edc // ldr c28, [x22, #3]
	.inst 0xc2dca4a1 // chkeq c5, c28
	b.ne comparison_fail
	.inst 0xc24012dc // ldr c28, [x22, #4]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc24016dc // ldr c28, [x22, #5]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc2401adc // ldr c28, [x22, #6]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc2401edc // ldr c28, [x22, #7]
	.inst 0xc2dca681 // chkeq c20, c28
	b.ne comparison_fail
	.inst 0xc24022dc // ldr c28, [x22, #8]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc24026dc // ldr c28, [x22, #9]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check system registers */
	ldr x22, =final_PCC_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc298403c // mrs c28, CELR_EL1
	.inst 0xc2dca6c1 // chkeq c22, c28
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
	ldr x2, =0x0000106a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001081
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x4040000c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40401000
	ldr x1, =check_data4
	ldr x2, =0x40401002
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40404000
	ldr x1, =check_data5
	ldr x2, =0x4040401c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40407ffc
	ldr x1, =check_data6
	ldr x2, =0x40408000
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
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
	.zero 96
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3984
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.byte 0xff, 0xff
.data
check_data2:
	.byte 0x68
.data
check_data3:
	.byte 0xbf, 0x13, 0x60, 0x78, 0xdd, 0x37, 0x03, 0x38, 0x40, 0x00, 0x3f, 0xd6
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x5f, 0x92, 0xc5, 0xc2, 0xbe, 0xfc, 0x7f, 0x42, 0x8c, 0xfe, 0x3f, 0x42, 0x60, 0xec, 0xc1, 0x82
	.byte 0x60, 0x59, 0x6c, 0x38, 0xa1, 0xa8, 0xd3, 0xc2, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x3000
	/* C2 */
	.octa 0x4000
	/* C3 */
	.octa 0x800000004002000400000000403fe000
	/* C5 */
	.octa 0x80000000000100070000000040407ffc
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x1000
	/* C18 */
	.octa 0x8000000001c000
	/* C20 */
	.octa 0x40000000000700070000000000001000
	/* C29 */
	.octa 0x1068
	/* C30 */
	.octa 0x1080
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x4000
	/* C3 */
	.octa 0x800000004002000400000000403fe000
	/* C5 */
	.octa 0x80000000000100070000000040407ffc
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x1000
	/* C18 */
	.octa 0x8000000001c000
	/* C20 */
	.octa 0x40000000000700070000000000001000
	/* C29 */
	.octa 0x1068
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc000000005ff060e0000000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x2000800020070007000000004040401c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001060
	.dword 0x0000000000001080
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
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x020002d6 // add c22, c22, #0
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x020202d6 // add c22, c22, #128
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x020402d6 // add c22, c22, #256
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x020602d6 // add c22, c22, #384
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x020802d6 // add c22, c22, #512
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x020a02d6 // add c22, c22, #640
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x020c02d6 // add c22, c22, #768
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x020e02d6 // add c22, c22, #896
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x021002d6 // add c22, c22, #1024
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x021202d6 // add c22, c22, #1152
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x021402d6 // add c22, c22, #1280
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x021602d6 // add c22, c22, #1408
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x021802d6 // add c22, c22, #1536
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x021a02d6 // add c22, c22, #1664
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x021c02d6 // add c22, c22, #1792
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600f96 // ldr x22, [c28, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f96 // str x22, [c28, #0]
	ldr x22, =0x4040401c
	mrs x28, ELR_EL1
	sub x22, x22, x28
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2dc // cvtp c28, x22
	.inst 0xc2d6439c // scvalue c28, c28, x22
	.inst 0x82600396 // ldr c22, [c28, #0]
	.inst 0x021e02d6 // add c22, c22, #1920
	.inst 0xc2c212c0 // br c22

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
