.section text0, #alloc, #execinstr
test_start:
	.inst 0x38be63bd // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:29 00:00 opc:110 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x386043bd // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:29 00:00 opc:100 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x783d53ff // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:101 o3:0 Rs:29 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xf8bf13ff // ldclr:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:31 00:00 opc:001 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xed1b99c7 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:7 Rn:14 Rt2:00110 imm7:0110111 L:0 1011010:1011010 opc:11
	.zero 1004
	.inst 0x387563dd // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:30 00:00 opc:110 0:0 Rs:21 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xc2e92be0 // ORRFLGS-C.CI-C Cd:0 Cn:31 0:0 01:01 imm8:01001001 11000010111:11000010111
	.inst 0xa23e8021 // SWP-CC.R-C Ct:1 Rn:1 100000:100000 Cs:30 1:1 R:0 A:0 10100010:10100010
	.inst 0xd2c4356e // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:14 imm16:0010000110101011 hw:10 100101:100101 opc:10 sf:1
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400955 // ldr c21, [x10, #2]
	.inst 0xc2400d5d // ldr c29, [x10, #3]
	.inst 0xc240115e // ldr c30, [x10, #4]
	/* Set up flags and system registers */
	ldr x10, =0x0
	msr SPSR_EL3, x10
	ldr x10, =initial_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288410a // msr CSP_EL0, c10
	ldr x10, =initial_SP_EL1_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc28c410a // msr CSP_EL1, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0xc0000
	msr CPACR_EL1, x10
	ldr x10, =0x4
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x4
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =initial_DDC_EL1_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc28c412a // msr DDC_EL1, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260120a // ldr c10, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc28e402a // msr CELR_EL3, c10
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400150 // ldr c16, [x10, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400550 // ldr c16, [x10, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400950 // ldr c16, [x10, #2]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2400d50 // ldr c16, [x10, #3]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc2401150 // ldr c16, [x10, #4]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2401550 // ldr c16, [x10, #5]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984110 // mrs c16, CSP_EL0
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	ldr x10, =final_SP_EL1_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc29c4110 // mrs c16, CSP_EL1
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	ldr x16, =0x2000000
	cmp x16, x10
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001070
	ldr x1, =check_data2
	ldr x2, =0x00001071
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001200
	ldr x1, =check_data3
	ldr x2, =0x00001201
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff0
	ldr x1, =check_data4
	ldr x2, =0x00001ff8
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
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
	.byte 0x91, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 496
	.byte 0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3552
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x30, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x02, 0x08, 0x00, 0x04, 0x08, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x30
.data
check_data4:
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0xbd, 0x63, 0xbe, 0x38, 0xbd, 0x43, 0x60, 0x38, 0xff, 0x53, 0x3d, 0x78, 0xff, 0x13, 0xbf, 0xf8
	.byte 0xc7, 0x99, 0x1b, 0xed
.data
check_data6:
	.byte 0xdd, 0x63, 0x75, 0x38, 0xe0, 0x2b, 0xe9, 0xc2, 0x21, 0x80, 0x3e, 0xa2, 0x6e, 0x35, 0xc4, 0xd2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x230
	/* C30 */
	.octa 0x80400080210000000000000001030
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x3fff800000004900000000000000
	/* C1 */
	.octa 0x0
	/* C14 */
	.octa 0x21ab00000000
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x80400080210000000000000001030
initial_SP_EL0_value:
	.octa 0x1020
initial_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
initial_DDC_EL0_value:
	.octa 0xc0000000000707ee0000000000003dd7
initial_DDC_EL1_value:
	.octa 0xdc0000000207000c0000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004800d00d0000000040400000
final_SP_EL0_value:
	.octa 0x1020
final_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x200080004800d00d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004401d0020000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001040
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001040
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001070
	.dword 0x0000000000001200
	.dword 0x0000000000001ff0
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x82600e0a // ldr x10, [c16, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e0a // str x10, [c16, #0]
	ldr x10, =0x40400414
	mrs x16, ELR_EL1
	sub x10, x10, x16
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b150 // cvtp c16, x10
	.inst 0xc2ca4210 // scvalue c16, c16, x10
	.inst 0x8260020a // ldr c10, [c16, #0]
	.inst 0x021e014a // add c10, c10, #1920
	.inst 0xc2c21140 // br c10

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
