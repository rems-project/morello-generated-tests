.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c14bbd // UNSEAL-C.CC-C Cd:29 Cn:29 0010:0010 opc:01 Cm:1 11000010110:11000010110
	.inst 0x54f6f74d // b_cond:aarch64/instrs/branch/conditional/cond cond:1101 0:0 imm19:1111011011110111010 01010100:01010100
	.inst 0x2dcd6c06 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:6 Rn:0 Rt2:11011 imm7:0011010 L:1 1011011:1011011 opc:00
	.inst 0x0242601e // ADD-C.CIS-C Cd:30 Cn:0 imm12:000010011000 sh:1 A:0 00000010:00000010
	.inst 0xc2c4103b // LDPBR-C.C-C Ct:27 Cn:1 100:100 opc:00 11000010110001000:11000010110001000
	.zero 5100
	.inst 0x3c96ffe2 // 0x3c96ffe2
	.inst 0x384b9366 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:6 Rn:27 00:00 imm9:010111001 0:0 opc:01 111000:111000 size:00
	.inst 0x3862425f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:18 00:00 opc:100 o3:0 Rs:2 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x9b287c36 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:22 Rn:1 Ra:31 o0:0 Rm:8 01:01 U:0 10011011:10011011
	.inst 0xd4000001
	.zero 60396
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e2 // ldr c2, [x7, #2]
	.inst 0xc2400cf2 // ldr c18, [x7, #3]
	.inst 0xc24010fb // ldr c27, [x7, #4]
	.inst 0xc24014fd // ldr c29, [x7, #5]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q2, =0x110000000000000000000000000000
	/* Set up flags and system registers */
	ldr x7, =0x0
	msr SPSR_EL3, x7
	ldr x7, =initial_SP_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc28c4107 // msr CSP_EL1, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30d5d99f
	msr SCTLR_EL1, x7
	ldr x7, =0x3c0000
	msr CPACR_EL1, x7
	ldr x7, =0x4
	msr S3_0_C1_C2_2, x7 // CCTLR_EL1
	ldr x7, =0x0
	msr S3_3_C1_C2_2, x7 // CCTLR_EL0
	ldr x7, =initial_DDC_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884127 // msr DDC_EL0, c7
	ldr x7, =initial_DDC_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc28c4127 // msr DDC_EL1, c7
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011a7 // ldr c7, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc28e4027 // msr CELR_EL3, c7
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x13, #0xd
	and x7, x7, x13
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000ed // ldr c13, [x7, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc24004ed // ldr c13, [x7, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc24008ed // ldr c13, [x7, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400ced // ldr c13, [x7, #3]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc24010ed // ldr c13, [x7, #4]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc24014ed // ldr c13, [x7, #5]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc24018ed // ldr c13, [x7, #6]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc2401ced // ldr c13, [x7, #7]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x13, v2.d[0]
	cmp x7, x13
	b.ne comparison_fail
	ldr x7, =0x11000000000000
	mov x13, v2.d[1]
	cmp x7, x13
	b.ne comparison_fail
	ldr x7, =0x0
	mov x13, v6.d[0]
	cmp x7, x13
	b.ne comparison_fail
	ldr x7, =0x0
	mov x13, v6.d[1]
	cmp x7, x13
	b.ne comparison_fail
	ldr x7, =0x0
	mov x13, v27.d[0]
	cmp x7, x13
	b.ne comparison_fail
	ldr x7, =0x0
	mov x13, v27.d[1]
	cmp x7, x13
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_SP_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc29c410d // mrs c13, CSP_EL1
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	ldr x13, =esr_el1_dump_address
	ldr x13, [x13]
	mov x7, 0x83
	orr x13, x13, x7
	ldr x7, =0x920000a3
	cmp x7, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001570
	ldr x1, =check_data0
	ldr x2, =0x00001580
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f7e
	ldr x1, =check_data1
	ldr x2, =0x00001f7f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fec
	ldr x1, =check_data2
	ldr x2, =0x00001ff4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40401400
	ldr x1, =check_data4
	ldr x2, =0x40401414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xbd, 0x4b, 0xc1, 0xc2, 0x4d, 0xf7, 0xf6, 0x54, 0x06, 0x6c, 0xcd, 0x2d, 0x1e, 0x60, 0x42, 0x02
	.byte 0x3b, 0x10, 0xc4, 0xc2
.data
check_data4:
	.byte 0xe2, 0xff, 0x96, 0x3c, 0x66, 0x93, 0x4b, 0x38, 0x5f, 0x42, 0x62, 0x38, 0x36, 0x7c, 0x28, 0x9b
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1f84
	/* C1 */
	.octa 0x81004000000710070000000000001e41
	/* C2 */
	.octa 0x0
	/* C18 */
	.octa 0x62d
	/* C27 */
	.octa 0xf74
	/* C29 */
	.octa 0xf20800000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1fec
	/* C1 */
	.octa 0x81004000000710070000000000001e41
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C18 */
	.octa 0x62d
	/* C27 */
	.octa 0xf74
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x99fec
initial_SP_EL1_value:
	.octa 0x6b0
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0xc000000060000f510000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005600061d0000000040401000
final_SP_EL1_value:
	.octa 0x61f
final_PCC_value:
	.octa 0x200080005600061d0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000540070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 96
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
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x82600da7 // ldr x7, [c13, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400da7 // str x7, [c13, #0]
	ldr x7, =0x40401414
	mrs x13, ELR_EL1
	sub x7, x7, x13
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ed // cvtp c13, x7
	.inst 0xc2c741ad // scvalue c13, c13, x7
	.inst 0x826001a7 // ldr c7, [c13, #0]
	.inst 0x021e00e7 // add c7, c7, #1920
	.inst 0xc2c210e0 // br c7

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
