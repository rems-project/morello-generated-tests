.section text0, #alloc, #execinstr
test_start:
	.inst 0xd65f02a0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:21 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 4
	.inst 0x783053bf // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:101 o3:0 Rs:16 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xa2e1ff26 // CASAL-C.R-C Ct:6 Rn:25 11111:11111 R:1 Cs:1 1:1 L:1 1:1 10100010:10100010
	.inst 0xba01002a // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:10 Rn:1 000000:000000 Rm:1 11010000:11010000 S:1 op:0 sf:1
	.inst 0x6df6ec41 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:1 Rn:2 Rt2:11011 imm7:1101101 L:1 1011011:1011011 opc:01
	.zero 504
	.inst 0xc2ff0bfc // ORRFLGS-C.CI-C Cd:28 Cn:31 0:0 01:01 imm8:11111000 11000010111:11000010111
	.inst 0xd4000001
	.zero 488
	.inst 0x8265ffdd // 0x8265ffdd
	.inst 0x8284fba8 // ALDRSH-R.RRB-64 Rt:8 Rn:29 opc:10 S:1 option:111 Rm:4 0:0 L:0 100000101:100000101
	.inst 0xd65f0020 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 64500
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
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400ae4 // ldr c4, [x23, #2]
	.inst 0xc2400ee6 // ldr c6, [x23, #3]
	.inst 0xc24012f0 // ldr c16, [x23, #4]
	.inst 0xc24016f5 // ldr c21, [x23, #5]
	.inst 0xc2401af9 // ldr c25, [x23, #6]
	.inst 0xc2401efd // ldr c29, [x23, #7]
	.inst 0xc24022fe // ldr c30, [x23, #8]
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4117 // msr CSP_EL1, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0x3c0000
	msr CPACR_EL1, x23
	ldr x23, =0x8
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0xc
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82601077 // ldr c23, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
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
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x3, #0xb
	and x23, x23, x3
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e3 // ldr c3, [x23, #0]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24006e3 // ldr c3, [x23, #1]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400ae3 // ldr c3, [x23, #2]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2400ee3 // ldr c3, [x23, #3]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc24012e3 // ldr c3, [x23, #4]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc24016e3 // ldr c3, [x23, #5]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2401ae3 // ldr c3, [x23, #6]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc2401ee3 // ldr c3, [x23, #7]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc24022e3 // ldr c3, [x23, #8]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc24026e3 // ldr c3, [x23, #9]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402ae3 // ldr c3, [x23, #10]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc29c4103 // mrs c3, CSP_EL1
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x23, 0x83
	orr x3, x3, x23
	ldr x23, =0x920000a3
	cmp x23, x3
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
	ldr x0, =0x00001388
	ldr x1, =check_data1
	ldr x2, =0x00001390
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400008
	ldr x1, =check_data3
	ldr x2, =0x40400018
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400210
	ldr x1, =check_data4
	ldr x2, =0x40400218
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x4040040c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.byte 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xa0, 0x02, 0x5f, 0xd6
.data
check_data3:
	.byte 0xbf, 0x53, 0x30, 0x78, 0x26, 0xff, 0xe1, 0xa2, 0x2a, 0x00, 0x01, 0xba, 0x41, 0xec, 0xf6, 0x6d
.data
check_data4:
	.byte 0xfc, 0x0b, 0xff, 0xc2, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0xdd, 0xff, 0x65, 0x82, 0xa8, 0xfb, 0x84, 0x82, 0x20, 0x00, 0x5f, 0xd6

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xf4000000000022
	/* C4 */
	.octa 0x800
	/* C6 */
	.octa 0x10000000000000000000
	/* C16 */
	.octa 0x0
	/* C21 */
	.octa 0x40400008
	/* C25 */
	.octa 0x1000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1090
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xf4000000000022
	/* C4 */
	.octa 0x800
	/* C6 */
	.octa 0x10000000000000000000
	/* C8 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C21 */
	.octa 0x40400008
	/* C25 */
	.octa 0x1000
	/* C28 */
	.octa 0xf800000000000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1090
initial_SP_EL1_value:
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd00000003b0000000000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000000500070000000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000480002100000000040400001
final_SP_EL1_value:
	.octa 0x0
final_PCC_value:
	.octa 0x20008000480002100000000040400218
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600c77 // ldr x23, [c3, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400c77 // str x23, [c3, #0]
	ldr x23, =0x40400218
	mrs x3, ELR_EL1
	sub x23, x23, x3
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e3 // cvtp c3, x23
	.inst 0xc2d74063 // scvalue c3, c3, x23
	.inst 0x82600077 // ldr c23, [c3, #0]
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
