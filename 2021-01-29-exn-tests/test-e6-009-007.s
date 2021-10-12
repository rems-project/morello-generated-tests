.section text0, #alloc, #execinstr
test_start:
	.inst 0x7d77e7ab // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:11 Rn:29 imm12:110111111001 opc:01 111101:111101 size:01
	.inst 0xd5033d5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1101 11010101000000110011:11010101000000110011
	.inst 0x081fffc1 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:30 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0xe2c70da6 // ALDUR-C.RI-C Ct:6 Rn:13 op2:11 imm9:001110000 V:0 op1:11 11100010:11100010
	.inst 0x425fff7f // LDAR-C.R-C Ct:31 Rn:27 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c250a2 // 0xc2c250a2
	.zero 8236
	.inst 0xc2c1a4c1 // 0xc2c1a4c1
	.inst 0xe2eaf2be // 0xe2eaf2be
	.inst 0x7861403f // 0x7861403f
	.inst 0xd4000001
	.zero 57260
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c5 // ldr c5, [x14, #1]
	.inst 0xc24009cd // ldr c13, [x14, #2]
	.inst 0xc2400dd5 // ldr c21, [x14, #3]
	.inst 0xc24011db // ldr c27, [x14, #4]
	.inst 0xc24015dd // ldr c29, [x14, #5]
	.inst 0xc24019de // ldr c30, [x14, #6]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q30, =0x8080800000000000
	/* Set up flags and system registers */
	ldr x14, =0x0
	msr SPSR_EL3, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0x3c0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x4
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011ee // ldr c14, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x15, #0xf
	and x14, x14, x15
	cmp x14, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001cf // ldr c15, [x14, #0]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24005cf // ldr c15, [x14, #1]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc24009cf // ldr c15, [x14, #2]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc2400dcf // ldr c15, [x14, #3]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc24011cf // ldr c15, [x14, #4]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc24015cf // ldr c15, [x14, #5]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc24019cf // ldr c15, [x14, #6]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2401dcf // ldr c15, [x14, #7]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x15, v11.d[0]
	cmp x14, x15
	b.ne comparison_fail
	ldr x14, =0x0
	mov x15, v11.d[1]
	cmp x14, x15
	b.ne comparison_fail
	ldr x14, =0x8080800000000000
	mov x15, v30.d[0]
	cmp x14, x15
	b.ne comparison_fail
	ldr x14, =0x0
	mov x15, v30.d[1]
	cmp x14, x15
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa5c1 // chkeq c14, c15
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
	ldr x0, =0x000010b0
	ldr x1, =check_data1
	ldr x2, =0x000010b8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bf2
	ldr x1, =check_data2
	ldr x2, =0x00001bf4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffc
	ldr x1, =check_data4
	ldr x2, =0x00001ffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40402044
	ldr x1, =check_data6
	ldr x2, =0x40402054
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
	.byte 0xfc, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf9, 0x3f, 0x00, 0x00
.data
check_data0:
	.byte 0xfc, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x80, 0x80
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xf9, 0x3f
.data
check_data5:
	.byte 0xab, 0xe7, 0x77, 0x7d, 0x5f, 0x3d, 0x03, 0xd5, 0xc1, 0xff, 0x1f, 0x08, 0xa6, 0x0d, 0xc7, 0xe2
	.byte 0x7f, 0xff, 0x5f, 0x42, 0xa2, 0x50, 0xc2, 0xc2
.data
check_data6:
	.byte 0xc1, 0xa4, 0xc1, 0xc2, 0xbe, 0xf2, 0xea, 0xe2, 0x3f, 0x40, 0x61, 0x78, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1ffc
	/* C5 */
	.octa 0x20008000800080000000000040402044
	/* C13 */
	.octa 0x90000000000100050000000000000f90
	/* C21 */
	.octa 0x400000002007001f0000000000001001
	/* C27 */
	.octa 0x1fe0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1ffd
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1ffc
	/* C5 */
	.octa 0x20008000800080000000000040402044
	/* C6 */
	.octa 0x1ffc
	/* C13 */
	.octa 0x90000000000100050000000000000f90
	/* C21 */
	.octa 0x400000002007001f0000000000001001
	/* C27 */
	.octa 0x1fe0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1ffd
initial_DDC_EL0_value:
	.octa 0xc0000000000700070000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000080000000000040402054
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x82600dee // ldr x14, [c15, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400dee // str x14, [c15, #0]
	ldr x14, =0x40402054
	mrs x15, ELR_EL1
	sub x14, x14, x15
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1cf // cvtp c15, x14
	.inst 0xc2ce41ef // scvalue c15, c15, x14
	.inst 0x826001ee // ldr c14, [c15, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
