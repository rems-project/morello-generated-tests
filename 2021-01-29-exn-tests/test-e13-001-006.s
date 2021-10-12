.section text0, #alloc, #execinstr
test_start:
	.inst 0x1224d7f2 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:18 Rn:31 imms:110101 immr:100100 N:0 100100:100100 opc:00 sf:0
	.inst 0xd125a426 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:6 Rn:1 imm12:100101101001 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x889ffc64 // stlr:aarch64/instrs/memory/ordered Rt:4 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c411df // LDPBR-C.C-C Ct:31 Cn:14 100:100 opc:00 11000010110001000:11000010110001000
	.zero 24
	.inst 0xd4000001
	.zero 8596
	.inst 0x08017c18 // stxrb:aarch64/instrs/memory/exclusive/single Rt:24 Rn:0 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:00
	.inst 0xb99e6496 // 0xb99e6496
	.inst 0xc2c6c10c // 0xc2c6c10c
	.inst 0x427f7c81 // 0x427f7c81
	.inst 0xc2c433b5 // 0xc2c433b5
	.zero 56876
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400443 // ldr c3, [x2, #1]
	.inst 0xc2400844 // ldr c4, [x2, #2]
	.inst 0xc2400c48 // ldr c8, [x2, #3]
	.inst 0xc240104e // ldr c14, [x2, #4]
	.inst 0xc240145d // ldr c29, [x2, #5]
	/* Set up flags and system registers */
	ldr x2, =0x0
	msr SPSR_EL3, x2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0xc0000
	msr CPACR_EL1, x2
	ldr x2, =0x0
	msr S3_0_C1_C2_2, x2 // CCTLR_EL1
	ldr x2, =0x0
	msr S3_3_C1_C2_2, x2 // CCTLR_EL0
	ldr x2, =initial_DDC_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884122 // msr DDC_EL0, c2
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601342 // ldr c2, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc28e4022 // msr CELR_EL3, c2
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x26, #0xf
	and x2, x2, x26
	cmp x2, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc240005a // ldr c26, [x2, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240045a // ldr c26, [x2, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240085a // ldr c26, [x2, #2]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc2400c5a // ldr c26, [x2, #3]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc240105a // ldr c26, [x2, #4]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc240145a // ldr c26, [x2, #5]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc240185a // ldr c26, [x2, #6]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc2401c5a // ldr c26, [x2, #7]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc240205a // ldr c26, [x2, #8]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc240245a // ldr c26, [x2, #9]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc240285a // ldr c26, [x2, #10]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2402c5a // ldr c26, [x2, #11]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001210
	ldr x1, =check_data1
	ldr x2, =0x00001214
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400028
	ldr x1, =check_data4
	ldr x2, =0x4040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x404021c0
	ldr x1, =check_data5
	ldr x2, =0x404021d4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040a014
	ldr x1, =check_data6
	ldr x2, =0x4040a015
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040be78
	ldr x1, =check_data7
	ldr x2, =0x4040be7c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
	.zero 16
	.byte 0xc0, 0x21, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.byte 0x28, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x06, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 4048
.data
check_data0:
	.zero 16
	.byte 0xc0, 0x21, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.byte 0x28, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x06, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0x14, 0xa0, 0x40, 0x40
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xf2, 0xd7, 0x24, 0x12, 0x26, 0xa4, 0x25, 0xd1, 0x64, 0xfc, 0x9f, 0x88, 0xdf, 0x11, 0xc4, 0xc2
.data
check_data4:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0x18, 0x7c, 0x01, 0x08, 0x96, 0x64, 0x9e, 0xb9, 0x0c, 0xc1, 0xc6, 0xc2, 0x81, 0x7c, 0x7f, 0x42
	.byte 0xb5, 0x33, 0xc4, 0xc2
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1ffe
	/* C3 */
	.octa 0x1210
	/* C4 */
	.octa 0x800000004000a002000000004040a014
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000600200020000000000001000
	/* C29 */
	.octa 0x90100000520400020000000000001010
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1ffe
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1210
	/* C4 */
	.octa 0x800000004000a002000000004040a014
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000600200020000000000001000
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x200080008000400000000000404021c0
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x90100000520400020000000000001010
	/* C30 */
	.octa 0x200080000000400000000000404021d4
initial_DDC_EL0_value:
	.octa 0xc00000000003000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x2000800000060005000000004040002c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
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
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600f42 // ldr x2, [c26, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f42 // str x2, [c26, #0]
	ldr x2, =0x4040002c
	mrs x26, ELR_EL1
	sub x2, x2, x26
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05a // cvtp c26, x2
	.inst 0xc2c2435a // scvalue c26, c26, x2
	.inst 0x82600342 // ldr c2, [c26, #0]
	.inst 0x021e0042 // add c2, c2, #1920
	.inst 0xc2c21040 // br c2

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
