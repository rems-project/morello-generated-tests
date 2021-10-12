.section text0, #alloc, #execinstr
test_start:
	.inst 0xb853ebdf // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:30 10:10 imm9:100111110 0:0 opc:01 111000:111000 size:10
	.inst 0x5ac00a05 // rev:aarch64/instrs/integer/arithmetic/rev Rd:5 Rn:16 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0xc2c043c5 // SCVALUE-C.CR-C Cd:5 Cn:30 000:000 opc:10 0:0 Rm:0 11000010110:11000010110
	.inst 0x489ffc1d // stlrh:aarch64/instrs/memory/ordered Rt:29 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x783a301f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:011 o3:0 Rs:26 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c08480 // BRS-C.C-C 00000:00000 Cn:4 001:001 opc:00 1:1 Cm:0 11000010110:11000010110
	.zero 1000
	.inst 0x08bd7fe0 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:0 Rn:31 11111:11111 o0:0 Rs:29 1:1 L:0 0010001:0010001 size:00
	.inst 0x78a943fd // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:31 00:00 opc:100 0:0 Rs:9 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xc2c033b6 // GCLEN-R.C-C Rd:22 Cn:29 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xd4000001
	.zero 64496
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400784 // ldr c4, [x28, #1]
	.inst 0xc2400b89 // ldr c9, [x28, #2]
	.inst 0xc2400f9a // ldr c26, [x28, #3]
	.inst 0xc240139d // ldr c29, [x28, #4]
	.inst 0xc240179e // ldr c30, [x28, #5]
	/* Set up flags and system registers */
	ldr x28, =0x0
	msr SPSR_EL3, x28
	ldr x28, =initial_SP_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288411c // msr CSP_EL0, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0xc0000
	msr CPACR_EL1, x28
	ldr x28, =0x0
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x4
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
	ldr x28, =initial_DDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288413c // msr DDC_EL0, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010fc // ldr c28, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e403c // msr CELR_EL3, c28
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400387 // ldr c7, [x28, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400787 // ldr c7, [x28, #1]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400b87 // ldr c7, [x28, #2]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc2400f87 // ldr c7, [x28, #3]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401387 // ldr c7, [x28, #4]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2401787 // ldr c7, [x28, #5]
	.inst 0xc2c7a741 // chkeq c26, c7
	b.ne comparison_fail
	.inst 0xc2401b87 // ldr c7, [x28, #6]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2401f87 // ldr c7, [x28, #7]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_SP_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2984107 // mrs c7, CSP_EL0
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000101e
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400018
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400410
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
	.zero 4080
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x01, 0x00
.data
check_data3:
	.byte 0xdf, 0xeb, 0x53, 0xb8, 0x05, 0x0a, 0xc0, 0x5a, 0xc5, 0x43, 0xc0, 0xc2, 0x1d, 0xfc, 0x9f, 0x48
	.byte 0x1f, 0x30, 0x3a, 0x78, 0x80, 0x84, 0xc0, 0xc2
.data
check_data4:
	.byte 0xe0, 0x7f, 0xbd, 0x08, 0xfd, 0x43, 0xa9, 0x78, 0xb6, 0x33, 0xc0, 0xc2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000200000000000000000000101e
	/* C4 */
	.octa 0x20408002000100050000000040400401
	/* C9 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x8001000400000000000010c2
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000200000000000000000000101e
	/* C4 */
	.octa 0x20408002000100050000000040400401
	/* C5 */
	.octa 0x80010004000000000000101e
	/* C9 */
	.octa 0x0
	/* C22 */
	.octa 0xffffffffffffffff
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x8001000400000000000010c2
initial_SP_EL0_value:
	.octa 0xc0000000004140050000000000001ff0
initial_DDC_EL0_value:
	.octa 0xc00000000006000500ffffffff800001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc0000000004140050000000000001ff0
final_PCC_value:
	.octa 0x20408000000100050000000040400410
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000218200030000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400410
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x021e039c // add c28, c28, #1920
	.inst 0xc2c21380 // br c28

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
