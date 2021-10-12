.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c13321 // GCFLGS-R.C-C Rd:1 Cn:25 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x9bbf7dd5 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:21 Rn:14 Ra:31 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0xc2c5b3a1 // CVTP-C.R-C Cd:1 Rn:29 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c1d337 // CPY-C.C-C Cd:23 Cn:25 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xa244afdf // LDR-C.RIBW-C Ct:31 Rn:30 11:11 imm9:001001010 0:0 opc:01 10100010:10100010
	.zero 54252
	.inst 0xb8395020 // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:1 00:00 opc:101 0:0 Rs:25 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x48dfff20 // ldarh:aarch64/instrs/memory/ordered Rt:0 Rn:25 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xe2bae1a6 // ASTUR-V.RI-S Rt:6 Rn:13 op2:00 imm9:110101110 V:1 op1:10 11100010:11100010
	.inst 0x790b8fdd // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:30 imm12:001011100011 opc:00 111001:111001 size:01
	.inst 0xd4000001
	.zero 11244
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
	ldr x9, =initial_cap_values
	.inst 0xc240012d // ldr c13, [x9, #0]
	.inst 0xc2400539 // ldr c25, [x9, #1]
	.inst 0xc240093d // ldr c29, [x9, #2]
	.inst 0xc2400d3e // ldr c30, [x9, #3]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q6, =0x0
	/* Set up flags and system registers */
	ldr x9, =0x0
	msr SPSR_EL3, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0x1c0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0xc
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =initial_DDC_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28c4129 // msr DDC_EL1, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601249 // ldr c9, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400132 // ldr c18, [x9, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400532 // ldr c18, [x9, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400932 // ldr c18, [x9, #2]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2400d32 // ldr c18, [x9, #3]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2401132 // ldr c18, [x9, #4]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc2401532 // ldr c18, [x9, #5]
	.inst 0xc2d2a721 // chkeq c25, c18
	b.ne comparison_fail
	.inst 0xc2401932 // ldr c18, [x9, #6]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2401d32 // ldr c18, [x9, #7]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x18, v6.d[0]
	cmp x9, x18
	b.ne comparison_fail
	ldr x9, =0x0
	mov x18, v6.d[1]
	cmp x9, x18
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	ldr x9, =esr_el1_dump_address
	ldr x9, [x9]
	mov x18, 0x80
	orr x9, x9, x18
	ldr x18, =0x920000a9
	cmp x18, x9
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
	ldr x0, =0x00001fc8
	ldr x1, =check_data1
	ldr x2, =0x00001fcc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
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
	ldr x0, =0x40408ffc
	ldr x1, =check_data4
	ldr x2, =0x40408ffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040d400
	ldr x1, =check_data5
	ldr x2, =0x4040d414
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
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.byte 0xfd, 0x8f, 0x40, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xfd, 0x8f, 0x40, 0xc0
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x10
.data
check_data3:
	.byte 0x21, 0x33, 0xc1, 0xc2, 0xd5, 0x7d, 0xbf, 0x9b, 0xa1, 0xb3, 0xc5, 0xc2, 0x37, 0xd3, 0xc1, 0xc2
	.byte 0xdf, 0xaf, 0x44, 0xa2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x20, 0x50, 0x39, 0xb8, 0x20, 0xff, 0xdf, 0x48, 0xa6, 0xe1, 0xba, 0xe2, 0xdd, 0x8f, 0x0b, 0x79
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C13 */
	.octa 0x201a
	/* C25 */
	.octa 0x800000000007500f0000000040408ffc
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x40000000000100050000000000001a36
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xe0008000000100070000000000001000
	/* C13 */
	.octa 0x201a
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x800000000007500f0000000040408ffc
	/* C25 */
	.octa 0x800000000007500f0000000040408ffc
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x40000000000100050000000000001a36
initial_DDC_EL0_value:
	.octa 0x8007007b00000000000e0000
initial_DDC_EL1_value:
	.octa 0x40000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000c41d000000004040d001
final_PCC_value:
	.octa 0x200080004000c41d000000004040d414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xe0008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001fc0
	.dword 0x0000000000001ff0
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600e49 // ldr x9, [c18, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400e49 // str x9, [c18, #0]
	ldr x9, =0x4040d414
	mrs x18, ELR_EL1
	sub x9, x9, x18
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b132 // cvtp c18, x9
	.inst 0xc2c94252 // scvalue c18, c18, x9
	.inst 0x82600249 // ldr c9, [c18, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
