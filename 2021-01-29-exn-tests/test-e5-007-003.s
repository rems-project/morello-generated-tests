.section text0, #alloc, #execinstr
test_start:
	.inst 0x489ffe21 // stlrh:aarch64/instrs/memory/ordered Rt:1 Rn:17 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x4817fc13 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:19 Rn:0 Rt2:11111 o0:1 Rs:23 0:0 L:0 0010000:0010000 size:01
	.inst 0x38015021 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:1 00:00 imm9:000010101 0:0 opc:00 111000:111000 size:00
	.inst 0xbc123fd6 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:22 Rn:30 11:11 imm9:100100011 0:0 opc:00 111100:111100 size:10
	.inst 0x397345b6 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:22 Rn:13 imm12:110011010001 opc:01 111001:111001 size:00
	.zero 5100
	.inst 0xb83f23ff // 0xb83f23ff
	.inst 0x889f7ed9 // 0x889f7ed9
	.inst 0xa22383e0 // 0xa22383e0
	.inst 0xdac0013e // 0xdac0013e
	.inst 0xd4000001
	.zero 60396
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b43 // ldr c3, [x26, #2]
	.inst 0xc2400f4d // ldr c13, [x26, #3]
	.inst 0xc2401351 // ldr c17, [x26, #4]
	.inst 0xc2401756 // ldr c22, [x26, #5]
	.inst 0xc2401b59 // ldr c25, [x26, #6]
	.inst 0xc2401f5e // ldr c30, [x26, #7]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q22, =0xb2000000
	/* Set up flags and system registers */
	ldr x26, =0x0
	msr SPSR_EL3, x26
	ldr x26, =initial_SP_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc28c411a // msr CSP_EL1, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0x3c0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x4
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012ba // ldr c26, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc28e403a // msr CELR_EL3, c26
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400355 // ldr c21, [x26, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400755 // ldr c21, [x26, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400b55 // ldr c21, [x26, #2]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2400f55 // ldr c21, [x26, #3]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2401355 // ldr c21, [x26, #4]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2401755 // ldr c21, [x26, #5]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2401b55 // ldr c21, [x26, #6]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc2401f55 // ldr c21, [x26, #7]
	.inst 0xc2d5a721 // chkeq c25, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0xb2000000
	mov x21, v22.d[0]
	cmp x26, x21
	b.ne comparison_fail
	ldr x26, =0x0
	mov x21, v22.d[1]
	cmp x26, x21
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_SP_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc29c4115 // mrs c21, CSP_EL1
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	ldr x21, =esr_el1_dump_address
	ldr x21, [x21]
	mov x26, 0x83
	orr x21, x21, x26
	ldr x26, =0x920000ab
	cmp x26, x21
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
	ldr x0, =0x00001015
	ldr x1, =check_data1
	ldr x2, =0x00001016
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001020
	ldr x1, =check_data2
	ldr x2, =0x00001024
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001080
	ldr x1, =check_data3
	ldr x2, =0x00001084
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
	ldr x0, =0x40401400
	ldr x1, =check_data5
	ldr x2, =0x40401414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x10, 0x04, 0x00, 0x08, 0x04, 0x20, 0x80, 0x05
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0xb2
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x21, 0xfe, 0x9f, 0x48, 0x13, 0xfc, 0x17, 0x48, 0x21, 0x50, 0x01, 0x38, 0xd6, 0x3f, 0x12, 0xbc
	.byte 0xb6, 0x45, 0x73, 0x39
.data
check_data5:
	.byte 0xff, 0x23, 0x3f, 0xb8, 0xd9, 0x7e, 0x9f, 0x88, 0xe0, 0x83, 0x23, 0xa2, 0x3e, 0x01, 0xc0, 0xda
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1000
	/* C3 */
	.octa 0x5802004080004108000000000000000
	/* C13 */
	.octa 0xfffffffffffff32f
	/* C17 */
	.octa 0x1000
	/* C22 */
	.octa 0x400000000007000f0000000000001080
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x10fd
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1000
	/* C3 */
	.octa 0x5802004080004108000000000000000
	/* C13 */
	.octa 0xfffffffffffff32f
	/* C17 */
	.octa 0x1000
	/* C22 */
	.octa 0x400000000007000f0000000000001080
	/* C23 */
	.octa 0x1
	/* C25 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0xcc000000580100010000000000001000
initial_DDC_EL0_value:
	.octa 0x400000000007000400ffffffffff7800
initial_VBAR_EL1_value:
	.octa 0x20008000600006000000000040401001
final_SP_EL1_value:
	.octa 0xcc000000580100010000000000001000
final_PCC_value:
	.octa 0x20008000600006000000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x82600eba // ldr x26, [c21, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eba // str x26, [c21, #0]
	ldr x26, =0x40401414
	mrs x21, ELR_EL1
	sub x26, x26, x21
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b355 // cvtp c21, x26
	.inst 0xc2da42b5 // scvalue c21, c21, x26
	.inst 0x826002ba // ldr c26, [c21, #0]
	.inst 0x021e035a // add c26, c26, #1920
	.inst 0xc2c21340 // br c26

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
