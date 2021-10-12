.section text0, #alloc, #execinstr
test_start:
	.inst 0x1aca2515 // lsrv:aarch64/instrs/integer/shift/variable Rd:21 Rn:8 op2:01 0010:0010 Rm:10 0011010110:0011010110 sf:0
	.inst 0xa2b87f97 // CAS-C.R-C Ct:23 Rn:28 11111:11111 R:0 Cs:24 1:1 L:0 1:1 10100010:10100010
	.inst 0x90edffff // ADRP-C.IP-C Rd:31 immhi:110110111111111111 P:1 10000:10000 immlo:00 op:1
	.inst 0xc2c23062 // BLRS-C-C 00010:00010 Cn:3 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xe293b6fe // ALDUR-R.RI-32 Rt:30 Rn:23 op2:01 imm9:100111011 V:0 op1:10 11100010:11100010
	.zero 4
	.inst 0xd0d0a50d // ADRP-C.IP-C Rd:13 immhi:101000010100101000 P:1 10000:10000 immlo:10 op:1
	.inst 0x69f0bd5f // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:31 Rn:10 Rt2:01111 imm7:1100001 L:1 1010011:1010011 opc:01
	.inst 0xba1f03be // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:29 000000:000000 Rm:31 11010000:11010000 S:1 op:0 sf:1
	.inst 0xd4000001
	.zero 984
	.inst 0xc2c25220 // RET-C-C 00000:00000 Cn:17 100:100 opc:10 11000010110000100:11000010110000100
	.zero 64508
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
	ldr x1, =initial_cap_values
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc240042a // ldr c10, [x1, #1]
	.inst 0xc2400831 // ldr c17, [x1, #2]
	.inst 0xc2400c37 // ldr c23, [x1, #3]
	.inst 0xc2401038 // ldr c24, [x1, #4]
	.inst 0xc240143c // ldr c28, [x1, #5]
	/* Set up flags and system registers */
	ldr x1, =0x0
	msr SPSR_EL3, x1
	ldr x1, =0x200
	msr CPTR_EL3, x1
	ldr x1, =0x30d5d99f
	msr SCTLR_EL1, x1
	ldr x1, =0xc0000
	msr CPACR_EL1, x1
	ldr x1, =0x4
	msr S3_0_C1_C2_2, x1 // CCTLR_EL1
	ldr x1, =0x8c
	msr S3_3_C1_C2_2, x1 // CCTLR_EL0
	ldr x1, =initial_DDC_EL0_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc2884121 // msr DDC_EL0, c1
	ldr x1, =initial_DDC_EL1_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc28c4121 // msr DDC_EL1, c1
	ldr x1, =0x80000000
	msr HCR_EL2, x1
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601241 // ldr c1, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc28e4021 // msr CELR_EL3, c1
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr DDC_EL3, c1
	ldr x1, =0x30851035
	msr SCTLR_EL3, x1
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x1, =final_cap_values
	.inst 0xc2400032 // ldr c18, [x1, #0]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2400432 // ldr c18, [x1, #1]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2400832 // ldr c18, [x1, #2]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2400c32 // ldr c18, [x1, #3]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401032 // ldr c18, [x1, #4]
	.inst 0xc2d2a621 // chkeq c17, c18
	b.ne comparison_fail
	.inst 0xc2401432 // ldr c18, [x1, #5]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc2401832 // ldr c18, [x1, #6]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc2401c32 // ldr c18, [x1, #7]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	/* Check system registers */
	ldr x1, =final_PCC_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	ldr x1, =esr_el1_dump_address
	ldr x1, [x1]
	mov x18, 0xc1
	orr x1, x1, x18
	ldr x18, =0x920000eb
	cmp x18, x1
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
	ldr x2, =0x40400014
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
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400404
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
	ldr x1, =0x30850030
	msr SCTLR_EL3, x1
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr DDC_EL3, c1
	ldr x1, =0x30850030
	msr SCTLR_EL3, x1
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
	.byte 0xfe, 0xb6, 0x93, 0xe2
.data
check_data2:
	.byte 0x0d, 0xa5, 0xd0, 0xd0, 0x5f, 0xbd, 0xf0, 0x69, 0xbe, 0x03, 0x1f, 0xba, 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.byte 0x20, 0x52, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x20008000800100050000000040400010
	/* C10 */
	.octa 0x107c
	/* C17 */
	.octa 0x20008000000100050000000040400018
	/* C23 */
	.octa 0x800040004000000009ffffffffffe0c8
	/* C24 */
	.octa 0x3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d
	/* C28 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C3 */
	.octa 0x20008000800100050000000040400010
	/* C10 */
	.octa 0x1000
	/* C13 */
	.octa 0xffffffffe18a2000
	/* C15 */
	.octa 0xffffffffc2c2c2c2
	/* C17 */
	.octa 0x20008000000100050000000040400018
	/* C23 */
	.octa 0x800040004000000009ffffffffffe0c8
	/* C24 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C28 */
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xd8100000000600030000000000000001
initial_DDC_EL1_value:
	.octa 0x800000003e03000700ffe00540200001
initial_VBAR_EL1_value:
	.octa 0x20008000500000010000000040400000
final_PCC_value:
	.octa 0x20008000000100050000000040400028
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
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
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
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x02000021 // add c1, c1, #0
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x02020021 // add c1, c1, #128
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x02040021 // add c1, c1, #256
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x02060021 // add c1, c1, #384
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x02080021 // add c1, c1, #512
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x020a0021 // add c1, c1, #640
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x020c0021 // add c1, c1, #768
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x020e0021 // add c1, c1, #896
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x02100021 // add c1, c1, #1024
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x02120021 // add c1, c1, #1152
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x02140021 // add c1, c1, #1280
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x02160021 // add c1, c1, #1408
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x02180021 // add c1, c1, #1536
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x021a0021 // add c1, c1, #1664
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x021c0021 // add c1, c1, #1792
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600e41 // ldr x1, [c18, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400e41 // str x1, [c18, #0]
	ldr x1, =0x40400028
	mrs x18, ELR_EL1
	sub x1, x1, x18
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b032 // cvtp c18, x1
	.inst 0xc2c14252 // scvalue c18, c18, x1
	.inst 0x82600241 // ldr c1, [c18, #0]
	.inst 0x021e0021 // add c1, c1, #1920
	.inst 0xc2c21020 // br c1

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
