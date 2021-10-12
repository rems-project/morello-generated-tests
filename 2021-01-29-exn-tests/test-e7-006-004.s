.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bfc03d // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:29 Rn:1 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x79e6403e // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:1 imm12:100110010000 opc:11 111001:111001 size:01
	.inst 0x425ffe5e // LDAR-C.R-C Ct:30 Rn:18 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x1a0e03a1 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:29 000000:000000 Rm:14 11010000:11010000 S:0 op:0 sf:0
	.inst 0x781e7fb3 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:19 Rn:29 11:11 imm9:111100111 0:0 opc:00 111000:111000 size:01
	.zero 4204
	.inst 0x00000002
	.zero 13180
	.inst 0xc2c8443e // 0xc2c8443e
	.inst 0x3ddf2aa0 // 0x3ddf2aa0
	.inst 0x82608947 // 0x82608947
	.inst 0xc221d6bf // 0xc221d6bf
	.inst 0xd4000001
	.zero 48108
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
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400788 // ldr c8, [x28, #1]
	.inst 0xc2400b8a // ldr c10, [x28, #2]
	.inst 0xc2400f92 // ldr c18, [x28, #3]
	.inst 0xc2401395 // ldr c21, [x28, #4]
	/* Set up flags and system registers */
	ldr x28, =0x0
	msr SPSR_EL3, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0x3c0000
	msr CPACR_EL1, x28
	ldr x28, =0x0
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x4
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
	ldr x28, =initial_DDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288413c // msr DDC_EL0, c28
	ldr x28, =initial_DDC_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28c413c // msr DDC_EL1, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x0, =pcc_return_ddc_capabilities
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0x8260101c // ldr c28, [c0, #1]
	.inst 0x82602000 // ldr c0, [c0, #2]
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
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x0, #0xf
	and x28, x28, x0
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2c0a4e1 // chkeq c7, c0
	b.ne comparison_fail
	.inst 0xc2400780 // ldr c0, [x28, #1]
	.inst 0xc2c0a501 // chkeq c8, c0
	b.ne comparison_fail
	.inst 0xc2400b80 // ldr c0, [x28, #2]
	.inst 0xc2c0a541 // chkeq c10, c0
	b.ne comparison_fail
	.inst 0xc2400f80 // ldr c0, [x28, #3]
	.inst 0xc2c0a641 // chkeq c18, c0
	b.ne comparison_fail
	.inst 0xc2401380 // ldr c0, [x28, #4]
	.inst 0xc2c0a6a1 // chkeq c21, c0
	b.ne comparison_fail
	.inst 0xc2401780 // ldr c0, [x28, #5]
	.inst 0xc2c0a7a1 // chkeq c29, c0
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x0, v0.d[0]
	cmp x28, x0
	b.ne comparison_fail
	ldr x28, =0x0
	mov x0, v0.d[1]
	cmp x28, x0
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2984020 // mrs c0, CELR_EL1
	.inst 0xc2c0a781 // chkeq c28, c0
	b.ne comparison_fail
	ldr x0, =esr_el1_dump_address
	ldr x0, [x0]
	mov x28, 0x83
	orr x0, x0, x28
	ldr x28, =0x920000e3
	cmp x28, x0
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
	ldr x0, =0x00001530
	ldr x1, =check_data1
	ldr x2, =0x00001540
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40401080
	ldr x1, =check_data5
	ldr x2, =0x40401081
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x404023a0
	ldr x1, =check_data6
	ldr x2, =0x404023a2
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40404400
	ldr x1, =check_data7
	ldr x2, =0x40404414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x3d, 0xc0, 0xbf, 0x38, 0x3e, 0x40, 0xe6, 0x79, 0x5e, 0xfe, 0x5f, 0x42, 0xa1, 0x03, 0x0e, 0x1a
	.byte 0xb3, 0x7f, 0x1e, 0x78
.data
check_data5:
	.byte 0x02
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0x3e, 0x44, 0xc8, 0xc2, 0xa0, 0x2a, 0xdf, 0x3d, 0x47, 0x89, 0x60, 0x82, 0xbf, 0xd6, 0x21, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40401080
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1fd8
	/* C18 */
	.octa 0x1000
	/* C21 */
	.octa 0xc000000000010005ffffffffffff9890
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1fd8
	/* C18 */
	.octa 0x1000
	/* C21 */
	.octa 0xc000000000010005ffffffffffff9890
	/* C29 */
	.octa 0x2
initial_DDC_EL0_value:
	.octa 0xc01000000001800600ffffffffff0001
initial_DDC_EL1_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x2000800048000c1d0000000040404001
final_PCC_value:
	.octa 0x2000800048000c1d0000000040404414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x82600c1c // ldr x28, [c0, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400c1c // str x28, [c0, #0]
	ldr x28, =0x40404414
	mrs x0, ELR_EL1
	sub x28, x28, x0
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b380 // cvtp c0, x28
	.inst 0xc2dc4000 // scvalue c0, c0, x28
	.inst 0x8260001c // ldr c28, [c0, #0]
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
