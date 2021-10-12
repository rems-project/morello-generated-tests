.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2bf7d80 // CAS-C.R-C Ct:0 Rn:12 11111:11111 R:0 Cs:31 1:1 L:0 1:1 10100010:10100010
	.inst 0x48dffdc1 // ldarh:aarch64/instrs/memory/ordered Rt:1 Rn:14 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xd3773bde // ubfm:aarch64/instrs/integer/bitfield Rd:30 Rn:30 imms:001110 immr:110111 N:1 100110:100110 opc:10 sf:1
	.inst 0xb8604a60 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:0 Rn:19 10:10 S:0 option:010 Rm:0 1:1 opc:01 111000:111000 size:10
	.inst 0xc2bdacff // ADD-C.CRI-C Cd:31 Cn:7 imm3:011 option:101 Rm:29 11000010101:11000010101
	.inst 0xc2d127c1 // 0xc2d127c1
	.inst 0x7a5b6b26 // 0x7a5b6b26
	.inst 0xc2c5b25f // 0xc2c5b25f
	.inst 0x78a13000 // 0x78a13000
	.inst 0xd4000001
	.zero 984
	.inst 0x00001180
	.zero 64508
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a7 // ldr c7, [x5, #1]
	.inst 0xc24008ac // ldr c12, [x5, #2]
	.inst 0xc2400cae // ldr c14, [x5, #3]
	.inst 0xc24010b1 // ldr c17, [x5, #4]
	.inst 0xc24014b2 // ldr c18, [x5, #5]
	.inst 0xc24018b3 // ldr c19, [x5, #6]
	.inst 0xc2401cbd // ldr c29, [x5, #7]
	/* Set up flags and system registers */
	ldr x5, =0x0
	msr SPSR_EL3, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0xc0000
	msr CPACR_EL1, x5
	ldr x5, =0x0
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x8
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011e5 // ldr c5, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x15, #0xf
	and x5, x5, x15
	cmp x5, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000af // ldr c15, [x5, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24004af // ldr c15, [x5, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24008af // ldr c15, [x5, #2]
	.inst 0xc2cfa4e1 // chkeq c7, c15
	b.ne comparison_fail
	.inst 0xc2400caf // ldr c15, [x5, #3]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc24010af // ldr c15, [x5, #4]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc24014af // ldr c15, [x5, #5]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc24018af // ldr c15, [x5, #6]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc2401caf // ldr c15, [x5, #7]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	.inst 0xc24020af // ldr c15, [x5, #8]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc298410f // mrs c15, CSP_EL0
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001180
	ldr x1, =check_data1
	ldr x2, =0x00001182
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001410
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
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400404
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.zero 2
.data
check_data1:
	.byte 0xff, 0xff
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x80, 0x7d, 0xbf, 0xa2, 0xc1, 0xfd, 0xdf, 0x48, 0xde, 0x3b, 0x77, 0xd3, 0x60, 0x4a, 0x60, 0xb8
	.byte 0xff, 0xac, 0xbd, 0xc2, 0xc1, 0x27, 0xd1, 0xc2, 0x26, 0x6b, 0x5b, 0x7a, 0x5f, 0xb2, 0xc5, 0xc2
	.byte 0x00, 0x30, 0xa1, 0x78, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.byte 0x80, 0x11, 0x00, 0x00

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C7 */
	.octa 0xc000c0000001e00380000000
	/* C12 */
	.octa 0x1400
	/* C14 */
	.octa 0x1000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x1ffc040400003
	/* C19 */
	.octa 0x40400400
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffffffffffffff
	/* C7 */
	.octa 0xc000c0000001e00380000000
	/* C12 */
	.octa 0x1400
	/* C14 */
	.octa 0x1000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x1ffc040400003
	/* C19 */
	.octa 0x40400400
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd0000000200b000700ffe00000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc000c0000001e00380000000
final_PCC_value:
	.octa 0x20008000000100070000000040400028
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
	.dword el1_vector_jump_cap
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40400028
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
