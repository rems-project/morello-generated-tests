.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c14bbd // UNSEAL-C.CC-C Cd:29 Cn:29 0010:0010 opc:01 Cm:1 11000010110:11000010110
	.inst 0x54f6f74d // b_cond:aarch64/instrs/branch/conditional/cond cond:1101 0:0 imm19:1111011011110111010 01010100:01010100
	.inst 0x2dcd6c06 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:6 Rn:0 Rt2:11011 imm7:0011010 L:1 1011011:1011011 opc:00
	.inst 0x0242601e // ADD-C.CIS-C Cd:30 Cn:0 imm12:000010011000 sh:1 A:0 00000010:00000010
	.inst 0xc2c4103b // LDPBR-C.C-C Ct:27 Cn:1 100:100 opc:00 11000010110001000:11000010110001000
	.zero 1004
	.inst 0x3c96ffe2 // 0x3c96ffe2
	.inst 0x384b9366 // 0x384b9366
	.inst 0x3862425f // 0x3862425f
	.inst 0x9b287c36 // 0x9b287c36
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
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e12 // ldr c18, [x16, #3]
	.inst 0xc240121b // ldr c27, [x16, #4]
	.inst 0xc240161d // ldr c29, [x16, #5]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =initial_SP_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4110 // msr CSP_EL1, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x3c0000
	msr CPACR_EL1, x16
	ldr x16, =0x4
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
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010b0 // ldr c16, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	mov x5, #0xd
	and x16, x16, x5
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400205 // ldr c5, [x16, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400605 // ldr c5, [x16, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a05 // ldr c5, [x16, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400e05 // ldr c5, [x16, #3]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2401205 // ldr c5, [x16, #4]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2401605 // ldr c5, [x16, #5]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc2401a05 // ldr c5, [x16, #6]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2401e05 // ldr c5, [x16, #7]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x5, v2.d[0]
	cmp x16, x5
	b.ne comparison_fail
	ldr x16, =0x0
	mov x5, v2.d[1]
	cmp x16, x5
	b.ne comparison_fail
	ldr x16, =0x0
	mov x5, v6.d[0]
	cmp x16, x5
	b.ne comparison_fail
	ldr x16, =0x0
	mov x5, v6.d[1]
	cmp x16, x5
	b.ne comparison_fail
	ldr x16, =0x0
	mov x5, v27.d[0]
	cmp x16, x5
	b.ne comparison_fail
	ldr x16, =0x0
	mov x5, v27.d[1]
	cmp x16, x5
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc29c4105 // mrs c5, CSP_EL1
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x16, 0x83
	orr x5, x5, x16
	ldr x16, =0x920000a3
	cmp x16, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ad4
	ldr x1, =check_data0
	ldr x2, =0x00001ad5
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001c08
	ldr x1, =check_data1
	ldr x2, =0x00001c09
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f70
	ldr x1, =check_data2
	ldr x2, =0x00001f80
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
	ldr x0, =0x4040006c
	ldr x1, =check_data4
	ldr x2, =0x40400074
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
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
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xbd, 0x4b, 0xc1, 0xc2, 0x4d, 0xf7, 0xf6, 0x54, 0x06, 0x6c, 0xcd, 0x2d, 0x1e, 0x60, 0x42, 0x02
	.byte 0x3b, 0x10, 0xc4, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xe2, 0xff, 0x96, 0x3c, 0x66, 0x93, 0x4b, 0x38, 0x5f, 0x42, 0x62, 0x38, 0x36, 0x7c, 0x28, 0x9b
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40400004
	/* C1 */
	.octa 0x810040004004000c0000000000001fa9
	/* C2 */
	.octa 0x0
	/* C18 */
	.octa 0x1c07
	/* C27 */
	.octa 0x1a1a
	/* C29 */
	.octa 0xfd4800000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x4040006c
	/* C1 */
	.octa 0x810040004004000c0000000000001fa9
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C18 */
	.octa 0x1c07
	/* C27 */
	.octa 0x1a1a
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x4049806c
initial_SP_EL1_value:
	.octa 0x2000
initial_DDC_EL0_value:
	.octa 0x800000004084002200000000403fe001
initial_DDC_EL1_value:
	.octa 0xc00000005f80000100ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x20008000400004000000000040400000
final_SP_EL1_value:
	.octa 0x1f6f
final_PCC_value:
	.octa 0x20008000400004000000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000402400000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
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
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x82600cb0 // ldr x16, [c5, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cb0 // str x16, [c5, #0]
	ldr x16, =0x40400414
	mrs x5, ELR_EL1
	sub x16, x16, x5
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b205 // cvtp c5, x16
	.inst 0xc2d040a5 // scvalue c5, c5, x16
	.inst 0x826000b0 // ldr c16, [c5, #0]
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
