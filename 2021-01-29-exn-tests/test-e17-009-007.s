.section text0, #alloc, #execinstr
test_start:
	.inst 0x783133bf // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:011 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25000 // RET-C-C 00000:00000 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 5112
	.inst 0x5ac01411 // 0x5ac01411
	.inst 0xa25cdbd8 // 0xa25cdbd8
	.inst 0x78e44826 // 0x78e44826
	.inst 0xc2daa7a1 // 0xc2daa7a1
	.inst 0xd4000001
	.zero 27624
	.inst 0x3821303f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c132c0 // GCFLGS-R.C-C Rd:0 Cn:22 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xf927497f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:11 imm12:100111010010 opc:00 111001:111001 size:11
	.zero 32760
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
	.inst 0xc2400a04 // ldr c4, [x16, #2]
	.inst 0xc2400e0b // ldr c11, [x16, #3]
	.inst 0xc2401211 // ldr c17, [x16, #4]
	.inst 0xc240161a // ldr c26, [x16, #5]
	.inst 0xc2401a1d // ldr c29, [x16, #6]
	.inst 0xc2401e1e // ldr c30, [x16, #7]
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =initial_DDC_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4130 // msr DDC_EL1, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601250 // ldr c16, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x18, #0xf
	and x16, x16, x18
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400212 // ldr c18, [x16, #0]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400612 // ldr c18, [x16, #1]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc2400a12 // ldr c18, [x16, #2]
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	.inst 0xc2400e12 // ldr c18, [x16, #3]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc2401212 // ldr c18, [x16, #4]
	.inst 0xc2d2a621 // chkeq c17, c18
	b.ne comparison_fail
	.inst 0xc2401612 // ldr c18, [x16, #5]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc2401a12 // ldr c18, [x16, #6]
	.inst 0xc2d2a741 // chkeq c26, c18
	b.ne comparison_fail
	.inst 0xc2401e12 // ldr c18, [x16, #7]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2402212 // ldr c18, [x16, #8]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a601 // chkeq c16, c18
	b.ne comparison_fail
	ldr x18, =esr_el1_dump_address
	ldr x18, [x18]
	mov x16, 0x83
	orr x18, x18, x16
	ldr x16, =0x920000eb
	cmp x16, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001410
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001700
	ldr x1, =check_data2
	ldr x2, =0x00001702
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40401400
	ldr x1, =check_data4
	ldr x2, =0x40401414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40407ffc
	ldr x1, =check_data5
	ldr x2, =0x40408008
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.byte 0x7c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x7c, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xbf, 0x33, 0x31, 0x78, 0x00, 0x50, 0xc2, 0xc2
.data
check_data4:
	.byte 0x11, 0x14, 0xc0, 0x5a, 0xd8, 0xdb, 0x5c, 0xa2, 0x26, 0x48, 0xe4, 0x78, 0xa1, 0xa7, 0xda, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0x3f, 0x30, 0x21, 0x38, 0xc0, 0x32, 0xc1, 0xc2, 0x7f, 0x49, 0x27, 0xf9

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000a007200f0000000040407ffd
	/* C1 */
	.octa 0xc0000000000100050000000000001000
	/* C4 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C26 */
	.octa 0xffffffffffffffffffffffffffffe8ff
	/* C29 */
	.octa 0x1700
	/* C30 */
	.octa 0x1730
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xc0000000000100050000000000001000
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x7c
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0x1f
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0xffffffffffffffffffffffffffffe8ff
	/* C29 */
	.octa 0x1700
	/* C30 */
	.octa 0x1730
initial_DDC_EL0_value:
	.octa 0xc0000000000700050000000000000001
initial_DDC_EL1_value:
	.octa 0x90000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040401000
final_PCC_value:
	.octa 0x200080004000041d0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000500050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001400
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600e50 // ldr x16, [c18, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e50 // str x16, [c18, #0]
	ldr x16, =0x40401414
	mrs x18, ELR_EL1
	sub x16, x16, x18
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b212 // cvtp c18, x16
	.inst 0xc2d04252 // scvalue c18, c18, x16
	.inst 0x82600250 // ldr c16, [c18, #0]
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
