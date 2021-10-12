.section text0, #alloc, #execinstr
test_start:
	.inst 0x22017fce // STXR-R.CR-C Ct:14 Rn:30 (1)(1)(1)(1)(1):11111 0:0 Rs:1 0:0 L:0 001000100:001000100
	.inst 0xac675f96 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:22 Rn:28 Rt2:10111 imm7:1001110 L:1 1011000:1011000 opc:10
	.inst 0xc2c0b017 // GCSEAL-R.C-C Rd:23 Cn:0 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x883dcbf0 // stlxp:aarch64/instrs/memory/exclusive/pair Rt:16 Rn:31 Rt2:10010 o0:1 Rs:29 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0xc2dc186f // ALIGND-C.CI-C Cd:15 Cn:3 0110:0110 U:0 imm6:111000 11000010110:11000010110
	.inst 0xc2c56a1b // 0xc2c56a1b
	.inst 0xb6e01abf // 0xb6e01abf
	.zero 848
	.inst 0x38db0161 // 0x38db0161
	.inst 0xb836815e // 0xb836815e
	.inst 0xd4000001
	.zero 64648
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400523 // ldr c3, [x9, #1]
	.inst 0xc240092a // ldr c10, [x9, #2]
	.inst 0xc2400d2b // ldr c11, [x9, #3]
	.inst 0xc240112e // ldr c14, [x9, #4]
	.inst 0xc2401530 // ldr c16, [x9, #5]
	.inst 0xc2401936 // ldr c22, [x9, #6]
	.inst 0xc2401d3c // ldr c28, [x9, #7]
	.inst 0xc240213e // ldr c30, [x9, #8]
	/* Set up flags and system registers */
	ldr x9, =0x0
	msr SPSR_EL3, x9
	ldr x9, =initial_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884109 // msr CSP_EL0, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0x3c0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x0
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012a9 // ldr c9, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400135 // ldr c21, [x9, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400535 // ldr c21, [x9, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400935 // ldr c21, [x9, #2]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2400d35 // ldr c21, [x9, #3]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401135 // ldr c21, [x9, #4]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401535 // ldr c21, [x9, #5]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc2401935 // ldr c21, [x9, #6]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2401d35 // ldr c21, [x9, #7]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2402135 // ldr c21, [x9, #8]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2402535 // ldr c21, [x9, #9]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc2402935 // ldr c21, [x9, #10]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc2402d35 // ldr c21, [x9, #11]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2403135 // ldr c21, [x9, #12]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x21, v22.d[0]
	cmp x9, x21
	b.ne comparison_fail
	ldr x9, =0x0
	mov x21, v22.d[1]
	cmp x9, x21
	b.ne comparison_fail
	ldr x9, =0x0
	mov x21, v23.d[0]
	cmp x9, x21
	b.ne comparison_fail
	ldr x9, =0x0
	mov x21, v23.d[1]
	cmp x9, x21
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984115 // mrs c21, CSP_EL0
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fb0
	ldr x1, =check_data0
	ldr x2, =0x00001fb8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fe0
	ldr x1, =check_data1
	ldr x2, =0x00001ff0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff8
	ldr x1, =check_data2
	ldr x2, =0x00001ffc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x4040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040036c
	ldr x1, =check_data5
	ldr x2, =0x40400378
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40408010
	ldr x1, =check_data6
	ldr x2, =0x40408030
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.zero 8
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xce, 0x7f, 0x01, 0x22, 0x96, 0x5f, 0x67, 0xac, 0x17, 0xb0, 0xc0, 0xc2, 0xf0, 0xcb, 0x3d, 0x88
	.byte 0x6f, 0x18, 0xdc, 0xc2, 0x1b, 0x6a, 0xc5, 0xc2, 0xbf, 0x1a, 0xe0, 0xb6
.data
check_data5:
	.byte 0x61, 0x01, 0xdb, 0x38, 0x5e, 0x81, 0x36, 0xb8, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 32

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x4001000000ffffffffffe001
	/* C10 */
	.octa 0x1ff8
	/* C11 */
	.octa 0x204e
	/* C14 */
	.octa 0x4000000000000000000000000000
	/* C16 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x40408330
	/* C30 */
	.octa 0x1fe0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x4001000000ffffffffffe001
	/* C10 */
	.octa 0x1ff8
	/* C11 */
	.octa 0x204e
	/* C14 */
	.octa 0x4000000000000000000000000000
	/* C15 */
	.octa 0x400100000000000000000000
	/* C16 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x40408330
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1fb0
initial_DDC_EL0_value:
	.octa 0xc8000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x1fb0
final_PCC_value:
	.octa 0x20008000000100070000000040400378
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x82600ea9 // ldr x9, [c21, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ea9 // str x9, [c21, #0]
	ldr x9, =0x40400378
	mrs x21, ELR_EL1
	sub x9, x9, x21
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b135 // cvtp c21, x9
	.inst 0xc2c942b5 // scvalue c21, c21, x9
	.inst 0x826002a9 // ldr c9, [c21, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
