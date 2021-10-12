.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d4bf38 // CSEL-C.CI-C Cd:24 Cn:25 11:11 cond:1011 Cm:20 11000010110:11000010110
	.inst 0x6a5a2821 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:1 imm6:001010 Rm:26 N:0 shift:01 01010:01010 opc:11 sf:0
	.inst 0xc2c364ac // CPYVALUE-C.C-C Cd:12 Cn:5 001:001 opc:11 0:0 Cm:3 11000010110:11000010110
	.inst 0x828ad012 // ASTRB-R.RRB-B Rt:18 Rn:0 opc:00 S:1 option:110 Rm:10 0:0 L:0 100000101:100000101
	.inst 0xe250bfc0 // ALDURSH-R.RI-32 Rt:0 Rn:30 op2:11 imm9:100001011 V:0 op1:01 11100010:11100010
	.inst 0xdac009a0 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:13 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x421fffa4 // STLR-C.R-C Ct:4 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xa2a0ffed // CASL-C.R-C Ct:13 Rn:31 11111:11111 R:1 Cs:0 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c21021 // CHKSLD-C-C 00001:00001 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc2400843 // ldr c3, [x2, #2]
	.inst 0xc2400c44 // ldr c4, [x2, #3]
	.inst 0xc2401045 // ldr c5, [x2, #4]
	.inst 0xc240144a // ldr c10, [x2, #5]
	.inst 0xc240184d // ldr c13, [x2, #6]
	.inst 0xc2401c52 // ldr c18, [x2, #7]
	.inst 0xc240205a // ldr c26, [x2, #8]
	.inst 0xc240245d // ldr c29, [x2, #9]
	.inst 0xc240285e // ldr c30, [x2, #10]
	/* Set up flags and system registers */
	ldr x2, =0x84000000
	msr SPSR_EL3, x2
	ldr x2, =initial_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884102 // msr CSP_EL0, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0xc0000
	msr CPACR_EL1, x2
	ldr x2, =0x0
	msr S3_0_C1_C2_2, x2 // CCTLR_EL1
	ldr x2, =0x4
	msr S3_3_C1_C2_2, x2 // CCTLR_EL0
	ldr x2, =initial_DDC_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884122 // msr DDC_EL0, c2
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012c2 // ldr c2, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e4022 // msr CELR_EL3, c2
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x22, #0xf
	and x2, x2, x22
	cmp x2, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400056 // ldr c22, [x2, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400456 // ldr c22, [x2, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400856 // ldr c22, [x2, #2]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc2400c56 // ldr c22, [x2, #3]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2401056 // ldr c22, [x2, #4]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2401456 // ldr c22, [x2, #5]
	.inst 0xc2d6a541 // chkeq c10, c22
	b.ne comparison_fail
	.inst 0xc2401856 // ldr c22, [x2, #6]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2401c56 // ldr c22, [x2, #7]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2402056 // ldr c22, [x2, #8]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2402456 // ldr c22, [x2, #9]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2402856 // ldr c22, [x2, #10]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402c56 // ldr c22, [x2, #11]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984116 // mrs c22, CSP_EL0
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001011
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001810
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
	.byte 0x80, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x08, 0x00, 0x00, 0x01, 0x01
	.zero 4080
.data
check_data0:
	.byte 0x80, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x08, 0x00, 0x00, 0x01, 0x01
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x08, 0x01, 0x02, 0x01, 0x08, 0x02, 0x10, 0x10, 0x08, 0x40, 0x00, 0x00
.data
check_data2:
	.byte 0x38, 0xbf, 0xd4, 0xc2, 0x21, 0x28, 0x5a, 0x6a, 0xac, 0x64, 0xc3, 0xc2, 0x12, 0xd0, 0x8a, 0x82
	.byte 0xc0, 0xbf, 0x50, 0xe2, 0xa0, 0x09, 0xc0, 0xda, 0xa4, 0xff, 0x1f, 0x42, 0xed, 0xff, 0xa0, 0xa2
	.byte 0x21, 0x10, 0xc2, 0xc2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0xffe84280
	/* C3 */
	.octa 0x80000000000000
	/* C4 */
	.octa 0x4008101002080102010800000000
	/* C5 */
	.octa 0x8180a60080000000000000
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x4000000000000808080204000000
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0x5ef5fc00
	/* C29 */
	.octa 0x48000000400400060000000000001800
	/* C30 */
	.octa 0x10e5
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1010000080100000000000000010080
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x80000000000000
	/* C4 */
	.octa 0x4008101002080102010800000000
	/* C5 */
	.octa 0x8180a60080000000000000
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x8180a60080000000000000
	/* C13 */
	.octa 0x4000000000000808080204000000
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0x5ef5fc00
	/* C29 */
	.octa 0x48000000400400060000000000001800
	/* C30 */
	.octa 0x10e5
initial_SP_EL0_value:
	.octa 0xc8000000600400010000000000001000
initial_DDC_EL0_value:
	.octa 0xc0000000580000100000000000006001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc8000000600400010000000000001000
final_PCC_value:
	.octa 0x20008000100640070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100640070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001800
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
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
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x82600ec2 // ldr x2, [c22, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ec2 // str x2, [c22, #0]
	ldr x2, =0x40400028
	mrs x22, ELR_EL1
	sub x2, x2, x22
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b056 // cvtp c22, x2
	.inst 0xc2c242d6 // scvalue c22, c22, x2
	.inst 0x826002c2 // ldr c2, [c22, #0]
	.inst 0x021e0042 // add c2, c2, #1920
	.inst 0xc2c21040 // br c2

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
