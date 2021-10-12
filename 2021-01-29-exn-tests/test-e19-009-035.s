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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b45 // ldr c5, [x26, #2]
	.inst 0xc2400f47 // ldr c7, [x26, #3]
	.inst 0xc240134d // ldr c13, [x26, #4]
	.inst 0xc240174f // ldr c15, [x26, #5]
	.inst 0xc2401b51 // ldr c17, [x26, #6]
	.inst 0xc2401f52 // ldr c18, [x26, #7]
	.inst 0xc2402359 // ldr c25, [x26, #8]
	.inst 0xc240275e // ldr c30, [x26, #9]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q5, =0x0
	ldr q26, =0x0
	/* Set up flags and system registers */
	ldr x26, =0x4000000
	msr SPSR_EL3, x26
	ldr x26, =initial_SP_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288411a // msr CSP_EL0, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0x3c0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x0
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260131a // ldr c26, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e403a // msr CELR_EL3, c26
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x24, #0xf
	and x26, x26, x24
	cmp x26, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400358 // ldr c24, [x26, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400758 // ldr c24, [x26, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400b58 // ldr c24, [x26, #2]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc2400f58 // ldr c24, [x26, #3]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2401358 // ldr c24, [x26, #4]
	.inst 0xc2d8a5a1 // chkeq c13, c24
	b.ne comparison_fail
	.inst 0xc2401758 // ldr c24, [x26, #5]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401b58 // ldr c24, [x26, #6]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2401f58 // ldr c24, [x26, #7]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2402358 // ldr c24, [x26, #8]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc2402758 // ldr c24, [x26, #9]
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	.inst 0xc2402b58 // ldr c24, [x26, #10]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2402f58 // ldr c24, [x26, #11]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2403358 // ldr c24, [x26, #12]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x24, v0.d[0]
	cmp x26, x24
	b.ne comparison_fail
	ldr x26, =0x0
	mov x24, v0.d[1]
	cmp x26, x24
	b.ne comparison_fail
	ldr x26, =0x0
	mov x24, v5.d[0]
	cmp x26, x24
	b.ne comparison_fail
	ldr x26, =0x0
	mov x24, v5.d[1]
	cmp x26, x24
	b.ne comparison_fail
	ldr x26, =0x0
	mov x24, v23.d[0]
	cmp x26, x24
	b.ne comparison_fail
	ldr x26, =0x0
	mov x24, v23.d[1]
	cmp x26, x24
	b.ne comparison_fail
	ldr x26, =0x0
	mov x24, v26.d[0]
	cmp x26, x24
	b.ne comparison_fail
	ldr x26, =0x0
	mov x24, v26.d[1]
	cmp x26, x24
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_SP_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984118 // mrs c24, CSP_EL0
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	ldr x24, =esr_el1_dump_address
	ldr x24, [x24]
	mov x26, 0x83
	orr x24, x24, x26
	ldr x26, =0x920000eb
	cmp x26, x24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001018
	ldr x1, =check_data0
	ldr x2, =0x0000101c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000016e8
	ldr x1, =check_data1
	ldr x2, =0x000016f8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40403e40
	ldr x1, =check_data4
	ldr x2, =0x40403e60
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
	.zero 16
.data
check_data2:
	.byte 0xf7, 0x49, 0xd9, 0xc2, 0xfa, 0x97, 0x2c, 0x6d, 0xdd, 0x33, 0xc5, 0xc2, 0xe0, 0x5c, 0xf2, 0xad
	.byte 0xb1, 0xfd, 0x1f, 0x42
.data
check_data3:
	.byte 0xa1, 0x18, 0x05, 0xb8, 0xc1, 0x33, 0xc7, 0xc2, 0x5c, 0x6e, 0x1f, 0x72, 0x17, 0x10, 0xc7, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 32

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfcd00b880422ffc0
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000510100010000000000000fc7
	/* C7 */
	.octa 0x80000000400500100000000040404000
	/* C13 */
	.octa 0x0
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
	.octa 0xfcd00b880422ffc0
	/* C1 */
	.octa 0xffffffffffffffff
	/* C5 */
	.octa 0x40000000510100010000000000000fc7
	/* C7 */
	.octa 0x80000000400500100000000040403e40
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0xfce0000000000000
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x400000005c0107f90000000000001820
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400001
final_SP_EL0_value:
	.octa 0x400000005c0107f90000000000001820
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100700070000000040400000
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
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40400414
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x021e035a // add c26, c26, #1920
	.inst 0xc2c21340 // br c26

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
