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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a12 // ldr c18, [x16, #2]
	.inst 0xc2400e16 // ldr c22, [x16, #3]
	.inst 0xc240121d // ldr c29, [x16, #4]
	.inst 0xc240161e // ldr c30, [x16, #5]
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =initial_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884110 // msr CSP_EL0, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x3c0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601170 // ldr c16, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240020b // ldr c11, [x16, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240060b // ldr c11, [x16, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400a0b // ldr c11, [x16, #2]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc2400e0b // ldr c11, [x16, #3]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc240120b // ldr c11, [x16, #4]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc240160b // ldr c11, [x16, #5]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc2401a0b // ldr c11, [x16, #6]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc2401e0b // ldr c11, [x16, #7]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc298410b // mrs c11, CSP_EL0
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x11, 0x80
	orr x16, x16, x11
	ldr x11, =0x920000e1
	cmp x11, x16
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.zero 1
.data
check_data3:
	.byte 0xff, 0xeb, 0x61, 0xb8, 0x7f, 0x82, 0x3c, 0x9b, 0xdf, 0xfe, 0x1f, 0x42, 0x0c, 0x40, 0xdf, 0xc2
	.byte 0x48, 0x3a, 0x25, 0xe2
.data
check_data4:
	.byte 0x06, 0xb0, 0xc6, 0xc2, 0xdb, 0x6f, 0xa5, 0x02, 0xbf, 0xff, 0x9f, 0x08, 0xbe, 0x54, 0x6e, 0x51
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x7200500800002b7008000
	/* C1 */
	.octa 0xeb00000000001000
	/* C18 */
	.octa 0x7f7fffffffffffb0
	/* C22 */
	.octa 0x40000000000200030000000000001100
	/* C29 */
	.octa 0x40000000000700870000000000001ffe
	/* C30 */
	.octa 0xc00620009c00000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x7200500800002b7008000
	/* C1 */
	.octa 0xeb00000000001000
	/* C6 */
	.octa 0x7200500800002b7008000
	/* C12 */
	.octa 0x720050000000000000000
	/* C18 */
	.octa 0x7f7fffffffffffb0
	/* C22 */
	.octa 0x40000000000200030000000000001100
	/* C27 */
	.octa 0xc00620009bfffffffffff6a5
	/* C29 */
	.octa 0x40000000000700870000000000001ffe
initial_SP_EL0_value:
	.octa 0x80000000500400041500000000000000
initial_DDC_EL0_value:
	.octa 0x400000000001000f00bffffdffffe001
initial_VBAR_EL1_value:
	.octa 0x200080005000f41d0000000040400001
final_SP_EL0_value:
	.octa 0x80000000500400041500000000000000
final_PCC_value:
	.octa 0x200080005000f41d0000000040400414
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
	.dword 0x0000000000001100
	.dword 0x0000000000001ff0
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600d70 // ldr x16, [c11, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d70 // str x16, [c11, #0]
	ldr x16, =0x40400414
	mrs x11, ELR_EL1
	sub x16, x16, x11
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20b // cvtp c11, x16
	.inst 0xc2d0416b // scvalue c11, c11, x16
	.inst 0x82600170 // ldr c16, [c11, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
