.section text0, #alloc, #execinstr
test_start:
	.inst 0x1aca2515 // lsrv:aarch64/instrs/integer/shift/variable Rd:21 Rn:8 op2:01 0010:0010 Rm:10 0011010110:0011010110 sf:0
	.inst 0xa2b87f97 // CAS-C.R-C Ct:23 Rn:28 11111:11111 R:0 Cs:24 1:1 L:0 1:1 10100010:10100010
	.inst 0x90edffff // ADRP-C.IP-C Rd:31 immhi:110110111111111111 P:1 10000:10000 immlo:00 op:1
	.inst 0xc2c23062 // BLRS-C-C 00010:00010 Cn:3 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xe293b6fe // ALDUR-R.RI-32 Rt:30 Rn:23 op2:01 imm9:100111011 V:0 op1:10 11100010:11100010
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 2020
	.inst 0xd0d0a50d // ADRP-C.IP-C Rd:13 immhi:101000010100101000 P:1 10000:10000 immlo:10 op:1
	.inst 0x69f0bd5f // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:31 Rn:10 Rt2:01111 imm7:1100001 L:1 1010011:1010011 opc:01
	.inst 0xba1f03be // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:29 000000:000000 Rm:31 11010000:11010000 S:1 op:0 sf:1
	.inst 0xd4000001
	.zero 33776
	.inst 0xc2c25220 // RET-C-C 00000:00000 Cn:17 100:100 opc:10 11000010110000100:11000010110000100
	.zero 29692
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
	ldr x4, =initial_cap_values
	.inst 0xc2400083 // ldr c3, [x4, #0]
	.inst 0xc240048a // ldr c10, [x4, #1]
	.inst 0xc2400891 // ldr c17, [x4, #2]
	.inst 0xc2400c97 // ldr c23, [x4, #3]
	.inst 0xc2401098 // ldr c24, [x4, #4]
	.inst 0xc240149c // ldr c28, [x4, #5]
	/* Set up flags and system registers */
	ldr x4, =0x0
	msr SPSR_EL3, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0xc0000
	msr CPACR_EL1, x4
	ldr x4, =0x0
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =0x8c
	msr S3_3_C1_C2_2, x4 // CCTLR_EL0
	ldr x4, =initial_DDC_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884124 // msr DDC_EL0, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601124 // ldr c4, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e4024 // msr CELR_EL3, c4
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400089 // ldr c9, [x4, #0]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2400489 // ldr c9, [x4, #1]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2400889 // ldr c9, [x4, #2]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc2400c89 // ldr c9, [x4, #3]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401089 // ldr c9, [x4, #4]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2401489 // ldr c9, [x4, #5]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2401889 // ldr c9, [x4, #6]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc2401c89 // ldr c9, [x4, #7]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	ldr x4, =esr_el1_dump_address
	ldr x4, [x4]
	mov x9, 0x80
	orr x4, x4, x9
	ldr x9, =0x920000a1
	cmp x9, x4
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
	ldr x2, =0x4040001c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400800
	ldr x1, =check_data2
	ldr x2, =0x40400810
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40408c00
	ldr x1, =check_data3
	ldr x2, =0x40408c04
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
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
	.byte 0xfe, 0xb6, 0x93, 0xe2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
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
	.octa 0x20008000800100070000000040400011
	/* C10 */
	.octa 0x80000000000100050000000040400090
	/* C17 */
	.octa 0x20008000800300070000000040400801
	/* C23 */
	.octa 0x4000000000000000000000003fc7
	/* C24 */
	.octa 0x3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d
	/* C28 */
	.octa 0xf00
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C3 */
	.octa 0x20008000800100070000000040400011
	/* C10 */
	.octa 0x80000000000100050000000040400014
	/* C13 */
	.octa 0x2000800000030007ffffffffe18a2000
	/* C15 */
	.octa 0xffffffffc2c2c2c2
	/* C17 */
	.octa 0x20008000800300070000000040400801
	/* C23 */
	.octa 0x4000000000000000000000003fc7
	/* C24 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C28 */
	.octa 0xf00
initial_DDC_EL0_value:
	.octa 0xd81000001007010700ffffffffffe000
initial_VBAR_EL1_value:
	.octa 0x20008000500088010000000040408800
final_PCC_value:
	.octa 0x20008000000300070000000040400810
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000501000000000000040400000
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600d24 // ldr x4, [c9, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d24 // str x4, [c9, #0]
	ldr x4, =0x40400810
	mrs x9, ELR_EL1
	sub x4, x4, x9
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b089 // cvtp c9, x4
	.inst 0xc2c44129 // scvalue c9, c9, x4
	.inst 0x82600124 // ldr c4, [c9, #0]
	.inst 0x021e0084 // add c4, c4, #1920
	.inst 0xc2c21080 // br c4

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0