.section text0, #alloc, #execinstr
test_start:
	.inst 0x29ca561c // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:28 Rn:16 Rt2:10101 imm7:0010100 L:1 1010011:1010011 opc:00
	.inst 0x08bb7fea // casb:aarch64/instrs/memory/atomicops/cas/single Rt:10 Rn:31 11111:11111 o0:0 Rs:27 1:1 L:0 0010001:0010001 size:00
	.inst 0xe27a0226 // ASTUR-V.RI-H Rt:6 Rn:17 op2:00 imm9:110100000 V:1 op1:01 11100010:11100010
	.inst 0xab02a7f0 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:16 Rn:31 imm6:101001 Rm:2 0:0 shift:00 01011:01011 S:1 op:0 sf:1
	.inst 0x227f17ed // LDXP-C.R-C Ct:13 Rn:31 Ct2:00101 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.zero 54252
	.inst 0xe2383fdf // ALDUR-V.RI-Q Rt:31 Rn:30 op2:11 imm9:110000011 V:1 op1:00 11100010:11100010
	.inst 0x2d8b1fde // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:30 Rn:30 Rt2:00111 imm7:0010110 L:0 1011011:1011011 opc:00
	.inst 0x9bb3f81e // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:0 Ra:30 o0:1 Rm:19 01:01 U:1 10011011:10011011
	.inst 0xc2e81b87 // CVT-C.CR-C Cd:7 Cn:28 0110:0110 0:0 0:0 Rm:8 11000010111:11000010111
	.inst 0xd4000001
	.zero 11244
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
	ldr x1, =initial_cap_values
	.inst 0xc240002a // ldr c10, [x1, #0]
	.inst 0xc2400430 // ldr c16, [x1, #1]
	.inst 0xc2400831 // ldr c17, [x1, #2]
	.inst 0xc2400c3b // ldr c27, [x1, #3]
	.inst 0xc240103e // ldr c30, [x1, #4]
	/* Vector registers */
	mrs x1, cptr_el3
	bfc x1, #10, #1
	msr cptr_el3, x1
	isb
	ldr q6, =0x0
	ldr q7, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x1, =0x0
	msr SPSR_EL3, x1
	ldr x1, =initial_SP_EL0_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc2884101 // msr CSP_EL0, c1
	ldr x1, =0x200
	msr CPTR_EL3, x1
	ldr x1, =0x30d5d99f
	msr SCTLR_EL1, x1
	ldr x1, =0x3c0000
	msr CPACR_EL1, x1
	ldr x1, =0x4
	msr S3_0_C1_C2_2, x1 // CCTLR_EL1
	ldr x1, =0x0
	msr S3_3_C1_C2_2, x1 // CCTLR_EL0
	ldr x1, =initial_DDC_EL0_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc2884121 // msr DDC_EL0, c1
	ldr x1, =initial_DDC_EL1_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc28c4121 // msr DDC_EL1, c1
	ldr x1, =0x80000000
	msr HCR_EL2, x1
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601301 // ldr c1, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e4021 // msr CELR_EL3, c1
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr DDC_EL3, c1
	ldr x1, =0x30851035
	msr SCTLR_EL3, x1
	isb
	/* Check processor flags */
	mrs x1, nzcv
	ubfx x1, x1, #28, #4
	mov x24, #0x3
	and x1, x1, x24
	cmp x1, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x1, =final_cap_values
	.inst 0xc2400038 // ldr c24, [x1, #0]
	.inst 0xc2d8a541 // chkeq c10, c24
	b.ne comparison_fail
	.inst 0xc2400438 // ldr c24, [x1, #1]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2400838 // ldr c24, [x1, #2]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc2400c38 // ldr c24, [x1, #3]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc2401038 // ldr c24, [x1, #4]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x1, =0x0
	mov x24, v6.d[0]
	cmp x1, x24
	b.ne comparison_fail
	ldr x1, =0x0
	mov x24, v6.d[1]
	cmp x1, x24
	b.ne comparison_fail
	ldr x1, =0x0
	mov x24, v7.d[0]
	cmp x1, x24
	b.ne comparison_fail
	ldr x1, =0x0
	mov x24, v7.d[1]
	cmp x1, x24
	b.ne comparison_fail
	ldr x1, =0x0
	mov x24, v30.d[0]
	cmp x1, x24
	b.ne comparison_fail
	ldr x1, =0x0
	mov x24, v30.d[1]
	cmp x1, x24
	b.ne comparison_fail
	ldr x1, =0x0
	mov x24, v31.d[0]
	cmp x1, x24
	b.ne comparison_fail
	ldr x1, =0x0
	mov x24, v31.d[1]
	cmp x1, x24
	b.ne comparison_fail
	/* Check system registers */
	ldr x1, =final_SP_EL0_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc2984118 // mrs c24, CSP_EL0
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	ldr x1, =final_PCC_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	ldr x24, =esr_el1_dump_address
	ldr x24, [x24]
	mov x1, 0x83
	orr x24, x24, x1
	ldr x1, =0x920000ab
	cmp x1, x24
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
	ldr x0, =0x00001054
	ldr x1, =check_data1
	ldr x2, =0x0000105c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a0
	ldr x1, =check_data2
	ldr x2, =0x000010a1
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010d8
	ldr x1, =check_data3
	ldr x2, =0x000010e0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fee
	ldr x1, =check_data4
	ldr x2, =0x00001ff0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040d400
	ldr x1, =check_data6
	ldr x2, =0x4040d414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x1, =0x30850030
	msr SCTLR_EL3, x1
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr DDC_EL3, c1
	ldr x1, =0x30850030
	msr SCTLR_EL3, x1
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
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x1c, 0x56, 0xca, 0x29, 0xea, 0x7f, 0xbb, 0x08, 0x26, 0x02, 0x7a, 0xe2, 0xf0, 0xa7, 0x02, 0xab
	.byte 0xed, 0x17, 0x7f, 0x22
.data
check_data6:
	.byte 0xdf, 0x3f, 0x38, 0xe2, 0xde, 0x1f, 0x8b, 0x2d, 0x1e, 0xf8, 0xb3, 0x9b, 0x87, 0x1b, 0xe8, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C10 */
	.octa 0x0
	/* C16 */
	.octa 0x1004
	/* C17 */
	.octa 0x4000000000010006000000000000204e
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x8000000060040009000000000000107d
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C10 */
	.octa 0x0
	/* C17 */
	.octa 0x4000000000010006000000000000204e
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x10a0
initial_DDC_EL0_value:
	.octa 0xc000000050b0018100ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x400000005801000300ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000d01d000000004040d000
final_SP_EL0_value:
	.octa 0x10a0
final_PCC_value:
	.octa 0x200080004000d01d000000004040d414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080400000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
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
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x02000021 // add c1, c1, #0
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x02020021 // add c1, c1, #128
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x02040021 // add c1, c1, #256
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x02060021 // add c1, c1, #384
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x02080021 // add c1, c1, #512
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x020a0021 // add c1, c1, #640
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x020c0021 // add c1, c1, #768
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x020e0021 // add c1, c1, #896
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x02100021 // add c1, c1, #1024
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x02120021 // add c1, c1, #1152
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x02140021 // add c1, c1, #1280
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x02160021 // add c1, c1, #1408
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x02180021 // add c1, c1, #1536
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x021a0021 // add c1, c1, #1664
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x021c0021 // add c1, c1, #1792
	.inst 0xc2c21020 // br c1
	.balign 128
	ldr x1, =esr_el1_dump_address
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600f01 // ldr x1, [c24, #0]
	cbnz x1, #28
	mrs x1, ESR_EL1
	.inst 0x82400f01 // str x1, [c24, #0]
	ldr x1, =0x4040d414
	mrs x24, ELR_EL1
	sub x1, x1, x24
	cbnz x1, #8
	smc 0
	ldr x1, =initial_VBAR_EL1_value
	.inst 0xc2c5b038 // cvtp c24, x1
	.inst 0xc2c14318 // scvalue c24, c24, x1
	.inst 0x82600301 // ldr c1, [c24, #0]
	.inst 0x021e0021 // add c1, c1, #1920
	.inst 0xc2c21020 // br c1

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
