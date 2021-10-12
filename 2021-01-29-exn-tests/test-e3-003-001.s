.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dd69bf // ORRFLGS-C.CR-C Cd:31 Cn:13 1010:1010 opc:01 Rm:29 11000010110:11000010110
	.inst 0x8245c33e // ASTR-C.RI-C Ct:30 Rn:25 op:00 imm9:001011100 L:0 1000001001:1000001001
	.inst 0x782703be // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:29 00:00 opc:000 0:0 Rs:7 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xc2dfa741 // CHKEQ-_.CC-C 00001:00001 Cn:26 001:001 opc:01 1:1 Cm:31 11000010110:11000010110
	.inst 0xaa919b0e // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:14 Rn:24 imm6:100110 Rm:17 N:0 shift:10 01010:01010 opc:01 sf:1
	.inst 0x08df7c21 // ldlarb:aarch64/instrs/memory/ordered Rt:1 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xe2eed020 // ASTUR-V.RI-D Rt:0 Rn:1 op2:00 imm9:011101101 V:1 op1:11 11100010:11100010
	.inst 0xc2c513e1 // CVTD-R.C-C Rd:1 Cn:31 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x2969f419 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:25 Rn:0 Rt2:11101 imm7:1010011 L:1 1010010:1010010 opc:00
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a47 // ldr c7, [x18, #2]
	.inst 0xc2400e4d // ldr c13, [x18, #3]
	.inst 0xc2401259 // ldr c25, [x18, #4]
	.inst 0xc240165a // ldr c26, [x18, #5]
	.inst 0xc2401a5d // ldr c29, [x18, #6]
	.inst 0xc2401e5e // ldr c30, [x18, #7]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	ldr x18, =0x4000000
	msr SPSR_EL3, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30d5d99f
	msr SCTLR_EL1, x18
	ldr x18, =0x3c0000
	msr CPACR_EL1, x18
	ldr x18, =0x0
	msr S3_0_C1_C2_2, x18 // CCTLR_EL1
	ldr x18, =0x4
	msr S3_3_C1_C2_2, x18 // CCTLR_EL0
	ldr x18, =initial_DDC_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884132 // msr DDC_EL0, c18
	ldr x18, =0x80000000
	msr HCR_EL2, x18
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82601112 // ldr c18, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x8, #0xf
	and x18, x18, x8
	cmp x18, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400248 // ldr c8, [x18, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400648 // ldr c8, [x18, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400a48 // ldr c8, [x18, #2]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2400e48 // ldr c8, [x18, #3]
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc2401248 // ldr c8, [x18, #4]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc2401648 // ldr c8, [x18, #5]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2401a48 // ldr c8, [x18, #6]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2401e48 // ldr c8, [x18, #7]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x8, v0.d[0]
	cmp x18, x8
	b.ne comparison_fail
	ldr x18, =0x0
	mov x8, v0.d[1]
	cmp x18, x8
	b.ne comparison_fail
	/* Check system registers */
	ldr x18, =final_SP_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2984108 // mrs c8, CSP_EL0
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	ldr x18, =final_PCC_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a641 // chkeq c18, c8
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
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x000010e8
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
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf3
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xbf, 0x69, 0xdd, 0xc2, 0x3e, 0xc3, 0x45, 0x82, 0xbe, 0x03, 0x27, 0x78, 0x41, 0xa7, 0xdf, 0xc2
	.byte 0x0e, 0x9b, 0x91, 0xaa, 0x21, 0x7c, 0xdf, 0x08, 0x20, 0xd0, 0xee, 0xe2, 0xe1, 0x13, 0xc5, 0xc2
	.byte 0x19, 0xf4, 0x69, 0x29, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000404000c8
	/* C1 */
	.octa 0x8000000008070806000000000000100f
	/* C7 */
	.octa 0x7c
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C25 */
	.octa 0xfffffffffffffb40
	/* C26 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C29 */
	.octa 0xc0000000400100020000000000001004
	/* C30 */
	.octa 0xf3000000000002000000000400000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000404000c8
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x7c
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C25 */
	.octa 0x8df7c21
	/* C26 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C29 */
	.octa 0xe2eed020
	/* C30 */
	.octa 0x4
initial_DDC_EL0_value:
	.octa 0x4c00000070040f0000ffffffffffe000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
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
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
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
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x02000252 // add c18, c18, #0
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x02020252 // add c18, c18, #128
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x02040252 // add c18, c18, #256
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x02060252 // add c18, c18, #384
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x02080252 // add c18, c18, #512
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x020a0252 // add c18, c18, #640
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x020c0252 // add c18, c18, #768
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x020e0252 // add c18, c18, #896
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x02100252 // add c18, c18, #1024
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x02120252 // add c18, c18, #1152
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x02140252 // add c18, c18, #1280
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x02160252 // add c18, c18, #1408
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x02180252 // add c18, c18, #1536
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x021a0252 // add c18, c18, #1664
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
	.inst 0x021c0252 // add c18, c18, #1792
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600d12 // ldr x18, [c8, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d12 // str x18, [c8, #0]
	ldr x18, =0x40400028
	mrs x8, ELR_EL1
	sub x18, x18, x8
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b248 // cvtp c8, x18
	.inst 0xc2d24108 // scvalue c8, c8, x18
	.inst 0x82600112 // ldr c18, [c8, #0]
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
