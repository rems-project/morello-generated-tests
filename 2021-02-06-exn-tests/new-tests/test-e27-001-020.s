.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8fd0021 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:1 00:00 opc:000 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x48fe7cfe // cash:aarch64/instrs/memory/atomicops/cas/single Rt:30 Rn:7 11111:11111 o0:0 Rs:30 1:1 L:1 0010001:0010001 size:01
	.inst 0x081fffe3 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:3 Rn:31 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0xb861033f // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:25 00:00 opc:000 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xe231dbe1 // ASTUR-V.RI-Q Rt:1 Rn:31 op2:10 imm9:100011101 V:1 op1:00 11100010:11100010
	.zero 49140
	.inst 0x901af1df // ADRDP-C.ID-C Rd:31 immhi:001101011110001110 P:0 10000:10000 immlo:00 op:1
	.inst 0xd4000001
	.zero 1008
	.inst 0xc2c531fc // CVTP-R.C-C Rd:28 Cn:15 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2de2240 // SCBNDSE-C.CR-C Cd:0 Cn:18 000:000 opc:01 0:0 Rm:30 11000010110:11000010110
	.inst 0xd65f0000 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 15348
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
	ldr x17, =initial_cap_values
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400627 // ldr c7, [x17, #1]
	.inst 0xc2400a2f // ldr c15, [x17, #2]
	.inst 0xc2400e32 // ldr c18, [x17, #3]
	.inst 0xc2401239 // ldr c25, [x17, #4]
	.inst 0xc240163d // ldr c29, [x17, #5]
	.inst 0xc2401a3e // ldr c30, [x17, #6]
	/* Set up flags and system registers */
	ldr x17, =0x4000000
	msr SPSR_EL3, x17
	ldr x17, =initial_SP_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884111 // msr CSP_EL0, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30d5d99f
	msr SCTLR_EL1, x17
	ldr x17, =0x1c0000
	msr CPACR_EL1, x17
	ldr x17, =0x8
	msr S3_0_C1_C2_2, x17 // CCTLR_EL1
	ldr x17, =initial_DDC_EL1_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc28c4131 // msr DDC_EL1, c17
	ldr x17, =0x80000000
	msr HCR_EL2, x17
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011d1 // ldr c17, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e4031 // msr CELR_EL3, c17
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x14, #0xf
	and x17, x17, x14
	cmp x17, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc240022e // ldr c14, [x17, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240062e // ldr c14, [x17, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400a2e // ldr c14, [x17, #2]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc2400e2e // ldr c14, [x17, #3]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc240122e // ldr c14, [x17, #4]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc240162e // ldr c14, [x17, #5]
	.inst 0xc2cea721 // chkeq c25, c14
	b.ne comparison_fail
	.inst 0xc2401a2e // ldr c14, [x17, #6]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc2401e2e // ldr c14, [x17, #7]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc240222e // ldr c14, [x17, #8]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check system registers */
	ldr x17, =final_SP_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc298410e // mrs c14, CSP_EL0
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	ldr x17, =final_PCC_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	ldr x17, =esr_el1_dump_address
	ldr x17, [x17]
	ldr x14, =0x1fe00000
	cmp x14, x17
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
	ldr x0, =0x00001700
	ldr x1, =check_data1
	ldr x2, =0x00001702
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x4040c008
	ldr x1, =check_data3
	ldr x2, =0x4040c010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040c400
	ldr x1, =check_data4
	ldr x2, =0x4040c40c
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
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
	.byte 0xc0, 0xff, 0x7f, 0xff, 0x80, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x80, 0xff, 0x00, 0x80, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x21, 0x00, 0xfd, 0xf8, 0xfe, 0x7c, 0xfe, 0x48, 0xe3, 0xff, 0x1f, 0x08, 0x3f, 0x03, 0x61, 0xb8
	.byte 0xe1, 0xdb, 0x31, 0xe2
.data
check_data3:
	.byte 0xdf, 0xf1, 0x1a, 0x90, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.byte 0xfc, 0x31, 0xc5, 0xc2, 0x40, 0x22, 0xde, 0xc2, 0x00, 0x00, 0x5f, 0xd6

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000000700060000000000001000
	/* C7 */
	.octa 0xc0000000000100050000000000001700
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x300070000000000000000
	/* C25 */
	.octa 0xc0000000400400080000000000001004
	/* C29 */
	.octa 0x1807fc000000040
	/* C30 */
	.octa 0xffff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400000000000000000000000
	/* C1 */
	.octa 0xff000080ff7fffc0
	/* C7 */
	.octa 0xc0000000000100050000000000001700
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x300070000000000000000
	/* C25 */
	.octa 0xc0000000400400080000000000001004
	/* C28 */
	.octa 0xffffffffbfbf3ff8
	/* C29 */
	.octa 0x1807fc000000040
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x40000000000000000000000000001000
initial_DDC_EL1_value:
	.octa 0x40002000007fffffd0000000
initial_VBAR_EL1_value:
	.octa 0x200080004600c008000000004040c001
final_SP_EL0_value:
	.octa 0x40000000000000000000000000001000
final_PCC_value:
	.octa 0x200080004600c008000000004040c010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000780000000000040400000
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
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword initial_SP_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
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
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x02000231 // add c17, c17, #0
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x02020231 // add c17, c17, #128
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x02040231 // add c17, c17, #256
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x02060231 // add c17, c17, #384
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x02080231 // add c17, c17, #512
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x020a0231 // add c17, c17, #640
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x020c0231 // add c17, c17, #768
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x020e0231 // add c17, c17, #896
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x02100231 // add c17, c17, #1024
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x02120231 // add c17, c17, #1152
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x02140231 // add c17, c17, #1280
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x02160231 // add c17, c17, #1408
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x02180231 // add c17, c17, #1536
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x021a0231 // add c17, c17, #1664
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x021c0231 // add c17, c17, #1792
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x82600dd1 // ldr x17, [c14, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400dd1 // str x17, [c14, #0]
	ldr x17, =0x4040c010
	mrs x14, ELR_EL1
	sub x17, x17, x14
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b22e // cvtp c14, x17
	.inst 0xc2d141ce // scvalue c14, c14, x17
	.inst 0x826001d1 // ldr c17, [c14, #0]
	.inst 0x021e0231 // add c17, c17, #1920
	.inst 0xc2c21220 // br c17

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
