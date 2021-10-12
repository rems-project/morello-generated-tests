.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23001 // CHKTGD-C-C 00001:00001 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x38601101 // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:8 00:00 opc:001 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x02d4b3ce // SUB-C.CIS-C Cd:14 Cn:30 imm12:010100101100 sh:1 A:1 00000010:00000010
	.inst 0xac8f0d20 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:0 Rn:9 Rt2:00011 imm7:0011110 L:0 1011001:1011001 opc:10
	.inst 0x825e1083 // ASTR-C.RI-C Ct:3 Rn:4 op:00 imm9:111100001 L:0 1000001001:1000001001
	.zero 1004
	.inst 0x824427e1 // 0x824427e1
	.inst 0xc2dec540 // 0xc2dec540
	.zero 3064
	.inst 0x622ac7fd // 0x622ac7fd
	.inst 0x386003ff // 0x386003ff
	.inst 0xd4000001
	.zero 61428
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400743 // ldr c3, [x26, #1]
	.inst 0xc2400b44 // ldr c4, [x26, #2]
	.inst 0xc2400f48 // ldr c8, [x26, #3]
	.inst 0xc2401349 // ldr c9, [x26, #4]
	.inst 0xc240174a // ldr c10, [x26, #5]
	.inst 0xc2401b51 // ldr c17, [x26, #6]
	.inst 0xc2401f5e // ldr c30, [x26, #7]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q0, =0x0
	ldr q3, =0x0
	/* Set up flags and system registers */
	ldr x26, =0x0
	msr SPSR_EL3, x26
	ldr x26, =initial_SP_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc28c411a // msr CSP_EL1, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0x3c0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x0
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =initial_DDC_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc28c413a // msr DDC_EL1, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010da // ldr c26, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc28e403a // msr CELR_EL3, c26
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x6, #0xf
	and x26, x26, x6
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400346 // ldr c6, [x26, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400746 // ldr c6, [x26, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400b46 // ldr c6, [x26, #2]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2400f46 // ldr c6, [x26, #3]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2401346 // ldr c6, [x26, #4]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2401746 // ldr c6, [x26, #5]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc2401b46 // ldr c6, [x26, #6]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401f46 // ldr c6, [x26, #7]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2402346 // ldr c6, [x26, #8]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2402746 // ldr c6, [x26, #9]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402b46 // ldr c6, [x26, #10]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x6, v0.d[0]
	cmp x26, x6
	b.ne comparison_fail
	ldr x26, =0x0
	mov x6, v0.d[1]
	cmp x26, x6
	b.ne comparison_fail
	ldr x26, =0x0
	mov x6, v3.d[0]
	cmp x26, x6
	b.ne comparison_fail
	ldr x26, =0x0
	mov x6, v3.d[1]
	cmp x26, x6
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_SP_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc29c4106 // mrs c6, CSP_EL1
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x26, 0x83
	orr x6, x6, x26
	ldr x26, =0x920000e3
	cmp x26, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001030
	ldr x1, =check_data0
	ldr x2, =0x00001050
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000105c
	ldr x1, =check_data1
	ldr x2, =0x0000105d
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001220
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000014b0
	ldr x1, =check_data3
	ldr x2, =0x000014b1
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000014f2
	ldr x1, =check_data4
	ldr x2, =0x000014f3
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400408
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40401000
	ldr x1, =check_data7
	ldr x2, =0x4040100c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
	.zero 80
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x93, 0x00, 0x00, 0x00
	.zero 1104
	.byte 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2880
.data
check_data0:
	.zero 32
.data
check_data1:
	.byte 0x93
.data
check_data2:
	.byte 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x0f, 0x00, 0x07, 0x00, 0x00, 0x00, 0x40, 0x01
	.byte 0x00, 0x01, 0x20, 0x00, 0x00, 0x08, 0x00, 0x00, 0x02, 0x01, 0x80, 0x80, 0x04, 0x40, 0x00, 0x00
.data
check_data3:
	.byte 0x80
.data
check_data4:
	.byte 0x93
.data
check_data5:
	.byte 0x01, 0x30, 0xc2, 0xc2, 0x01, 0x11, 0x60, 0x38, 0xce, 0xb3, 0xd4, 0x02, 0x20, 0x0d, 0x8f, 0xac
	.byte 0x83, 0x10, 0x5e, 0x82
.data
check_data6:
	.byte 0xe1, 0x27, 0x44, 0x82, 0x40, 0xc5, 0xde, 0xc2
.data
check_data7:
	.byte 0xfd, 0xc7, 0x2a, 0x62, 0xff, 0x03, 0x60, 0x38, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x4c00000000478e8f0000000000008009
	/* C8 */
	.octa 0x105c
	/* C9 */
	.octa 0x1030
	/* C10 */
	.octa 0x20408002000900070000000040401001
	/* C17 */
	.octa 0x4004808001020000080000200100
	/* C30 */
	.octa 0x14000020007000f0080000000000040
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40
	/* C1 */
	.octa 0x93
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x4c00000000478e8f0000000000008009
	/* C8 */
	.octa 0x105c
	/* C9 */
	.octa 0x1210
	/* C10 */
	.octa 0x20408002000900070000000040401001
	/* C14 */
	.octa 0x14000020007000f007fffffffad4040
	/* C17 */
	.octa 0x4004808001020000080000200100
	/* C29 */
	.octa 0x14000000007000f0080000000000040
	/* C30 */
	.octa 0x14000020007000f0080000000000040
initial_SP_EL1_value:
	.octa 0xcc0000000005000700000000000014b0
initial_DDC_EL0_value:
	.octa 0xc00000005414085c00ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x400000004000000100ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x20008000500100030000000040400001
final_SP_EL1_value:
	.octa 0xcc0000000005000700000000000014b0
final_PCC_value:
	.octa 0x2040800000090007000000004040100c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800005a100060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x82600cda // ldr x26, [c6, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400cda // str x26, [c6, #0]
	ldr x26, =0x4040100c
	mrs x6, ELR_EL1
	sub x26, x26, x6
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b346 // cvtp c6, x26
	.inst 0xc2da40c6 // scvalue c6, c6, x26
	.inst 0x826000da // ldr c26, [c6, #0]
	.inst 0x021e035a // add c26, c26, #1920
	.inst 0xc2c21340 // br c26

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
