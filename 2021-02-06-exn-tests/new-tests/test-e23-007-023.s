.section text0, #alloc, #execinstr
test_start:
	.inst 0x787d13f1 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:17 Rn:31 00:00 opc:001 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x393fbc1e // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:111111101111 opc:00 111001:111001 size:00
	.inst 0x2816bfdd // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:29 Rn:30 Rt2:01111 imm7:0101101 L:0 1010000:1010000 opc:00
	.inst 0xc2c5f1ba // CVTPZ-C.R-C Cd:26 Rn:13 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x82634306 // ALDR-C.RI-C Ct:6 Rn:24 op:00 imm9:000110100 L:1 1000001001:1000001001
	.zero 1004
	.inst 0xc2c05bde // ALIGNU-C.CI-C Cd:30 Cn:30 0110:0110 U:1 imm6:000000 11000010110:11000010110
	.inst 0xc2c1a8c0 // EORFLGS-C.CR-C Cd:0 Cn:6 1010:1010 opc:10 Rm:1 11000010110:11000010110
	.inst 0x225ffc73 // LDAXR-C.R-C Ct:19 Rn:3 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xc8a07c1e // cas:aarch64/instrs/memory/atomicops/cas/single Rt:30 Rn:0 11111:11111 o0:0 Rs:0 1:1 L:0 0010001:0010001 size:11
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
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a83 // ldr c3, [x20, #2]
	.inst 0xc2400e86 // ldr c6, [x20, #3]
	.inst 0xc240128d // ldr c13, [x20, #4]
	.inst 0xc240168f // ldr c15, [x20, #5]
	.inst 0xc2401a98 // ldr c24, [x20, #6]
	.inst 0xc2401e9d // ldr c29, [x20, #7]
	.inst 0xc240229e // ldr c30, [x20, #8]
	/* Set up flags and system registers */
	ldr x20, =0x4000000
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
	ldr x20, =0x0
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
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601214 // ldr c20, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400290 // ldr c16, [x20, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400690 // ldr c16, [x20, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400a90 // ldr c16, [x20, #2]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400e90 // ldr c16, [x20, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2401290 // ldr c16, [x20, #4]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc2401690 // ldr c16, [x20, #5]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2401a90 // ldr c16, [x20, #6]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc2401e90 // ldr c16, [x20, #7]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc2402290 // ldr c16, [x20, #8]
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	.inst 0xc2402690 // ldr c16, [x20, #9]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc2402a90 // ldr c16, [x20, #10]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2402e90 // ldr c16, [x20, #11]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check system registers */
	ldr x20, =final_SP_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984110 // mrs c16, CSP_EL0
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	ldr x20, =final_PCC_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	ldr x20, =esr_el1_dump_address
	ldr x20, [x20]
	mov x16, 0x80
	orr x20, x20, x16
	ldr x16, =0x920000a9
	cmp x16, x20
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001012
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010b4
	ldr x1, =check_data2
	ldr x2, =0x000010bc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001400
	ldr x1, =check_data3
	ldr x2, =0x00001410
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
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xff, 0xff
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xf1, 0x13, 0x7d, 0x78, 0x1e, 0xbc, 0x3f, 0x39, 0xdd, 0xbf, 0x16, 0x28, 0xba, 0xf1, 0xc5, 0xc2
	.byte 0x06, 0x43, 0x63, 0x82
.data
check_data5:
	.byte 0xde, 0x5b, 0xc0, 0xc2, 0xc0, 0xa8, 0xc1, 0xc2, 0x73, 0xfc, 0x5f, 0x22, 0x1e, 0x7c, 0xa0, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000b00070000000000000011
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1400
	/* C6 */
	.octa 0x800000000000000000001000
	/* C13 */
	.octa 0x4000000000000000
	/* C15 */
	.octa 0x100
	/* C24 */
	.octa 0x7ffffffffffcc0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000520400010000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1400
	/* C6 */
	.octa 0x800000000000000000001000
	/* C13 */
	.octa 0x4000000000000000
	/* C15 */
	.octa 0x100
	/* C17 */
	.octa 0xffff
	/* C19 */
	.octa 0x0
	/* C24 */
	.octa 0x7ffffffffffcc0
	/* C26 */
	.octa 0x20008000274000004000000000000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000520400010000000000001000
initial_SP_EL0_value:
	.octa 0xc0000000580400000000000000001010
initial_DDC_EL0_value:
	.octa 0x8000000000000000000000000
initial_DDC_EL1_value:
	.octa 0xc00000000007000700ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x20008000400000410000000040400000
final_SP_EL0_value:
	.octa 0xc0000000580400000000000000001010
final_PCC_value:
	.octa 0x20008000400000410000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000274000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001400
	.dword initial_cap_values + 0
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001400
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x00000000000010b0
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
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02000294 // add c20, c20, #0
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02020294 // add c20, c20, #128
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02040294 // add c20, c20, #256
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02060294 // add c20, c20, #384
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02080294 // add c20, c20, #512
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x020a0294 // add c20, c20, #640
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x020c0294 // add c20, c20, #768
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x020e0294 // add c20, c20, #896
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02100294 // add c20, c20, #1024
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02120294 // add c20, c20, #1152
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02140294 // add c20, c20, #1280
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02160294 // add c20, c20, #1408
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x02180294 // add c20, c20, #1536
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x021a0294 // add c20, c20, #1664
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
	.inst 0x021c0294 // add c20, c20, #1792
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600e14 // ldr x20, [c16, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400e14 // str x20, [c16, #0]
	ldr x20, =0x40400414
	mrs x16, ELR_EL1
	sub x20, x20, x16
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b290 // cvtp c16, x20
	.inst 0xc2d44210 // scvalue c16, c16, x20
	.inst 0x82600214 // ldr c20, [c16, #0]
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
