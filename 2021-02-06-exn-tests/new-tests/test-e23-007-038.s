.section text0, #alloc, #execinstr
test_start:
	.inst 0x787d13f1 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:17 Rn:31 00:00 opc:001 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x393fbc1e // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:111111101111 opc:00 111001:111001 size:00
	.inst 0x2816bfdd // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:29 Rn:30 Rt2:01111 imm7:0101101 L:0 1010000:1010000 opc:00
	.inst 0xc2c5f1ba // CVTPZ-C.R-C Cd:26 Rn:13 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x82634306 // ALDR-C.RI-C Ct:6 Rn:24 op:00 imm9:000110100 L:1 1000001001:1000001001
	.inst 0xc2c05bde // ALIGNU-C.CI-C Cd:30 Cn:30 0110:0110 U:1 imm6:000000 11000010110:11000010110
	.inst 0xc2c1a8c0 // EORFLGS-C.CR-C Cd:0 Cn:6 1010:1010 opc:10 Rm:1 11000010110:11000010110
	.inst 0x225ffc73 // LDAXR-C.R-C Ct:19 Rn:3 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xc8a07c1e // cas:aarch64/instrs/memory/atomicops/cas/single Rt:30 Rn:0 11111:11111 o0:0 Rs:0 1:1 L:0 0010001:0010001 size:11
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c3 // ldr c3, [x14, #2]
	.inst 0xc2400dcd // ldr c13, [x14, #3]
	.inst 0xc24011cf // ldr c15, [x14, #4]
	.inst 0xc24015d8 // ldr c24, [x14, #5]
	.inst 0xc24019dd // ldr c29, [x14, #6]
	.inst 0xc2401dde // ldr c30, [x14, #7]
	/* Set up flags and system registers */
	ldr x14, =0x4000000
	msr SPSR_EL3, x14
	ldr x14, =initial_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288410e // msr CSP_EL0, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0xc0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x0
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012ee // ldr c14, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d7 // ldr c23, [x14, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24005d7 // ldr c23, [x14, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24009d7 // ldr c23, [x14, #2]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400dd7 // ldr c23, [x14, #3]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc24011d7 // ldr c23, [x14, #4]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc24015d7 // ldr c23, [x14, #5]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc24019d7 // ldr c23, [x14, #6]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401dd7 // ldr c23, [x14, #7]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc24021d7 // ldr c23, [x14, #8]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc24025d7 // ldr c23, [x14, #9]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc24029d7 // ldr c23, [x14, #10]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2402dd7 // ldr c23, [x14, #11]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a5c1 // chkeq c14, c23
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001030
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
	ldr x0, =0x000012b0
	ldr x1, =check_data3
	ldr x2, =0x000012c0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001801
	ldr x1, =check_data4
	ldr x2, =0x00001802
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001840
	ldr x1, =check_data5
	ldr x2, =0x00001848
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
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
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
	.byte 0xff, 0x7a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x59, 0x00, 0x00, 0x00, 0x00
	.zero 640
	.byte 0x40, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0
	.zero 1408
	.byte 0x40, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1968
.data
check_data0:
	.byte 0xff, 0x7a
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x59, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x02, 0x00, 0x18, 0x00, 0x00
.data
check_data3:
	.byte 0x40, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0xf1, 0x13, 0x7d, 0x78, 0x1e, 0xbc, 0x3f, 0x39, 0xdd, 0xbf, 0x16, 0x28, 0xba, 0xf1, 0xc5, 0xc2
	.byte 0x06, 0x43, 0x63, 0x82, 0xde, 0x5b, 0xc0, 0xc2, 0xc0, 0xa8, 0xc1, 0xc2, 0x73, 0xfc, 0x5f, 0x22
	.byte 0x1e, 0x7c, 0xa0, 0xc8, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000006000087a0000000000000812
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x90000000000500070000000000001020
	/* C13 */
	.octa 0x180000000000000
	/* C15 */
	.octa 0x1800
	/* C24 */
	.octa 0xf70
	/* C29 */
	.octa 0x2000000
	/* C30 */
	.octa 0x40000000000100070000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1840
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x90000000000500070000000000001020
	/* C6 */
	.octa 0xc0000000000000000000000000001840
	/* C13 */
	.octa 0x180000000000000
	/* C15 */
	.octa 0x1800
	/* C17 */
	.octa 0x7aff
	/* C19 */
	.octa 0x590000000000000000000000
	/* C24 */
	.octa 0xf70
	/* C26 */
	.octa 0x20008000000100070180000000000000
	/* C29 */
	.octa 0x2000000
	/* C30 */
	.octa 0x40000000000100070000000000001000
initial_SP_EL0_value:
	.octa 0xc0000000401400c20000000000001000
initial_DDC_EL0_value:
	.octa 0x90100000202702e70000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc0000000401400c20000000000001000
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
	.dword 0x0000000000001020
	.dword 0x00000000000012b0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001020
	.dword 0x00000000000012b0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000010b0
	.dword 0x0000000000001800
	.dword 0x0000000000001840
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40400028
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
