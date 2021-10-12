.section text0, #alloc, #execinstr
test_start:
	.inst 0x783133bf // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:011 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25000 // RET-C-C 00000:00000 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 1016
	.inst 0x5ac01411 // 0x5ac01411
	.inst 0xa25cdbd8 // 0xa25cdbd8
	.inst 0x78e44826 // 0x78e44826
	.inst 0xc2daa7a1 // 0xc2daa7a1
	.inst 0xd4000001
	.zero 32240
	.inst 0x3821303f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c132c0 // GCFLGS-R.C-C Rd:0 Cn:22 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xf927497f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:11 imm12:100111010010 opc:00 111001:111001 size:11
	.zero 32240
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400944 // ldr c4, [x10, #2]
	.inst 0xc2400d4b // ldr c11, [x10, #3]
	.inst 0xc2401151 // ldr c17, [x10, #4]
	.inst 0xc240155a // ldr c26, [x10, #5]
	.inst 0xc240195d // ldr c29, [x10, #6]
	.inst 0xc2401d5e // ldr c30, [x10, #7]
	/* Set up flags and system registers */
	ldr x10, =0x0
	msr SPSR_EL3, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0xc0000
	msr CPACR_EL1, x10
	ldr x10, =0x0
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x0
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =initial_DDC_EL1_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc28c412a // msr DDC_EL1, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011aa // ldr c10, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc28e402a // msr CELR_EL3, c10
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x13, #0xf
	and x10, x10, x13
	cmp x10, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240014d // ldr c13, [x10, #0]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240054d // ldr c13, [x10, #1]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc240094d // ldr c13, [x10, #2]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc2400d4d // ldr c13, [x10, #3]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240114d // ldr c13, [x10, #4]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc240154d // ldr c13, [x10, #5]
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	.inst 0xc240194d // ldr c13, [x10, #6]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc2401d4d // ldr c13, [x10, #7]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240214d // ldr c13, [x10, #8]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	ldr x13, =esr_el1_dump_address
	ldr x13, [x13]
	mov x10, 0x83
	orr x13, x13, x10
	ldr x10, =0x920000e3
	cmp x10, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010d0
	ldr x1, =check_data0
	ldr x2, =0x000010e0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001801
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001920
	ldr x1, =check_data2
	ldr x2, =0x00001922
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
	ldr x0, =0x40408204
	ldr x1, =check_data5
	ldr x2, =0x40408210
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040ffe4
	ldr x1, =check_data6
	ldr x2, =0x4040ffe6
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
	.zero 1
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
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000c40180050000000040408205
	/* C1 */
	.octa 0xc0000000000300070000000000001800
	/* C4 */
	.octa 0x4040e7e4
	/* C11 */
	.octa 0x4000000000170007007fffffffffe181
	/* C17 */
	.octa 0x0
	/* C26 */
	.octa 0x1920
	/* C29 */
	.octa 0x1920
	/* C30 */
	.octa 0x1400
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xc0000000000300070000000000001800
	/* C4 */
	.octa 0x4040e7e4
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x4000000000170007007fffffffffe181
	/* C17 */
	.octa 0x1f
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x1920
	/* C29 */
	.octa 0x1920
	/* C30 */
	.octa 0x1400
initial_DDC_EL0_value:
	.octa 0xc00000004001000200ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x90100000200100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400000
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800001bf82030000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x82600daa // ldr x10, [c13, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400daa // str x10, [c13, #0]
	ldr x10, =0x40400414
	mrs x13, ELR_EL1
	sub x10, x10, x13
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b14d // cvtp c13, x10
	.inst 0xc2ca41ad // scvalue c13, c13, x10
	.inst 0x826001aa // ldr c10, [c13, #0]
	.inst 0x021e014a // add c10, c10, #1920
	.inst 0xc2c21140 // br c10

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
