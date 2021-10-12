.section text0, #alloc, #execinstr
test_start:
	.inst 0x1aca2515 // lsrv:aarch64/instrs/integer/shift/variable Rd:21 Rn:8 op2:01 0010:0010 Rm:10 0011010110:0011010110 sf:0
	.inst 0xa2b87f97 // CAS-C.R-C Ct:23 Rn:28 11111:11111 R:0 Cs:24 1:1 L:0 1:1 10100010:10100010
	.inst 0x90edffff // ADRP-C.IP-C Rd:31 immhi:110110111111111111 P:1 10000:10000 immlo:00 op:1
	.inst 0xc2c23062 // BLRS-C-C 00010:00010 Cn:3 100:100 opc:01 11000010110000100:11000010110000100
	.zero 8
	.inst 0xd0d0a50d // ADRP-C.IP-C Rd:13 immhi:101000010100101000 P:1 10000:10000 immlo:10 op:1
	.inst 0x69f0bd5f // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:31 Rn:10 Rt2:01111 imm7:1100001 L:1 1010011:1010011 opc:01
	.inst 0xba1f03be // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:29 000000:000000 Rm:31 11010000:11010000 S:1 op:0 sf:1
	.inst 0xd4000001
	.zero 92
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 884
	.inst 0xc2c25220 // RET-C-C 00000:00000 Cn:17 100:100 opc:10 11000010110000100:11000010110000100
	.zero 48140
	.inst 0xe293b6fe // ALDUR-R.RI-32 Rt:30 Rn:23 op2:01 imm9:100111011 V:0 op1:10 11100010:11100010
	.zero 16364
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c3 // ldr c3, [x6, #0]
	.inst 0xc24004ca // ldr c10, [x6, #1]
	.inst 0xc24008d1 // ldr c17, [x6, #2]
	.inst 0xc2400cd7 // ldr c23, [x6, #3]
	.inst 0xc24010d8 // ldr c24, [x6, #4]
	.inst 0xc24014dc // ldr c28, [x6, #5]
	/* Set up flags and system registers */
	ldr x6, =0x0
	msr SPSR_EL3, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x8c
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012c6 // ldr c6, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d6 // ldr c22, [x6, #0]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc24004d6 // ldr c22, [x6, #1]
	.inst 0xc2d6a541 // chkeq c10, c22
	b.ne comparison_fail
	.inst 0xc24008d6 // ldr c22, [x6, #2]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2400cd6 // ldr c22, [x6, #3]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc24010d6 // ldr c22, [x6, #4]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc24014d6 // ldr c22, [x6, #5]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc24018d6 // ldr c22, [x6, #6]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2401cd6 // ldr c22, [x6, #7]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x22, 0x80
	orr x6, x6, x22
	ldr x22, =0x920000a1
	cmp x22, x6
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
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400018
	ldr x1, =check_data2
	ldr x2, =0x40400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400084
	ldr x1, =check_data3
	ldr x2, =0x4040008c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400404
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040c010
	ldr x1, =check_data5
	ldr x2, =0x4040c014
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
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 4080
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x15, 0x25, 0xca, 0x1a, 0x97, 0x7f, 0xb8, 0xa2, 0xff, 0xff, 0xed, 0x90, 0x62, 0x30, 0xc2, 0xc2
.data
check_data2:
	.byte 0x0d, 0xa5, 0xd0, 0xd0, 0x5f, 0xbd, 0xf0, 0x69, 0xbe, 0x03, 0x1f, 0xba, 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0x20, 0x52, 0xc2, 0xc2
.data
check_data5:
	.byte 0xfe, 0xb6, 0x93, 0xe2

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x2000800080030007000000004040c010
	/* C10 */
	.octa 0x80000000400100020000000040400100
	/* C17 */
	.octa 0x20008000950020000000000040400019
	/* C23 */
	.octa 0x8000400000070007ff9fc00000000400
	/* C24 */
	.octa 0x3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d
	/* C28 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C3 */
	.octa 0x2000800080030007000000004040c010
	/* C10 */
	.octa 0x80000000400100020000000040400084
	/* C13 */
	.octa 0x2000800015002000ffffffffe18a2000
	/* C15 */
	.octa 0xffffffffc2c2c2c2
	/* C17 */
	.octa 0x20008000950020000000000040400019
	/* C23 */
	.octa 0x8000400000070007ff9fc00000000400
	/* C24 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C28 */
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xd8100000000300070000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000f4020000000040400000
final_PCC_value:
	.octa 0x20008000150020000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080005001d0090000000040400000
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
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x82600ec6 // ldr x6, [c22, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ec6 // str x6, [c22, #0]
	ldr x6, =0x40400028
	mrs x22, ELR_EL1
	sub x6, x6, x22
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d6 // cvtp c22, x6
	.inst 0xc2c642d6 // scvalue c22, c22, x6
	.inst 0x826002c6 // ldr c6, [c22, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
