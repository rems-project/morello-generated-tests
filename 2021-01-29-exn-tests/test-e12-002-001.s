.section text0, #alloc, #execinstr
test_start:
	.inst 0xfc59d3a1 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:1 Rn:29 00:00 imm9:110011101 0:0 opc:01 111100:111100 size:11
	.inst 0x1a912569 // csinc:aarch64/instrs/integer/conditional/select Rd:9 Rn:11 o2:1 0:0 cond:0010 Rm:17 011010100:011010100 op:0 sf:0
	.inst 0x9b1e0e8e // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:14 Rn:20 Ra:3 o0:0 Rm:30 0011011000:0011011000 sf:1
	.inst 0x2df34c1f // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:31 Rn:0 Rt2:10011 imm7:1100110 L:1 1011011:1011011 opc:00
	.inst 0x717ba428 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:8 Rn:1 imm12:111011101001 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xc2f1f020 // EORFLGS-C.CI-C Cd:0 Cn:1 0:0 10:10 imm8:10001111 11000010111:11000010111
	.inst 0xa244103e // LDUR-C.RI-C Ct:30 Rn:1 00:00 imm9:001000001 0:0 opc:01 10100010:10100010
	.inst 0x08127fbe // stxrb:aarch64/instrs/memory/exclusive/single Rt:30 Rn:29 Rt2:11111 o0:0 Rs:18 0:0 L:0 0010000:0010000 size:00
	.inst 0xc2d86bcd // ORRFLGS-C.CR-C Cd:13 Cn:30 1010:1010 opc:01 Rm:24 11000010110:11000010110
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008dd // ldr c29, [x6, #2]
	/* Set up flags and system registers */
	ldr x6, =0x20000000
	msr SPSR_EL3, x6
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
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82601046 // ldr c6, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
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
	mov x2, #0xf
	and x6, x6, x2
	cmp x6, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c2 // ldr c2, [x6, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2c2a501 // chkeq c8, c2
	b.ne comparison_fail
	.inst 0xc2400cc2 // ldr c2, [x6, #3]
	.inst 0xc2c2a641 // chkeq c18, c2
	b.ne comparison_fail
	.inst 0xc24010c2 // ldr c2, [x6, #4]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc24014c2 // ldr c2, [x6, #5]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x2, v1.d[0]
	cmp x6, x2
	b.ne comparison_fail
	ldr x6, =0x0
	mov x2, v1.d[1]
	cmp x6, x2
	b.ne comparison_fail
	ldr x6, =0x0
	mov x2, v19.d[0]
	cmp x6, x2
	b.ne comparison_fail
	ldr x6, =0x0
	mov x2, v19.d[1]
	cmp x6, x2
	b.ne comparison_fail
	ldr x6, =0x0
	mov x2, v31.d[0]
	cmp x6, x2
	b.ne comparison_fail
	ldr x6, =0x0
	mov x2, v31.d[1]
	cmp x6, x2
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a4c1 // chkeq c6, c2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001070
	ldr x1, =check_data0
	ldr x2, =0x00001080
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011f8
	ldr x1, =check_data1
	ldr x2, =0x00001200
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000125b
	ldr x1, =check_data2
	ldr x2, =0x0000125c
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
	ldr x0, =0x4040ff98
	ldr x1, =check_data4
	ldr x2, =0x4040ffa0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xa1, 0xd3, 0x59, 0xfc, 0x69, 0x25, 0x91, 0x1a, 0x8e, 0x0e, 0x1e, 0x9b, 0x1f, 0x4c, 0xf3, 0x2d
	.byte 0x28, 0xa4, 0x7b, 0x71, 0x20, 0xf0, 0xf1, 0xc2, 0x3e, 0x10, 0x44, 0xa2, 0xbe, 0x7f, 0x12, 0x08
	.byte 0xcd, 0x6b, 0xd8, 0xc2, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40410000
	/* C1 */
	.octa 0x102f
	/* C29 */
	.octa 0x125b
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x8f0000000000102f
	/* C1 */
	.octa 0x102f
	/* C8 */
	.octa 0xff11802f
	/* C18 */
	.octa 0x1
	/* C29 */
	.octa 0x125b
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc0100000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000200620070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001070
	.dword el1_vector_jump_cap
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400028
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
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
