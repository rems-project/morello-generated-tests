.section text0, #alloc, #execinstr
test_start:
	.inst 0xf824518b // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:11 Rn:12 00:00 opc:101 0:0 Rs:4 1:1 R:0 A:0 111000:111000 size:11
	.inst 0x82df4be7 // ALDRSH-R.RRB-32 Rt:7 Rn:31 opc:10 S:0 option:010 Rm:31 0:0 L:1 100000101:100000101
	.inst 0x78189821 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:1 10:10 imm9:110001001 0:0 opc:00 111000:111000 size:01
	.inst 0xe29d67bb // ALDUR-R.RI-32 Rt:27 Rn:29 op2:01 imm9:111010110 V:0 op1:10 11100010:11100010
	.inst 0x38bf43c7 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:7 Rn:30 00:00 opc:100 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xd8bd1f6a // 0xd8bd1f6a
	.inst 0x380943b0 // 0x380943b0
	.inst 0x2220ba9d // 0x2220ba9d
	.inst 0x38db009c // 0x38db009c
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400664 // ldr c4, [x19, #1]
	.inst 0xc2400a6c // ldr c12, [x19, #2]
	.inst 0xc2400e6e // ldr c14, [x19, #3]
	.inst 0xc2401270 // ldr c16, [x19, #4]
	.inst 0xc2401674 // ldr c20, [x19, #5]
	.inst 0xc2401a7d // ldr c29, [x19, #6]
	.inst 0xc2401e7e // ldr c30, [x19, #7]
	/* Set up flags and system registers */
	ldr x19, =0x0
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884113 // msr CSP_EL0, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x4
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f3 // ldr c19, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400277 // ldr c23, [x19, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400677 // ldr c23, [x19, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a77 // ldr c23, [x19, #2]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2400e77 // ldr c23, [x19, #3]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2401277 // ldr c23, [x19, #4]
	.inst 0xc2d7a561 // chkeq c11, c23
	b.ne comparison_fail
	.inst 0xc2401677 // ldr c23, [x19, #5]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401a77 // ldr c23, [x19, #6]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2401e77 // ldr c23, [x19, #7]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2402277 // ldr c23, [x19, #8]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2402677 // ldr c23, [x19, #9]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2402a77 // ldr c23, [x19, #10]
	.inst 0xc2d7a781 // chkeq c28, c23
	b.ne comparison_fail
	.inst 0xc2402e77 // ldr c23, [x19, #11]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2403277 // ldr c23, [x19, #12]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001140
	ldr x1, =check_data1
	ldr x2, =0x00001148
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001500
	ldr x1, =check_data2
	ldr x2, =0x00001502
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f40
	ldr x1, =check_data3
	ldr x2, =0x00001f44
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f90
	ldr x1, =check_data4
	ldr x2, =0x00001f92
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffe
	ldr x1, =check_data5
	ldr x2, =0x00001fff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040fffe
	ldr x1, =check_data7
	ldr x2, =0x4040ffff
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 304
	.byte 0x4f, 0x00, 0x41, 0x40, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3760
.data
check_data0:
	.byte 0x01
.data
check_data1:
	.byte 0x4f, 0x00, 0x41, 0x40, 0x00, 0x00, 0x00, 0x80
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x07, 0x20
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x8b, 0x51, 0x24, 0xf8, 0xe7, 0x4b, 0xdf, 0x82, 0x21, 0x98, 0x18, 0x78, 0xbb, 0x67, 0x9d, 0xe2
	.byte 0xc7, 0x43, 0xbf, 0x38, 0x6a, 0x1f, 0xbd, 0xd8, 0xb0, 0x43, 0x09, 0x38, 0x9d, 0xba, 0x20, 0x22
	.byte 0x9c, 0x00, 0xdb, 0x38, 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x2007
	/* C4 */
	.octa 0x4041004e
	/* C12 */
	.octa 0x1140
	/* C14 */
	.octa 0x4000000000000000000000000000
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x1fc0
	/* C29 */
	.octa 0x80004000000100050000000000001f6a
	/* C30 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x2007
	/* C4 */
	.octa 0x4041004e
	/* C7 */
	.octa 0x1
	/* C11 */
	.octa 0x800000004041004f
	/* C12 */
	.octa 0x1140
	/* C14 */
	.octa 0x4000000000000000000000000000
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x1fc0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x80004000000100050000000000001f6a
	/* C30 */
	.octa 0x1000
initial_SP_EL0_value:
	.octa 0x800000000000c0000000000000001500
initial_DDC_EL0_value:
	.octa 0xc80000000003000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x800000000000c0000000000000001500
final_PCC_value:
	.octa 0x200080000005400f0000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000005400f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 96
	.dword final_cap_values + 176
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
