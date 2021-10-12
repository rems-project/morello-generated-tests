.section text0, #alloc, #execinstr
test_start:
	.inst 0x7d77e7ab // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:11 Rn:29 imm12:110111111001 opc:01 111101:111101 size:01
	.inst 0xd5033d5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1101 11010101000000110011:11010101000000110011
	.inst 0x081fffc1 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:30 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0xe2c70da6 // ALDUR-C.RI-C Ct:6 Rn:13 op2:11 imm9:001110000 V:0 op1:11 11100010:11100010
	.inst 0x425fff7f // LDAR-C.R-C Ct:31 Rn:27 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c250a2 // 0xc2c250a2
	.zero 8172
	.inst 0xc2c1a4c1 // 0xc2c1a4c1
	.inst 0xe2eaf2be // 0xe2eaf2be
	.inst 0x7861403f // 0x7861403f
	.inst 0xd4000001
	.zero 57324
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
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400625 // ldr c5, [x17, #1]
	.inst 0xc2400a2d // ldr c13, [x17, #2]
	.inst 0xc2400e35 // ldr c21, [x17, #3]
	.inst 0xc240123b // ldr c27, [x17, #4]
	.inst 0xc240163d // ldr c29, [x17, #5]
	.inst 0xc2401a3e // ldr c30, [x17, #6]
	/* Vector registers */
	mrs x17, cptr_el3
	bfc x17, #10, #1
	msr cptr_el3, x17
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x17, =0x0
	msr SPSR_EL3, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30d5d99f
	msr SCTLR_EL1, x17
	ldr x17, =0x3c0000
	msr CPACR_EL1, x17
	ldr x17, =0x0
	msr S3_0_C1_C2_2, x17 // CCTLR_EL1
	ldr x17, =0x4
	msr S3_3_C1_C2_2, x17 // CCTLR_EL0
	ldr x17, =initial_DDC_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884131 // msr DDC_EL0, c17
	ldr x17, =0x80000000
	msr HCR_EL2, x17
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82601271 // ldr c17, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
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
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x19, #0xf
	and x17, x17, x19
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400233 // ldr c19, [x17, #0]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400633 // ldr c19, [x17, #1]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc2400a33 // ldr c19, [x17, #2]
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	.inst 0xc2400e33 // ldr c19, [x17, #3]
	.inst 0xc2d3a5a1 // chkeq c13, c19
	b.ne comparison_fail
	.inst 0xc2401233 // ldr c19, [x17, #4]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc2401633 // ldr c19, [x17, #5]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc2401a33 // ldr c19, [x17, #6]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2401e33 // ldr c19, [x17, #7]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x17, =0x0
	mov x19, v11.d[0]
	cmp x17, x19
	b.ne comparison_fail
	ldr x17, =0x0
	mov x19, v11.d[1]
	cmp x17, x19
	b.ne comparison_fail
	ldr x17, =0x0
	mov x19, v30.d[0]
	cmp x17, x19
	b.ne comparison_fail
	ldr x17, =0x0
	mov x19, v30.d[1]
	cmp x17, x19
	b.ne comparison_fail
	/* Check system registers */
	ldr x17, =final_PCC_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984033 // mrs c19, CELR_EL1
	.inst 0xc2d3a621 // chkeq c17, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001070
	ldr x1, =check_data0
	ldr x2, =0x00001080
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
	ldr x0, =0x000010f4
	ldr x1, =check_data2
	ldr x2, =0x000010f6
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
	ldr x0, =0x00001ffa
	ldr x1, =check_data4
	ldr x2, =0x00001ffc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffe
	ldr x1, =check_data5
	ldr x2, =0x00001fff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400018
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40402004
	ldr x1, =check_data7
	ldr x2, =0x40402014
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.zero 240
	.byte 0x00, 0x00, 0x00, 0x00, 0x55, 0x9f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3840
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xf4, 0x10
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xab, 0xe7, 0x77, 0x7d, 0x5f, 0x3d, 0x03, 0xd5, 0xc1, 0xff, 0x1f, 0x08, 0xa6, 0x0d, 0xc7, 0xe2
	.byte 0x7f, 0xff, 0x5f, 0x42, 0xa2, 0x50, 0xc2, 0xc2
.data
check_data7:
	.byte 0xc1, 0xa4, 0xc1, 0xc2, 0xbe, 0xf2, 0xea, 0xe2, 0x3f, 0x40, 0x61, 0x78, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc00000000001000500000000000010f4
	/* C5 */
	.octa 0x20008000700120010000000040402005
	/* C13 */
	.octa 0x90000000000100050000000000001000
	/* C21 */
	.octa 0x1001
	/* C27 */
	.octa 0x1fe0
	/* C29 */
	.octa 0x408
	/* C30 */
	.octa 0x1ffe
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xc00000000001000500000000000010f4
	/* C5 */
	.octa 0x20008000700120010000000040402005
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x90000000000100050000000000001000
	/* C21 */
	.octa 0x1001
	/* C27 */
	.octa 0x1fe0
	/* C29 */
	.octa 0x408
	/* C30 */
	.octa 0x1ffe
initial_DDC_EL0_value:
	.octa 0xc00000002000000000801ffe0efb9001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000700120010000000040402014
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300060000000040400000
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
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
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
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x02000231 // add c17, c17, #0
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x02020231 // add c17, c17, #128
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x02040231 // add c17, c17, #256
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x02060231 // add c17, c17, #384
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x02080231 // add c17, c17, #512
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x020a0231 // add c17, c17, #640
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x020c0231 // add c17, c17, #768
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x020e0231 // add c17, c17, #896
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x02100231 // add c17, c17, #1024
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x02120231 // add c17, c17, #1152
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x02140231 // add c17, c17, #1280
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x02160231 // add c17, c17, #1408
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x02180231 // add c17, c17, #1536
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x021a0231 // add c17, c17, #1664
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
	.inst 0x021c0231 // add c17, c17, #1792
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600e71 // ldr x17, [c19, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e71 // str x17, [c19, #0]
	ldr x17, =0x40402014
	mrs x19, ELR_EL1
	sub x17, x17, x19
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b233 // cvtp c19, x17
	.inst 0xc2d14273 // scvalue c19, c19, x17
	.inst 0x82600271 // ldr c17, [c19, #0]
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
