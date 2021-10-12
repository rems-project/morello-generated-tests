.section text0, #alloc, #execinstr
test_start:
	.inst 0x8248c40a // ASTRB-R.RI-B Rt:10 Rn:0 op:01 imm9:010001100 L:0 1000001001:1000001001
	.inst 0xb8420ad1 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:17 Rn:22 10:10 imm9:000100000 0:0 opc:01 111000:111000 size:10
	.inst 0x227f4ee0 // LDXP-C.R-C Ct:0 Rn:23 Ct2:10011 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0x289a10dd // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:29 Rn:6 Rt2:00100 imm7:0110100 L:0 1010001:1010001 opc:00
	.inst 0x889f7f3d // stllr:aarch64/instrs/memory/ordered Rt:29 Rn:25 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.zero 1004
	.inst 0x9bab59fd // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:15 Ra:22 o0:0 Rm:11 01:01 U:1 10011011:10011011
	.inst 0x3a516020 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:1 00:00 cond:0110 Rm:17 111010010:111010010 op:0 sf:0
	.inst 0xc2d8983d // ALIGND-C.CI-C Cd:29 Cn:1 0110:0110 U:0 imm6:110001 11000010110:11000010110
	.inst 0x08e67fb5 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:21 Rn:29 11111:11111 o0:0 Rs:6 1:1 L:1 0010001:0010001 size:00
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2400f06 // ldr c6, [x24, #3]
	.inst 0xc240130a // ldr c10, [x24, #4]
	.inst 0xc2401715 // ldr c21, [x24, #5]
	.inst 0xc2401b16 // ldr c22, [x24, #6]
	.inst 0xc2401f17 // ldr c23, [x24, #7]
	.inst 0xc2402319 // ldr c25, [x24, #8]
	.inst 0xc240271d // ldr c29, [x24, #9]
	/* Set up flags and system registers */
	ldr x24, =0x4000000
	msr SPSR_EL3, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0xc0000
	msr CPACR_EL1, x24
	ldr x24, =0x4
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x4
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =initial_DDC_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28c4138 // msr DDC_EL1, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601378 // ldr c24, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x27, #0xf
	and x24, x24, x27
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240031b // ldr c27, [x24, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240071b // ldr c27, [x24, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400b1b // ldr c27, [x24, #2]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc2400f1b // ldr c27, [x24, #3]
	.inst 0xc2dba4c1 // chkeq c6, c27
	b.ne comparison_fail
	.inst 0xc240131b // ldr c27, [x24, #4]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc240171b // ldr c27, [x24, #5]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc2401b1b // ldr c27, [x24, #6]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc2401f1b // ldr c27, [x24, #7]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc240231b // ldr c27, [x24, #8]
	.inst 0xc2dba6c1 // chkeq c22, c27
	b.ne comparison_fail
	.inst 0xc240271b // ldr c27, [x24, #9]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc2402b1b // ldr c27, [x24, #10]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc2402f1b // ldr c27, [x24, #11]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	ldr x24, =esr_el1_dump_address
	ldr x24, [x24]
	mov x27, 0x80
	orr x24, x24, x27
	ldr x27, =0x920000eb
	cmp x27, x24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001005
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x0000101c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001060
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001084
	ldr x1, =check_data3
	ldr x2, =0x00001085
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
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x0a, 0xc4, 0x48, 0x82, 0xd1, 0x0a, 0x42, 0xb8, 0xe0, 0x4e, 0x7f, 0x22, 0xdd, 0x10, 0x9a, 0x28
	.byte 0x3d, 0x7f, 0x9f, 0x88
.data
check_data5:
	.byte 0xfd, 0x59, 0xab, 0x9b, 0x20, 0x60, 0x51, 0x3a, 0x3d, 0x98, 0xd8, 0xc2, 0xb5, 0x7f, 0xe6, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xef7
	/* C1 */
	.octa 0x100100070000000000000001
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x40000000000100060000000000001040
	/* C10 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x800000005800004a0000000000000ff8
	/* C23 */
	.octa 0x80100000410001620000000000001040
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x100100070000000000000001
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x10
	/* C10 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x800000005800004a0000000000000ff8
	/* C23 */
	.octa 0x80100000410001620000000000001040
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x100100070000000000000000
initial_DDC_EL0_value:
	.octa 0x40000000500a008100ffffffffffe003
initial_DDC_EL1_value:
	.octa 0xc0000000720210840000000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000400001010000000040400000
final_PCC_value:
	.octa 0x20008000400001010000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001040
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001040
	.dword 0x0000000000001050
	.dword 0x0000000000001080
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600f78 // ldr x24, [c27, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f78 // str x24, [c27, #0]
	ldr x24, =0x40400414
	mrs x27, ELR_EL1
	sub x24, x24, x27
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31b // cvtp c27, x24
	.inst 0xc2d8437b // scvalue c27, c27, x24
	.inst 0x82600378 // ldr c24, [c27, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
