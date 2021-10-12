.section text0, #alloc, #execinstr
test_start:
	.inst 0x7830e8ee // strh_reg:aarch64/instrs/memory/single/general/register Rt:14 Rn:7 10:10 S:0 option:111 Rm:16 1:1 opc:00 111000:111000 size:01
	.inst 0x383351be // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:13 00:00 opc:101 0:0 Rs:19 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x7807ebfe // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:31 10:10 imm9:001111110 0:0 opc:00 111000:111000 size:01
	.inst 0xc2e59b61 // SUBS-R.CC-C Rd:1 Cn:27 100110:100110 Cm:5 11000010111:11000010111
	.inst 0x82e6d3ec // ALDR-R.RRB-32 Rt:12 Rn:31 opc:00 S:1 option:110 Rm:6 1:1 L:1 100000101:100000101
	.zero 1004
	.inst 0x62026fa8 // 0x62026fa8
	.inst 0xe2804bbd // 0xe2804bbd
	.inst 0x1a1503cf // 0x1a1503cf
	.inst 0x9285d599 // 0x9285d599
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
	ldr x3, =initial_cap_values
	.inst 0xc2400065 // ldr c5, [x3, #0]
	.inst 0xc2400466 // ldr c6, [x3, #1]
	.inst 0xc2400867 // ldr c7, [x3, #2]
	.inst 0xc2400c68 // ldr c8, [x3, #3]
	.inst 0xc240106d // ldr c13, [x3, #4]
	.inst 0xc240146e // ldr c14, [x3, #5]
	.inst 0xc2401870 // ldr c16, [x3, #6]
	.inst 0xc2401c73 // ldr c19, [x3, #7]
	.inst 0xc240207b // ldr c27, [x3, #8]
	.inst 0xc240247d // ldr c29, [x3, #9]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =initial_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884103 // msr CSP_EL0, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0xc0000
	msr CPACR_EL1, x3
	ldr x3, =0x4
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x0
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =initial_DDC_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4123 // msr DDC_EL1, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601183 // ldr c3, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
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
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x12, #0xf
	and x3, x3, x12
	cmp x3, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006c // ldr c12, [x3, #0]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240046c // ldr c12, [x3, #1]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc240086c // ldr c12, [x3, #2]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc2400c6c // ldr c12, [x3, #3]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc240106c // ldr c12, [x3, #4]
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	.inst 0xc240146c // ldr c12, [x3, #5]
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	.inst 0xc240186c // ldr c12, [x3, #6]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc2401c6c // ldr c12, [x3, #7]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240206c // ldr c12, [x3, #8]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc240246c // ldr c12, [x3, #9]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc240286c // ldr c12, [x3, #10]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc2402c6c // ldr c12, [x3, #11]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc240306c // ldr c12, [x3, #12]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298410c // mrs c12, CSP_EL0
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	ldr x12, =esr_el1_dump_address
	ldr x12, [x12]
	mov x3, 0x83
	orr x12, x12, x3
	ldr x3, =0x920000ab
	cmp x3, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001060
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000107e
	ldr x1, =check_data1
	ldr x2, =0x00001080
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a0
	ldr x1, =check_data2
	ldr x2, =0x000010a2
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
	ldr x0, =0x40400064
	ldr x1, =check_data4
	ldr x2, =0x40400068
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.byte 0x02, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xee, 0xe8, 0x30, 0x78, 0xbe, 0x51, 0x33, 0x38, 0xfe, 0xeb, 0x07, 0x78, 0x61, 0x9b, 0xe5, 0xc2
	.byte 0xec, 0xd3, 0xe6, 0x82
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xa8, 0x6f, 0x02, 0x62, 0xbd, 0x4b, 0x80, 0xe2, 0xcf, 0x03, 0x15, 0x1a, 0x99, 0xd5, 0x85, 0x92
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x1cc
	/* C7 */
	.octa 0x1010
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x10a1
	/* C14 */
	.octa 0x200
	/* C16 */
	.octa 0x90
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x4c000000510400020000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x1cc
	/* C7 */
	.octa 0x1010
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x10a1
	/* C14 */
	.octa 0x200
	/* C16 */
	.octa 0x90
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0xffffffffffffd153
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x2
initial_SP_EL0_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc0000000000300070000000000000001
initial_DDC_EL1_value:
	.octa 0x800000003c1ffc1d00000000403f0008
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400001
final_SP_EL0_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001e0640070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 160
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600d83 // ldr x3, [c12, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d83 // str x3, [c12, #0]
	ldr x3, =0x40400414
	mrs x12, ELR_EL1
	sub x3, x3, x12
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06c // cvtp c12, x3
	.inst 0xc2c3418c // scvalue c12, c12, x3
	.inst 0x82600183 // ldr c3, [c12, #0]
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
