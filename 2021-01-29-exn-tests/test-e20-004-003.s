.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2b813fc // ASTUR-V.RI-S Rt:28 Rn:31 op2:00 imm9:110000001 V:1 op1:10 11100010:11100010
	.inst 0xb15377df // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:30 imm12:010011011101 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x4b20ab9f // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:28 imm3:010 option:101 Rm:0 01011001:01011001 S:0 op:1 sf:0
	.inst 0xc2c710e1 // RRLEN-R.R-C Rd:1 Rn:7 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x3881fae1 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:23 10:10 imm9:000011111 0:0 opc:10 111000:111000 size:00
	.zero 1004
	.inst 0x3a5e7824 // 0x3a5e7824
	.inst 0xe21493fd // 0xe21493fd
	.inst 0xc2dad0e0 // 0xc2dad0e0
	.zero 31732
	.inst 0xb8fd72d4 // 0xb8fd72d4
	.inst 0xd4000001
	.zero 32760
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
	.inst 0xc24000c7 // ldr c7, [x6, #0]
	.inst 0xc24004d6 // ldr c22, [x6, #1]
	.inst 0xc24008d7 // ldr c23, [x6, #2]
	.inst 0xc2400cdd // ldr c29, [x6, #3]
	.inst 0xc24010de // ldr c30, [x6, #4]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q28, =0x0
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884106 // msr CSP_EL0, c6
	ldr x6, =initial_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4106 // msr CSP_EL1, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0x3c0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x4
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =initial_DDC_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4126 // msr DDC_EL1, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601206 // ldr c6, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
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
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x16, #0xf
	and x6, x6, x16
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d0 // ldr c16, [x6, #0]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24004d0 // ldr c16, [x6, #1]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc24008d0 // ldr c16, [x6, #2]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc2400cd0 // ldr c16, [x6, #3]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc24010d0 // ldr c16, [x6, #4]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc24014d0 // ldr c16, [x6, #5]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc24018d0 // ldr c16, [x6, #6]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x16, v28.d[0]
	cmp x6, x16
	b.ne comparison_fail
	ldr x6, =0x0
	mov x16, v28.d[1]
	cmp x6, x16
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc29c4110 // mrs c16, CSP_EL1
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x6, 0x83
	orr x16, x16, x6
	ldr x6, =0x920000ab
	cmp x6, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001109
	ldr x1, =check_data0
	ldr x2, =0x0000110a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001804
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f84
	ldr x1, =check_data2
	ldr x2, =0x00001f88
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fa0
	ldr x1, =check_data3
	ldr x2, =0x00001fb0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x4040040c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40408000
	ldr x1, =check_data6
	ldr x2, =0x40408008
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 2048
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1936
	.byte 0x00, 0x80, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x07, 0x80, 0x07, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 80
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x01, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x80, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x07, 0x80, 0x07, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.byte 0xfc, 0x13, 0xb8, 0xe2, 0xdf, 0x77, 0x53, 0xb1, 0x9f, 0xab, 0x20, 0x4b, 0xe1, 0x10, 0xc7, 0xc2
	.byte 0xe1, 0xfa, 0x81, 0x38
.data
check_data5:
	.byte 0x24, 0x78, 0x5e, 0x3a, 0xfd, 0x93, 0x14, 0xe2, 0xe0, 0xd0, 0xda, 0xc2
.data
check_data6:
	.byte 0xd4, 0x72, 0xfd, 0xb8, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x90100000380400070000000000002240
	/* C22 */
	.octa 0x1800
	/* C23 */
	.octa 0x80000000000000
	/* C29 */
	.octa 0x80000000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x2240
	/* C7 */
	.octa 0x90100000380400070000000000002240
	/* C20 */
	.octa 0x100
	/* C22 */
	.octa 0x1800
	/* C23 */
	.octa 0x80000000000000
	/* C29 */
	.octa 0x80000000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x2000
initial_SP_EL1_value:
	.octa 0x11c0
initial_DDC_EL0_value:
	.octa 0x400000005fa1000300ffffffffffe000
initial_DDC_EL1_value:
	.octa 0xc00000007002000400ffffffffffe003
initial_VBAR_EL1_value:
	.octa 0x20008000402000250000000040400001
final_SP_EL1_value:
	.octa 0x11c0
final_PCC_value:
	.octa 0x20008000000780070000000040408008
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fa0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword initial_DDC_EL0_value
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600e06 // ldr x6, [c16, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e06 // str x6, [c16, #0]
	ldr x6, =0x40408008
	mrs x16, ELR_EL1
	sub x6, x6, x16
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d0 // cvtp c16, x6
	.inst 0xc2c64210 // scvalue c16, c16, x6
	.inst 0x82600206 // ldr c6, [c16, #0]
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
