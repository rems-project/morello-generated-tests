.section text0, #alloc, #execinstr
test_start:
	.inst 0xe200a7a1 // ALDURB-R.RI-32 Rt:1 Rn:29 op2:01 imm9:000001010 V:0 op1:00 11100010:11100010
	.inst 0x6a4046aa // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:10 Rn:21 imm6:010001 Rm:0 N:0 shift:01 01010:01010 opc:11 sf:0
	.inst 0xd82c30c0 // prfm_lit:aarch64/instrs/memory/literal/general Rt:0 imm19:0010110000110000110 011000:011000 opc:11
	.inst 0x9ac02280 // lslv:aarch64/instrs/integer/shift/variable Rd:0 Rn:20 op2:00 0010:0010 Rm:0 0011010110:0011010110 sf:1
	.inst 0xf0d4a3e1 // ADRP-C.IP-C Rd:1 immhi:101010010100011111 P:1 10000:10000 immlo:11 op:1
	.inst 0x7a53c160 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:11 00:00 cond:1100 Rm:19 111010010:111010010 op:1 sf:0
	.inst 0xbd5ceb00 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:0 Rn:24 imm12:011100111010 opc:01 111101:111101 size:10
	.inst 0x227f60ff // LDXP-C.R-C Ct:31 Rn:7 Ct2:11000 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xf82f511f // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:8 00:00 opc:101 o3:0 Rs:15 1:1 R:0 A:0 00:00 V:0 111:111 size:11
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a7 // ldr c7, [x13, #1]
	.inst 0xc24009a8 // ldr c8, [x13, #2]
	.inst 0xc2400daf // ldr c15, [x13, #3]
	.inst 0xc24011b5 // ldr c21, [x13, #4]
	.inst 0xc24015b8 // ldr c24, [x13, #5]
	.inst 0xc24019bd // ldr c29, [x13, #6]
	/* Set up flags and system registers */
	ldr x13, =0x4000000
	msr SPSR_EL3, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0x3c0000
	msr CPACR_EL1, x13
	ldr x13, =0x0
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =0x0
	msr S3_3_C1_C2_2, x13 // CCTLR_EL0
	ldr x13, =initial_DDC_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc288412d // msr DDC_EL0, c13
	ldr x13, =0x80000000
	msr HCR_EL2, x13
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011cd // ldr c13, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e402d // msr CELR_EL3, c13
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001ae // ldr c14, [x13, #0]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24005ae // ldr c14, [x13, #1]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc24009ae // ldr c14, [x13, #2]
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	.inst 0xc2400dae // ldr c14, [x13, #3]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc24011ae // ldr c14, [x13, #4]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc24015ae // ldr c14, [x13, #5]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc24019ae // ldr c14, [x13, #6]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc2401dae // ldr c14, [x13, #7]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x14, v0.d[0]
	cmp x13, x14
	b.ne comparison_fail
	ldr x13, =0x0
	mov x14, v0.d[1]
	cmp x13, x14
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000014e8
	ldr x1, =check_data1
	ldr x2, =0x000014ec
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bfe
	ldr x1, =check_data2
	ldr x2, =0x00001bff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
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
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 4048
	.byte 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xa1, 0xa7, 0x00, 0xe2, 0xaa, 0x46, 0x40, 0x6a, 0xc0, 0x30, 0x2c, 0xd8, 0x80, 0x22, 0xc0, 0x9a
	.byte 0xe1, 0xa3, 0xd4, 0xf0, 0x60, 0xc1, 0x53, 0x7a, 0x00, 0xeb, 0x5c, 0xbd, 0xff, 0x60, 0x7f, 0x22
	.byte 0x1f, 0x51, 0x2f, 0xf8, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfffe0000
	/* C7 */
	.octa 0x90000000000100050000000000001000
	/* C8 */
	.octa 0xc0000000000100050000000000001ff0
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0xffffffff
	/* C24 */
	.octa 0x8000000000070004fffffffffffff800
	/* C29 */
	.octa 0x1bf4
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x2000800000004008ffffffffe987f000
	/* C7 */
	.octa 0x90000000000100050000000000001000
	/* C8 */
	.octa 0xc0000000000100050000000000001ff0
	/* C10 */
	.octa 0x7fff
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0xffffffff
	/* C24 */
	.octa 0x101800000000000000000000000
	/* C29 */
	.octa 0x1bf4
initial_DDC_EL0_value:
	.octa 0x80000000000080080000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000040080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0
final_tag_unset_locations:
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
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40400028
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021e01ad // add c13, c13, #1920
	.inst 0xc2c211a0 // br c13

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
