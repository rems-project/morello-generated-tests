.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1401d // SCVALUE-C.CR-C Cd:29 Cn:0 000:000 opc:10 0:0 Rm:1 11000010110:11000010110
	.inst 0xa246883a // LDTR-C.RIB-C Ct:26 Rn:1 10:10 imm9:001101000 0:0 opc:01 10100010:10100010
	.inst 0x882c93dd // stlxp:aarch64/instrs/memory/exclusive/pair Rt:29 Rn:30 Rt2:00100 o0:1 Rs:12 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0xba40c3e3 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0011 0:0 Rn:31 00:00 cond:1100 Rm:0 111010010:111010010 op:0 sf:1
	.inst 0xd2dad070 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:16 imm16:1101011010000011 hw:10 100101:100101 opc:10 sf:1
	.inst 0xa25049ed // LDTR-C.RIB-C Ct:13 Rn:15 10:10 imm9:100000100 0:0 opc:01 10100010:10100010
	.inst 0x227f602f // LDXP-C.R-C Ct:15 Rn:1 Ct2:11000 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0x78d7dd1e // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:8 11:11 imm9:101111101 0:0 opc:11 111000:111000 size:01
	.inst 0x511b23af // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:15 Rn:29 imm12:011011001000 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xd4000001
	.zero 32788
	.inst 0x40400000
	.zero 32704
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400928 // ldr c8, [x9, #2]
	.inst 0xc2400d2f // ldr c15, [x9, #3]
	.inst 0xc240113e // ldr c30, [x9, #4]
	/* Set up flags and system registers */
	ldr x9, =0x4000000
	msr SPSR_EL3, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0xc0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010a9 // ldr c9, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x5, #0xf
	and x9, x9, x5
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400125 // ldr c5, [x9, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400525 // ldr c5, [x9, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400925 // ldr c5, [x9, #2]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2400d25 // ldr c5, [x9, #3]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc2401125 // ldr c5, [x9, #4]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2401525 // ldr c5, [x9, #5]
	.inst 0xc2c5a5e1 // chkeq c15, c5
	b.ne comparison_fail
	.inst 0xc2401925 // ldr c5, [x9, #6]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc2401d25 // ldr c5, [x9, #7]
	.inst 0xc2c5a701 // chkeq c24, c5
	b.ne comparison_fail
	.inst 0xc2402125 // ldr c5, [x9, #8]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2402525 // ldr c5, [x9, #9]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402925 // ldr c5, [x9, #10]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001680
	ldr x1, =check_data1
	ldr x2, =0x00001690
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000016a0
	ldr x1, =check_data2
	ldr x2, =0x000016b0
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
	ldr x2, =0x40400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040803e
	ldr x1, =check_data5
	ldr x2, =0x40408040
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
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.byte 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
	.byte 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
	.zero 1632
	.byte 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
	.zero 16
	.byte 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x80, 0x01, 0x08, 0x40, 0x40
	.zero 2368
	.byte 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
	.byte 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
.data
check_data1:
	.byte 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
.data
check_data2:
	.byte 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x80, 0x01, 0x08, 0x40, 0x40
.data
check_data3:
	.byte 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
.data
check_data4:
	.byte 0x1d, 0x40, 0xc1, 0xc2, 0x3a, 0x88, 0x46, 0xa2, 0xdd, 0x93, 0x2c, 0x88, 0xe3, 0xc3, 0x40, 0xba
	.byte 0x70, 0xd0, 0xda, 0xd2, 0xed, 0x49, 0x50, 0xa2, 0x2f, 0x60, 0x7f, 0x22, 0x1e, 0xdd, 0xd7, 0x78
	.byte 0xaf, 0x23, 0x1b, 0x51, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0x40, 0x40

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800300070000e00000000001
	/* C1 */
	.octa 0x80000000000100050000000000001000
	/* C8 */
	.octa 0x800000000007800f00000000404080c1
	/* C15 */
	.octa 0x90000000000100060000000000002660
	/* C30 */
	.octa 0x40000000000100050000000000001ff0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800300070000e00000000001
	/* C1 */
	.octa 0x80000000000100050000000000001000
	/* C8 */
	.octa 0x800000000007800f000000004040803e
	/* C12 */
	.octa 0x1
	/* C13 */
	.octa 0x40400801804040404040404040404040
	/* C15 */
	.octa 0x938
	/* C16 */
	.octa 0xd68300000000
	/* C24 */
	.octa 0x40404040404040404040404040404040
	/* C26 */
	.octa 0x40404040404040404040404040404040
	/* C29 */
	.octa 0x800300070000000000001000
	/* C30 */
	.octa 0x4040
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080000005004f0000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000005004f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x00000000000016a0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001010
	.dword 0x00000000000016a0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x82600ca9 // ldr x9, [c5, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400ca9 // str x9, [c5, #0]
	ldr x9, =0x40400028
	mrs x5, ELR_EL1
	sub x9, x9, x5
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b125 // cvtp c5, x9
	.inst 0xc2c940a5 // scvalue c5, c5, x9
	.inst 0x826000a9 // ldr c9, [c5, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
