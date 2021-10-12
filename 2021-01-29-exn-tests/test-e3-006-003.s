.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2cf23dc // SCBNDSE-C.CR-C Cd:28 Cn:30 000:000 opc:01 0:0 Rm:15 11000010110:11000010110
	.inst 0x421ffea1 // STLR-C.R-C Ct:1 Rn:21 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xcb5dffbe // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:29 imm6:111111 Rm:29 0:0 shift:01 01011:01011 S:0 op:1 sf:1
	.inst 0x085ffc1f // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:31 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xc89f7fde // stllr:aarch64/instrs/memory/ordered Rt:30 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.zero 1004
	.inst 0x28a9c321 // 0x28a9c321
	.inst 0xc2bdcc08 // 0xc2bdcc08
	.inst 0x911ea411 // 0x911ea411
	.inst 0xc2d15bba // 0xc2d15bba
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc2400850 // ldr c16, [x2, #2]
	.inst 0xc2400c55 // ldr c21, [x2, #3]
	.inst 0xc2401059 // ldr c25, [x2, #4]
	.inst 0xc240145d // ldr c29, [x2, #5]
	.inst 0xc240185e // ldr c30, [x2, #6]
	/* Set up flags and system registers */
	ldr x2, =0x0
	msr SPSR_EL3, x2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0xc0000
	msr CPACR_EL1, x2
	ldr x2, =0x0
	msr S3_0_C1_C2_2, x2 // CCTLR_EL1
	ldr x2, =0x0
	msr S3_3_C1_C2_2, x2 // CCTLR_EL0
	ldr x2, =initial_DDC_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884122 // msr DDC_EL0, c2
	ldr x2, =initial_DDC_EL1_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc28c4122 // msr DDC_EL1, c2
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010a2 // ldr c2, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	.inst 0xc2400045 // ldr c5, [x2, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400445 // ldr c5, [x2, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400845 // ldr c5, [x2, #2]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2400c45 // ldr c5, [x2, #3]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc2401045 // ldr c5, [x2, #4]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2401445 // ldr c5, [x2, #5]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2401845 // ldr c5, [x2, #6]
	.inst 0xc2c5a721 // chkeq c25, c5
	b.ne comparison_fail
	.inst 0xc2401c45 // ldr c5, [x2, #7]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2402045 // ldr c5, [x2, #8]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402445 // ldr c5, [x2, #9]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x2, 0x83
	orr x5, x5, x2
	ldr x2, =0x920000e3
	cmp x2, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001780
	ldr x1, =check_data1
	ldr x2, =0x00001790
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xdc, 0x23, 0xcf, 0xc2, 0xa1, 0xfe, 0x1f, 0x42, 0xbe, 0xff, 0x5d, 0xcb, 0x1f, 0xfc, 0x5f, 0x08
	.byte 0xde, 0x7f, 0x9f, 0xc8
.data
check_data3:
	.byte 0x21, 0xc3, 0xa9, 0x28, 0x08, 0xcc, 0xbd, 0xc2, 0x11, 0xa4, 0x1e, 0x91, 0xba, 0x5b, 0xd1, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000520070000000000001000
	/* C1 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C21 */
	.octa 0x1780
	/* C25 */
	.octa 0x1000
	/* C29 */
	.octa 0x100178080000080000000
	/* C30 */
	.octa 0x300070000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000520070000000000001000
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0x4000052007fffffffc00001000
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x17a9
	/* C21 */
	.octa 0x1780
	/* C25 */
	.octa 0xf4c
	/* C26 */
	.octa 0x100178080000400000000
	/* C29 */
	.octa 0x100178080000080000000
	/* C30 */
	.octa 0x808000007fffffff
initial_DDC_EL0_value:
	.octa 0xc0000000108100060000000000000001
initial_DDC_EL1_value:
	.octa 0x400000000007004f00ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000001e0000000040400000
final_PCC_value:
	.octa 0x200080004000001e0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000400040000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
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
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x82600ca2 // ldr x2, [c5, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ca2 // str x2, [c5, #0]
	ldr x2, =0x40400414
	mrs x5, ELR_EL1
	sub x2, x2, x5
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b045 // cvtp c5, x2
	.inst 0xc2c240a5 // scvalue c5, c5, x2
	.inst 0x826000a2 // ldr c2, [c5, #0]
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
