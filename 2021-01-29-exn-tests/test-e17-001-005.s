.section text0, #alloc, #execinstr
test_start:
	.inst 0x08df7fd4 // ldlarb:aarch64/instrs/memory/ordered Rt:20 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xb87b835a // swp:aarch64/instrs/memory/atomicops/swp Rt:26 Rn:26 100000:100000 Rs:27 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x826e50b4 // ALDR-C.RI-C Ct:20 Rn:5 op:00 imm9:011100101 L:1 1000001001:1000001001
	.inst 0x7818c3df // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:30 00:00 imm9:110001100 0:0 opc:00 111000:111000 size:01
	.inst 0x423f7fac // ASTLRB-R.R-B Rt:12 Rn:29 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.zero 1004
	.inst 0xf82010df // 0xf82010df
	.inst 0x5a9fc57d // 0x5a9fc57d
	.inst 0xc2e89b1f // 0xc2e89b1f
	.inst 0x38530c5f // 0x38530c5f
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
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400945 // ldr c5, [x10, #2]
	.inst 0xc2400d46 // ldr c6, [x10, #3]
	.inst 0xc2401148 // ldr c8, [x10, #4]
	.inst 0xc2401558 // ldr c24, [x10, #5]
	.inst 0xc240195a // ldr c26, [x10, #6]
	.inst 0xc2401d5b // ldr c27, [x10, #7]
	.inst 0xc240215d // ldr c29, [x10, #8]
	.inst 0xc240255e // ldr c30, [x10, #9]
	/* Set up flags and system registers */
	ldr x10, =0x0
	msr SPSR_EL3, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0xc0000
	msr CPACR_EL1, x10
	ldr x10, =0x0
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x0
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011ca // ldr c10, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
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
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x14, #0xf
	and x10, x10, x14
	cmp x10, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240014e // ldr c14, [x10, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240054e // ldr c14, [x10, #1]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc240094e // ldr c14, [x10, #2]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc2400d4e // ldr c14, [x10, #3]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc240114e // ldr c14, [x10, #4]
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	.inst 0xc240154e // ldr c14, [x10, #5]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc240194e // ldr c14, [x10, #6]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc2401d4e // ldr c14, [x10, #7]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc240214e // ldr c14, [x10, #8]
	.inst 0xc2cea761 // chkeq c27, c14
	b.ne comparison_fail
	.inst 0xc240254e // ldr c14, [x10, #9]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	ldr x14, =esr_el1_dump_address
	ldr x14, [x14]
	mov x10, 0x83
	orr x14, x14, x10
	ldr x10, =0x920000eb
	cmp x10, x14
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
	ldr x0, =0x00001014
	ldr x1, =check_data1
	ldr x2, =0x00001016
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001050
	ldr x1, =check_data2
	ldr x2, =0x00001060
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001088
	ldr x1, =check_data3
	ldr x2, =0x00001089
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001100
	ldr x1, =check_data4
	ldr x2, =0x00001108
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001730
	ldr x1, =check_data5
	ldr x2, =0x00001731
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x40400414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.zero 256
	.byte 0x00, 0x10, 0xfb, 0xf9, 0xfd, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x10, 0xfb, 0xf9, 0xfd, 0x00, 0x00, 0xff
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xd4, 0x7f, 0xdf, 0x08, 0x5a, 0x83, 0x7b, 0xb8, 0xb4, 0x50, 0x6e, 0x82, 0xdf, 0xc3, 0x18, 0x78
	.byte 0xac, 0x7f, 0x3f, 0x42
.data
check_data7:
	.byte 0xdf, 0x10, 0x20, 0xf8, 0x7d, 0xc5, 0x9f, 0x5a, 0x1f, 0x9b, 0xe8, 0xc2, 0x5f, 0x0c, 0x53, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000600000020000000000001800
	/* C5 */
	.octa 0x80100000080700af0000000000000200
	/* C6 */
	.octa 0xc00000000007028f0000000000001100
	/* C8 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x1000
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1088
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000600000020000000000001730
	/* C5 */
	.octa 0x80100000080700af0000000000000200
	/* C6 */
	.octa 0xc00000000007028f0000000000001100
	/* C8 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x1088
initial_DDC_EL0_value:
	.octa 0xc000000000070cef0000000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000600100150000000040400001
final_PCC_value:
	.octa 0x20008000600100150000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword initial_DDC_EL0_value
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x82600dca // ldr x10, [c14, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400dca // str x10, [c14, #0]
	ldr x10, =0x40400414
	mrs x14, ELR_EL1
	sub x10, x10, x14
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14e // cvtp c14, x10
	.inst 0xc2ca41ce // scvalue c14, c14, x10
	.inst 0x826001ca // ldr c10, [c14, #0]
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
