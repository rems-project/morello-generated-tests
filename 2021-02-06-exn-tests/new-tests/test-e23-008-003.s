.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ac12d91 // rorv:aarch64/instrs/integer/shift/variable Rd:17 Rn:12 op2:11 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0x383713ff // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:001 o3:0 Rs:23 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc254f41f // LDR-C.RIB-C Ct:31 Rn:0 imm12:010100111101 L:1 110000100:110000100
	.inst 0xbc4a4c21 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:1 Rn:1 11:11 imm9:010100100 0:0 opc:01 111100:111100 size:10
	.inst 0x085ffebe // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:30 Rn:21 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.zero 9196
	.inst 0x38ce1dfe // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:15 11:11 imm9:011100001 0:0 opc:11 111000:111000 size:00
	.inst 0xd361c5e6 // ubfm:aarch64/instrs/integer/bitfield Rd:6 Rn:15 imms:110001 immr:100001 N:1 100110:100110 opc:10 sf:1
	.inst 0xf9a7c341 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:26 imm12:100111110000 opc:10 111001:111001 size:11
	.inst 0xa84d67a0 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:0 Rn:29 Rt2:11001 imm7:0011010 L:1 1010000:1010000 opc:10
	.inst 0xd4000001
	.zero 56300
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc240084f // ldr c15, [x2, #2]
	.inst 0xc2400c55 // ldr c21, [x2, #3]
	.inst 0xc2401057 // ldr c23, [x2, #4]
	.inst 0xc240145d // ldr c29, [x2, #5]
	/* Set up flags and system registers */
	ldr x2, =0x4000000
	msr SPSR_EL3, x2
	ldr x2, =initial_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884102 // msr CSP_EL0, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0x3c0000
	msr CPACR_EL1, x2
	ldr x2, =0x0
	msr S3_0_C1_C2_2, x2 // CCTLR_EL1
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011c2 // ldr c2, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e4022 // msr CELR_EL3, c2
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc240004e // ldr c14, [x2, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240044e // ldr c14, [x2, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240084e // ldr c14, [x2, #2]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc2400c4e // ldr c14, [x2, #3]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc240104e // ldr c14, [x2, #4]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc240144e // ldr c14, [x2, #5]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc240184e // ldr c14, [x2, #6]
	.inst 0xc2cea721 // chkeq c25, c14
	b.ne comparison_fail
	.inst 0xc2401c4e // ldr c14, [x2, #7]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc240204e // ldr c14, [x2, #8]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x2, =0x0
	mov x14, v1.d[0]
	cmp x2, x14
	b.ne comparison_fail
	ldr x2, =0x0
	mov x14, v1.d[1]
	cmp x2, x14
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc298410e // mrs c14, CSP_EL0
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	ldr x2, =esr_el1_dump_address
	ldr x2, [x2]
	mov x14, 0x80
	orr x2, x2, x14
	ldr x14, =0x920000ab
	cmp x14, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001810
	ldr x1, =check_data0
	ldr x2, =0x00001811
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001cd8
	ldr x1, =check_data1
	ldr x2, =0x00001ce8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fb8
	ldr x1, =check_data2
	ldr x2, =0x00001fbc
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
	ldr x0, =0x40402400
	ldr x1, =check_data4
	ldr x2, =0x40402414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40407ae0
	ldr x1, =check_data5
	ldr x2, =0x40407af0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040a07d
	ldr x1, =check_data6
	ldr x2, =0x4040a07e
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
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
	.zero 2064
	.byte 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2016
.data
check_data0:
	.byte 0xfe
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x91, 0x2d, 0xc1, 0x9a, 0xff, 0x13, 0x37, 0x38, 0x1f, 0xf4, 0x54, 0xc2, 0x21, 0x4c, 0x4a, 0xbc
	.byte 0xbe, 0xfe, 0x5f, 0x08
.data
check_data4:
	.byte 0xfe, 0x1d, 0xce, 0x38, 0xe6, 0xc5, 0x61, 0xd3, 0x41, 0xc3, 0xa7, 0xf9, 0xa0, 0x67, 0x4d, 0xa8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000c0000000000040402710
	/* C1 */
	.octa 0x80000000000180050000000000001f14
	/* C15 */
	.octa 0x800000004001a0020000000040409f9c
	/* C21 */
	.octa 0x80000000000000
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000100050000000000001c08
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000000180050000000000001fb8
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x800000004001a002000000004040a07d
	/* C21 */
	.octa 0x80000000000000
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000100050000000000001c08
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000000100050000000000001810
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040402001
final_SP_EL0_value:
	.octa 0xc0000000000100050000000000001810
final_PCC_value:
	.octa 0x200080004000041d0000000040402414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword initial_SP_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001810
	.dword 0x0000000040407ae0
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
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x82600dc2 // ldr x2, [c14, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400dc2 // str x2, [c14, #0]
	ldr x2, =0x40402414
	mrs x14, ELR_EL1
	sub x2, x2, x14
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b04e // cvtp c14, x2
	.inst 0xc2c241ce // scvalue c14, c14, x2
	.inst 0x826001c2 // ldr c2, [c14, #0]
	.inst 0x021e0042 // add c2, c2, #1920
	.inst 0xc2c21040 // br c2

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
