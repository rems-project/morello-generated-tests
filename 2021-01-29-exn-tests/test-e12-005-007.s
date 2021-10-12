.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23001 // CHKTGD-C-C 00001:00001 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x38601101 // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:8 00:00 opc:001 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x02d4b3ce // SUB-C.CIS-C Cd:14 Cn:30 imm12:010100101100 sh:1 A:1 00000010:00000010
	.inst 0xac8f0d20 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:0 Rn:9 Rt2:00011 imm7:0011110 L:0 1011001:1011001 opc:10
	.inst 0x825e1083 // ASTR-C.RI-C Ct:3 Rn:4 op:00 imm9:111100001 L:0 1000001001:1000001001
	.zero 236
	.inst 0x622ac7fd // 0x622ac7fd
	.inst 0x386003ff // 0x386003ff
	.inst 0xd4000001
	.zero 756
	.inst 0x824427e1 // 0x824427e1
	.inst 0xc2dec540 // 0xc2dec540
	.zero 64504
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e3 // ldr c3, [x23, #1]
	.inst 0xc2400ae4 // ldr c4, [x23, #2]
	.inst 0xc2400ee8 // ldr c8, [x23, #3]
	.inst 0xc24012e9 // ldr c9, [x23, #4]
	.inst 0xc24016ea // ldr c10, [x23, #5]
	.inst 0xc2401af1 // ldr c17, [x23, #6]
	.inst 0xc2401efe // ldr c30, [x23, #7]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q0, =0x0
	ldr q3, =0x0
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4117 // msr CSP_EL1, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0x3c0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x0
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010b7 // ldr c23, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x5, #0xf
	and x23, x23, x5
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e5 // ldr c5, [x23, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24006e5 // ldr c5, [x23, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400ae5 // ldr c5, [x23, #2]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc2400ee5 // ldr c5, [x23, #3]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc24012e5 // ldr c5, [x23, #4]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc24016e5 // ldr c5, [x23, #5]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc2401ae5 // ldr c5, [x23, #6]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2401ee5 // ldr c5, [x23, #7]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc24022e5 // ldr c5, [x23, #8]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc24026e5 // ldr c5, [x23, #9]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402ae5 // ldr c5, [x23, #10]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x5, v0.d[0]
	cmp x23, x5
	b.ne comparison_fail
	ldr x23, =0x0
	mov x5, v0.d[1]
	cmp x23, x5
	b.ne comparison_fail
	ldr x23, =0x0
	mov x5, v3.d[0]
	cmp x23, x5
	b.ne comparison_fail
	ldr x23, =0x0
	mov x5, v3.d[1]
	cmp x23, x5
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc29c4105 // mrs c5, CSP_EL1
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x23, 0x83
	orr x5, x5, x23
	ldr x23, =0x920000eb
	cmp x23, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000012a0
	ldr x1, =check_data1
	ldr x2, =0x000012c0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012f2
	ldr x1, =check_data2
	ldr x2, =0x000012f3
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
	ldr x0, =0x40400100
	ldr x1, =check_data4
	ldr x2, =0x4040010c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400408
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.byte 0x64, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x80, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x61, 0x07, 0x01, 0x00, 0x40, 0x40, 0x00
	.byte 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x08
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0x64
.data
check_data3:
	.byte 0x01, 0x30, 0xc2, 0xc2, 0x01, 0x11, 0x60, 0x38, 0xce, 0xb3, 0xd4, 0x02, 0x20, 0x0d, 0x8f, 0xac
	.byte 0x83, 0x10, 0x5e, 0x82
.data
check_data4:
	.byte 0xfd, 0xc7, 0x2a, 0x62, 0xff, 0x03, 0x60, 0x38, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0xe1, 0x27, 0x44, 0x82, 0x40, 0xc5, 0xde, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x1000
	/* C9 */
	.octa 0x12a0
	/* C10 */
	.octa 0x20408004000100070000000040400100
	/* C17 */
	.octa 0x8002000000000000002000000008000
	/* C30 */
	.octa 0x404004010761050000000000038000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x64
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x1000
	/* C9 */
	.octa 0x1480
	/* C10 */
	.octa 0x20408004000100070000000040400100
	/* C14 */
	.octa 0x40400401076105ffffffffffb0c000
	/* C17 */
	.octa 0x8002000000000000002000000008000
	/* C29 */
	.octa 0x404000010761050000000000038000
	/* C30 */
	.octa 0x404004010761050000000000038000
initial_SP_EL1_value:
	.octa 0x400000000000801000000000000012b0
initial_DDC_EL0_value:
	.octa 0xc0000000400202b40000000000000001
initial_DDC_EL1_value:
	.octa 0xcc0000005800000400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x20008000500004000000000040400000
final_SP_EL1_value:
	.octa 0x400000000000801000000000000012b0
final_PCC_value:
	.octa 0x2040800000010007000000004040010c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000096090000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040010c
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
