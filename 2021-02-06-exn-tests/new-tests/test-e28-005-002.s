.section text0, #alloc, #execinstr
test_start:
	.inst 0x38cde4be // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:5 01:01 imm9:011011110 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c73301 // RRMASK-R.R-C Rd:1 Rn:24 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xe2aab7bf // ALDUR-V.RI-S Rt:31 Rn:29 op2:01 imm9:010101011 V:1 op1:10 11100010:11100010
	.inst 0x78bc03dd // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:30 00:00 opc:000 0:0 Rs:28 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x78138839 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:25 Rn:1 10:10 imm9:100111000 0:0 opc:00 111000:111000 size:01
	.zero 21484
	.inst 0x785ed3fe // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:31 00:00 imm9:111101101 0:0 opc:01 111000:111000 size:01
	.inst 0x7941c7c0 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:30 imm12:000001110001 opc:01 111001:111001 size:01
	.inst 0x7a4ee82d // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1101 0:0 Rn:1 10:10 cond:1110 imm5:01110 111010010:111010010 op:1 sf:0
	.inst 0xc2dd6810 // ORRFLGS-C.CR-C Cd:16 Cn:0 1010:1010 opc:01 Rm:29 11000010110:11000010110
	.inst 0xd4000001
	.zero 44012
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
	ldr x11, =initial_cap_values
	.inst 0xc2400165 // ldr c5, [x11, #0]
	.inst 0xc2400578 // ldr c24, [x11, #1]
	.inst 0xc240097c // ldr c28, [x11, #2]
	.inst 0xc2400d7d // ldr c29, [x11, #3]
	/* Set up flags and system registers */
	ldr x11, =0x0
	msr SPSR_EL3, x11
	ldr x11, =initial_SP_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c410b // msr CSP_EL1, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0x3c0000
	msr CPACR_EL1, x11
	ldr x11, =0x4
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x4
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =initial_DDC_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c412b // msr DDC_EL1, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260124b // ldr c11, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc28e402b // msr CELR_EL3, c11
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x18, #0xf
	and x11, x11, x18
	cmp x11, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400172 // ldr c18, [x11, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400572 // ldr c18, [x11, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400972 // ldr c18, [x11, #2]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2400d72 // ldr c18, [x11, #3]
	.inst 0xc2d2a601 // chkeq c16, c18
	b.ne comparison_fail
	.inst 0xc2401172 // ldr c18, [x11, #4]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc2401572 // ldr c18, [x11, #5]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc2401972 // ldr c18, [x11, #6]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2401d72 // ldr c18, [x11, #7]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x18, v31.d[0]
	cmp x11, x18
	b.ne comparison_fail
	ldr x11, =0x0
	mov x18, v31.d[1]
	cmp x11, x18
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_SP_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc29c4112 // mrs c18, CSP_EL1
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	ldr x11, =esr_el1_dump_address
	ldr x11, [x11]
	mov x18, 0x80
	orr x11, x11, x18
	ldr x18, =0x920000ea
	cmp x18, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001038
	ldr x1, =check_data0
	ldr x2, =0x0000103a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010fc
	ldr x1, =check_data1
	ldr x2, =0x00001100
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000018e8
	ldr x1, =check_data2
	ldr x2, =0x000018ea
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fee
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40405400
	ldr x1, =check_data6
	ldr x2, =0x40405414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
	.zero 4064
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x18
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x38, 0x00
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x05, 0x18
.data
check_data4:
	.byte 0x38
.data
check_data5:
	.byte 0xbe, 0xe4, 0xcd, 0x38, 0x01, 0x33, 0xc7, 0xc2, 0xbf, 0xb7, 0xaa, 0xe2, 0xdd, 0x03, 0xbc, 0x78
	.byte 0x39, 0x88, 0x13, 0x78
.data
check_data6:
	.byte 0xfe, 0xd3, 0x5e, 0x78, 0xc0, 0xc7, 0x41, 0x79, 0x2d, 0xe8, 0x4e, 0x7a, 0x10, 0x68, 0xdd, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0xffe
	/* C24 */
	.octa 0x18000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x800000005a040b320000000000001051
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffffffffffffe0
	/* C5 */
	.octa 0x10dc
	/* C16 */
	.octa 0x0
	/* C24 */
	.octa 0x18000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1805
initial_SP_EL1_value:
	.octa 0x2000
initial_DDC_EL0_value:
	.octa 0xc00000001007100700ffffffffffe000
initial_DDC_EL1_value:
	.octa 0x80000000400000010000000000008001
initial_VBAR_EL1_value:
	.octa 0x200080005800501d0000000040405000
final_SP_EL1_value:
	.octa 0x2000
final_PCC_value:
	.octa 0x200080005800501d0000000040405414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001fc300070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001030
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x82600e4b // ldr x11, [c18, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e4b // str x11, [c18, #0]
	ldr x11, =0x40405414
	mrs x18, ELR_EL1
	sub x11, x11, x18
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b172 // cvtp c18, x11
	.inst 0xc2cb4252 // scvalue c18, c18, x11
	.inst 0x8260024b // ldr c11, [c18, #0]
	.inst 0x021e016b // add c11, c11, #1920
	.inst 0xc2c21160 // br c11

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
