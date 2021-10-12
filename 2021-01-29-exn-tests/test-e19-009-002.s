.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d949f7 // UNSEAL-C.CC-C Cd:23 Cn:15 0010:0010 opc:01 Cm:25 11000010110:11000010110
	.inst 0x6d2c97fa // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:26 Rn:31 Rt2:00101 imm7:1011001 L:0 1011010:1011010 opc:01
	.inst 0xc2c533dd // CVTP-R.C-C Rd:29 Cn:30 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xadf25ce0 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:0 Rn:7 Rt2:10111 imm7:1100100 L:1 1011011:1011011 opc:10
	.inst 0x421ffdb1 // STLR-C.R-C Ct:17 Rn:13 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.zero 1004
	.inst 0xb80518a1 // 0xb80518a1
	.inst 0xc2c733c1 // 0xc2c733c1
	.inst 0x721f6e5c // 0x721f6e5c
	.inst 0xc2c71017 // 0xc2c71017
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c5 // ldr c5, [x6, #2]
	.inst 0xc2400cc7 // ldr c7, [x6, #3]
	.inst 0xc24010cd // ldr c13, [x6, #4]
	.inst 0xc24014cf // ldr c15, [x6, #5]
	.inst 0xc24018d1 // ldr c17, [x6, #6]
	.inst 0xc2401cd2 // ldr c18, [x6, #7]
	.inst 0xc24020d9 // ldr c25, [x6, #8]
	.inst 0xc24024de // ldr c30, [x6, #9]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q5, =0x2000000000000000
	ldr q26, =0x0
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884106 // msr CSP_EL0, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0x3c0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x0
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
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
	cmp x6, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d0 // ldr c16, [x6, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24004d0 // ldr c16, [x6, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24008d0 // ldr c16, [x6, #2]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc2400cd0 // ldr c16, [x6, #3]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc24010d0 // ldr c16, [x6, #4]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc24014d0 // ldr c16, [x6, #5]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc24018d0 // ldr c16, [x6, #6]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc2401cd0 // ldr c16, [x6, #7]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc24020d0 // ldr c16, [x6, #8]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc24024d0 // ldr c16, [x6, #9]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc24028d0 // ldr c16, [x6, #10]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	.inst 0xc2402cd0 // ldr c16, [x6, #11]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc24030d0 // ldr c16, [x6, #12]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x16, v0.d[0]
	cmp x6, x16
	b.ne comparison_fail
	ldr x6, =0x0
	mov x16, v0.d[1]
	cmp x6, x16
	b.ne comparison_fail
	ldr x6, =0x2000000000000000
	mov x16, v5.d[0]
	cmp x6, x16
	b.ne comparison_fail
	ldr x6, =0x0
	mov x16, v5.d[1]
	cmp x6, x16
	b.ne comparison_fail
	ldr x6, =0x0
	mov x16, v23.d[0]
	cmp x6, x16
	b.ne comparison_fail
	ldr x6, =0x0
	mov x16, v23.d[1]
	cmp x6, x16
	b.ne comparison_fail
	ldr x6, =0x0
	mov x16, v26.d[0]
	cmp x6, x16
	b.ne comparison_fail
	ldr x6, =0x0
	mov x16, v26.d[1]
	cmp x6, x16
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984110 // mrs c16, CSP_EL0
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
	ldr x6, =0x920000eb
	cmp x6, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001100
	ldr x1, =check_data0
	ldr x2, =0x00001104
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000012d8
	ldr x1, =check_data1
	ldr x2, =0x000012e8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e40
	ldr x1, =check_data2
	ldr x2, =0x00001e60
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
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
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
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0xf7, 0x49, 0xd9, 0xc2, 0xfa, 0x97, 0x2c, 0x6d, 0xdd, 0x33, 0xc5, 0xc2, 0xe0, 0x5c, 0xf2, 0xad
	.byte 0xb1, 0xfd, 0x1f, 0x42
.data
check_data4:
	.byte 0xa1, 0x18, 0x05, 0xb8, 0xc1, 0x33, 0xc7, 0xc2, 0x5c, 0x6e, 0x1f, 0x72, 0x17, 0x10, 0xc7, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x400000000005000300000000000010af
	/* C7 */
	.octa 0x80000000100700450000000000002000
	/* C13 */
	.octa 0x1000000000080000000000000
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffffffffffffff
	/* C5 */
	.octa 0x400000000005000300000000000010af
	/* C7 */
	.octa 0x80000000100700450000000000001e40
	/* C13 */
	.octa 0x1000000000080000000000000
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x4000000058c40aec0000000000001410
initial_VBAR_EL1_value:
	.octa 0x20008000500000820000000040400001
final_SP_EL0_value:
	.octa 0x4000000058c40aec0000000000001410
final_PCC_value:
	.octa 0x20008000500000820000000040400414
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
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 192
	.dword initial_SP_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
	ldr x6, =0x40400414
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
