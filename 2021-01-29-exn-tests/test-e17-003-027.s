.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2b1803a // SWPA-CC.R-C Ct:26 Rn:1 100000:100000 Cs:17 1:1 R:0 A:1 10100010:10100010
	.inst 0xbd7643bf // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:31 Rn:29 imm12:110110010000 opc:01 111101:111101 size:10
	.inst 0xc2c23142 // BLRS-C-C 00010:00010 Cn:10 100:100 opc:01 11000010110000100:11000010110000100
	.zero 4076
	.inst 0x38478829 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:1 10:10 imm9:001111000 0:0 opc:01 111000:111000 size:00
	.inst 0xa2eb7e04 // CASA-C.R-C Ct:4 Rn:16 11111:11111 R:0 Cs:11 1:1 L:1 1:1 10100010:10100010
	.inst 0x384d8ba1 // 0x384d8ba1
	.inst 0x7824109f // 0x7824109f
	.inst 0xf0e858dd // 0xf0e858dd
	.inst 0x787df9b8 // 0x787df9b8
	.inst 0xd4000001
	.zero 61420
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc240086a // ldr c10, [x3, #2]
	.inst 0xc2400c6b // ldr c11, [x3, #3]
	.inst 0xc240106d // ldr c13, [x3, #4]
	.inst 0xc2401470 // ldr c16, [x3, #5]
	.inst 0xc2401871 // ldr c17, [x3, #6]
	.inst 0xc2401c7d // ldr c29, [x3, #7]
	/* Set up flags and system registers */
	ldr x3, =0x4000000
	msr SPSR_EL3, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0x3c0000
	msr CPACR_EL1, x3
	ldr x3, =0x0
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x0
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x0, =pcc_return_ddc_capabilities
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0x82601003 // ldr c3, [c0, #1]
	.inst 0x82602000 // ldr c0, [c0, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2c0a421 // chkeq c1, c0
	b.ne comparison_fail
	.inst 0xc2400460 // ldr c0, [x3, #1]
	.inst 0xc2c0a481 // chkeq c4, c0
	b.ne comparison_fail
	.inst 0xc2400860 // ldr c0, [x3, #2]
	.inst 0xc2c0a521 // chkeq c9, c0
	b.ne comparison_fail
	.inst 0xc2400c60 // ldr c0, [x3, #3]
	.inst 0xc2c0a541 // chkeq c10, c0
	b.ne comparison_fail
	.inst 0xc2401060 // ldr c0, [x3, #4]
	.inst 0xc2c0a561 // chkeq c11, c0
	b.ne comparison_fail
	.inst 0xc2401460 // ldr c0, [x3, #5]
	.inst 0xc2c0a5a1 // chkeq c13, c0
	b.ne comparison_fail
	.inst 0xc2401860 // ldr c0, [x3, #6]
	.inst 0xc2c0a601 // chkeq c16, c0
	b.ne comparison_fail
	.inst 0xc2401c60 // ldr c0, [x3, #7]
	.inst 0xc2c0a621 // chkeq c17, c0
	b.ne comparison_fail
	.inst 0xc2402060 // ldr c0, [x3, #8]
	.inst 0xc2c0a701 // chkeq c24, c0
	b.ne comparison_fail
	.inst 0xc2402460 // ldr c0, [x3, #9]
	.inst 0xc2c0a741 // chkeq c26, c0
	b.ne comparison_fail
	.inst 0xc2402860 // ldr c0, [x3, #10]
	.inst 0xc2c0a7a1 // chkeq c29, c0
	b.ne comparison_fail
	.inst 0xc2402c60 // ldr c0, [x3, #11]
	.inst 0xc2c0a7c1 // chkeq c30, c0
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x0, v31.d[0]
	cmp x3, x0
	b.ne comparison_fail
	ldr x3, =0x0
	mov x0, v31.d[1]
	cmp x3, x0
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984020 // mrs c0, CELR_EL1
	.inst 0xc2c0a461 // chkeq c3, c0
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001178
	ldr x1, =check_data2
	ldr x2, =0x00001179
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x4040000c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400ff8
	ldr x1, =check_data4
	ldr x2, =0x40401014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40405efc
	ldr x1, =check_data5
	ldr x2, =0x40405efd
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40409464
	ldr x1, =check_data6
	ldr x2, =0x40409468
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040effc
	ldr x1, =check_data7
	ldr x2, =0x4040effe
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6b, 0x01, 0x11, 0x51, 0x00, 0x00, 0x00, 0xc0
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x3a, 0x80, 0xb1, 0xa2, 0xbf, 0x43, 0x76, 0xbd, 0x42, 0x31, 0xc2, 0xc2
.data
check_data4:
	.byte 0x29, 0x88, 0x47, 0x38, 0x04, 0x7e, 0xeb, 0xa2, 0xa1, 0x8b, 0x4d, 0x38, 0x9f, 0x10, 0x24, 0x78
	.byte 0xdd, 0x58, 0xe8, 0xf0, 0xb8, 0xf9, 0x7d, 0x78, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 4
.data
check_data7:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xdc100000580106800000000000001100
	/* C4 */
	.octa 0xc00000005111016b0000000000001000
	/* C10 */
	.octa 0x20008000000100050000000040400ff9
	/* C11 */
	.octa 0x800000000000000000000000
	/* C13 */
	.octa 0x8000000000020003000000001e5d6ffc
	/* C16 */
	.octa 0xdc000000000180050000000000001000
	/* C17 */
	.octa 0x20000000000000000000000000000000
	/* C29 */
	.octa 0x800000002001c0050000000040405e24
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0xc00000005111016b0000000000001000
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x20008000000100050000000040400ff9
	/* C11 */
	.octa 0x800000000000000000000000
	/* C13 */
	.octa 0x8000000000020003000000001e5d6ffc
	/* C16 */
	.octa 0xdc000000000180050000000000001000
	/* C17 */
	.octa 0x20000000000000000000000000000000
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x20008000000100050000000010f1c000
	/* C30 */
	.octa 0x2000800040210000000000004040000d
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000100050000000040401014
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000402100000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001100
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 176
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600c03 // ldr x3, [c0, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c03 // str x3, [c0, #0]
	ldr x3, =0x40401014
	mrs x0, ELR_EL1
	sub x3, x3, x0
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b060 // cvtp c0, x3
	.inst 0xc2c34000 // scvalue c0, c0, x3
	.inst 0x82600003 // ldr c3, [c0, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
