.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2e0997c // SUBS-R.CC-C Rd:28 Cn:11 100110:100110 Cm:0 11000010111:11000010111
	.inst 0x8265137f // ALDR-C.RI-C Ct:31 Rn:27 op:00 imm9:001010001 L:1 1000001001:1000001001
	.inst 0x911a9bb4 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:20 Rn:29 imm12:011010100110 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x2d038401 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:1 Rn:0 Rt2:00001 imm7:0000111 L:0 1011010:1011010 opc:00
	.inst 0xa259a5e1 // LDR-C.RIAW-C Ct:1 Rn:15 01:01 imm9:110011010 0:0 opc:01 10100010:10100010
	.zero 1004
	.inst 0x383e7167 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:7 Rn:11 00:00 opc:111 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x421f7c3f // ASTLR-C.R-C Ct:31 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xf83710d1 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:17 Rn:6 00:00 opc:001 0:0 Rs:23 1:1 R:0 A:0 111000:111000 size:11
	.inst 0x38cd03bf // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:29 00:00 imm9:011010000 0:0 opc:11 111000:111000 size:00
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b26 // ldr c6, [x25, #2]
	.inst 0xc2400f2b // ldr c11, [x25, #3]
	.inst 0xc240132f // ldr c15, [x25, #4]
	.inst 0xc2401737 // ldr c23, [x25, #5]
	.inst 0xc2401b3b // ldr c27, [x25, #6]
	.inst 0xc2401f3d // ldr c29, [x25, #7]
	.inst 0xc240233e // ldr c30, [x25, #8]
	/* Vector registers */
	mrs x25, cptr_el3
	bfc x25, #10, #1
	msr cptr_el3, x25
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	ldr x25, =0x4000000
	msr SPSR_EL3, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0x3c0000
	msr CPACR_EL1, x25
	ldr x25, =0x0
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0x0
	msr S3_3_C1_C2_2, x25 // CCTLR_EL0
	ldr x25, =initial_DDC_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884139 // msr DDC_EL0, c25
	ldr x25, =initial_DDC_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4139 // msr DDC_EL1, c25
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82601119 // ldr c25, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	mov x8, #0xf
	and x25, x25, x8
	cmp x25, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400328 // ldr c8, [x25, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400728 // ldr c8, [x25, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400b28 // ldr c8, [x25, #2]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc2400f28 // ldr c8, [x25, #3]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2401328 // ldr c8, [x25, #4]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc2401728 // ldr c8, [x25, #5]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc2401b28 // ldr c8, [x25, #6]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc2401f28 // ldr c8, [x25, #7]
	.inst 0xc2c8a681 // chkeq c20, c8
	b.ne comparison_fail
	.inst 0xc2402328 // ldr c8, [x25, #8]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2402728 // ldr c8, [x25, #9]
	.inst 0xc2c8a761 // chkeq c27, c8
	b.ne comparison_fail
	.inst 0xc2402b28 // ldr c8, [x25, #10]
	.inst 0xc2c8a781 // chkeq c28, c8
	b.ne comparison_fail
	.inst 0xc2402f28 // ldr c8, [x25, #11]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2403328 // ldr c8, [x25, #12]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x8, v1.d[0]
	cmp x25, x8
	b.ne comparison_fail
	ldr x25, =0x0
	mov x8, v1.d[1]
	cmp x25, x8
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x8, 0x80
	orr x25, x25, x8
	ldr x8, =0x920000a9
	cmp x8, x25
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
	ldr x0, =0x0000120c
	ldr x1, =check_data1
	ldr x2, =0x00001214
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001910
	ldr x1, =check_data2
	ldr x2, =0x00001920
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001cfc
	ldr x1, =check_data3
	ldr x2, =0x00001cfd
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
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
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x7c, 0x99, 0xe0, 0xc2, 0x7f, 0x13, 0x65, 0x82, 0xb4, 0x9b, 0x1a, 0x91, 0x01, 0x84, 0x03, 0x2d
	.byte 0xe1, 0xa5, 0x59, 0xa2
.data
check_data5:
	.byte 0x67, 0x71, 0x3e, 0x38, 0x3f, 0x7c, 0x1f, 0x42, 0xd1, 0x10, 0x37, 0xf8, 0xbf, 0x03, 0xcd, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000600a000c00000000000011f0
	/* C1 */
	.octa 0x40000000400000020000000000001000
	/* C6 */
	.octa 0x1008
	/* C11 */
	.octa 0x1213
	/* C15 */
	.octa 0x800000000000000000000000
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x1400
	/* C29 */
	.octa 0x1c2c
	/* C30 */
	.octa 0x80
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000000600a000c00000000000011f0
	/* C1 */
	.octa 0x40000000400000020000000000001000
	/* C6 */
	.octa 0x1008
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x1213
	/* C15 */
	.octa 0x800000000000000000000000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x22d2
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x1400
	/* C28 */
	.octa 0x3
	/* C29 */
	.octa 0x1c2c
	/* C30 */
	.octa 0x80
initial_DDC_EL0_value:
	.octa 0x90100000401000810000000000000000
initial_DDC_EL1_value:
	.octa 0xc0000000400c054100ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004418c4190000000040400000
final_PCC_value:
	.octa 0x200080004418c4190000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000003100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001910
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001910
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001200
	.dword 0x0000000000001210
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
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600d19 // ldr x25, [c8, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d19 // str x25, [c8, #0]
	ldr x25, =0x40400414
	mrs x8, ELR_EL1
	sub x25, x25, x8
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b328 // cvtp c8, x25
	.inst 0xc2d94108 // scvalue c8, c8, x25
	.inst 0x82600119 // ldr c25, [c8, #0]
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
