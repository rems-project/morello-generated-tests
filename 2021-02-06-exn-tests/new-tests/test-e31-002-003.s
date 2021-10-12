.section text0, #alloc, #execinstr
test_start:
	.inst 0x780ff9c0 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:14 10:10 imm9:011111111 0:0 opc:00 111000:111000 size:01
	.inst 0x399abfa1 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:29 imm12:011010101111 opc:10 111001:111001 size:00
	.inst 0x78d855ff // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:15 01:01 imm9:110000101 0:0 opc:11 111000:111000 size:01
	.inst 0xa2bb7c1e // CAS-C.R-C Ct:30 Rn:0 11111:11111 R:0 Cs:27 1:1 L:0 1:1 10100010:10100010
	.inst 0x78156731 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:17 Rn:25 01:01 imm9:101010110 0:0 opc:00 111000:111000 size:01
	.zero 1004
	.inst 0x88f2fff8 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:24 Rn:31 11111:11111 o0:1 Rs:18 1:1 L:1 0010001:0010001 size:10
	.inst 0xb7d7417f // tbnz:aarch64/instrs/branch/conditional/test Rt:31 imm14:11101000001011 b40:11010 op:1 011011:011011 b5:1
	.inst 0x82fd67e1 // ALDR-R.RRB-64 Rt:1 Rn:31 opc:01 S:0 option:011 Rm:29 1:1 L:1 100000101:100000101
	.inst 0xe2d69031 // ASTUR-R.RI-64 Rt:17 Rn:1 op2:00 imm9:101101001 V:0 op1:11 11100010:11100010
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006ae // ldr c14, [x21, #1]
	.inst 0xc2400aaf // ldr c15, [x21, #2]
	.inst 0xc2400eb1 // ldr c17, [x21, #3]
	.inst 0xc24012b2 // ldr c18, [x21, #4]
	.inst 0xc24016b9 // ldr c25, [x21, #5]
	.inst 0xc2401abb // ldr c27, [x21, #6]
	.inst 0xc2401ebd // ldr c29, [x21, #7]
	.inst 0xc24022be // ldr c30, [x21, #8]
	/* Set up flags and system registers */
	ldr x21, =0x0
	msr SPSR_EL3, x21
	ldr x21, =initial_SP_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc28c4115 // msr CSP_EL1, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30d5d99f
	msr SCTLR_EL1, x21
	ldr x21, =0xc0000
	msr CPACR_EL1, x21
	ldr x21, =0x0
	msr S3_0_C1_C2_2, x21 // CCTLR_EL1
	ldr x21, =0x0
	msr S3_3_C1_C2_2, x21 // CCTLR_EL0
	ldr x21, =initial_DDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884135 // msr DDC_EL0, c21
	ldr x21, =initial_DDC_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc28c4135 // msr DDC_EL1, c21
	ldr x21, =0x80000000
	msr HCR_EL2, x21
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601175 // ldr c21, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc28e4035 // msr CELR_EL3, c21
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002ab // ldr c11, [x21, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24006ab // ldr c11, [x21, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400aab // ldr c11, [x21, #2]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc2400eab // ldr c11, [x21, #3]
	.inst 0xc2cba5e1 // chkeq c15, c11
	b.ne comparison_fail
	.inst 0xc24012ab // ldr c11, [x21, #4]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc24016ab // ldr c11, [x21, #5]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc2401aab // ldr c11, [x21, #6]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	.inst 0xc2401eab // ldr c11, [x21, #7]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc24022ab // ldr c11, [x21, #8]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc24026ab // ldr c11, [x21, #9]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check system registers */
	ldr x21, =final_SP_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc29c410b // mrs c11, CSP_EL1
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	ldr x21, =final_PCC_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	ldr x21, =esr_el1_dump_address
	ldr x21, [x21]
	mov x11, 0x80
	orr x21, x21, x11
	ldr x11, =0x920000e1
	cmp x11, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001006
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000012af
	ldr x1, =check_data1
	ldr x2, =0x000012b0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001320
	ldr x1, =check_data2
	ldr x2, =0x00001330
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001508
	ldr x1, =check_data3
	ldr x2, =0x0000150a
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001c00
	ldr x1, =check_data4
	ldr x2, =0x00001c08
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f70
	ldr x1, =check_data5
	ldr x2, =0x00001f78
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x40400414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
	.zero 3072
	.byte 0x07, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1008
.data
check_data0:
	.zero 6
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x20, 0x13
.data
check_data4:
	.byte 0x07, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0x00, 0x00, 0x02, 0x00, 0x02, 0x02, 0x00, 0x02
.data
check_data6:
	.byte 0xc0, 0xf9, 0x0f, 0x78, 0xa1, 0xbf, 0x9a, 0x39, 0xff, 0x55, 0xd8, 0x78, 0x1e, 0x7c, 0xbb, 0xa2
	.byte 0x31, 0x67, 0x15, 0x78
.data
check_data7:
	.byte 0xf8, 0xff, 0xf2, 0x88, 0x7f, 0x41, 0xd7, 0xb7, 0xe1, 0x67, 0xfd, 0x82, 0x31, 0x90, 0xd6, 0xe2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1320
	/* C14 */
	.octa 0x1409
	/* C15 */
	.octa 0x1004
	/* C17 */
	.octa 0x200020200020000
	/* C18 */
	.octa 0xffffffff
	/* C25 */
	.octa 0x80000000000001
	/* C27 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C29 */
	.octa 0xc00
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1320
	/* C1 */
	.octa 0x2007
	/* C14 */
	.octa 0x1409
	/* C15 */
	.octa 0xf89
	/* C17 */
	.octa 0x200020200020000
	/* C18 */
	.octa 0x0
	/* C25 */
	.octa 0x80000000000001
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0xc00
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0xc0000000040600070000000000001000
initial_DDC_EL0_value:
	.octa 0xcc000000000200030000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000700070000000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000500000140000000040400001
final_SP_EL1_value:
	.octa 0xc0000000040600070000000000001000
final_PCC_value:
	.octa 0x20008000500000140000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001320
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 144
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001320
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001500
	.dword 0x0000000000001f70
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
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x020002b5 // add c21, c21, #0
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x020202b5 // add c21, c21, #128
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x020402b5 // add c21, c21, #256
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x020602b5 // add c21, c21, #384
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x020802b5 // add c21, c21, #512
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x020a02b5 // add c21, c21, #640
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x020c02b5 // add c21, c21, #768
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x020e02b5 // add c21, c21, #896
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x021002b5 // add c21, c21, #1024
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x021202b5 // add c21, c21, #1152
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x021402b5 // add c21, c21, #1280
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x021602b5 // add c21, c21, #1408
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x021802b5 // add c21, c21, #1536
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x021a02b5 // add c21, c21, #1664
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x021c02b5 // add c21, c21, #1792
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600d75 // ldr x21, [c11, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400d75 // str x21, [c11, #0]
	ldr x21, =0x40400414
	mrs x11, ELR_EL1
	sub x21, x21, x11
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ab // cvtp c11, x21
	.inst 0xc2d5416b // scvalue c11, c11, x21
	.inst 0x82600175 // ldr c21, [c11, #0]
	.inst 0x021e02b5 // add c21, c21, #1920
	.inst 0xc2c212a0 // br c21

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
