.section text0, #alloc, #execinstr
test_start:
	.inst 0x78c6bc3b // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:27 Rn:1 11:11 imm9:001101011 0:0 opc:11 111000:111000 size:01
	.inst 0x11451bcf // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:15 Rn:30 imm12:000101000110 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xa25e19c1 // LDTR-C.RIB-C Ct:1 Rn:14 10:10 imm9:111100001 0:0 opc:01 10100010:10100010
	.inst 0x0b2029c4 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:4 Rn:14 imm3:010 option:001 Rm:0 01011001:01011001 S:0 op:0 sf:0
	.inst 0xc2dd067f // BUILD-C.C-C Cd:31 Cn:19 001:001 opc:00 0:0 Cm:29 11000010110:11000010110
	.inst 0xc2c19032 // 0xc2c19032
	.inst 0xc2c233c1 // 0xc2c233c1
	.inst 0x82c6cc29 // 0x82c6cc29
	.inst 0xf874101d // 0xf874101d
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
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a6 // ldr c6, [x13, #2]
	.inst 0xc2400dae // ldr c14, [x13, #3]
	.inst 0xc24011b3 // ldr c19, [x13, #4]
	.inst 0xc24015b4 // ldr c20, [x13, #5]
	.inst 0xc24019bd // ldr c29, [x13, #6]
	.inst 0xc2401dbe // ldr c30, [x13, #7]
	/* Set up flags and system registers */
	ldr x13, =0x4000000
	msr SPSR_EL3, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0xc0000
	msr CPACR_EL1, x13
	ldr x13, =0x0
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =0x4
	msr S3_3_C1_C2_2, x13 // CCTLR_EL0
	ldr x13, =initial_DDC_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc288412d // msr DDC_EL0, c13
	ldr x13, =0x80000000
	msr HCR_EL2, x13
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012ed // ldr c13, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	mov x23, #0xf
	and x13, x13, x23
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b7 // ldr c23, [x13, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24005b7 // ldr c23, [x13, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24009b7 // ldr c23, [x13, #2]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2400db7 // ldr c23, [x13, #3]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc24011b7 // ldr c23, [x13, #4]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc24015b7 // ldr c23, [x13, #5]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc24019b7 // ldr c23, [x13, #6]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc2401db7 // ldr c23, [x13, #7]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc24021b7 // ldr c23, [x13, #8]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc24025b7 // ldr c23, [x13, #9]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc24029b7 // ldr c23, [x13, #10]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2402db7 // ldr c23, [x13, #11]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc24031b7 // ldr c23, [x13, #12]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_SP_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100c
	ldr x1, =check_data0
	ldr x2, =0x0000100e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001188
	ldr x1, =check_data1
	ldr x2, =0x0000118a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fa0
	ldr x1, =check_data2
	ldr x2, =0x00001fb0
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
	.zero 4000
	.byte 0x34, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 64
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x34, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.data
check_data4:
	.byte 0x3b, 0xbc, 0xc6, 0x78, 0xcf, 0x1b, 0x45, 0x11, 0xc1, 0x19, 0x5e, 0xa2, 0xc4, 0x29, 0x20, 0x0b
	.byte 0x7f, 0x06, 0xdd, 0xc2, 0x32, 0x90, 0xc1, 0xc2, 0xc1, 0x33, 0xc2, 0xc2, 0x29, 0xcc, 0xc6, 0x82
	.byte 0x1d, 0x10, 0x74, 0xf8, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ff0
	/* C1 */
	.octa 0x80000000400100020000000000000fa1
	/* C6 */
	.octa 0xc6
	/* C14 */
	.octa 0x80000000000100050000000000002190
	/* C19 */
	.octa 0x134007001022b980000001
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0x30017000fe20000000001
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ff0
	/* C1 */
	.octa 0x1034
	/* C4 */
	.octa 0xa150
	/* C6 */
	.octa 0xc6
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000000002190
	/* C15 */
	.octa 0x146000
	/* C18 */
	.octa 0x1034
	/* C19 */
	.octa 0x134007001022b980000001
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x800000004000008e0000000000004000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x134007001022b980000001
final_PCC_value:
	.octa 0x20008000000080080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 192
	.dword initial_DDC_EL0_value
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
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x82600eed // ldr x13, [c23, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400eed // str x13, [c23, #0]
	ldr x13, =0x40400028
	mrs x23, ELR_EL1
	sub x13, x13, x23
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b7 // cvtp c23, x13
	.inst 0xc2cd42f7 // scvalue c23, c23, x13
	.inst 0x826002ed // ldr c13, [c23, #0]
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
