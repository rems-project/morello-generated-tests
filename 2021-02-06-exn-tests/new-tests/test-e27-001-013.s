.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8fd0021 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:1 00:00 opc:000 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x48fe7cfe // cash:aarch64/instrs/memory/atomicops/cas/single Rt:30 Rn:7 11111:11111 o0:0 Rs:30 1:1 L:1 0010001:0010001 size:01
	.inst 0x081fffe3 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:3 Rn:31 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0xb861033f // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:25 00:00 opc:000 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xe231dbe1 // ASTUR-V.RI-Q Rt:1 Rn:31 op2:10 imm9:100011101 V:1 op1:00 11100010:11100010
	.inst 0xc2c531fc // CVTP-R.C-C Rd:28 Cn:15 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2de2240 // SCBNDSE-C.CR-C Cd:0 Cn:18 000:000 opc:01 0:0 Rm:30 11000010110:11000010110
	.inst 0xd65f0000 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 3052
	.inst 0x901af1df // ADRDP-C.ID-C Rd:31 immhi:001101011110001110 P:0 10000:10000 immlo:00 op:1
	.inst 0xd4000001
	.zero 62444
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
	ldr x26, =initial_cap_values
	.inst 0xc2400341 // ldr c1, [x26, #0]
	.inst 0xc2400747 // ldr c7, [x26, #1]
	.inst 0xc2400b4f // ldr c15, [x26, #2]
	.inst 0xc2400f52 // ldr c18, [x26, #3]
	.inst 0xc2401359 // ldr c25, [x26, #4]
	.inst 0xc240175d // ldr c29, [x26, #5]
	.inst 0xc2401b5e // ldr c30, [x26, #6]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	ldr x26, =0x4000000
	msr SPSR_EL3, x26
	ldr x26, =initial_SP_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288411a // msr CSP_EL0, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0x3c0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x4
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260111a // ldr c26, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc28e403a // msr CELR_EL3, c26
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x8, #0xf
	and x26, x26, x8
	cmp x26, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400348 // ldr c8, [x26, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400748 // ldr c8, [x26, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400b48 // ldr c8, [x26, #2]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2400f48 // ldr c8, [x26, #3]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc2401348 // ldr c8, [x26, #4]
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	.inst 0xc2401748 // ldr c8, [x26, #5]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc2401b48 // ldr c8, [x26, #6]
	.inst 0xc2c8a781 // chkeq c28, c8
	b.ne comparison_fail
	.inst 0xc2401f48 // ldr c8, [x26, #7]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2402348 // ldr c8, [x26, #8]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x8, v1.d[0]
	cmp x26, x8
	b.ne comparison_fail
	ldr x26, =0x0
	mov x8, v1.d[1]
	cmp x26, x8
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_SP_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984108 // mrs c8, CSP_EL0
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a741 // chkeq c26, c8
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001081
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001140
	ldr x1, =check_data2
	ldr x2, =0x00001150
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400020
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400c0c
	ldr x1, =check_data4
	ldr x2, =0x40400c14
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
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x21, 0x00, 0xfd, 0xf8, 0xfe, 0x7c, 0xfe, 0x48, 0xe3, 0xff, 0x1f, 0x08, 0x3f, 0x03, 0x61, 0xb8
	.byte 0xe1, 0xdb, 0x31, 0xe2, 0xfc, 0x31, 0xc5, 0xc2, 0x40, 0x22, 0xde, 0xc2, 0x00, 0x00, 0x5f, 0xd6
.data
check_data4:
	.byte 0xdf, 0xf1, 0x1a, 0x90, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000100100060000000000001000
	/* C7 */
	.octa 0xc0000000540000000000000000001000
	/* C15 */
	.octa 0x200000000000000
	/* C18 */
	.octa 0x100070000000040400c0c
	/* C25 */
	.octa 0xc00000002000c0200000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xffff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x4c0c0c0c0000000040400c0c
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0xc0000000540000000000000000001000
	/* C15 */
	.octa 0x200000000000000
	/* C18 */
	.octa 0x100070000000040400c0c
	/* C25 */
	.octa 0xc00000002000c0200000000000001000
	/* C28 */
	.octa 0x200000000000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x40000000004300070000000000001080
initial_DDC_EL0_value:
	.octa 0x40000000600001a30000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x40000000004300070000000000001080
final_PCC_value:
	.octa 0x20008000000700060000000040400c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700060000000040400000
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
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001140
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x82600d1a // ldr x26, [c8, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400d1a // str x26, [c8, #0]
	ldr x26, =0x40400c14
	mrs x8, ELR_EL1
	sub x26, x26, x8
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b348 // cvtp c8, x26
	.inst 0xc2da4108 // scvalue c8, c8, x26
	.inst 0x8260011a // ldr c26, [c8, #0]
	.inst 0x021e035a // add c26, c26, #1920
	.inst 0xc2c21340 // br c26

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
