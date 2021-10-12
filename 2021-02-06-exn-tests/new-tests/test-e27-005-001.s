.section text0, #alloc, #execinstr
test_start:
	.inst 0xb89bebde // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:30 10:10 imm9:110111110 0:0 opc:10 111000:111000 size:10
	.inst 0x7820113f // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:9 00:00 opc:001 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x38bfc09e // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:30 Rn:4 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x78bfc3fd // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:29 Rn:31 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0x88a07ccf // cas:aarch64/instrs/memory/atomicops/cas/single Rt:15 Rn:6 11111:11111 o0:0 Rs:0 1:1 L:0 0010001:0010001 size:10
	.zero 9196
	.inst 0xc2da8421 // CHKSS-_.CC-C 00001:00001 Cn:1 001:001 opc:00 1:1 Cm:26 11000010110:11000010110
	.inst 0xb87f33bf // stset:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:011 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x5ac0131e // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:24 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2c5d038 // CVTDZ-C.R-C Cd:24 Rn:1 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xd4000001
	.zero 56300
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400984 // ldr c4, [x12, #2]
	.inst 0xc2400d86 // ldr c6, [x12, #3]
	.inst 0xc2401189 // ldr c9, [x12, #4]
	.inst 0xc240159a // ldr c26, [x12, #5]
	.inst 0xc240199e // ldr c30, [x12, #6]
	/* Set up flags and system registers */
	ldr x12, =0x0
	msr SPSR_EL3, x12
	ldr x12, =initial_SP_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc288410c // msr CSP_EL0, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30d5d99f
	msr SCTLR_EL1, x12
	ldr x12, =0xc0000
	msr CPACR_EL1, x12
	ldr x12, =0x4
	msr S3_0_C1_C2_2, x12 // CCTLR_EL1
	ldr x12, =0x4
	msr S3_3_C1_C2_2, x12 // CCTLR_EL0
	ldr x12, =initial_DDC_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc288412c // msr DDC_EL0, c12
	ldr x12, =initial_DDC_EL1_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc28c412c // msr DDC_EL1, c12
	ldr x12, =0x80000000
	msr HCR_EL2, x12
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012cc // ldr c12, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e402c // msr CELR_EL3, c12
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x22, #0xf
	and x12, x12, x22
	cmp x12, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400196 // ldr c22, [x12, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400596 // ldr c22, [x12, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400996 // ldr c22, [x12, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400d96 // ldr c22, [x12, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401196 // ldr c22, [x12, #4]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401596 // ldr c22, [x12, #5]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2401996 // ldr c22, [x12, #6]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2401d96 // ldr c22, [x12, #7]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x12, =final_SP_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2984116 // mrs c22, CSP_EL0
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	ldr x12, =final_PCC_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	ldr x12, =esr_el1_dump_address
	ldr x12, [x12]
	mov x22, 0xc1
	orr x12, x12, x22
	ldr x22, =0x920000eb
	cmp x22, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000014c0
	ldr x1, =check_data0
	ldr x2, =0x000014c4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001680
	ldr x1, =check_data1
	ldr x2, =0x00001682
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x404007c0
	ldr x1, =check_data5
	ldr x2, =0x404007c4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40402400
	ldr x1, =check_data6
	ldr x2, =0x40402414
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
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
	.zero 1664
	.byte 0xf7, 0xee, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2400
	.byte 0xc0, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0xf7, 0xee
.data
check_data2:
	.byte 0xc0, 0x14
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xde, 0xeb, 0x9b, 0xb8, 0x3f, 0x11, 0x20, 0x78, 0x9e, 0xc0, 0xbf, 0x38, 0xfd, 0xc3, 0xbf, 0x78
	.byte 0xcf, 0x7c, 0xa0, 0x88
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x21, 0x84, 0xda, 0xc2, 0xbf, 0x33, 0x7f, 0xb8, 0x1e, 0x13, 0xc0, 0x5a, 0x38, 0xd0, 0xc5, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x700060040000000000000
	/* C4 */
	.octa 0x1ffe
	/* C6 */
	.octa 0x800000000000c9
	/* C9 */
	.octa 0x1680
	/* C26 */
	.octa 0x2840f0000000000000000
	/* C30 */
	.octa 0x40400802
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x700060040000000000000
	/* C4 */
	.octa 0x1ffe
	/* C6 */
	.octa 0x800000000000c9
	/* C9 */
	.octa 0x1680
	/* C24 */
	.octa 0xc0000000000600000040000000000000
	/* C26 */
	.octa 0x2840f0000000000000000
	/* C29 */
	.octa 0x14c0
initial_SP_EL0_value:
	.octa 0x1ff0
initial_DDC_EL0_value:
	.octa 0xc0000000004300070000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000600000000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004000201d0000000040402000
final_SP_EL0_value:
	.octa 0x1ff0
final_PCC_value:
	.octa 0x200080004000201d0000000040402414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
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
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000014c0
	.dword 0x0000000000001680
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
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0200018c // add c12, c12, #0
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0202018c // add c12, c12, #128
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0204018c // add c12, c12, #256
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0206018c // add c12, c12, #384
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0208018c // add c12, c12, #512
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x020a018c // add c12, c12, #640
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x020c018c // add c12, c12, #768
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x020e018c // add c12, c12, #896
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0210018c // add c12, c12, #1024
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0212018c // add c12, c12, #1152
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0214018c // add c12, c12, #1280
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0216018c // add c12, c12, #1408
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0218018c // add c12, c12, #1536
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x021a018c // add c12, c12, #1664
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x021c018c // add c12, c12, #1792
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40402414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x021e018c // add c12, c12, #1920
	.inst 0xc2c21180 // br c12

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
