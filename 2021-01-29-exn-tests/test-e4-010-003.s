.section text0, #alloc, #execinstr
test_start:
	.inst 0xd2d40e08 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:8 imm16:1010000001110000 hw:10 100101:100101 opc:10 sf:1
	.inst 0xc2c013d1 // GCBASE-R.C-C Rd:17 Cn:30 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x8251a7fe // ASTRB-R.RI-B Rt:30 Rn:31 op:01 imm9:100011010 L:0 1000001001:1000001001
	.inst 0x9103c943 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:3 Rn:10 imm12:000011110010 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xe2170bfe // ALDURSB-R.RI-64 Rt:30 Rn:31 op2:10 imm9:101110000 V:0 op1:00 11100010:11100010
	.inst 0xa2be7fbf // 0xa2be7fbf
	.inst 0x783c815d // 0x783c815d
	.inst 0xc2dfa3a3 // 0xc2dfa3a3
	.inst 0x29036d74 // 0x29036d74
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
	ldr x26, =initial_cap_values
	.inst 0xc240034a // ldr c10, [x26, #0]
	.inst 0xc240074b // ldr c11, [x26, #1]
	.inst 0xc2400b54 // ldr c20, [x26, #2]
	.inst 0xc2400f5b // ldr c27, [x26, #3]
	.inst 0xc240135c // ldr c28, [x26, #4]
	.inst 0xc240175d // ldr c29, [x26, #5]
	.inst 0xc2401b5e // ldr c30, [x26, #6]
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
	ldr x26, =0xc0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x4
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011da // ldr c26, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034e // ldr c14, [x26, #0]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc240074e // ldr c14, [x26, #1]
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	.inst 0xc2400b4e // ldr c14, [x26, #2]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc2400f4e // ldr c14, [x26, #3]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc240134e // ldr c14, [x26, #4]
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	.inst 0xc240174e // ldr c14, [x26, #5]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc2401b4e // ldr c14, [x26, #6]
	.inst 0xc2cea761 // chkeq c27, c14
	b.ne comparison_fail
	.inst 0xc2401f4e // ldr c14, [x26, #7]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc240234e // ldr c14, [x26, #8]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc240274e // ldr c14, [x26, #9]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_SP_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc298410e // mrs c14, CSP_EL0
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea741 // chkeq c26, c14
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
	ldr x0, =0x00001370
	ldr x1, =check_data1
	ldr x2, =0x00001371
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000151a
	ldr x1, =check_data2
	ldr x2, =0x0000151b
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
	.byte 0x00, 0x00, 0x02, 0x02, 0x02, 0x02, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x08, 0x0e, 0xd4, 0xd2, 0xd1, 0x13, 0xc0, 0xc2, 0xfe, 0xa7, 0x51, 0x82, 0x43, 0xc9, 0x03, 0x91
	.byte 0xfe, 0x0b, 0x17, 0xe2, 0xbf, 0x7f, 0xbe, 0xa2, 0x5d, 0x81, 0x3c, 0x78, 0xa3, 0xa3, 0xdf, 0xc2
	.byte 0x74, 0x6d, 0x03, 0x29, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C10 */
	.octa 0xc0000000001e00010000000000001000
	/* C11 */
	.octa 0x40000000000100050000000000000fe8
	/* C20 */
	.octa 0x2020000
	/* C27 */
	.octa 0x20202
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0xd0000000000500030000000000001000
	/* C30 */
	.octa 0x700060000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0xa07000000000
	/* C10 */
	.octa 0xc0000000001e00010000000000001000
	/* C11 */
	.octa 0x40000000000100050000000000000fe8
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x2020000
	/* C27 */
	.octa 0x20202
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1400
initial_DDC_EL0_value:
	.octa 0xc00000006002000000ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x1400
final_PCC_value:
	.octa 0x200080000005004f0000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000005004f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 144
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x82600dda // ldr x26, [c14, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dda // str x26, [c14, #0]
	ldr x26, =0x40400028
	mrs x14, ELR_EL1
	sub x26, x26, x14
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34e // cvtp c14, x26
	.inst 0xc2da41ce // scvalue c14, c14, x26
	.inst 0x826001da // ldr c26, [c14, #0]
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
