.section text0, #alloc, #execinstr
test_start:
	.inst 0xb861ebff // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:31 Rn:31 10:10 S:0 option:111 Rm:1 1:1 opc:01 111000:111000 size:10
	.inst 0x9b3c827f // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:19 Ra:0 o0:1 Rm:28 01:01 U:0 10011011:10011011
	.inst 0x421ffedf // STLR-C.R-C Ct:31 Rn:22 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2df400c // SCVALUE-C.CR-C Cd:12 Cn:0 000:000 opc:10 0:0 Rm:31 11000010110:11000010110
	.inst 0xe2253a48 // ASTUR-V.RI-Q Rt:8 Rn:18 op2:10 imm9:001010011 V:1 op1:00 11100010:11100010
	.zero 1004
	.inst 0xc2c6b006 // CLRPERM-C.CI-C Cd:6 Cn:0 100:100 perm:101 1100001011000110:1100001011000110
	.inst 0x02a56fdb // SUB-C.CIS-C Cd:27 Cn:30 imm12:100101011011 sh:0 A:1 00000010:00000010
	.inst 0x089fffbf // stlrb:aarch64/instrs/memory/ordered Rt:31 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x516e54be // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:5 imm12:101110010101 sh:1 0:0 10001:10001 S:0 op:1 sf:0
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a32 // ldr c18, [x17, #2]
	.inst 0xc2400e36 // ldr c22, [x17, #3]
	.inst 0xc240123d // ldr c29, [x17, #4]
	.inst 0xc240163e // ldr c30, [x17, #5]
	/* Set up flags and system registers */
	ldr x17, =0x4000000
	msr SPSR_EL3, x17
	ldr x17, =initial_SP_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884111 // msr CSP_EL0, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30d5d99f
	msr SCTLR_EL1, x17
	ldr x17, =0x3c0000
	msr CPACR_EL1, x17
	ldr x17, =0x0
	msr S3_0_C1_C2_2, x17 // CCTLR_EL1
	ldr x17, =0x0
	msr S3_3_C1_C2_2, x17 // CCTLR_EL0
	ldr x17, =initial_DDC_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884131 // msr DDC_EL0, c17
	ldr x17, =0x80000000
	msr HCR_EL2, x17
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601331 // ldr c17, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc28e4031 // msr CELR_EL3, c17
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400239 // ldr c25, [x17, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400639 // ldr c25, [x17, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400a39 // ldr c25, [x17, #2]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc2400e39 // ldr c25, [x17, #3]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2401239 // ldr c25, [x17, #4]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2401639 // ldr c25, [x17, #5]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc2401a39 // ldr c25, [x17, #6]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc2401e39 // ldr c25, [x17, #7]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x17, =final_SP_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984119 // mrs c25, CSP_EL0
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	ldr x17, =final_PCC_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	ldr x17, =esr_el1_dump_address
	ldr x17, [x17]
	mov x25, 0x80
	orr x17, x17, x25
	ldr x25, =0x920000e9
	cmp x25, x17
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
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400400
	ldr x1, =check_data2
	ldr x2, =0x40400414
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
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
	.zero 16
.data
check_data1:
	.byte 0xff, 0xeb, 0x61, 0xb8, 0x7f, 0x82, 0x3c, 0x9b, 0xdf, 0xfe, 0x1f, 0x42, 0x0c, 0x40, 0xdf, 0xc2
	.byte 0x48, 0x3a, 0x25, 0xe2
.data
check_data2:
	.byte 0x06, 0xb0, 0xc6, 0xc2, 0xdb, 0x6f, 0xa5, 0x02, 0xbf, 0xff, 0x9f, 0x08, 0xbe, 0x54, 0x6e, 0x51
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x720470080000180002001
	/* C1 */
	.octa 0x0
	/* C18 */
	.octa 0xffffffffffffffad
	/* C22 */
	.octa 0x40000000000300070000000000001000
	/* C29 */
	.octa 0x40000000400308210000000000001000
	/* C30 */
	.octa 0x1000000a0070000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x720470080000180002001
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x720470080000180002001
	/* C12 */
	.octa 0x720470000000000000000
	/* C18 */
	.octa 0xffffffffffffffad
	/* C22 */
	.octa 0x40000000000300070000000000001000
	/* C27 */
	.octa 0x1000000a007fffffffffffff6a5
	/* C29 */
	.octa 0x40000000400308210000000000001000
initial_SP_EL0_value:
	.octa 0x80000000400400000000000040400000
initial_DDC_EL0_value:
	.octa 0x1000000000000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004800010d0000000040400001
final_SP_EL0_value:
	.octa 0x80000000400400000000000040400000
final_PCC_value:
	.octa 0x200080004800010d0000000040400414
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
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
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
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x02000231 // add c17, c17, #0
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x02020231 // add c17, c17, #128
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x02040231 // add c17, c17, #256
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x02060231 // add c17, c17, #384
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x02080231 // add c17, c17, #512
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x020a0231 // add c17, c17, #640
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x020c0231 // add c17, c17, #768
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x020e0231 // add c17, c17, #896
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x02100231 // add c17, c17, #1024
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x02120231 // add c17, c17, #1152
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x02140231 // add c17, c17, #1280
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x02160231 // add c17, c17, #1408
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x02180231 // add c17, c17, #1536
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x021a0231 // add c17, c17, #1664
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x021c0231 // add c17, c17, #1792
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600f31 // ldr x17, [c25, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400f31 // str x17, [c25, #0]
	ldr x17, =0x40400414
	mrs x25, ELR_EL1
	sub x17, x17, x25
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b239 // cvtp c25, x17
	.inst 0xc2d14339 // scvalue c25, c25, x17
	.inst 0x82600331 // ldr c17, [c25, #0]
	.inst 0x021e0231 // add c17, c17, #1920
	.inst 0xc2c21220 // br c17

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
