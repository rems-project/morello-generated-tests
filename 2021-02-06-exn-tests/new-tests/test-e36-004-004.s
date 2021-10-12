.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df187e // ALIGND-C.CI-C Cd:30 Cn:3 0110:0110 U:0 imm6:111110 11000010110:11000010110
	.inst 0xc2c1323f // GCFLGS-R.C-C Rd:31 Cn:17 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x8272594b // ALDR-R.RI-32 Rt:11 Rn:10 op:10 imm9:100100101 L:1 1000001001:1000001001
	.inst 0xc2df8bbf // CHKSSU-C.CC-C Cd:31 Cn:29 0010:0010 opc:10 Cm:31 11000010110:11000010110
	.inst 0xb85ff75d // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:26 01:01 imm9:111111111 0:0 opc:01 111000:111000 size:10
	.zero 40
	.inst 0xe2b3f2fe // ASTUR-V.RI-S Rt:30 Rn:23 op2:00 imm9:100111111 V:1 op1:10 11100010:11100010
	.inst 0x2cad1960 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:0 Rn:11 Rt2:00110 imm7:1011010 L:0 1011001:1011001 opc:00
	.inst 0xd4000001
	.zero 952
	.inst 0xb860323f // stset:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:011 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xd65f0000 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 34964
	.inst 0x00001000
	.zero 29536
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c3 // ldr c3, [x6, #1]
	.inst 0xc24008ca // ldr c10, [x6, #2]
	.inst 0xc2400cd1 // ldr c17, [x6, #3]
	.inst 0xc24010d7 // ldr c23, [x6, #4]
	.inst 0xc24014da // ldr c26, [x6, #5]
	.inst 0xc24018dd // ldr c29, [x6, #6]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q0, =0x0
	ldr q6, =0x1000000
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884106 // msr CSP_EL0, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0x1c0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x0
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =initial_DDC_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4126 // msr DDC_EL1, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82601106 // ldr c6, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x8, #0xf
	and x6, x6, x8
	cmp x6, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c8 // ldr c8, [x6, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24004c8 // ldr c8, [x6, #1]
	.inst 0xc2c8a461 // chkeq c3, c8
	b.ne comparison_fail
	.inst 0xc24008c8 // ldr c8, [x6, #2]
	.inst 0xc2c8a541 // chkeq c10, c8
	b.ne comparison_fail
	.inst 0xc2400cc8 // ldr c8, [x6, #3]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc24010c8 // ldr c8, [x6, #4]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc24014c8 // ldr c8, [x6, #5]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc24018c8 // ldr c8, [x6, #6]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2401cc8 // ldr c8, [x6, #7]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc24020c8 // ldr c8, [x6, #8]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x8, v0.d[0]
	cmp x6, x8
	b.ne comparison_fail
	ldr x6, =0x0
	mov x8, v0.d[1]
	cmp x6, x8
	b.ne comparison_fail
	ldr x6, =0x1000000
	mov x8, v6.d[0]
	cmp x6, x8
	b.ne comparison_fail
	ldr x6, =0x0
	mov x8, v6.d[1]
	cmp x6, x8
	b.ne comparison_fail
	ldr x6, =0x0
	mov x8, v30.d[0]
	cmp x6, x8
	b.ne comparison_fail
	ldr x6, =0x0
	mov x8, v30.d[1]
	cmp x6, x8
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984108 // mrs c8, CSP_EL0
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x8, 0xc1
	orr x6, x6, x8
	ldr x8, =0x920000eb
	cmp x8, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001804
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x4040003c
	ldr x1, =check_data3
	ldr x2, =0x40400048
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400408
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40408c9c
	ldr x1, =check_data5
	ldr x2, =0x40408ca0
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
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x3c, 0x00, 0x40, 0x40
.data
check_data2:
	.byte 0x7e, 0x18, 0xdf, 0xc2, 0x3f, 0x32, 0xc1, 0xc2, 0x4b, 0x59, 0x72, 0x82, 0xbf, 0x8b, 0xdf, 0xc2
	.byte 0x5d, 0xf7, 0x5f, 0xb8
.data
check_data3:
	.byte 0xfe, 0xf2, 0xb3, 0xe2, 0x60, 0x19, 0xad, 0x2c, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.byte 0x3f, 0x32, 0x60, 0xb8, 0x00, 0x00, 0x5f, 0xd6
.data
check_data5:
	.byte 0x00, 0x10, 0x00, 0x00

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4040003c
	/* C3 */
	.octa 0x20002401634e0080000000000001
	/* C10 */
	.octa 0x40408808
	/* C17 */
	.octa 0x1800
	/* C23 */
	.octa 0x400000000001000500000000000010c9
	/* C26 */
	.octa 0x8000000040020002ff8000000001ffff
	/* C29 */
	.octa 0x2000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x4040003c
	/* C3 */
	.octa 0x20002401634e0080000000000001
	/* C10 */
	.octa 0x40408808
	/* C11 */
	.octa 0xf68
	/* C17 */
	.octa 0x1800
	/* C23 */
	.octa 0x400000000001000500000000000010c9
	/* C26 */
	.octa 0x8000000040020002ff8000000001ffff
	/* C29 */
	.octa 0x2000000000000000000000000000
	/* C30 */
	.octa 0x20002401634e0000000000000000
initial_SP_EL0_value:
	.octa 0x180060080000000000000
initial_DDC_EL0_value:
	.octa 0x80000000000780070000000040406001
initial_DDC_EL1_value:
	.octa 0xc0000000000701030000000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000500000000000000040400000
final_SP_EL0_value:
	.octa 0x180060080000000000000
final_PCC_value:
	.octa 0x20008000500000000000000040400048
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004020c0210000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
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
	.dword 0x0000000000001000
	.dword 0x0000000000001800
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600d06 // ldr x6, [c8, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d06 // str x6, [c8, #0]
	ldr x6, =0x40400048
	mrs x8, ELR_EL1
	sub x6, x6, x8
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c8 // cvtp c8, x6
	.inst 0xc2c64108 // scvalue c8, c8, x6
	.inst 0x82600106 // ldr c6, [c8, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
