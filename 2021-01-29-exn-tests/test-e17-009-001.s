.section text0, #alloc, #execinstr
test_start:
	.inst 0x783133bf // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:011 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25000 // RET-C-C 00000:00000 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 1016
	.inst 0x5ac01411 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:17 Rn:0 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xa25cdbd8 // LDTR-C.RIB-C Ct:24 Rn:30 10:10 imm9:111001101 0:0 opc:01 10100010:10100010
	.inst 0x78e44826 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:6 Rn:1 10:10 S:0 option:010 Rm:4 1:1 opc:11 111000:111000 size:01
	.inst 0xc2daa7a1 // CHKEQ-_.CC-C 00001:00001 Cn:29 001:001 opc:01 1:1 Cm:26 11000010110:11000010110
	.inst 0xd4000001
	.zero 7148
	.inst 0x3821303f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c132c0 // GCFLGS-R.C-C Rd:0 Cn:22 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xf927497f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:11 imm12:100111010010 opc:00 111001:111001 size:11
	.zero 57332
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a64 // ldr c4, [x19, #2]
	.inst 0xc2400e6b // ldr c11, [x19, #3]
	.inst 0xc2401271 // ldr c17, [x19, #4]
	.inst 0xc240167a // ldr c26, [x19, #5]
	.inst 0xc2401a7d // ldr c29, [x19, #6]
	.inst 0xc2401e7e // ldr c30, [x19, #7]
	/* Set up flags and system registers */
	ldr x19, =0x0
	msr SPSR_EL3, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x0
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =initial_DDC_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4133 // msr DDC_EL1, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601373 // ldr c19, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x27, #0xf
	and x19, x19, x27
	cmp x19, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240027b // ldr c27, [x19, #0]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240067b // ldr c27, [x19, #1]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc2400a7b // ldr c27, [x19, #2]
	.inst 0xc2dba4c1 // chkeq c6, c27
	b.ne comparison_fail
	.inst 0xc2400e7b // ldr c27, [x19, #3]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc240127b // ldr c27, [x19, #4]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc240167b // ldr c27, [x19, #5]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc2401a7b // ldr c27, [x19, #6]
	.inst 0xc2dba741 // chkeq c26, c27
	b.ne comparison_fail
	.inst 0xc2401e7b // ldr c27, [x19, #7]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240227b // ldr c27, [x19, #8]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x19, 0x83
	orr x27, x27, x19
	ldr x19, =0x920000eb
	cmp x19, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001032
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
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
	ldr x0, =0x40402000
	ldr x1, =check_data5
	ldr x2, =0x4040200c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.zero 4064
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x04, 0x00, 0x00
	.zero 16
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x40
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x04, 0x00, 0x00
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
	.octa 0x20008000e00cf00c0000000040402001
	/* C1 */
	.octa 0xc0000000200500050000000000001000
	/* C4 */
	.octa 0xfe4
	/* C11 */
	.octa 0x80000000000000
	/* C17 */
	.octa 0x4000
	/* C26 */
	.octa 0x1030
	/* C29 */
	.octa 0x1030
	/* C30 */
	.octa 0x2310
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xc0000000200500050000000000001000
	/* C4 */
	.octa 0xfe4
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x80000000000000
	/* C17 */
	.octa 0x1f
	/* C24 */
	.octa 0x420000000000000000000000000
	/* C26 */
	.octa 0x1030
	/* C29 */
	.octa 0x1030
	/* C30 */
	.octa 0x2310
initial_DDC_EL0_value:
	.octa 0xc0000000520204b400ffffffffffe000
initial_DDC_EL1_value:
	.octa 0x90000000400410040000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080006000001d0000000040400000
final_PCC_value:
	.octa 0x200080006000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440400000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
