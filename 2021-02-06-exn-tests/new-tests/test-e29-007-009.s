.section text0, #alloc, #execinstr
test_start:
	.inst 0x08dffda1 // ldarb:aarch64/instrs/memory/ordered Rt:1 Rn:13 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x382b62df // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:110 o3:0 Rs:11 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa20f941e // STR-C.RIAW-C Ct:30 Rn:0 01:01 imm9:011111001 0:0 opc:00 10100010:10100010
	.inst 0x387d33bf // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:011 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc87f8bea // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:10 Rn:31 Rt2:00010 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.zero 1004
	.inst 0x382172c9 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:22 00:00 opc:111 0:0 Rs:1 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x3a1e0341 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:26 000000:000000 Rm:30 11010000:11010000 S:1 op:0 sf:0
	.inst 0x629d6be2 // STP-C.RIBW-C Ct:2 Rn:31 Ct2:11010 imm7:0111010 L:0 011000101:011000101
	.inst 0xb811ad5c // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:28 Rn:10 11:11 imm9:100011010 0:0 opc:00 111000:111000 size:10
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400642 // ldr c2, [x18, #1]
	.inst 0xc2400a4a // ldr c10, [x18, #2]
	.inst 0xc2400e4b // ldr c11, [x18, #3]
	.inst 0xc240124d // ldr c13, [x18, #4]
	.inst 0xc2401656 // ldr c22, [x18, #5]
	.inst 0xc2401a5a // ldr c26, [x18, #6]
	.inst 0xc2401e5c // ldr c28, [x18, #7]
	.inst 0xc240225d // ldr c29, [x18, #8]
	.inst 0xc240265e // ldr c30, [x18, #9]
	/* Set up flags and system registers */
	ldr x18, =0x4000000
	msr SPSR_EL3, x18
	ldr x18, =initial_SP_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884112 // msr CSP_EL0, c18
	ldr x18, =initial_SP_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc28c4112 // msr CSP_EL1, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30d5d99f
	msr SCTLR_EL1, x18
	ldr x18, =0xc0000
	msr CPACR_EL1, x18
	ldr x18, =0x0
	msr S3_0_C1_C2_2, x18 // CCTLR_EL1
	ldr x18, =0x80000000
	msr HCR_EL2, x18
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011f2 // ldr c18, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e4032 // msr CELR_EL3, c18
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x15, #0xb
	and x18, x18, x15
	cmp x18, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024f // ldr c15, [x18, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240064f // ldr c15, [x18, #1]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400a4f // ldr c15, [x18, #2]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc2400e4f // ldr c15, [x18, #3]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc240124f // ldr c15, [x18, #4]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc240164f // ldr c15, [x18, #5]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc2401a4f // ldr c15, [x18, #6]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc2401e4f // ldr c15, [x18, #7]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc240224f // ldr c15, [x18, #8]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc240264f // ldr c15, [x18, #9]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2402a4f // ldr c15, [x18, #10]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check system registers */
	ldr x18, =final_SP_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc298410f // mrs c15, CSP_EL0
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	ldr x18, =final_SP_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc29c410f // mrs c15, CSP_EL1
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	ldr x18, =final_PCC_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	ldr x18, =esr_el1_dump_address
	ldr x18, [x18]
	mov x15, 0xc1
	orr x18, x18, x15
	ldr x15, =0x920000eb
	cmp x15, x18
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001330
	ldr x1, =check_data2
	ldr x2, =0x00001334
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x40, 0x10
.data
check_data3:
	.byte 0xa1, 0xfd, 0xdf, 0x08, 0xdf, 0x62, 0x2b, 0x38, 0x1e, 0x94, 0x0f, 0xa2, 0xbf, 0x33, 0x7d, 0x38
	.byte 0xea, 0x8b, 0x7f, 0xc8
.data
check_data4:
	.byte 0xc9, 0x72, 0x21, 0x38, 0x41, 0x03, 0x1e, 0x3a, 0xe2, 0x6b, 0x9d, 0x62, 0x5c, 0xad, 0x11, 0xb8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x48000000000300070000000000001000
	/* C2 */
	.octa 0x0
	/* C10 */
	.octa 0x4000000058040e6e0000000000001416
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x80000000000300070000000000001000
	/* C22 */
	.octa 0xc0000000000300070000000000001000
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C28 */
	.octa 0x10400000
	/* C29 */
	.octa 0xc0000000400000040000000000001000
	/* C30 */
	.octa 0x4000000000000000020000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x48000000000300070000000000001f90
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x4000000058040e6e0000000000001330
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x80000000000300070000000000001000
	/* C22 */
	.octa 0xc0000000000300070000000000001000
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C28 */
	.octa 0x10400000
	/* C29 */
	.octa 0xc0000000400000040000000000001000
	/* C30 */
	.octa 0x4000000000000000020000000000
initial_SP_EL0_value:
	.octa 0x800000004201082cc8000000016be000
initial_SP_EL1_value:
	.octa 0x4c000000000100070000000000000c80
initial_VBAR_EL1_value:
	.octa 0x200080005000020d0000000040400001
final_SP_EL0_value:
	.octa 0x800000004201082cc8000000016be000
final_SP_EL1_value:
	.octa 0x4c000000000100070000000000001020
final_PCC_value:
	.octa 0x200080005000020d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000200000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword initial_SP_EL0_value
	.dword initial_SP_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001020
	.dword 0x0000000000001030
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001330
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
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02000252 // add c18, c18, #0
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02020252 // add c18, c18, #128
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02040252 // add c18, c18, #256
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02060252 // add c18, c18, #384
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02080252 // add c18, c18, #512
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x020a0252 // add c18, c18, #640
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x020c0252 // add c18, c18, #768
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x020e0252 // add c18, c18, #896
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02100252 // add c18, c18, #1024
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02120252 // add c18, c18, #1152
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02140252 // add c18, c18, #1280
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02160252 // add c18, c18, #1408
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x02180252 // add c18, c18, #1536
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x021a0252 // add c18, c18, #1664
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x021c0252 // add c18, c18, #1792
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x82600df2 // ldr x18, [c15, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400df2 // str x18, [c15, #0]
	ldr x18, =0x40400414
	mrs x15, ELR_EL1
	sub x18, x18, x15
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24f // cvtp c15, x18
	.inst 0xc2d241ef // scvalue c15, c15, x18
	.inst 0x826001f2 // ldr c18, [c15, #0]
	.inst 0x021e0252 // add c18, c18, #1920
	.inst 0xc2c21240 // br c18

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
