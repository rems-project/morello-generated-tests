.section text0, #alloc, #execinstr
test_start:
	.inst 0x889f7c1e // stllr:aarch64/instrs/memory/ordered Rt:30 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x081ffcdd // stlxrb:aarch64/instrs/memory/exclusive/single Rt:29 Rn:6 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0x382012bf // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:001 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x429b6966 // STP-C.RIB-C Ct:6 Rn:11 Ct2:11010 imm7:0110110 L:0 010000101:010000101
	.inst 0xadb4603e // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:30 Rn:1 Rt2:11000 imm7:1101000 L:0 1011011:1011011 opc:10
	.zero 1004
	.inst 0x787f509f // 0x787f509f
	.inst 0xc2dd8bfd // 0xc2dd8bfd
	.inst 0xc2c81a3f // 0xc2c81a3f
	.inst 0x8a75d7b7 // 0x8a75d7b7
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2400f06 // ldr c6, [x24, #3]
	.inst 0xc240130b // ldr c11, [x24, #4]
	.inst 0xc2401711 // ldr c17, [x24, #5]
	.inst 0xc2401b15 // ldr c21, [x24, #6]
	.inst 0xc2401f1a // ldr c26, [x24, #7]
	.inst 0xc240231d // ldr c29, [x24, #8]
	.inst 0xc240271e // ldr c30, [x24, #9]
	/* Set up flags and system registers */
	ldr x24, =0x0
	msr SPSR_EL3, x24
	ldr x24, =initial_SP_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28c4118 // msr CSP_EL1, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0x3c0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x4
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010b8 // ldr c24, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x5, #0xf
	and x24, x24, x5
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400305 // ldr c5, [x24, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400705 // ldr c5, [x24, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400b05 // ldr c5, [x24, #2]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2400f05 // ldr c5, [x24, #3]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2401305 // ldr c5, [x24, #4]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2401705 // ldr c5, [x24, #5]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2401b05 // ldr c5, [x24, #6]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2401f05 // ldr c5, [x24, #7]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2402305 // ldr c5, [x24, #8]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2402705 // ldr c5, [x24, #9]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402b05 // ldr c5, [x24, #10]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_SP_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc29c4105 // mrs c5, CSP_EL1
	.inst 0xc2c5a701 // chkeq c24, c5
	b.ne comparison_fail
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a701 // chkeq c24, c5
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x24, 0x83
	orr x5, x5, x24
	ldr x24, =0x920000e3
	cmp x24, x5
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
	ldr x0, =0x00001360
	ldr x1, =check_data1
	ldr x2, =0x00001380
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001404
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001740
	ldr x1, =check_data3
	ldr x2, =0x00001741
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
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
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff
.data
check_data1:
	.byte 0x40, 0x17, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xbd, 0x00, 0x00, 0x00, 0x8d, 0x00, 0x00
	.byte 0x00, 0xaf, 0x00, 0xad, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa9, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0xff
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x1e, 0x7c, 0x9f, 0x88, 0xdd, 0xfc, 0x1f, 0x08, 0xbf, 0x12, 0x20, 0x38, 0x66, 0x69, 0x9b, 0x42
	.byte 0x3e, 0x60, 0xb4, 0xad
.data
check_data5:
	.byte 0x9f, 0x50, 0x7f, 0x78, 0xfd, 0x8b, 0xdd, 0xc2, 0x3f, 0x1a, 0xc8, 0xc2, 0xb7, 0xd7, 0x75, 0x8a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1400
	/* C1 */
	.octa 0x80000004000008
	/* C4 */
	.octa 0xc0000000000100050000000000001366
	/* C6 */
	.octa 0x8d000000bd000000000000001740
	/* C11 */
	.octa 0x1000
	/* C17 */
	.octa 0x80070007000000000000e000
	/* C21 */
	.octa 0x1000
	/* C26 */
	.octa 0xa9000000000000000000ad00af00
	/* C29 */
	.octa 0x4101000400000000003fe001
	/* C30 */
	.octa 0xff000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1400
	/* C1 */
	.octa 0x80000004000008
	/* C4 */
	.octa 0xc0000000000100050000000000001366
	/* C6 */
	.octa 0x8d000000bd000000000000001740
	/* C11 */
	.octa 0x1000
	/* C17 */
	.octa 0x80070007000000000000e000
	/* C21 */
	.octa 0x1000
	/* C23 */
	.octa 0x800000003fe001
	/* C26 */
	.octa 0xa9000000000000000000ad00af00
	/* C29 */
	.octa 0x4000000000800000003fe001
	/* C30 */
	.octa 0xff000000
initial_SP_EL1_value:
	.octa 0x4000000000800000003fe001
initial_DDC_EL0_value:
	.octa 0xcc000000010200040000000000000000
initial_VBAR_EL1_value:
	.octa 0x20008000500002010000000040400001
final_SP_EL1_value:
	.octa 0x800700070000000000000000
final_PCC_value:
	.octa 0x20008000500002010000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001001c0050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x82600cb8 // ldr x24, [c5, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cb8 // str x24, [c5, #0]
	ldr x24, =0x40400414
	mrs x5, ELR_EL1
	sub x24, x24, x5
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b305 // cvtp c5, x24
	.inst 0xc2d840a5 // scvalue c5, c5, x24
	.inst 0x826000b8 // ldr c24, [c5, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
