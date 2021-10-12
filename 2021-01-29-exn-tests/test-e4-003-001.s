.section text0, #alloc, #execinstr
test_start:
	.inst 0x6267643e // LDNP-C.RIB-C Ct:30 Rn:1 Ct2:11001 imm7:1001110 L:1 011000100:011000100
	.inst 0x2942ccf1 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:17 Rn:7 Rt2:10011 imm7:0000101 L:1 1010010:1010010 opc:00
	.inst 0x085f7e44 // ldxrb:aarch64/instrs/memory/exclusive/single Rt:4 Rn:18 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x421ffc30 // STLR-C.R-C Ct:16 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xe21cf1b0 // ASTURB-R.RI-32 Rt:16 Rn:13 op2:00 imm9:111001111 V:0 op1:00 11100010:11100010
	.zero 1004
	.inst 0xfa41a1a2 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0010 0:0 Rn:13 00:00 cond:1010 Rm:1 111010010:111010010 op:1 sf:1
	.inst 0x6c8443fa // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:26 Rn:31 Rt2:10000 imm7:0001000 L:0 1011001:1011001 opc:01
	.inst 0x2d9e7404 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:4 Rn:0 Rt2:11101 imm7:0111100 L:0 1011011:1011011 opc:00
	.inst 0x227f1d20 // LDXP-C.R-C Ct:0 Rn:9 Ct2:00111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e7 // ldr c7, [x15, #2]
	.inst 0xc2400de9 // ldr c9, [x15, #3]
	.inst 0xc24011ed // ldr c13, [x15, #4]
	.inst 0xc24015f0 // ldr c16, [x15, #5]
	.inst 0xc24019f2 // ldr c18, [x15, #6]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q4, =0x0
	ldr q16, =0x0
	ldr q26, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x15, =0x4000000
	msr SPSR_EL3, x15
	ldr x15, =initial_SP_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c410f // msr CSP_EL1, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0x3c0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x4
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =initial_DDC_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c412f // msr DDC_EL1, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260136f // ldr c15, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e402f // msr CELR_EL3, c15
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x27, #0xf
	and x15, x15, x27
	cmp x15, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001fb // ldr c27, [x15, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24005fb // ldr c27, [x15, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc24009fb // ldr c27, [x15, #2]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc2400dfb // ldr c27, [x15, #3]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc24011fb // ldr c27, [x15, #4]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc24015fb // ldr c27, [x15, #5]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc24019fb // ldr c27, [x15, #6]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc2401dfb // ldr c27, [x15, #7]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc24021fb // ldr c27, [x15, #8]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc24025fb // ldr c27, [x15, #9]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc24029fb // ldr c27, [x15, #10]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc2402dfb // ldr c27, [x15, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x27, v4.d[0]
	cmp x15, x27
	b.ne comparison_fail
	ldr x15, =0x0
	mov x27, v4.d[1]
	cmp x15, x27
	b.ne comparison_fail
	ldr x15, =0x0
	mov x27, v16.d[0]
	cmp x15, x27
	b.ne comparison_fail
	ldr x15, =0x0
	mov x27, v16.d[1]
	cmp x15, x27
	b.ne comparison_fail
	ldr x15, =0x0
	mov x27, v26.d[0]
	cmp x15, x27
	b.ne comparison_fail
	ldr x15, =0x0
	mov x27, v26.d[1]
	cmp x15, x27
	b.ne comparison_fail
	ldr x15, =0x0
	mov x27, v29.d[0]
	cmp x15, x27
	b.ne comparison_fail
	ldr x15, =0x0
	mov x27, v29.d[1]
	cmp x15, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc29c411b // mrs c27, CSP_EL1
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x15, 0x83
	orr x27, x27, x15
	ldr x15, =0x920000eb
	cmp x15, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001014
	ldr x1, =check_data0
	ldr x2, =0x0000101c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010e0
	ldr x1, =check_data2
	ldr x2, =0x00001100
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001240
	ldr x1, =check_data3
	ldr x2, =0x00001260
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000013f2
	ldr x1, =check_data4
	ldr x2, =0x000013f3
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001400
	ldr x1, =check_data5
	ldr x2, =0x00001410
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001ed0
	ldr x1, =check_data6
	ldr x2, =0x00001ed8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400000
	ldr x1, =check_data7
	ldr x2, =0x40400014
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x40400400
	ldr x1, =check_data8
	ldr x2, =0x40400414
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
	.zero 8
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data6:
	.zero 8
.data
check_data7:
	.byte 0x3e, 0x64, 0x67, 0x62, 0xf1, 0xcc, 0x42, 0x29, 0x44, 0x7e, 0x5f, 0x08, 0x30, 0xfc, 0x1f, 0x42
	.byte 0xb0, 0xf1, 0x1c, 0xe2
.data
check_data8:
	.byte 0xa2, 0xa1, 0x41, 0xfa, 0xfa, 0x43, 0x84, 0x6c, 0x04, 0x74, 0x9e, 0x2d, 0x20, 0x1d, 0x7f, 0x22
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1de0
	/* C1 */
	.octa 0xc8100000580400020000000000001400
	/* C7 */
	.octa 0x80000000000400000000000000001000
	/* C9 */
	.octa 0x1240
	/* C13 */
	.octa 0x80000000000031
	/* C16 */
	.octa 0x4000004000000000000000000000
	/* C18 */
	.octa 0x800000006012000400000000000013f2
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc8100000580400020000000000001400
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x1240
	/* C13 */
	.octa 0x80000000000031
	/* C16 */
	.octa 0x4000004000000000000000000000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x800000006012000400000000000013f2
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x1080
initial_DDC_EL0_value:
	.octa 0x500050000000000000000
initial_DDC_EL1_value:
	.octa 0xd0100000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_SP_EL1_value:
	.octa 0x10c0
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000067a0070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010e0
	.dword 0x0000000000001240
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 128
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x82600f6f // ldr x15, [c27, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400f6f // str x15, [c27, #0]
	ldr x15, =0x40400414
	mrs x27, ELR_EL1
	sub x15, x15, x27
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1fb // cvtp c27, x15
	.inst 0xc2cf437b // scvalue c27, c27, x15
	.inst 0x8260036f // ldr c15, [c27, #0]
	.inst 0x021e01ef // add c15, c15, #1920
	.inst 0xc2c211e0 // br c15

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
