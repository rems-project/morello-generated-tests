.section text0, #alloc, #execinstr
test_start:
	.inst 0xb86a73bf // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:111 o3:0 Rs:10 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x513ac3a0 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:29 imm12:111010110000 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xf86b63bf // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:110 o3:0 Rs:11 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x827e8e7d // ALDR-R.RI-64 Rt:29 Rn:19 op:11 imm9:111101000 L:1 1000001001:1000001001
	.inst 0xc2df8b9d // CHKSSU-C.CC-C Cd:29 Cn:28 0010:0010 opc:10 Cm:31 11000010110:11000010110
	.inst 0x385aa3de // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:30 00:00 imm9:110101010 0:0 opc:01 111000:111000 size:00
	.inst 0xc2dd6701 // CPYVALUE-C.C-C Cd:1 Cn:24 001:001 opc:11 0:0 Cm:29 11000010110:11000010110
	.inst 0xe252224a // ASTURH-R.RI-32 Rt:10 Rn:18 op2:00 imm9:100100010 V:0 op1:01 11100010:11100010
	.inst 0x62fec3a0 // LDP-C.RIBW-C Ct:0 Rn:29 Ct2:10000 imm7:1111101 L:1 011000101:011000101
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
	ldr x25, =initial_cap_values
	.inst 0xc240032a // ldr c10, [x25, #0]
	.inst 0xc240072b // ldr c11, [x25, #1]
	.inst 0xc2400b32 // ldr c18, [x25, #2]
	.inst 0xc2400f33 // ldr c19, [x25, #3]
	.inst 0xc2401338 // ldr c24, [x25, #4]
	.inst 0xc240173c // ldr c28, [x25, #5]
	.inst 0xc2401b3d // ldr c29, [x25, #6]
	.inst 0xc2401f3e // ldr c30, [x25, #7]
	/* Set up flags and system registers */
	ldr x25, =0x0
	msr SPSR_EL3, x25
	ldr x25, =initial_SP_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884119 // msr CSP_EL0, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0xc0000
	msr CPACR_EL1, x25
	ldr x25, =0x0
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0x4
	msr S3_3_C1_C2_2, x25 // CCTLR_EL0
	ldr x25, =initial_DDC_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884139 // msr DDC_EL0, c25
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601139 // ldr c25, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e4039 // msr CELR_EL3, c25
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x9, #0xf
	and x25, x25, x9
	cmp x25, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400329 // ldr c9, [x25, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400729 // ldr c9, [x25, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400b29 // ldr c9, [x25, #2]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2400f29 // ldr c9, [x25, #3]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc2401329 // ldr c9, [x25, #4]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401729 // ldr c9, [x25, #5]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2401b29 // ldr c9, [x25, #6]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2401f29 // ldr c9, [x25, #7]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc2402329 // ldr c9, [x25, #8]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402729 // ldr c9, [x25, #9]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402b29 // ldr c9, [x25, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_SP_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984109 // mrs c9, CSP_EL0
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101a
	ldr x1, =check_data0
	ldr x2, =0x0000101b
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001210
	ldr x1, =check_data1
	ldr x2, =0x00001230
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014c2
	ldr x1, =check_data2
	ldr x2, =0x000014c4
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
	ldr x0, =0x40408f40
	ldr x1, =check_data4
	ldr x2, =0x40408f48
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
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
	.zero 544
	.byte 0x80, 0x00, 0x10, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3536
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xbf, 0x73, 0x6a, 0xb8, 0xa0, 0xc3, 0x3a, 0x51, 0xbf, 0x63, 0x6b, 0xf8, 0x7d, 0x8e, 0x7e, 0x82
	.byte 0x9d, 0x8b, 0xdf, 0xc2, 0xde, 0xa3, 0x5a, 0x38, 0x01, 0x67, 0xdd, 0xc2, 0x4a, 0x22, 0x52, 0xe2
	.byte 0xa0, 0xc3, 0xfe, 0x62, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C18 */
	.octa 0x400000000001000500000000000015a0
	/* C19 */
	.octa 0x80000000400288490000000040408000
	/* C24 */
	.octa 0x800000070000000000000000
	/* C28 */
	.octa 0xffffc000600720070000000000001240
	/* C29 */
	.octa 0x1220
	/* C30 */
	.octa 0x1070
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800000070000000000001240
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x20000000000
	/* C18 */
	.octa 0x400000000001000500000000000015a0
	/* C19 */
	.octa 0x80000000400288490000000040408000
	/* C24 */
	.octa 0x800000070000000000000000
	/* C28 */
	.octa 0xffffc000600720070000000000001240
	/* C29 */
	.octa 0x1210
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x102710070000000000000001
initial_DDC_EL0_value:
	.octa 0xd0000000523200000000000000006001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x102710070000000000000001
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
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001210
	.dword 0x0000000000001220
	.dword 0x00000000000014c0
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x021e0339 // add c25, c25, #1920
	.inst 0xc2c21320 // br c25

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
