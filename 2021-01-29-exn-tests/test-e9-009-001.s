.section text0, #alloc, #execinstr
test_start:
	.inst 0xf9314ddf // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:14 imm12:110001010011 opc:00 111001:111001 size:11
	.inst 0xc2d8bbf4 // SCBNDS-C.CI-C Cd:20 Cn:31 1110:1110 S:0 imm6:110001 11000010110:11000010110
	.inst 0x882ba627 // stlxp:aarch64/instrs/memory/exclusive/pair Rt:7 Rn:17 Rt2:01001 o0:1 Rs:11 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0xa2ef7fd6 // CASA-C.R-C Ct:22 Rn:30 11111:11111 R:0 Cs:15 1:1 L:1 1:1 10100010:10100010
	.inst 0xc2c21382 // BRS-C-C 00010:00010 Cn:28 100:100 opc:00 11000010110000100:11000010110000100
	.zero 32748
	.inst 0x9b1f4422 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:2 Rn:1 Ra:17 o0:0 Rm:31 0011011000:0011011000 sf:1
	.inst 0x8251303e // ASTR-C.RI-C Ct:30 Rn:1 op:00 imm9:100010011 L:0 1000001001:1000001001
	.inst 0xe25b18df // ALDURSH-R.RI-64 Rt:31 Rn:6 op2:10 imm9:110110001 V:0 op1:01 11100010:11100010
	.inst 0x9ac8241e // lsrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:0 op2:01 0010:0010 Rm:8 0011010110:0011010110 sf:1
	.inst 0xd4000001
	.zero 32748
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006e6 // ldr c6, [x23, #1]
	.inst 0xc2400aee // ldr c14, [x23, #2]
	.inst 0xc2400eef // ldr c15, [x23, #3]
	.inst 0xc24012f1 // ldr c17, [x23, #4]
	.inst 0xc24016f6 // ldr c22, [x23, #5]
	.inst 0xc2401afc // ldr c28, [x23, #6]
	.inst 0xc2401efe // ldr c30, [x23, #7]
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x0
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601317 // ldr c23, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f8 // ldr c24, [x23, #0]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24006f8 // ldr c24, [x23, #1]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400af8 // ldr c24, [x23, #2]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2400ef8 // ldr c24, [x23, #3]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc24012f8 // ldr c24, [x23, #4]
	.inst 0xc2d8a5c1 // chkeq c14, c24
	b.ne comparison_fail
	.inst 0xc24016f8 // ldr c24, [x23, #5]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401af8 // ldr c24, [x23, #6]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2401ef8 // ldr c24, [x23, #7]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc24022f8 // ldr c24, [x23, #8]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc24026f8 // ldr c24, [x23, #9]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984118 // mrs c24, CSP_EL0
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a6e1 // chkeq c23, c24
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
	ldr x0, =0x00001120
	ldr x1, =check_data1
	ldr x2, =0x00001128
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c10
	ldr x1, =check_data2
	ldr x2, =0x00001c20
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
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
	ldr x0, =0x40408000
	ldr x1, =check_data5
	ldr x2, =0x40408014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x404080b4
	ldr x1, =check_data6
	ldr x2, =0x404080b6
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.zero 8
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xdf, 0x4d, 0x31, 0xf9, 0xf4, 0xbb, 0xd8, 0xc2, 0x27, 0xa6, 0x2b, 0x88, 0xd6, 0x7f, 0xef, 0xa2
	.byte 0x82, 0x13, 0xc2, 0xc2
.data
check_data5:
	.byte 0x22, 0x44, 0x1f, 0x9b, 0x3e, 0x30, 0x51, 0x82, 0xdf, 0x18, 0x5b, 0xe2, 0x1e, 0x24, 0xc8, 0x9a
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xae0
	/* C6 */
	.octa 0x40408103
	/* C14 */
	.octa 0xffffffffffffae88
	/* C15 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C17 */
	.octa 0x1ff0
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x20008000a08740060000000040408001
	/* C30 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xae0
	/* C2 */
	.octa 0x1ff0
	/* C6 */
	.octa 0x40408103
	/* C11 */
	.octa 0x1
	/* C14 */
	.octa 0xffffffffffffae88
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x1ff0
	/* C20 */
	.octa 0x403100000000000000000000
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x20008000a08740060000000040408001
initial_SP_EL0_value:
	.octa 0x400000000000000000000000
initial_DDC_EL0_value:
	.octa 0xcc1000000002000700e0000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x400000000000000000000000
final_PCC_value:
	.octa 0x20008000208740060000000040408014
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000e0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 144
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40408014
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
