.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c13321 // GCFLGS-R.C-C Rd:1 Cn:25 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x9bbf7dd5 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:21 Rn:14 Ra:31 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0xc2c5b3a1 // CVTP-C.R-C Cd:1 Rn:29 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c1d337 // CPY-C.C-C Cd:23 Cn:25 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xa244afdf // LDR-C.RIBW-C Ct:31 Rn:30 11:11 imm9:001001010 0:0 opc:01 10100010:10100010
	.inst 0xb8395020 // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:1 00:00 opc:101 0:0 Rs:25 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x48dfff20 // ldarh:aarch64/instrs/memory/ordered Rt:0 Rn:25 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xe2bae1a6 // ASTUR-V.RI-S Rt:6 Rn:13 op2:00 imm9:110101110 V:1 op1:10 11100010:11100010
	.inst 0x790b8fdd // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:30 imm12:001011100011 opc:00 111001:111001 size:01
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
	ldr x24, =initial_cap_values
	.inst 0xc240030d // ldr c13, [x24, #0]
	.inst 0xc2400719 // ldr c25, [x24, #1]
	.inst 0xc2400b1d // ldr c29, [x24, #2]
	.inst 0xc2400f1e // ldr c30, [x24, #3]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q6, =0x0
	/* Set up flags and system registers */
	ldr x24, =0x0
	msr SPSR_EL3, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0x3c0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0xc
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601098 // ldr c24, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400304 // ldr c4, [x24, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400704 // ldr c4, [x24, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc2400f04 // ldr c4, [x24, #3]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc2401304 // ldr c4, [x24, #4]
	.inst 0xc2c4a6e1 // chkeq c23, c4
	b.ne comparison_fail
	.inst 0xc2401704 // ldr c4, [x24, #5]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc2401b04 // ldr c4, [x24, #6]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2401f04 // ldr c4, [x24, #7]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x4, v6.d[0]
	cmp x24, x4
	b.ne comparison_fail
	ldr x24, =0x0
	mov x4, v6.d[1]
	cmp x24, x4
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001050
	ldr x1, =check_data1
	ldr x2, =0x00001060
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001616
	ldr x1, =check_data2
	ldr x2, =0x00001618
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fb8
	ldr x1, =check_data3
	ldr x2, =0x00001fbc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffc
	ldr x1, =check_data4
	ldr x2, =0x00001ffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400028
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
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf5, 0x3d, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xf5, 0x3d, 0x00, 0x80
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x10
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x21, 0x33, 0xc1, 0xc2, 0xd5, 0x7d, 0xbf, 0x9b, 0xa1, 0xb3, 0xc5, 0xc2, 0x37, 0xd3, 0xc1, 0xc2
	.byte 0xdf, 0xaf, 0x44, 0xa2, 0x20, 0x50, 0x39, 0xb8, 0x20, 0xff, 0xdf, 0x48, 0xa6, 0xe1, 0xba, 0xe2
	.byte 0xdd, 0x8f, 0x0b, 0x79, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C13 */
	.octa 0x4000000000010005000000000000200a
	/* C25 */
	.octa 0x1ff4
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0xba8
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x20008000000100070000000000001000
	/* C13 */
	.octa 0x4000000000010005000000000000200a
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x1ff4
	/* C25 */
	.octa 0x1ff4
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1048
initial_DDC_EL0_value:
	.octa 0xc01000004002000800ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000100070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001050
	.dword 0x0000000000001610
	.dword 0x0000000000001fb0
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
