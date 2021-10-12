.section text0, #alloc, #execinstr
test_start:
	.inst 0x7830e8ee // strh_reg:aarch64/instrs/memory/single/general/register Rt:14 Rn:7 10:10 S:0 option:111 Rm:16 1:1 opc:00 111000:111000 size:01
	.inst 0x383351be // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:13 00:00 opc:101 0:0 Rs:19 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x7807ebfe // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:31 10:10 imm9:001111110 0:0 opc:00 111000:111000 size:01
	.inst 0xc2e59b61 // SUBS-R.CC-C Rd:1 Cn:27 100110:100110 Cm:5 11000010111:11000010111
	.inst 0x82e6d3ec // ALDR-R.RRB-32 Rt:12 Rn:31 opc:00 S:1 option:110 Rm:6 1:1 L:1 100000101:100000101
	.inst 0x62026fa8 // 0x62026fa8
	.inst 0xe2804bbd // 0xe2804bbd
	.inst 0x1a1503cf // 0x1a1503cf
	.inst 0x9285d599 // 0x9285d599
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
	ldr x11, =initial_cap_values
	.inst 0xc2400165 // ldr c5, [x11, #0]
	.inst 0xc2400566 // ldr c6, [x11, #1]
	.inst 0xc2400967 // ldr c7, [x11, #2]
	.inst 0xc2400d68 // ldr c8, [x11, #3]
	.inst 0xc240116d // ldr c13, [x11, #4]
	.inst 0xc240156e // ldr c14, [x11, #5]
	.inst 0xc2401970 // ldr c16, [x11, #6]
	.inst 0xc2401d73 // ldr c19, [x11, #7]
	.inst 0xc240217b // ldr c27, [x11, #8]
	.inst 0xc240257d // ldr c29, [x11, #9]
	/* Set up flags and system registers */
	ldr x11, =0x0
	msr SPSR_EL3, x11
	ldr x11, =initial_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288410b // msr CSP_EL0, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0xc0000
	msr CPACR_EL1, x11
	ldr x11, =0x0
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x0
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260128b // ldr c11, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc28e402b // msr CELR_EL3, c11
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x20, #0xf
	and x11, x11, x20
	cmp x11, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400174 // ldr c20, [x11, #0]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400574 // ldr c20, [x11, #1]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc2400974 // ldr c20, [x11, #2]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2400d74 // ldr c20, [x11, #3]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2401174 // ldr c20, [x11, #4]
	.inst 0xc2d4a501 // chkeq c8, c20
	b.ne comparison_fail
	.inst 0xc2401574 // ldr c20, [x11, #5]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2401974 // ldr c20, [x11, #6]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2401d74 // ldr c20, [x11, #7]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2402174 // ldr c20, [x11, #8]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2402574 // ldr c20, [x11, #9]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc2402974 // ldr c20, [x11, #10]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc2402d74 // ldr c20, [x11, #11]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc2403174 // ldr c20, [x11, #12]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2403574 // ldr c20, [x11, #13]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984114 // mrs c20, CSP_EL0
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a561 // chkeq c11, c20
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
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000100e
	ldr x1, =check_data2
	ldr x2, =0x00001014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001040
	ldr x1, =check_data3
	ldr x2, =0x00001060
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001802
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xee, 0xe8, 0x30, 0x78, 0xbe, 0x51, 0x33, 0x38, 0xfe, 0xeb, 0x07, 0x78, 0x61, 0x9b, 0xe5, 0xc2
	.byte 0xec, 0xd3, 0xe6, 0x82, 0xa8, 0x6f, 0x02, 0x62, 0xbd, 0x4b, 0x80, 0xe2, 0xcf, 0x03, 0x15, 0x1a
	.byte 0x99, 0xd5, 0x85, 0x92, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x20
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x1800
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000100070000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x20
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x1800
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0xffffffffffffd153
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x8
initial_SP_EL0_value:
	.octa 0x80000000540808290000000000000f90
initial_DDC_EL0_value:
	.octa 0xcc000000000300060000000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x80000000540808290000000000000f90
final_PCC_value:
	.octa 0x200080004800c8010000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004800c8010000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x82600e8b // ldr x11, [c20, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e8b // str x11, [c20, #0]
	ldr x11, =0x40400028
	mrs x20, ELR_EL1
	sub x11, x11, x20
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b174 // cvtp c20, x11
	.inst 0xc2cb4294 // scvalue c20, c20, x11
	.inst 0x8260028b // ldr c11, [c20, #0]
	.inst 0x021e016b // add c11, c11, #1920
	.inst 0xc2c21160 // br c11

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
