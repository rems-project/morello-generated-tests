.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23201 // CHKTGD-C-C 00001:00001 Cn:16 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c06801 // ORRFLGS-C.CR-C Cd:1 Cn:0 1010:1010 opc:01 Rm:0 11000010110:11000010110
	.inst 0x131254e1 // sbfm:aarch64/instrs/integer/bitfield Rd:1 Rn:7 imms:010101 immr:010010 N:0 100110:100110 opc:00 sf:0
	.inst 0x69e8e5dd // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:29 Rn:14 Rt2:11001 imm7:1010001 L:1 1010011:1010011 opc:01
	.inst 0x887f9bd2 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:18 Rn:30 Rt2:00110 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.zero 1004
	.inst 0x5a81c34c // 0x5a81c34c
	.inst 0x8254b3e5 // 0x8254b3e5
	.inst 0xc2e1199d // 0xc2e1199d
	.inst 0xc2df6bc3 // 0xc2df6bc3
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a5 // ldr c5, [x13, #1]
	.inst 0xc24009ae // ldr c14, [x13, #2]
	.inst 0xc2400db0 // ldr c16, [x13, #3]
	.inst 0xc24011be // ldr c30, [x13, #4]
	/* Set up flags and system registers */
	ldr x13, =0x4000000
	msr SPSR_EL3, x13
	ldr x13, =initial_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c410d // msr CSP_EL1, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0xc0000
	msr CPACR_EL1, x13
	ldr x13, =0x0
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =initial_DDC_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c412d // msr DDC_EL1, c13
	ldr x13, =0x80000000
	msr HCR_EL2, x13
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260108d // ldr c13, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
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
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x4, #0xf
	and x13, x13, x4
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a4 // ldr c4, [x13, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24005a4 // ldr c4, [x13, #1]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc24009a4 // ldr c4, [x13, #2]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2400da4 // ldr c4, [x13, #3]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc24011a4 // ldr c4, [x13, #4]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc24015a4 // ldr c4, [x13, #5]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc24019a4 // ldr c4, [x13, #6]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc29c4104 // mrs c4, CSP_EL1
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	ldr x4, =esr_el1_dump_address
	ldr x4, [x4]
	mov x13, 0x83
	orr x4, x4, x13
	ldr x13, =0x920000ab
	cmp x13, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001dd0
	ldr x1, =check_data0
	ldr x2, =0x00001de0
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
	ldr x0, =0x40400400
	ldr x1, =check_data2
	ldr x2, =0x40400414
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400744
	ldr x1, =check_data3
	ldr x2, =0x4040074c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0x01, 0x32, 0xc2, 0xc2, 0x01, 0x68, 0xc0, 0xc2, 0xe1, 0x54, 0x12, 0x13, 0xdd, 0xe5, 0xe8, 0x69
	.byte 0xd2, 0x9b, 0x7f, 0x88
.data
check_data2:
	.byte 0x4c, 0xc3, 0x81, 0x5a, 0xe5, 0xb3, 0x54, 0x82, 0x9d, 0x19, 0xe1, 0xc2, 0xc3, 0x6b, 0xdf, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C5 */
	.octa 0x4000000000000000000000000000
	/* C14 */
	.octa 0x80000000000000080000000040400800
	/* C16 */
	.octa 0x0
	/* C30 */
	.octa 0x800000002180200ffe000000000f4f11
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x800000002180200ffe000000000f4f11
	/* C5 */
	.octa 0x4000000000000000000000000000
	/* C14 */
	.octa 0x80000000000000080000000040400744
	/* C16 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x800000002180200ffe000000000f4f11
initial_SP_EL1_value:
	.octa 0x920
initial_DDC_EL1_value:
	.octa 0x480000000401c0050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080006000001d0000000040400001
final_SP_EL1_value:
	.octa 0x920
final_PCC_value:
	.octa 0x200080006000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000408200000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
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
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x82600c8d // ldr x13, [c4, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400c8d // str x13, [c4, #0]
	ldr x13, =0x40400414
	mrs x4, ELR_EL1
	sub x13, x13, x4
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a4 // cvtp c4, x13
	.inst 0xc2cd4084 // scvalue c4, c4, x13
	.inst 0x8260008d // ldr c13, [c4, #0]
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
