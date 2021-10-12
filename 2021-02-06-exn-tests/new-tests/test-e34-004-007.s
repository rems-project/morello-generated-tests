.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df03a9 // SCBNDS-C.CR-C Cd:9 Cn:29 000:000 opc:00 0:0 Rm:31 11000010110:11000010110
	.inst 0x782563ff // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:5 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xd2d1320f // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:15 imm16:1000100110010000 hw:10 100101:100101 opc:10 sf:1
	.inst 0x8246db59 // ASTR-R.RI-32 Rt:25 Rn:26 op:10 imm9:001101101 L:0 1000001001:1000001001
	.inst 0xe25857bd // ALDURH-R.RI-32 Rt:29 Rn:29 op2:01 imm9:110000101 V:0 op1:01 11100010:11100010
	.zero 1004
	.inst 0x421ffff4 // STLR-C.R-C Ct:20 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x826fd426 // ALDRB-R.RI-B Rt:6 Rn:1 op:01 imm9:011111101 L:1 1000001001:1000001001
	.inst 0x787e63bf // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:110 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xb7a3a337 // tbnz:aarch64/instrs/branch/conditional/test Rt:23 imm14:01110100011001 b40:10100 op:1 011011:011011 b5:1
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
	ldr x11, =initial_cap_values
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400565 // ldr c5, [x11, #1]
	.inst 0xc2400974 // ldr c20, [x11, #2]
	.inst 0xc2400d77 // ldr c23, [x11, #3]
	.inst 0xc2401179 // ldr c25, [x11, #4]
	.inst 0xc240157a // ldr c26, [x11, #5]
	.inst 0xc240197d // ldr c29, [x11, #6]
	.inst 0xc2401d7e // ldr c30, [x11, #7]
	/* Set up flags and system registers */
	ldr x11, =0x4000000
	msr SPSR_EL3, x11
	ldr x11, =initial_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288410b // msr CSP_EL0, c11
	ldr x11, =initial_SP_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c410b // msr CSP_EL1, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0xc0000
	msr CPACR_EL1, x11
	ldr x11, =0x0
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x0
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
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260122b // ldr c11, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
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
	.inst 0xc2400171 // ldr c17, [x11, #0]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400571 // ldr c17, [x11, #1]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc2400971 // ldr c17, [x11, #2]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc2400d71 // ldr c17, [x11, #3]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc2401171 // ldr c17, [x11, #4]
	.inst 0xc2d1a5e1 // chkeq c15, c17
	b.ne comparison_fail
	.inst 0xc2401571 // ldr c17, [x11, #5]
	.inst 0xc2d1a681 // chkeq c20, c17
	b.ne comparison_fail
	.inst 0xc2401971 // ldr c17, [x11, #6]
	.inst 0xc2d1a6e1 // chkeq c23, c17
	b.ne comparison_fail
	.inst 0xc2401d71 // ldr c17, [x11, #7]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc2402171 // ldr c17, [x11, #8]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc2402571 // ldr c17, [x11, #9]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402971 // ldr c17, [x11, #10]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984111 // mrs c17, CSP_EL0
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	ldr x11, =final_SP_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc29c4111 // mrs c17, CSP_EL1
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984031 // mrs c17, CELR_EL1
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	ldr x11, =esr_el1_dump_address
	ldr x11, [x11]
	mov x17, 0x80
	orr x11, x11, x17
	ldr x17, =0x920000a1
	cmp x17, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001105
	ldr x1, =check_data0
	ldr x2, =0x00001106
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011d4
	ldr x1, =check_data1
	ldr x2, =0x000011d8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001410
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
	.zero 1024
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3056
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xa9, 0x03, 0xdf, 0xc2, 0xff, 0x63, 0x25, 0x78, 0x0f, 0x32, 0xd1, 0xd2, 0x59, 0xdb, 0x46, 0x82
	.byte 0xbd, 0x57, 0x58, 0xe2
.data
check_data4:
	.byte 0xf4, 0xff, 0x1f, 0x42, 0x26, 0xd4, 0x6f, 0x82, 0xbf, 0x63, 0x7e, 0x78, 0x37, 0xa3, 0xa3, 0xb7
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000020140050000000000001008
	/* C5 */
	.octa 0x0
	/* C20 */
	.octa 0x40000000000
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x1020
	/* C29 */
	.octa 0x10000100030000000000001404
	/* C30 */
	.octa 0x8000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x80000000020140050000000000001008
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x10540414040000000000001404
	/* C15 */
	.octa 0x899000000000
	/* C20 */
	.octa 0x40000000000
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x1020
	/* C29 */
	.octa 0x10000100030000000000001404
	/* C30 */
	.octa 0x8000
initial_SP_EL0_value:
	.octa 0xc0000000080300050000000000001400
initial_SP_EL1_value:
	.octa 0x1400
initial_DDC_EL0_value:
	.octa 0xc00000000007041d0000000000000001
initial_DDC_EL1_value:
	.octa 0xcc000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_SP_EL0_value:
	.octa 0xc0000000080300050000000000001400
final_SP_EL1_value:
	.octa 0x1400
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000430100000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000011d0
	.dword 0x0000000000001400
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
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x82600e2b // ldr x11, [c17, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400e2b // str x11, [c17, #0]
	ldr x11, =0x40400414
	mrs x17, ELR_EL1
	sub x11, x11, x17
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b171 // cvtp c17, x11
	.inst 0xc2cb4231 // scvalue c17, c17, x11
	.inst 0x8260022b // ldr c11, [c17, #0]
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
