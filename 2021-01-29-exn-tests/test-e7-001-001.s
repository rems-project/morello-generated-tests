.section text0, #alloc, #execinstr
test_start:
	.inst 0xe21b115f // ASTURB-R.RI-32 Rt:31 Rn:10 op2:00 imm9:110110001 V:0 op1:00 11100010:11100010
	.inst 0xd63f0360 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:27 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.inst 0xd4000001
	.zero 2060
	.inst 0x827fdc19 // ALDR-R.RI-64 Rt:25 Rn:0 op:11 imm9:111111101 L:1 1000001001:1000001001
	.inst 0x780e4401 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:0 01:01 imm9:011100100 0:0 opc:00 111000:111000 size:01
	.inst 0xc28fa57e // MSR-C.I-C Ct:30 op2:011 CRm:0101 CRn:1010 op1:111 o0:1 L:0 11000010100:11000010100
	.zero 3036
	.inst 0x392ac4de // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:6 imm12:101010110001 opc:00 111001:111001 size:00
	.inst 0x5ac01400 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:0 Rn:0 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2dd03ce // SCBNDS-C.CR-C Cd:14 Cn:30 000:000 opc:00 0:0 Rm:29 11000010110:11000010110
	.inst 0xc2c253c2 // RETS-C-C 00010:00010 Cn:30 100:100 opc:10 11000010110000100:11000010110000100
	.zero 60400
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400886 // ldr c6, [x4, #2]
	.inst 0xc2400c8a // ldr c10, [x4, #3]
	.inst 0xc240109b // ldr c27, [x4, #4]
	/* Set up flags and system registers */
	ldr x4, =0x4000000
	msr SPSR_EL3, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0xc0000
	msr CPACR_EL1, x4
	ldr x4, =0x0
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =0x80
	msr S3_3_C1_C2_2, x4 // CCTLR_EL0
	ldr x4, =initial_DDC_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884124 // msr DDC_EL0, c4
	ldr x4, =initial_DDC_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc28c4124 // msr DDC_EL1, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011e4 // ldr c4, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e4024 // msr CELR_EL3, c4
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008f // ldr c15, [x4, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240048f // ldr c15, [x4, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240088f // ldr c15, [x4, #2]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc2400c8f // ldr c15, [x4, #3]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc240108f // ldr c15, [x4, #4]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc240148f // ldr c15, [x4, #5]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc240188f // ldr c15, [x4, #6]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	ldr x15, =esr_el1_dump_address
	ldr x15, [x15]
	mov x4, 0x0
	orr x15, x15, x4
	ldr x4, =0x2000000
	cmp x4, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x0000100a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fb2
	ldr x1, =check_data1
	ldr x2, =0x00001fb3
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x40400818
	ldr x1, =check_data5
	ldr x2, =0x40400824
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40401400
	ldr x1, =check_data6
	ldr x2, =0x40401410
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x09
.data
check_data4:
	.byte 0x5f, 0x11, 0x1b, 0xe2, 0x60, 0x03, 0x3f, 0xd6, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0x19, 0xdc, 0x7f, 0x82, 0x01, 0x44, 0x0e, 0x78, 0x7e, 0xa5, 0x8f, 0xc2
.data
check_data6:
	.byte 0xde, 0xc4, 0x2a, 0x39, 0x00, 0x14, 0xc0, 0x5a, 0xce, 0x03, 0xdd, 0xc2, 0xc2, 0x53, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000007000d0000000000001008
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x154d
	/* C10 */
	.octa 0x2001
	/* C27 */
	.octa 0x40400818
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x12
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x154d
	/* C10 */
	.octa 0x2001
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x40400818
	/* C30 */
	.octa 0x20008000800040080000000040400009
initial_DDC_EL0_value:
	.octa 0xc00000000003000700ffe00000000001
initial_DDC_EL1_value:
	.octa 0x40000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000040d0000000040401000
final_PCC_value:
	.octa 0x2000800000004008000000004040000c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword el1_vector_jump_cap
	.dword final_cap_values + 96
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x82600de4 // ldr x4, [c15, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400de4 // str x4, [c15, #0]
	ldr x4, =0x4040000c
	mrs x15, ELR_EL1
	sub x4, x4, x15
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08f // cvtp c15, x4
	.inst 0xc2c441ef // scvalue c15, c15, x4
	.inst 0x826001e4 // ldr c4, [c15, #0]
	.inst 0x021e0084 // add c4, c4, #1920
	.inst 0xc2c21080 // br c4

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
