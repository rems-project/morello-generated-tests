.section text0, #alloc, #execinstr
test_start:
	.inst 0xf87d21ff // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:15 00:00 opc:010 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c0f3ac // GCTYPE-R.C-C Rd:12 Cn:29 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x48df7c3d // ldlarh:aarch64/instrs/memory/ordered Rt:29 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x388a0a5e // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:18 10:10 imm9:010100000 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c21000 // BR-C-C 00000:00000 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.zero 32748
	.inst 0x48df7e5d // ldlarh:aarch64/instrs/memory/ordered Rt:29 Rn:18 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xb82c029f // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:000 o3:0 Rs:12 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x6d3c9bbf // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:31 Rn:29 Rt2:00110 imm7:1111001 L:0 1011010:1011010 opc:01
	.inst 0xa203ebb4 // STTR-C.RIB-C Ct:20 Rn:29 10:10 imm9:000111110 0:0 opc:00 10100010:10100010
	.inst 0xd4000001
	.zero 32748
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
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a6f // ldr c15, [x19, #2]
	.inst 0xc2400e72 // ldr c18, [x19, #3]
	.inst 0xc2401274 // ldr c20, [x19, #4]
	.inst 0xc240167d // ldr c29, [x19, #5]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q6, =0x0
	ldr q31, =0x0
	/* Set up flags and system registers */
	ldr x19, =0x4000000
	msr SPSR_EL3, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0x3c0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x0
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f3 // ldr c19, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	.inst 0xc2400277 // ldr c23, [x19, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400677 // ldr c23, [x19, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a77 // ldr c23, [x19, #2]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2400e77 // ldr c23, [x19, #3]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc2401277 // ldr c23, [x19, #4]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2401677 // ldr c23, [x19, #5]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2401a77 // ldr c23, [x19, #6]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2401e77 // ldr c23, [x19, #7]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x23, v6.d[0]
	cmp x19, x23
	b.ne comparison_fail
	ldr x19, =0x0
	mov x23, v6.d[1]
	cmp x19, x23
	b.ne comparison_fail
	ldr x19, =0x0
	mov x23, v31.d[0]
	cmp x19, x23
	b.ne comparison_fail
	ldr x19, =0x0
	mov x23, v31.d[1]
	cmp x19, x23
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a661 // chkeq c19, c23
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001022
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010c1
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001408
	ldr x1, =check_data3
	ldr x2, =0x00001418
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001808
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001820
	ldr x1, =check_data5
	ldr x2, =0x00001830
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x404003f0
	ldr x1, =check_data7
	ldr x2, =0x404003f2
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x40408000
	ldr x1, =check_data8
	ldr x2, =0x40408014
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
	.zero 32
	.byte 0x40, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x40, 0x14
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x08, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x80, 0x40, 0x00, 0x00, 0x00, 0x80, 0x00
.data
check_data6:
	.byte 0xff, 0x21, 0x7d, 0xf8, 0xac, 0xf3, 0xc0, 0xc2, 0x3d, 0x7c, 0xdf, 0x48, 0x5e, 0x0a, 0x8a, 0x38
	.byte 0x00, 0x10, 0xc2, 0xc2
.data
check_data7:
	.zero 2
.data
check_data8:
	.byte 0x5d, 0x7e, 0xdf, 0x48, 0x9f, 0x02, 0x2c, 0xb8, 0xbf, 0x9b, 0x3c, 0x6d, 0xb4, 0xeb, 0x03, 0xa2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000800100070000000040408000
	/* C1 */
	.octa 0x800000003e01000700000000404003f0
	/* C15 */
	.octa 0xc0000000000100050000000000001800
	/* C18 */
	.octa 0x80000000000100050000000000001020
	/* C20 */
	.octa 0x800000004080020000000000001008
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x20008000800100070000000040408000
	/* C1 */
	.octa 0x800000003e01000700000000404003f0
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0xc0000000000100050000000000001800
	/* C18 */
	.octa 0x80000000000100050000000000001020
	/* C20 */
	.octa 0x800000004080020000000000001008
	/* C29 */
	.octa 0x1440
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xcc00000059000baa0000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000100070000000040408014
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001820
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001400
	.dword 0x0000000000001410
	.dword 0x0000000000001800
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
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40408014
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
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
