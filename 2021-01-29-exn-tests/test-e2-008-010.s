.section text0, #alloc, #execinstr
test_start:
	.inst 0x91345bad // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:13 Rn:29 imm12:110100010110 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xf255b57d // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:29 Rn:11 imms:101101 immr:010101 N:1 100100:100100 opc:11 sf:1
	.inst 0x1ad62e40 // rorv:aarch64/instrs/integer/shift/variable Rd:0 Rn:18 op2:11 0010:0010 Rm:22 0011010110:0011010110 sf:0
	.inst 0xc2d94938 // UNSEAL-C.CC-C Cd:24 Cn:9 0010:0010 opc:01 Cm:25 11000010110:11000010110
	.inst 0xe2019881 // ALDURSB-R.RI-64 Rt:1 Rn:4 op2:10 imm9:000011001 V:0 op1:00 11100010:11100010
	.zero 9196
	.inst 0x9b34fffe // 0x9b34fffe
	.inst 0xb8fe32b0 // 0xb8fe32b0
	.inst 0xfa4063ea // 0xfa4063ea
	.inst 0xc8df7c1f // 0xc8df7c1f
	.inst 0xd4000001
	.zero 56300
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
	.inst 0xc2400384 // ldr c4, [x28, #0]
	.inst 0xc2400789 // ldr c9, [x28, #1]
	.inst 0xc2400b8b // ldr c11, [x28, #2]
	.inst 0xc2400f92 // ldr c18, [x28, #3]
	.inst 0xc2401395 // ldr c21, [x28, #4]
	.inst 0xc2401796 // ldr c22, [x28, #5]
	.inst 0xc2401b99 // ldr c25, [x28, #6]
	/* Set up flags and system registers */
	ldr x28, =0x4000000
	msr SPSR_EL3, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0xc0000
	msr CPACR_EL1, x28
	ldr x28, =0x4
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
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011dc // ldr c28, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
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
	mov x14, #0xf
	and x28, x28, x14
	cmp x28, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038e // ldr c14, [x28, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240078e // ldr c14, [x28, #1]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc2400b8e // ldr c14, [x28, #2]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc2400f8e // ldr c14, [x28, #3]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc240138e // ldr c14, [x28, #4]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc240178e // ldr c14, [x28, #5]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc2401b8e // ldr c14, [x28, #6]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc2401f8e // ldr c14, [x28, #7]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc240238e // ldr c14, [x28, #8]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc240278e // ldr c14, [x28, #9]
	.inst 0xc2cea721 // chkeq c25, c14
	b.ne comparison_fail
	.inst 0xc2402b8e // ldr c14, [x28, #10]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc2402f8e // ldr c14, [x28, #11]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	ldr x14, =esr_el1_dump_address
	ldr x14, [x14]
	mov x28, 0x83
	orr x14, x14, x28
	ldr x28, =0x920000ab
	cmp x28, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40402400
	ldr x1, =check_data2
	ldr x2, =0x40402414
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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
	.byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
.data
check_data1:
	.byte 0xad, 0x5b, 0x34, 0x91, 0x7d, 0xb5, 0x55, 0xf2, 0x40, 0x2e, 0xd6, 0x1a, 0x38, 0x49, 0xd9, 0xc2
	.byte 0x81, 0x98, 0x01, 0xe2
.data
check_data2:
	.byte 0xfe, 0xff, 0x34, 0x9b, 0xb0, 0x32, 0xfe, 0xb8, 0xea, 0x63, 0x40, 0xfa, 0x1f, 0x7c, 0xdf, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x7fffffffffffe7
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x80000000001
	/* C18 */
	.octa 0x4000
	/* C21 */
	.octa 0x1000
	/* C22 */
	.octa 0x2
	/* C25 */
	.octa 0x4000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C4 */
	.octa 0x7fffffffffffe7
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x80000000001
	/* C16 */
	.octa 0xfefefefe
	/* C18 */
	.octa 0x4000
	/* C21 */
	.octa 0x1000
	/* C22 */
	.octa 0x2
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x80000000001
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x700060000000000000000
initial_DDC_EL1_value:
	.octa 0xc00000000003000700ffe00000000000
initial_VBAR_EL1_value:
	.octa 0x200080007000201d0000000040402000
final_PCC_value:
	.octa 0x200080007000201d0000000040402414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000004000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
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
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x82600ddc // ldr x28, [c14, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400ddc // str x28, [c14, #0]
	ldr x28, =0x40402414
	mrs x14, ELR_EL1
	sub x28, x28, x14
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38e // cvtp c14, x28
	.inst 0xc2dc41ce // scvalue c14, c14, x28
	.inst 0x826001dc // ldr c28, [c14, #0]
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
