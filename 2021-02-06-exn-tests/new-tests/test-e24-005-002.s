.section text0, #alloc, #execinstr
test_start:
	.inst 0xc81e7c01 // stxr:aarch64/instrs/memory/exclusive/single Rt:1 Rn:0 Rt2:11111 o0:0 Rs:30 0:0 L:0 0010000:0010000 size:11
	.inst 0xc2c06834 // ORRFLGS-C.CR-C Cd:20 Cn:1 1010:1010 opc:01 Rm:0 11000010110:11000010110
	.inst 0xc2cfec3f // CSEL-C.CI-C Cd:31 Cn:1 11:11 cond:1110 Cm:15 11000010110:11000010110
	.inst 0x384ecd7d // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:29 Rn:11 11:11 imm9:011101100 0:0 opc:01 111000:111000 size:00
	.inst 0x3873201f // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:0 00:00 opc:010 0:0 Rs:19 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xd15e8a9f // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:20 imm12:011110100010 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x9105bb7f // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:27 imm12:000101101110 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x2972b812 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:18 Rn:0 Rt2:01110 imm7:1100101 L:1 1010010:1010010 opc:00
	.inst 0x78be2325 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:5 Rn:25 00:00 opc:010 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:01
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008eb // ldr c11, [x7, #2]
	.inst 0xc2400cf3 // ldr c19, [x7, #3]
	.inst 0xc24010f9 // ldr c25, [x7, #4]
	/* Set up flags and system registers */
	ldr x7, =0x4000000
	msr SPSR_EL3, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30d5d99f
	msr SCTLR_EL1, x7
	ldr x7, =0xc0000
	msr CPACR_EL1, x7
	ldr x7, =0x0
	msr S3_0_C1_C2_2, x7 // CCTLR_EL1
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601187 // ldr c7, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e4027 // msr CELR_EL3, c7
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000ec // ldr c12, [x7, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24004ec // ldr c12, [x7, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24008ec // ldr c12, [x7, #2]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc2400cec // ldr c12, [x7, #3]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc24010ec // ldr c12, [x7, #4]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc24014ec // ldr c12, [x7, #5]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc24018ec // ldr c12, [x7, #6]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2401cec // ldr c12, [x7, #7]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc24020ec // ldr c12, [x7, #8]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc24024ec // ldr c12, [x7, #9]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc24028ec // ldr c12, [x7, #10]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001014
	ldr x1, =check_data0
	ldr x2, =0x0000101c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001088
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
	.zero 8
.data
check_data2:
	.byte 0x01, 0x00, 0x00
.data
check_data3:
	.byte 0x01, 0x7c, 0x1e, 0xc8, 0x34, 0x68, 0xc0, 0xc2, 0x3f, 0xec, 0xcf, 0xc2, 0x7d, 0xcd, 0x4e, 0x38
	.byte 0x1f, 0x20, 0x73, 0x38, 0x9f, 0x8a, 0x5e, 0xd1, 0x7f, 0xbb, 0x05, 0x91, 0x12, 0xb8, 0x72, 0x29
	.byte 0x25, 0x23, 0xbe, 0x78, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001080
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C11 */
	.octa 0x80000000000600070000000000001f12
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0xc0000000000100050000000000001ffc
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001080
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x80000000000600070000000000001ffe
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x3fff800000000000000000000000
	/* C25 */
	.octa 0xc0000000000100050000000000001ffc
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080000005004f0000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000005004f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001080
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
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400028
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021e00e7 // add c7, c7, #1920
	.inst 0xc2c210e0 // br c7

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
