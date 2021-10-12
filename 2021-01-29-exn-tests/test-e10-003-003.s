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
	.inst 0x9285d599 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:25 imm16:0010111010101100 hw:00 100101:100101 opc:00 sf:1
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
	ldr x20, =initial_cap_values
	.inst 0xc2400285 // ldr c5, [x20, #0]
	.inst 0xc2400686 // ldr c6, [x20, #1]
	.inst 0xc2400a87 // ldr c7, [x20, #2]
	.inst 0xc2400e88 // ldr c8, [x20, #3]
	.inst 0xc240128d // ldr c13, [x20, #4]
	.inst 0xc240168e // ldr c14, [x20, #5]
	.inst 0xc2401a90 // ldr c16, [x20, #6]
	.inst 0xc2401e93 // ldr c19, [x20, #7]
	.inst 0xc240229b // ldr c27, [x20, #8]
	.inst 0xc240269d // ldr c29, [x20, #9]
	/* Set up flags and system registers */
	ldr x20, =0x0
	msr SPSR_EL3, x20
	ldr x20, =initial_SP_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2884114 // msr CSP_EL0, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30d5d99f
	msr SCTLR_EL1, x20
	ldr x20, =0xc0000
	msr CPACR_EL1, x20
	ldr x20, =0x4
	msr S3_0_C1_C2_2, x20 // CCTLR_EL1
	ldr x20, =0x0
	msr S3_3_C1_C2_2, x20 // CCTLR_EL0
	ldr x20, =initial_DDC_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2884134 // msr DDC_EL0, c20
	ldr x20, =initial_DDC_EL1_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc28c4134 // msr DDC_EL1, c20
	ldr x20, =0x80000000
	msr HCR_EL2, x20
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601194 // ldr c20, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e4034 // msr CELR_EL3, c20
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x12, #0xf
	and x20, x20, x12
	cmp x20, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240028c // ldr c12, [x20, #0]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240068c // ldr c12, [x20, #1]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc2400a8c // ldr c12, [x20, #2]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc2400e8c // ldr c12, [x20, #3]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc240128c // ldr c12, [x20, #4]
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	.inst 0xc240168c // ldr c12, [x20, #5]
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	.inst 0xc2401a8c // ldr c12, [x20, #6]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc2401e8c // ldr c12, [x20, #7]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240228c // ldr c12, [x20, #8]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc240268c // ldr c12, [x20, #9]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc2402a8c // ldr c12, [x20, #10]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc2402e8c // ldr c12, [x20, #11]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc240328c // ldr c12, [x20, #12]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check system registers */
	ldr x20, =final_SP_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc298410c // mrs c12, CSP_EL0
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	ldr x20, =final_PCC_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	ldr x12, =esr_el1_dump_address
	ldr x12, [x12]
	mov x20, 0x83
	orr x12, x12, x20
	ldr x20, =0x920000ab
	cmp x20, x12
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
	ldr x0, =0x00001064
	ldr x1, =check_data1
	ldr x2, =0x00001068
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x000010a0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001802
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f0e
	ldr x1, =check_data4
	ldr x2, =0x00001f10
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
	.byte 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x20, 0x00
.data
check_data5:
	.byte 0xee, 0xe8, 0x30, 0x78, 0xbe, 0x51, 0x33, 0x38, 0xfe, 0xeb, 0x07, 0x78, 0x61, 0x9b, 0xe5, 0xc2
	.byte 0xec, 0xd3, 0xe6, 0x82
.data
check_data6:
	.byte 0xa8, 0x6f, 0x02, 0x62, 0xbd, 0x4b, 0x80, 0xe2, 0xcf, 0x03, 0x15, 0x1a, 0x99, 0xd5, 0x85, 0x92
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x8000003c
	/* C7 */
	.octa 0x800
	/* C8 */
	.octa 0x4000000000000000000000000000
	/* C13 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x1000
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x48000000000700070000000000001040
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x8000003c
	/* C7 */
	.octa 0x800
	/* C8 */
	.octa 0x4000000000000000000000000000
	/* C13 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x1000
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0xffffffffffffd153
	/* C27 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20
initial_SP_EL0_value:
	.octa 0x1e90
initial_DDC_EL0_value:
	.octa 0xc00000000003000700ffe00000000001
initial_DDC_EL1_value:
	.octa 0x800000000007000d0000000000000003
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400001
final_SP_EL0_value:
	.octa 0x1e90
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000420000000000000040400000
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
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
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
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x02000294 // add c20, c20, #0
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x02020294 // add c20, c20, #128
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x02040294 // add c20, c20, #256
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x02060294 // add c20, c20, #384
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x02080294 // add c20, c20, #512
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x020a0294 // add c20, c20, #640
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x020c0294 // add c20, c20, #768
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x020e0294 // add c20, c20, #896
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x02100294 // add c20, c20, #1024
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x02120294 // add c20, c20, #1152
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x02140294 // add c20, c20, #1280
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x02160294 // add c20, c20, #1408
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x02180294 // add c20, c20, #1536
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x021a0294 // add c20, c20, #1664
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x021c0294 // add c20, c20, #1792
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600d94 // ldr x20, [c12, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d94 // str x20, [c12, #0]
	ldr x20, =0x40400414
	mrs x12, ELR_EL1
	sub x20, x20, x12
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28c // cvtp c12, x20
	.inst 0xc2d4418c // scvalue c12, c12, x20
	.inst 0x82600194 // ldr c20, [c12, #0]
	.inst 0x021e0294 // add c20, c20, #1920
	.inst 0xc2c21280 // br c20

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
