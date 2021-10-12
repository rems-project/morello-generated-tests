.section text0, #alloc, #execinstr
test_start:
	.inst 0x787f73fd // lduminh:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:31 00:00 opc:111 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x48dffffe // ldarh:aarch64/instrs/memory/ordered Rt:30 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x6d2ab3ef // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:15 Rn:31 Rt2:01100 imm7:1010101 L:0 1011010:1011010 opc:01
	.inst 0x8ae04d9f // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:12 imm6:010011 Rm:0 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0x089ffe21 // stlrb:aarch64/instrs/memory/ordered Rt:1 Rn:17 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x9028cffd // ADRDP-C.ID-C Rd:29 immhi:010100011001111111 P:0 10000:10000 immlo:00 op:1
	.inst 0x429764d4 // STP-C.RIB-C Ct:20 Rn:6 Ct2:11001 imm7:0101110 L:0 010000101:010000101
	.inst 0xc2c48401 // CHKSS-_.CC-C 00001:00001 Cn:0 001:001 opc:00 1:1 Cm:4 11000010110:11000010110
	.inst 0x089fffe6 // stlrb:aarch64/instrs/memory/ordered Rt:6 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400904 // ldr c4, [x8, #2]
	.inst 0xc2400d06 // ldr c6, [x8, #3]
	.inst 0xc2401111 // ldr c17, [x8, #4]
	.inst 0xc2401514 // ldr c20, [x8, #5]
	.inst 0xc2401919 // ldr c25, [x8, #6]
	.inst 0xc2401d1c // ldr c28, [x8, #7]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q12, =0x0
	ldr q15, =0x0
	/* Set up flags and system registers */
	ldr x8, =0x4000000
	msr SPSR_EL3, x8
	ldr x8, =initial_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884108 // msr CSP_EL0, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0x3c0000
	msr CPACR_EL1, x8
	ldr x8, =0x0
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x10
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601168 // ldr c8, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	mov x11, #0xf
	and x8, x8, x11
	cmp x8, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010b // ldr c11, [x8, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240050b // ldr c11, [x8, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240090b // ldr c11, [x8, #2]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc2400d0b // ldr c11, [x8, #3]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc240110b // ldr c11, [x8, #4]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc240150b // ldr c11, [x8, #5]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc240190b // ldr c11, [x8, #6]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	.inst 0xc2401d0b // ldr c11, [x8, #7]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc240210b // ldr c11, [x8, #8]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc240250b // ldr c11, [x8, #9]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x11, v12.d[0]
	cmp x8, x11
	b.ne comparison_fail
	ldr x8, =0x0
	mov x11, v12.d[1]
	cmp x8, x11
	b.ne comparison_fail
	ldr x8, =0x0
	mov x11, v15.d[0]
	cmp x8, x11
	b.ne comparison_fail
	ldr x8, =0x0
	mov x11, v15.d[1]
	cmp x8, x11
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298410b // mrs c11, CSP_EL0
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001410
	ldr x1, =check_data1
	ldr x2, =0x00001430
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000018c8
	ldr x1, =check_data2
	ldr x2, =0x000018d8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a20
	ldr x1, =check_data3
	ldr x2, =0x00001a22
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
	.zero 2592
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1488
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x30, 0x00
.data
check_data4:
	.byte 0xfd, 0x73, 0x7f, 0x78, 0xfe, 0xff, 0xdf, 0x48, 0xef, 0xb3, 0x2a, 0x6d, 0x9f, 0x4d, 0xe0, 0x8a
	.byte 0x21, 0xfe, 0x9f, 0x08, 0xfd, 0xcf, 0x28, 0x90, 0xd4, 0x64, 0x97, 0x42, 0x01, 0x84, 0xc4, 0xc2
	.byte 0xe6, 0xff, 0x9f, 0x08, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffc000400600060000000000010001
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x40220004000000000000e223
	/* C6 */
	.octa 0x4c000000548104710000000000001130
	/* C17 */
	.octa 0x40000000100700030000000000001000
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x80054007007fffffc0000004
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xffffc000400600060000000000010001
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x40220004000000000000e223
	/* C6 */
	.octa 0x4c000000548104710000000000001130
	/* C17 */
	.octa 0x40000000100700030000000000001000
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x80054007007fffffc0000004
	/* C29 */
	.octa 0x8005400700800000119fc000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000400c0a780000000000001a20
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc0000000400c0a780000000000001a20
final_PCC_value:
	.octa 0x20008000000700070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_SP_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001410
	.dword 0x0000000000001420
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000018c0
	.dword 0x00000000000018d0
	.dword 0x0000000000001a20
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
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400028
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
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
