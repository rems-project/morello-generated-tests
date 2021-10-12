.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c713ec // RRLEN-R.R-C Rd:12 Rn:31 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xf8589383 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:3 Rn:28 00:00 imm9:110001001 0:0 opc:01 111000:111000 size:11
	.inst 0xc8dffe8d // ldar:aarch64/instrs/memory/ordered Rt:13 Rn:20 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x38bfc312 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:18 Rn:24 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0xc2d8443d // CSEAL-C.C-C Cd:29 Cn:1 001:001 opc:10 0:0 Cm:24 11000010110:11000010110
	.inst 0xe235eba1 // ASTUR-V.RI-Q Rt:1 Rn:29 op2:10 imm9:101011110 V:1 op1:00 11100010:11100010
	.inst 0x3851d020 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:1 00:00 imm9:100011101 0:0 opc:01 111000:111000 size:00
	.inst 0xb8a580bd // swp:aarch64/instrs/memory/atomicops/swp Rt:29 Rn:5 100000:100000 Rs:5 1:1 R:0 A:1 111000:111000 size:10
	.inst 0xba0b02be // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:21 000000:000000 Rm:11 11010000:11010000 S:1 op:0 sf:1
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400605 // ldr c5, [x16, #1]
	.inst 0xc2400a14 // ldr c20, [x16, #2]
	.inst 0xc2400e18 // ldr c24, [x16, #3]
	.inst 0xc240121c // ldr c28, [x16, #4]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x3c0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x4
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011d0 // ldr c16, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240020e // ldr c14, [x16, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240060e // ldr c14, [x16, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400a0e // ldr c14, [x16, #2]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc2400e0e // ldr c14, [x16, #3]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc240120e // ldr c14, [x16, #4]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc240160e // ldr c14, [x16, #5]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc2401a0e // ldr c14, [x16, #6]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc2401e0e // ldr c14, [x16, #7]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc240220e // ldr c14, [x16, #8]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc240260e // ldr c14, [x16, #9]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc2402a0e // ldr c14, [x16, #10]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x14, v1.d[0]
	cmp x16, x14
	b.ne comparison_fail
	ldr x16, =0x0
	mov x14, v1.d[1]
	cmp x16, x14
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f90
	ldr x1, =check_data1
	ldr x2, =0x00001f98
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fbf
	ldr x1, =check_data2
	ldr x2, =0x00001fc0
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
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xec, 0x13, 0xc7, 0xc2, 0x83, 0x93, 0x58, 0xf8, 0x8d, 0xfe, 0xdf, 0xc8, 0x12, 0xc3, 0xbf, 0x38
	.byte 0x3d, 0x44, 0xd8, 0xc2, 0xa1, 0xeb, 0x35, 0xe2, 0x20, 0xd0, 0x51, 0x38, 0xbd, 0x80, 0xa5, 0xb8
	.byte 0xbe, 0x02, 0x0b, 0xba, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x400000000007000700000000000010a2
	/* C5 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x2000000400400040000000000000004
	/* C28 */
	.octa 0x1007
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400000000007000700000000000010a2
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x2000000400400040000000000000004
	/* C28 */
	.octa 0x1007
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc00000000007002000000000000affc0
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080000127c0070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000127c0070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x82600dd0 // ldr x16, [c14, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400dd0 // str x16, [c14, #0]
	ldr x16, =0x40400028
	mrs x14, ELR_EL1
	sub x16, x16, x14
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20e // cvtp c14, x16
	.inst 0xc2d041ce // scvalue c14, c14, x16
	.inst 0x826001d0 // ldr c16, [c14, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
