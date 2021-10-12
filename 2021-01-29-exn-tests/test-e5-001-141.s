.section text0, #alloc, #execinstr
test_start:
	.inst 0x7821323f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x0820ffa2 // casp:aarch64/instrs/memory/atomicops/cas/pair Rt:2 Rn:29 Rt2:11111 o0:1 Rs:0 1:1 L:0 0010000:0010000 sz:0 0:0
	.inst 0x38ff0196 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:12 00:00 opc:000 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x8276b7bd // ALDRB-R.RI-B Rt:29 Rn:29 op:01 imm9:101101011 L:1 1000001001:1000001001
	.inst 0x223ad1c8 // STLXP-R.CR-C Ct:8 Rn:14 Ct2:10100 1:1 Rs:26 1:1 L:0 001000100:001000100
	.zero 58348
	.inst 0xc2c611bf // 0xc2c611bf
	.inst 0xb8e46140 // 0xb8e46140
	.inst 0xa86d643d // 0xa86d643d
	.inst 0x485f7fbe // 0x485f7fbe
	.inst 0xd4000001
	.zero 7148
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
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a42 // ldr c2, [x18, #2]
	.inst 0xc2400e43 // ldr c3, [x18, #3]
	.inst 0xc2401244 // ldr c4, [x18, #4]
	.inst 0xc2401648 // ldr c8, [x18, #5]
	.inst 0xc2401a4a // ldr c10, [x18, #6]
	.inst 0xc2401e4c // ldr c12, [x18, #7]
	.inst 0xc240224d // ldr c13, [x18, #8]
	.inst 0xc240264e // ldr c14, [x18, #9]
	.inst 0xc2402a51 // ldr c17, [x18, #10]
	.inst 0xc2402e54 // ldr c20, [x18, #11]
	.inst 0xc240325d // ldr c29, [x18, #12]
	/* Set up flags and system registers */
	ldr x18, =0x4000000
	msr SPSR_EL3, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30d5d99f
	msr SCTLR_EL1, x18
	ldr x18, =0xc0000
	msr CPACR_EL1, x18
	ldr x18, =0x4
	msr S3_0_C1_C2_2, x18 // CCTLR_EL1
	ldr x18, =0x4
	msr S3_3_C1_C2_2, x18 // CCTLR_EL0
	ldr x18, =initial_DDC_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884132 // msr DDC_EL0, c18
	ldr x18, =initial_DDC_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc28c4132 // msr DDC_EL1, c18
	ldr x18, =0x80000000
	msr HCR_EL2, x18
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601352 // ldr c18, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240025a // ldr c26, [x18, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240065a // ldr c26, [x18, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a5a // ldr c26, [x18, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400e5a // ldr c26, [x18, #3]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc240125a // ldr c26, [x18, #4]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc240165a // ldr c26, [x18, #5]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc2401a5a // ldr c26, [x18, #6]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc2401e5a // ldr c26, [x18, #7]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc240225a // ldr c26, [x18, #8]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc240265a // ldr c26, [x18, #9]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc2402a5a // ldr c26, [x18, #10]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc2402e5a // ldr c26, [x18, #11]
	.inst 0xc2daa681 // chkeq c20, c26
	b.ne comparison_fail
	.inst 0xc240325a // ldr c26, [x18, #12]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc240365a // ldr c26, [x18, #13]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc2403a5a // ldr c26, [x18, #14]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2403e5a // ldr c26, [x18, #15]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check system registers */
	ldr x18, =final_SP_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc29c411a // mrs c26, CSP_EL1
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	ldr x18, =final_PCC_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	ldr x26, =esr_el1_dump_address
	ldr x26, [x26]
	mov x18, 0x83
	orr x26, x26, x18
	ldr x18, =0x920000e3
	cmp x18, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001173
	ldr x1, =check_data2
	ldr x2, =0x00001174
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013d0
	ldr x1, =check_data3
	ldr x2, =0x000013e0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001880
	ldr x1, =check_data4
	ldr x2, =0x00001882
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
	ldr x0, =0x4040e400
	ldr x1, =check_data6
	ldr x2, =0x4040e414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x15, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 896
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1184
	.byte 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1904
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x01, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x40, 0x15
.data
check_data5:
	.byte 0x3f, 0x32, 0x21, 0x78, 0xa2, 0xff, 0x20, 0x08, 0x96, 0x01, 0xff, 0x38, 0xbd, 0xb7, 0x76, 0x82
	.byte 0xc8, 0xd1, 0x3a, 0x22
.data
check_data6:
	.byte 0xbf, 0x11, 0xc6, 0xc2, 0x40, 0x61, 0xe4, 0xb8, 0x3d, 0x64, 0x6d, 0xa8, 0xbe, 0x7f, 0x5f, 0x48
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1500
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1040
	/* C12 */
	.octa 0xc0000000400110000000000000001000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x4c0000000022000d00ffffffffffffff
	/* C17 */
	.octa 0xc0000000000300070000000000001880
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000504403f80000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x100
	/* C1 */
	.octa 0x1500
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1040
	/* C12 */
	.octa 0xc0000000400110000000000000001000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x4c0000000022000d00ffffffffffffff
	/* C17 */
	.octa 0xc0000000000300070000000000001880
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x800000001007000f0000000000000001
initial_DDC_EL1_value:
	.octa 0xc00000000021000500ffffffe300e001
initial_VBAR_EL1_value:
	.octa 0x200080004000e02d000000004040e000
final_SP_EL1_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080004000e02d000000004040e414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500400000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword initial_cap_values + 160
	.dword initial_cap_values + 176
	.dword initial_cap_values + 192
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 176
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
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x02000252 // add c18, c18, #0
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x02020252 // add c18, c18, #128
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x02040252 // add c18, c18, #256
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x02060252 // add c18, c18, #384
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x02080252 // add c18, c18, #512
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x020a0252 // add c18, c18, #640
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x020c0252 // add c18, c18, #768
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x020e0252 // add c18, c18, #896
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x02100252 // add c18, c18, #1024
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x02120252 // add c18, c18, #1152
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x02140252 // add c18, c18, #1280
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x02160252 // add c18, c18, #1408
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x02180252 // add c18, c18, #1536
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x021a0252 // add c18, c18, #1664
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
	.inst 0x021c0252 // add c18, c18, #1792
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600f52 // ldr x18, [c26, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400f52 // str x18, [c26, #0]
	ldr x18, =0x4040e414
	mrs x26, ELR_EL1
	sub x18, x18, x26
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b25a // cvtp c26, x18
	.inst 0xc2d2435a // scvalue c26, c26, x18
	.inst 0x82600352 // ldr c18, [c26, #0]
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
