.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c213c1 // CHKSLD-C-C 00001:00001 Cn:30 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xa9c7ec01 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:0 Rt2:11011 imm7:0001111 L:1 1010011:1010011 opc:10
	.inst 0xc2cda375 // CLRPERM-C.CR-C Cd:21 Cn:27 000:000 1:1 10:10 Rm:13 11000010110:11000010110
	.inst 0x82ceeb6b // ALDRSH-R.RRB-32 Rt:11 Rn:27 opc:10 S:0 option:111 Rm:14 0:0 L:1 100000101:100000101
	.inst 0xc2ef1bbf // CVT-C.CR-C Cd:31 Cn:29 0110:0110 0:0 0:0 Rm:15 11000010111:11000010111
	.inst 0x885f7ffd // ldxr:aarch64/instrs/memory/exclusive/single Rt:29 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0xc2e133e6 // EORFLGS-C.CI-C Cd:6 Cn:31 0:0 10:10 imm8:00001001 11000010111:11000010111
	.inst 0x3897e59d // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:12 01:01 imm9:101111110 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c061de // SCOFF-C.CR-C Cd:30 Cn:14 000:000 opc:11 0:0 Rm:0 11000010110:11000010110
	.inst 0xd4000001
	.zero 65468
	.inst 0x0000c2c2
	.zero 20
	.inst 0x00c20000
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc240048c // ldr c12, [x4, #1]
	.inst 0xc240088e // ldr c14, [x4, #2]
	.inst 0xc2400c8f // ldr c15, [x4, #3]
	.inst 0xc240109d // ldr c29, [x4, #4]
	.inst 0xc240149e // ldr c30, [x4, #5]
	/* Set up flags and system registers */
	ldr x4, =0x4000000
	msr SPSR_EL3, x4
	ldr x4, =initial_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884104 // msr CSP_EL0, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0xc0000
	msr CPACR_EL1, x4
	ldr x4, =0x0
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =0x4
	msr S3_3_C1_C2_2, x4 // CCTLR_EL0
	ldr x4, =initial_DDC_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884124 // msr DDC_EL0, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010e4 // ldr c4, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e4024 // msr CELR_EL3, c4
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x7, #0xf
	and x4, x4, x7
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400087 // ldr c7, [x4, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400487 // ldr c7, [x4, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400887 // ldr c7, [x4, #2]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc2400c87 // ldr c7, [x4, #3]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401087 // ldr c7, [x4, #4]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401487 // ldr c7, [x4, #5]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401887 // ldr c7, [x4, #6]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401c87 // ldr c7, [x4, #7]
	.inst 0xc2c7a6a1 // chkeq c21, c7
	b.ne comparison_fail
	.inst 0xc2402087 // ldr c7, [x4, #8]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402487 // ldr c7, [x4, #9]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402887 // ldr c7, [x4, #10]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984107 // mrs c7, CSP_EL0
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001600
	ldr x1, =check_data0
	ldr x2, =0x00001610
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff0
	ldr x1, =check_data1
	ldr x2, =0x00001ff4
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
	ldr x0, =0x4040ffe4
	ldr x1, =check_data3
	ldr x2, =0x4040ffe6
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040fffe
	ldr x1, =check_data4
	ldr x2, =0x4040ffff
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
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
	.zero 1536
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xe4, 0xef, 0x40, 0x00, 0x00, 0x00, 0x82, 0xff
	.zero 2528
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xe4, 0xef, 0x40, 0x00, 0x00, 0x00, 0x82, 0xff
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc1, 0x13, 0xc2, 0xc2, 0x01, 0xec, 0xc7, 0xa9, 0x75, 0xa3, 0xcd, 0xc2, 0x6b, 0xeb, 0xce, 0x82
	.byte 0xbf, 0x1b, 0xef, 0xc2, 0xfd, 0x7f, 0x5f, 0x88, 0xe6, 0x33, 0xe1, 0xc2, 0x9d, 0xe5, 0x97, 0x38
	.byte 0xde, 0x61, 0xc0, 0xc2, 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.byte 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001588
	/* C12 */
	.octa 0x8000000000010005000000004040fffe
	/* C14 */
	.octa 0x80031ffb007e000040001000
	/* C15 */
	.octa 0x0
	/* C29 */
	.octa 0x800020070000000000000000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001600
	/* C1 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C6 */
	.octa 0x80000000000100050900000000001ff0
	/* C11 */
	.octa 0xffffc2c2
	/* C12 */
	.octa 0x8000000000010005000000004040ff7c
	/* C14 */
	.octa 0x80031ffb007e000040001000
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0xff8200000040efe4
	/* C27 */
	.octa 0xff8200000040efe4
	/* C29 */
	.octa 0xffffffffffffffc2
	/* C30 */
	.octa 0x80031ffb0081ff8000001600
initial_SP_EL0_value:
	.octa 0x80000000000100050000000000001ff0
initial_DDC_EL0_value:
	.octa 0x800000000009c0050000100000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x80000000000100050000000000001ff0
final_PCC_value:
	.octa 0x20008000000040080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x82600ce4 // ldr x4, [c7, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400ce4 // str x4, [c7, #0]
	ldr x4, =0x40400028
	mrs x7, ELR_EL1
	sub x4, x4, x7
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b087 // cvtp c7, x4
	.inst 0xc2c440e7 // scvalue c7, c7, x4
	.inst 0x826000e4 // ldr c4, [c7, #0]
	.inst 0x021e0084 // add c4, c4, #1920
	.inst 0xc2c21080 // br c4

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
