.section text0, #alloc, #execinstr
test_start:
	.inst 0x786273bf // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:111 o3:0 Rs:2 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x7c7fc82e // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:14 Rn:1 10:10 S:0 option:110 Rm:31 1:1 opc:01 111100:111100 size:01
	.inst 0xd2b2b750 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:16 imm16:1001010110111010 hw:01 100101:100101 opc:10 sf:1
	.inst 0x427fff7d // ALDAR-R.R-32 Rt:29 Rn:27 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c653c1 // CLRPERM-C.CI-C Cd:1 Cn:30 100:100 perm:010 1100001011000110:1100001011000110
	.inst 0x427f7e6a // ALDARB-R.R-B Rt:10 Rn:19 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c6f3df // CLRPERM-C.CI-C Cd:31 Cn:30 100:100 perm:111 1100001011000110:1100001011000110
	.inst 0x921cb055 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:21 Rn:2 imms:101100 immr:011100 N:0 100100:100100 opc:00 sf:1
	.inst 0xe2d37c30 // ALDUR-C.RI-C Ct:16 Rn:1 op2:11 imm9:100110111 V:0 op1:11 11100010:11100010
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
	ldr x17, =initial_cap_values
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2400a33 // ldr c19, [x17, #2]
	.inst 0xc2400e3b // ldr c27, [x17, #3]
	.inst 0xc240123d // ldr c29, [x17, #4]
	.inst 0xc240163e // ldr c30, [x17, #5]
	/* Set up flags and system registers */
	ldr x17, =0x4000000
	msr SPSR_EL3, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30d5d99f
	msr SCTLR_EL1, x17
	ldr x17, =0x3c0000
	msr CPACR_EL1, x17
	ldr x17, =0x0
	msr S3_0_C1_C2_2, x17 // CCTLR_EL1
	ldr x17, =0x0
	msr S3_3_C1_C2_2, x17 // CCTLR_EL0
	ldr x17, =initial_DDC_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884131 // msr DDC_EL0, c17
	ldr x17, =0x80000000
	msr HCR_EL2, x17
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f1 // ldr c17, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e4031 // msr CELR_EL3, c17
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400237 // ldr c23, [x17, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400637 // ldr c23, [x17, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400a37 // ldr c23, [x17, #2]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2400e37 // ldr c23, [x17, #3]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2401237 // ldr c23, [x17, #4]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc2401637 // ldr c23, [x17, #5]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc2401a37 // ldr c23, [x17, #6]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2401e37 // ldr c23, [x17, #7]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2402237 // ldr c23, [x17, #8]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x17, =0x0
	mov x23, v14.d[0]
	cmp x17, x23
	b.ne comparison_fail
	ldr x17, =0x0
	mov x23, v14.d[1]
	cmp x17, x23
	b.ne comparison_fail
	/* Check system registers */
	ldr x17, =final_SP_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	ldr x17, =final_PCC_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001920
	ldr x1, =check_data0
	ldr x2, =0x00001922
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x404001fc
	ldr x1, =check_data2
	ldr x2, =0x404001fe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x4040ffe0
	ldr x1, =check_data3
	ldr x2, =0x4040fff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040fff8
	ldr x1, =check_data4
	ldr x2, =0x4040fffc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040fffe
	ldr x1, =check_data5
	ldr x2, =0x4040ffff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
	.zero 2336
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1744
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xbf, 0x73, 0x62, 0x78, 0x2e, 0xc8, 0x7f, 0x7c, 0x50, 0xb7, 0xb2, 0xd2, 0x7d, 0xff, 0x7f, 0x42
	.byte 0xc1, 0x53, 0xc6, 0xc2, 0x6a, 0x7e, 0x7f, 0x42, 0xdf, 0xf3, 0xc6, 0xc2, 0x55, 0xb0, 0x1c, 0x92
	.byte 0x30, 0x7c, 0xd3, 0xe2, 0x01, 0x00, 0x00, 0xd4
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000000001000500000000404001fc
	/* C2 */
	.octa 0x0
	/* C19 */
	.octa 0x4040fffe
	/* C27 */
	.octa 0x4040fff8
	/* C29 */
	.octa 0xc0000000000500010000000000001920
	/* C30 */
	.octa 0x8000000000000000404100a9
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x8000000000000000404100a9
	/* C2 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x4040fffe
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x4040fff8
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x8000000000000000404100a9
initial_DDC_EL0_value:
	.octa 0x90000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x8000000000000000404100a9
final_PCC_value:
	.octa 0x20008000200180060000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200180060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
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
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x02000231 // add c17, c17, #0
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x02020231 // add c17, c17, #128
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x02040231 // add c17, c17, #256
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x02060231 // add c17, c17, #384
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x02080231 // add c17, c17, #512
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x020a0231 // add c17, c17, #640
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x020c0231 // add c17, c17, #768
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x020e0231 // add c17, c17, #896
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x02100231 // add c17, c17, #1024
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x02120231 // add c17, c17, #1152
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x02140231 // add c17, c17, #1280
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x02160231 // add c17, c17, #1408
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x02180231 // add c17, c17, #1536
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x021a0231 // add c17, c17, #1664
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x021c0231 // add c17, c17, #1792
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x82600ef1 // ldr x17, [c23, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400ef1 // str x17, [c23, #0]
	ldr x17, =0x40400028
	mrs x23, ELR_EL1
	sub x17, x17, x23
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b237 // cvtp c23, x17
	.inst 0xc2d142f7 // scvalue c23, c23, x17
	.inst 0x826002f1 // ldr c17, [c23, #0]
	.inst 0x021e0231 // add c17, c17, #1920
	.inst 0xc2c21220 // br c17

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
