.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23201 // CHKTGD-C-C 00001:00001 Cn:16 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c06801 // ORRFLGS-C.CR-C Cd:1 Cn:0 1010:1010 opc:01 Rm:0 11000010110:11000010110
	.inst 0x131254e1 // sbfm:aarch64/instrs/integer/bitfield Rd:1 Rn:7 imms:010101 immr:010010 N:0 100110:100110 opc:00 sf:0
	.inst 0x69e8e5dd // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:29 Rn:14 Rt2:11001 imm7:1010001 L:1 1010011:1010011 opc:01
	.inst 0x887f9bd2 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:18 Rn:30 Rt2:00110 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.zero 33772
	.inst 0x5a81c34c // 0x5a81c34c
	.inst 0x8254b3e5 // 0x8254b3e5
	.inst 0xc2e1199d // 0xc2e1199d
	.inst 0xc2df6bc3 // 0xc2df6bc3
	.inst 0xd4000001
	.zero 31724
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
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400625 // ldr c5, [x17, #1]
	.inst 0xc2400a2e // ldr c14, [x17, #2]
	.inst 0xc2400e30 // ldr c16, [x17, #3]
	.inst 0xc240123e // ldr c30, [x17, #4]
	/* Set up flags and system registers */
	ldr x17, =0x4000000
	msr SPSR_EL3, x17
	ldr x17, =initial_SP_EL1_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc28c4111 // msr CSP_EL1, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30d5d99f
	msr SCTLR_EL1, x17
	ldr x17, =0xc0000
	msr CPACR_EL1, x17
	ldr x17, =0x0
	msr S3_0_C1_C2_2, x17 // CCTLR_EL1
	ldr x17, =0x80000000
	msr HCR_EL2, x17
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82601291 // ldr c17, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
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
	mov x20, #0xf
	and x17, x17, x20
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400234 // ldr c20, [x17, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400634 // ldr c20, [x17, #1]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2400a34 // ldr c20, [x17, #2]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc2400e34 // ldr c20, [x17, #3]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401234 // ldr c20, [x17, #4]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2401634 // ldr c20, [x17, #5]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc2401a34 // ldr c20, [x17, #6]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check system registers */
	ldr x17, =final_SP_EL1_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc29c4114 // mrs c20, CSP_EL1
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	ldr x17, =final_PCC_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	ldr x20, =esr_el1_dump_address
	ldr x20, [x20]
	mov x17, 0x83
	orr x20, x20, x17
	ldr x17, =0x920000ab
	cmp x17, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001144
	ldr x1, =check_data0
	ldr x2, =0x0000114c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fe0
	ldr x1, =check_data1
	ldr x2, =0x00001ff0
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
	ldr x0, =0x40408400
	ldr x1, =check_data3
	ldr x2, =0x40408414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.byte 0x01, 0x32, 0xc2, 0xc2, 0x01, 0x68, 0xc0, 0xc2, 0xe1, 0x54, 0x12, 0x13, 0xdd, 0xe5, 0xe8, 0x69
	.byte 0xd2, 0x9b, 0x7f, 0x88
.data
check_data3:
	.byte 0x4c, 0xc3, 0x81, 0x5a, 0xe5, 0xb3, 0x54, 0x82, 0x9d, 0x19, 0xe1, 0xc2, 0xc3, 0x6b, 0xdf, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C5 */
	.octa 0x4000000000000000000000000000
	/* C14 */
	.octa 0x80000000000100050000000000001200
	/* C16 */
	.octa 0x0
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x4000000000000000000000000000
	/* C14 */
	.octa 0x80000000000100050000000000001144
	/* C16 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x48000000000100050000000000000b30
initial_VBAR_EL1_value:
	.octa 0x200080004440445d0000000040408000
final_SP_EL1_value:
	.octa 0x48000000000100050000000000000b30
final_PCC_value:
	.octa 0x200080004440445d0000000040408414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001007901f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_SP_EL1_value
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
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x02000231 // add c17, c17, #0
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x02020231 // add c17, c17, #128
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x02040231 // add c17, c17, #256
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x02060231 // add c17, c17, #384
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x02080231 // add c17, c17, #512
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x020a0231 // add c17, c17, #640
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x020c0231 // add c17, c17, #768
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x020e0231 // add c17, c17, #896
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x02100231 // add c17, c17, #1024
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x02120231 // add c17, c17, #1152
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x02140231 // add c17, c17, #1280
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x02160231 // add c17, c17, #1408
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x02180231 // add c17, c17, #1536
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x021a0231 // add c17, c17, #1664
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
	.inst 0x021c0231 // add c17, c17, #1792
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600e91 // ldr x17, [c20, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400e91 // str x17, [c20, #0]
	ldr x17, =0x40408414
	mrs x20, ELR_EL1
	sub x17, x17, x20
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b234 // cvtp c20, x17
	.inst 0xc2d14294 // scvalue c20, c20, x17
	.inst 0x82600291 // ldr c17, [c20, #0]
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
