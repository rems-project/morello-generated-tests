.section text0, #alloc, #execinstr
test_start:
	.inst 0xb88584ff // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:7 01:01 imm9:001011000 0:0 opc:10 111000:111000 size:10
	.inst 0x5a97e061 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:3 o2:0 0:0 cond:1110 Rm:23 011010100:011010100 op:1 sf:0
	.inst 0xb35c099d // bfm:aarch64/instrs/integer/bitfield Rd:29 Rn:12 imms:000010 immr:011100 N:1 100110:100110 opc:01 sf:1
	.inst 0xc2c25183 // RETR-C-C 00011:00011 Cn:12 100:100 opc:10 11000010110000100:11000010110000100
	.zero 1008
	.inst 0xc2c1c01e // CVT-R.CC-C Rd:30 Cn:0 110000:110000 Cm:1 11000010110:11000010110
	.inst 0x225f7c24 // LDXR-C.R-C Ct:4 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xa215c3ef // STUR-C.RI-C Ct:15 Rn:31 00:00 imm9:101011100 0:0 opc:00 10100010:10100010
	.inst 0xc2f5981d // SUBS-R.CC-C Rd:29 Cn:0 100110:100110 Cm:21 11000010111:11000010111
	.inst 0xd4000001
	.zero 35820
	.inst 0x785af55e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:10 01:01 imm9:110101111 0:0 opc:01 111000:111000 size:01
	.zero 28668
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
	.inst 0xc2400563 // ldr c3, [x11, #1]
	.inst 0xc2400967 // ldr c7, [x11, #2]
	.inst 0xc2400d6a // ldr c10, [x11, #3]
	.inst 0xc240116c // ldr c12, [x11, #4]
	.inst 0xc240156f // ldr c15, [x11, #5]
	.inst 0xc2401975 // ldr c21, [x11, #6]
	/* Set up flags and system registers */
	ldr x11, =0x0
	msr SPSR_EL3, x11
	ldr x11, =initial_SP_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c410b // msr CSP_EL1, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0xc0000
	msr CPACR_EL1, x11
	ldr x11, =0x4
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
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260138b // ldr c11, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x28, #0xf
	and x11, x11, x28
	cmp x11, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240017c // ldr c28, [x11, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240057c // ldr c28, [x11, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240097c // ldr c28, [x11, #2]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc2400d7c // ldr c28, [x11, #3]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc240117c // ldr c28, [x11, #4]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc240157c // ldr c28, [x11, #5]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc240197c // ldr c28, [x11, #6]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc2401d7c // ldr c28, [x11, #7]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc240217c // ldr c28, [x11, #8]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc240257c // ldr c28, [x11, #9]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc240297c // ldr c28, [x11, #10]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_SP_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc29c411c // mrs c28, CSP_EL1
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc298403c // mrs c28, CELR_EL1
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	ldr x11, =esr_el1_dump_address
	ldr x11, [x11]
	mov x28, 0xc1
	orr x11, x11, x28
	ldr x28, =0x920000eb
	cmp x28, x11
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
	ldr x0, =0x00001410
	ldr x1, =check_data1
	ldr x2, =0x00001420
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f80
	ldr x1, =check_data2
	ldr x2, =0x00001f90
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400010
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
	ldr x0, =0x40409000
	ldr x1, =check_data5
	ldr x2, =0x40409004
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
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x08, 0x02
.data
check_data3:
	.byte 0xff, 0x84, 0x85, 0xb8, 0x61, 0xe0, 0x97, 0x5a, 0x9d, 0x09, 0x5c, 0xb3, 0x83, 0x51, 0xc2, 0xc2
.data
check_data4:
	.byte 0x1e, 0xc0, 0xc1, 0xc2, 0x24, 0x7c, 0x5f, 0x22, 0xef, 0xc3, 0x15, 0xa2, 0x1d, 0x98, 0xf5, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0x5e, 0xf5, 0x5a, 0x78

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x140c
	/* C7 */
	.octa 0x1000
	/* C10 */
	.octa 0x80000000000004
	/* C12 */
	.octa 0x20008000b00720150000000040409000
	/* C15 */
	.octa 0x2084000000000000000800000000000
	/* C21 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x140c
	/* C3 */
	.octa 0x140c
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x1058
	/* C10 */
	.octa 0x80000000000004
	/* C12 */
	.octa 0x20008000b00720150000000040409000
	/* C15 */
	.octa 0x2084000000000000000800000000000
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x2020
initial_DDC_EL0_value:
	.octa 0x800000006002000000ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xc81000004002000400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000001e0000000040400000
final_SP_EL1_value:
	.octa 0x2020
final_PCC_value:
	.octa 0x200080004000001e0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000126c0010000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001f80
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001410
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
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x82600f8b // ldr x11, [c28, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f8b // str x11, [c28, #0]
	ldr x11, =0x40400414
	mrs x28, ELR_EL1
	sub x11, x11, x28
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b17c // cvtp c28, x11
	.inst 0xc2cb439c // scvalue c28, c28, x11
	.inst 0x8260038b // ldr c11, [c28, #0]
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
