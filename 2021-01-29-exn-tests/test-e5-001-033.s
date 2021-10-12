.section text0, #alloc, #execinstr
test_start:
	.inst 0x7821323f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x0820ffa2 // casp:aarch64/instrs/memory/atomicops/cas/pair Rt:2 Rn:29 Rt2:11111 o0:1 Rs:0 1:1 L:0 0010000:0010000 sz:0 0:0
	.inst 0x38ff0196 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:12 00:00 opc:000 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x8276b7bd // ALDRB-R.RI-B Rt:29 Rn:29 op:01 imm9:101101011 L:1 1000001001:1000001001
	.inst 0x223ad1c8 // STLXP-R.CR-C Ct:8 Rn:14 Ct2:10100 1:1 Rs:26 1:1 L:0 001000100:001000100
	.zero 3052
	.inst 0xc2c611bf // 0xc2c611bf
	.inst 0xb8e46140 // 0xb8e46140
	.inst 0xa86d643d // 0xa86d643d
	.inst 0x485f7fbe // 0x485f7fbe
	.inst 0xd4000001
	.zero 62444
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400962 // ldr c2, [x11, #2]
	.inst 0xc2400d63 // ldr c3, [x11, #3]
	.inst 0xc2401164 // ldr c4, [x11, #4]
	.inst 0xc2401568 // ldr c8, [x11, #5]
	.inst 0xc240196a // ldr c10, [x11, #6]
	.inst 0xc2401d6c // ldr c12, [x11, #7]
	.inst 0xc240216d // ldr c13, [x11, #8]
	.inst 0xc240256e // ldr c14, [x11, #9]
	.inst 0xc2402971 // ldr c17, [x11, #10]
	.inst 0xc2402d74 // ldr c20, [x11, #11]
	.inst 0xc240317d // ldr c29, [x11, #12]
	/* Set up flags and system registers */
	ldr x11, =0x4000000
	msr SPSR_EL3, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0xc0000
	msr CPACR_EL1, x11
	ldr x11, =0x0
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x4
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =initial_DDC_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c412b // msr DDC_EL1, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260136b // ldr c11, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e402b // msr CELR_EL3, c11
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240017b // ldr c27, [x11, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240057b // ldr c27, [x11, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240097b // ldr c27, [x11, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400d7b // ldr c27, [x11, #3]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc240117b // ldr c27, [x11, #4]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc240157b // ldr c27, [x11, #5]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc240197b // ldr c27, [x11, #6]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc2401d7b // ldr c27, [x11, #7]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc240217b // ldr c27, [x11, #8]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc240257b // ldr c27, [x11, #9]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc240297b // ldr c27, [x11, #10]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc2402d7b // ldr c27, [x11, #11]
	.inst 0xc2dba681 // chkeq c20, c27
	b.ne comparison_fail
	.inst 0xc240317b // ldr c27, [x11, #12]
	.inst 0xc2dba6c1 // chkeq c22, c27
	b.ne comparison_fail
	.inst 0xc240357b // ldr c27, [x11, #13]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc240397b // ldr c27, [x11, #14]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc2403d7b // ldr c27, [x11, #15]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_SP_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc29c411b // mrs c27, CSP_EL1
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x11, 0x83
	orr x27, x27, x11
	ldr x11, =0x920000eb
	cmp x11, x27
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
	ldr x2, =0x00001042
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010d0
	ldr x1, =check_data2
	ldr x2, =0x000010e0
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
	ldr x0, =0x40400c00
	ldr x1, =check_data5
	ldr x2, =0x40400c14
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x404041eb
	ldr x1, =check_data6
	ldr x2, =0x404041ec
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 192
	.byte 0x02, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3872
.data
check_data0:
	.byte 0x80, 0x00, 0x00, 0x00, 0x10, 0x20, 0x04, 0x00
.data
check_data1:
	.byte 0x00, 0x12
.data
check_data2:
	.byte 0x02, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x3f, 0x32, 0x21, 0x78, 0xa2, 0xff, 0x20, 0x08, 0x96, 0x01, 0xff, 0x38, 0xbd, 0xb7, 0x76, 0x82
	.byte 0xc8, 0xd1, 0x3a, 0x22
.data
check_data5:
	.byte 0xbf, 0x11, 0xc6, 0xc2, 0x40, 0x61, 0xe4, 0xb8, 0x3d, 0x64, 0x6d, 0xa8, 0xbe, 0x7f, 0x5f, 0x48
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1200
	/* C2 */
	.octa 0x80
	/* C3 */
	.octa 0x42010
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1000
	/* C12 */
	.octa 0xc0000000000100050000000000001ffe
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x800000000000000000000000
	/* C17 */
	.octa 0xc0000000400000440000000000001040
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0xc0000000000100050000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80
	/* C1 */
	.octa 0x1200
	/* C2 */
	.octa 0x80
	/* C3 */
	.octa 0x42010
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1000
	/* C12 */
	.octa 0xc0000000000100050000000000001ffe
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x800000000000000000000000
	/* C17 */
	.octa 0xc0000000400000440000000000001040
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x1002
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000000f030b00000000403e0001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004c20003d0000000040400800
final_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x200080004c20003d0000000040400c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000400020000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword initial_cap_values + 160
	.dword initial_cap_values + 176
	.dword initial_cap_values + 192
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x82600f6b // ldr x11, [c27, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f6b // str x11, [c27, #0]
	ldr x11, =0x40400c14
	mrs x27, ELR_EL1
	sub x11, x11, x27
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17b // cvtp c27, x11
	.inst 0xc2cb437b // scvalue c27, c27, x11
	.inst 0x8260036b // ldr c11, [c27, #0]
	.inst 0x021e016b // add c11, c11, #1920
	.inst 0xc2c21160 // br c11

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
