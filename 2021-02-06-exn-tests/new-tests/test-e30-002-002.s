.section text0, #alloc, #execinstr
test_start:
	.inst 0x6d9fd412 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:18 Rn:0 Rt2:10101 imm7:0111111 L:0 1011011:1011011 opc:01
	.inst 0xfa5cab01 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0001 0:0 Rn:24 10:10 cond:1010 imm5:11100 111010010:111010010 op:1 sf:1
	.inst 0xe2b2860a // ALDUR-V.RI-S Rt:10 Rn:16 op2:01 imm9:100101000 V:1 op1:10 11100010:11100010
	.inst 0x785a77dd // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:30 01:01 imm9:110100111 0:0 opc:01 111000:111000 size:01
	.inst 0x38a0701d // lduminb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:0 00:00 opc:111 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x3868201f // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:0 00:00 opc:010 0:0 Rs:8 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x382903ff // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:000 o3:0 Rs:9 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x485f7c0d // ldxrh:aarch64/instrs/memory/exclusive/single Rt:13 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x1acc2021 // lslv:aarch64/instrs/integer/shift/variable Rd:1 Rn:1 op2:00 0010:0010 Rm:12 0011010110:0011010110 sf:0
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a8 // ldr c8, [x5, #1]
	.inst 0xc24008a9 // ldr c9, [x5, #2]
	.inst 0xc2400cb0 // ldr c16, [x5, #3]
	.inst 0xc24010be // ldr c30, [x5, #4]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q18, =0x0
	ldr q21, =0x0
	/* Set up flags and system registers */
	ldr x5, =0x80000000
	msr SPSR_EL3, x5
	ldr x5, =initial_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884105 // msr CSP_EL0, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0x3c0000
	msr CPACR_EL1, x5
	ldr x5, =0x0
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x0
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82601285 // ldr c5, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x20, #0xf
	and x5, x5, x20
	cmp x5, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b4 // ldr c20, [x5, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24004b4 // ldr c20, [x5, #1]
	.inst 0xc2d4a501 // chkeq c8, c20
	b.ne comparison_fail
	.inst 0xc24008b4 // ldr c20, [x5, #2]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2400cb4 // ldr c20, [x5, #3]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc24010b4 // ldr c20, [x5, #4]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc24014b4 // ldr c20, [x5, #5]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc24018b4 // ldr c20, [x5, #6]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x20, v10.d[0]
	cmp x5, x20
	b.ne comparison_fail
	ldr x5, =0x0
	mov x20, v10.d[1]
	cmp x5, x20
	b.ne comparison_fail
	ldr x5, =0x0
	mov x20, v18.d[0]
	cmp x5, x20
	b.ne comparison_fail
	ldr x5, =0x0
	mov x20, v18.d[1]
	cmp x5, x20
	b.ne comparison_fail
	ldr x5, =0x0
	mov x20, v21.d[0]
	cmp x5, x20
	b.ne comparison_fail
	ldr x5, =0x0
	mov x20, v21.d[1]
	cmp x5, x20
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984114 // mrs c20, CSP_EL0
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a4a1 // chkeq c5, c20
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
	ldr x0, =0x00001780
	ldr x1, =check_data1
	ldr x2, =0x00001790
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x4040a018
	ldr x1, =check_data3
	ldr x2, =0x4040a01c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040fffc
	ldr x1, =check_data4
	ldr x2, =0x4040fffe
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
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.zero 1
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x12, 0xd4, 0x9f, 0x6d, 0x01, 0xab, 0x5c, 0xfa, 0x0a, 0x86, 0xb2, 0xe2, 0xdd, 0x77, 0x5a, 0x78
	.byte 0x1d, 0x70, 0xa0, 0x38, 0x1f, 0x20, 0x68, 0x38, 0xff, 0x03, 0x29, 0x38, 0x0d, 0x7c, 0x5f, 0x48
	.byte 0x21, 0x20, 0xcc, 0x1a, 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1588
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x800000002007a007000000004040a0f0
	/* C30 */
	.octa 0x4040fffc
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1780
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x800000002007a007000000004040a0f0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x4040ffa3
initial_SP_EL0_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc00000000003000700ffe00000040001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x20008000000601070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000601070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001780
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400028
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
