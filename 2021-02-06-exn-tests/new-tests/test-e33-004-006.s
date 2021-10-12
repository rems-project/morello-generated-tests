.section text0, #alloc, #execinstr
test_start:
	.inst 0x697653a6 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:6 Rn:29 Rt2:10100 imm7:1101100 L:1 1010010:1010010 opc:01
	.inst 0x299a5cb7 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:23 Rn:5 Rt2:10111 imm7:0110100 L:0 1010011:1010011 opc:00
	.inst 0xb81de61a // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:26 Rn:16 01:01 imm9:111011110 0:0 opc:00 111000:111000 size:10
	.inst 0x4b338819 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:25 Rn:0 imm3:010 option:100 Rm:19 01011001:01011001 S:0 op:1 sf:0
	.inst 0xc2dd8481 // CHKSS-_.CC-C 00001:00001 Cn:4 001:001 opc:00 1:1 Cm:29 11000010110:11000010110
	.inst 0x787f23bf // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:010 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xd85484df // prfm_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:0101010010000100110 011000:011000 opc:11
	.inst 0xe2af659e // ALDUR-V.RI-S Rt:30 Rn:12 op2:01 imm9:011110110 V:1 op1:10 11100010:11100010
	.inst 0xe210d3a1 // ASTURB-R.RI-32 Rt:1 Rn:29 op2:00 imm9:100001101 V:0 op1:00 11100010:11100010
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc2400865 // ldr c5, [x3, #2]
	.inst 0xc2400c6c // ldr c12, [x3, #3]
	.inst 0xc2401070 // ldr c16, [x3, #4]
	.inst 0xc2401477 // ldr c23, [x3, #5]
	.inst 0xc240187a // ldr c26, [x3, #6]
	.inst 0xc2401c7d // ldr c29, [x3, #7]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0x3c0000
	msr CPACR_EL1, x3
	ldr x3, =0x0
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x4
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82601103 // ldr c3, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x8, #0xf
	and x3, x3, x8
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400068 // ldr c8, [x3, #0]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400468 // ldr c8, [x3, #1]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc2400868 // ldr c8, [x3, #2]
	.inst 0xc2c8a4a1 // chkeq c5, c8
	b.ne comparison_fail
	.inst 0xc2400c68 // ldr c8, [x3, #3]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc2401068 // ldr c8, [x3, #4]
	.inst 0xc2c8a581 // chkeq c12, c8
	b.ne comparison_fail
	.inst 0xc2401468 // ldr c8, [x3, #5]
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	.inst 0xc2401868 // ldr c8, [x3, #6]
	.inst 0xc2c8a681 // chkeq c20, c8
	b.ne comparison_fail
	.inst 0xc2401c68 // ldr c8, [x3, #7]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2402068 // ldr c8, [x3, #8]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2402468 // ldr c8, [x3, #9]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x8, v30.d[0]
	cmp x3, x8
	b.ne comparison_fail
	ldr x3, =0x0
	mov x8, v30.d[1]
	cmp x3, x8
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a461 // chkeq c3, c8
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000130d
	ldr x1, =check_data2
	ldr x2, =0x0000130e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013b0
	ldr x1, =check_data3
	ldr x2, =0x000013b8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001400
	ldr x1, =check_data4
	ldr x2, =0x00001402
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff8
	ldr x1, =check_data5
	ldr x2, =0x00001ffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
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
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x19
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0xa6, 0x53, 0x76, 0x69, 0xb7, 0x5c, 0x9a, 0x29, 0x1a, 0xe6, 0x1d, 0xb8, 0x19, 0x88, 0x33, 0x4b
	.byte 0x81, 0x84, 0xdd, 0xc2, 0xbf, 0x23, 0x7f, 0x78, 0xdf, 0x84, 0x54, 0xd8, 0x9e, 0x65, 0xaf, 0xe2
	.byte 0xa1, 0xd3, 0x10, 0xe2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x200920050000000000000000
	/* C5 */
	.octa 0xf50
	/* C12 */
	.octa 0x80000000000100050000000000001f02
	/* C16 */
	.octa 0x1000
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x19000000
	/* C29 */
	.octa 0x40000000000000000000000000001400
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x200920050000000000000000
	/* C5 */
	.octa 0x1020
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x80000000000100050000000000001f02
	/* C16 */
	.octa 0xfde
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x19000000
	/* C29 */
	.octa 0x40000000000000000000000000001400
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000100070000000040400028
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
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001020
	.dword 0x0000000000001300
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600d03 // ldr x3, [c8, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d03 // str x3, [c8, #0]
	ldr x3, =0x40400028
	mrs x8, ELR_EL1
	sub x3, x3, x8
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b068 // cvtp c8, x3
	.inst 0xc2c34108 // scvalue c8, c8, x3
	.inst 0x82600103 // ldr c3, [c8, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
