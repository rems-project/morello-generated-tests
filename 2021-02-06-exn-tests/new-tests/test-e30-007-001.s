.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c513bd // CVTD-R.C-C Rd:29 Cn:29 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2c513fd // CVTD-R.C-C Rd:29 Cn:31 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x7821119f // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:12 00:00 opc:001 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x8280d03d // ASTRB-R.RRB-B Rt:29 Rn:1 opc:00 S:1 option:110 Rm:0 0:0 L:0 100000101:100000101
	.inst 0xb20356d2 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:18 Rn:22 imms:010101 immr:000011 N:0 100100:100100 opc:01 sf:1
	.inst 0x88dffc21 // ldar:aarch64/instrs/memory/ordered Rt:1 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x3a000391 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:17 Rn:28 000000:000000 Rm:0 11010000:11010000 S:1 op:0 sf:0
	.inst 0x358a3528 // cbnz:aarch64/instrs/branch/conditional/compare Rt:8 imm19:1000101000110101001 op:1 011010:011010 sf:0
	.inst 0x227ff379 // LDAXP-C.R-C Ct:25 Rn:27 Ct2:11100 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xd4000001
	.zero 65496
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae8 // ldr c8, [x23, #2]
	.inst 0xc2400eec // ldr c12, [x23, #3]
	.inst 0xc24012fb // ldr c27, [x23, #4]
	.inst 0xc24016fd // ldr c29, [x23, #5]
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x4
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82601297 // ldr c23, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f4 // ldr c20, [x23, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24006f4 // ldr c20, [x23, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400af4 // ldr c20, [x23, #2]
	.inst 0xc2d4a501 // chkeq c8, c20
	b.ne comparison_fail
	.inst 0xc2400ef4 // ldr c20, [x23, #3]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc24012f4 // ldr c20, [x23, #4]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc24016f4 // ldr c20, [x23, #5]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc2401af4 // ldr c20, [x23, #6]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2401ef4 // ldr c20, [x23, #7]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984114 // mrs c20, CSP_EL0
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001060
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.byte 0x26, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x04, 0x10, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x02, 0x00, 0x00
	.zero 4000
.data
check_data0:
	.byte 0x00, 0xc0, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x04, 0x10, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x02, 0x00, 0x00
.data
check_data2:
	.byte 0xbd, 0x13, 0xc5, 0xc2, 0xfd, 0x13, 0xc5, 0xc2, 0x9f, 0x11, 0x21, 0x78, 0x3d, 0xd0, 0x80, 0x82
	.byte 0xd2, 0x56, 0x03, 0xb2, 0x21, 0xfc, 0xdf, 0x88, 0x91, 0x03, 0x00, 0x3a, 0x28, 0x35, 0x8a, 0x35
	.byte 0x79, 0xf3, 0x7f, 0x22, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40000000000700270000000000001000
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x1000
	/* C27 */
	.octa 0x1040
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc000
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x1000
	/* C25 */
	.octa 0x1004800000000000000000000000
	/* C27 */
	.octa 0x1040
	/* C28 */
	.octa 0x200800000000000000000000000
	/* C29 */
	.octa 0x100000000000
initial_SP_EL0_value:
	.octa 0x100000000000
initial_DDC_EL0_value:
	.octa 0xd00000001f73000700ffe00000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x100000000000
final_PCC_value:
	.octa 0x20008000000300070000000040400028
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
	.dword 0x0000000000001040
	.dword 0x0000000000001050
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001040
	.dword 0x0000000000001050
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600e97 // ldr x23, [c20, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e97 // str x23, [c20, #0]
	ldr x23, =0x40400028
	mrs x20, ELR_EL1
	sub x23, x23, x20
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f4 // cvtp c20, x23
	.inst 0xc2d74294 // scvalue c20, c20, x23
	.inst 0x82600297 // ldr c23, [c20, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
