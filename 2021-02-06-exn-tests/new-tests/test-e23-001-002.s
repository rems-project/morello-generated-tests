.section text0, #alloc, #execinstr
test_start:
	.inst 0x787f73fd // lduminh:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:31 00:00 opc:111 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x48dffffe // ldarh:aarch64/instrs/memory/ordered Rt:30 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x6d2ab3ef // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:15 Rn:31 Rt2:01100 imm7:1010101 L:0 1011010:1011010 opc:01
	.inst 0x8ae04d9f // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:12 imm6:010011 Rm:0 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0x089ffe21 // stlrb:aarch64/instrs/memory/ordered Rt:1 Rn:17 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.zero 1004
	.inst 0x9028cffd // ADRDP-C.ID-C Rd:29 immhi:010100011001111111 P:0 10000:10000 immlo:00 op:1
	.inst 0x429764d4 // STP-C.RIB-C Ct:20 Rn:6 Ct2:11001 imm7:0101110 L:0 010000101:010000101
	.inst 0xc2c48401 // CHKSS-_.CC-C 00001:00001 Cn:0 001:001 opc:00 1:1 Cm:4 11000010110:11000010110
	.inst 0x089fffe6 // stlrb:aarch64/instrs/memory/ordered Rt:6 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
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
	.inst 0xc2400604 // ldr c4, [x16, #1]
	.inst 0xc2400a06 // ldr c6, [x16, #2]
	.inst 0xc2400e11 // ldr c17, [x16, #3]
	.inst 0xc2401214 // ldr c20, [x16, #4]
	.inst 0xc2401619 // ldr c25, [x16, #5]
	.inst 0xc2401a1c // ldr c28, [x16, #6]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q12, =0x8000000000000004
	ldr q15, =0x0
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =initial_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884110 // msr CSP_EL0, c16
	ldr x16, =initial_SP_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4110 // msr CSP_EL1, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x3c0000
	msr CPACR_EL1, x16
	ldr x16, =0x10
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
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
	mov x5, #0xf
	and x16, x16, x5
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400205 // ldr c5, [x16, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400605 // ldr c5, [x16, #1]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2400a05 // ldr c5, [x16, #2]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2400e05 // ldr c5, [x16, #3]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2401205 // ldr c5, [x16, #4]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc2401605 // ldr c5, [x16, #5]
	.inst 0xc2c5a721 // chkeq c25, c5
	b.ne comparison_fail
	.inst 0xc2401a05 // ldr c5, [x16, #6]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc2401e05 // ldr c5, [x16, #7]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402205 // ldr c5, [x16, #8]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x8000000000000004
	mov x5, v12.d[0]
	cmp x16, x5
	b.ne comparison_fail
	ldr x16, =0x0
	mov x5, v12.d[1]
	cmp x16, x5
	b.ne comparison_fail
	ldr x16, =0x0
	mov x5, v15.d[0]
	cmp x16, x5
	b.ne comparison_fail
	ldr x16, =0x0
	mov x5, v15.d[1]
	cmp x16, x5
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984105 // mrs c5, CSP_EL0
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
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
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x5, 0x80
	orr x16, x16, x5
	ldr x5, =0x920000e9
	cmp x5, x16
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
	ldr x0, =0x00001700
	ldr x1, =check_data1
	ldr x2, =0x00001720
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ab8
	ldr x1, =check_data2
	ldr x2, =0x00001ac8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c10
	ldr x1, =check_data3
	ldr x2, =0x00001c12
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
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
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
	.zero 3088
	.byte 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 992
.data
check_data0:
	.byte 0x20
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xfd, 0x73, 0x7f, 0x78, 0xfe, 0xff, 0xdf, 0x48, 0xef, 0xb3, 0x2a, 0x6d, 0x9f, 0x4d, 0xe0, 0x8a
	.byte 0x21, 0xfe, 0x9f, 0x08
.data
check_data5:
	.byte 0xfd, 0xcf, 0x28, 0x90, 0xd4, 0x64, 0x97, 0x42, 0x01, 0x84, 0xc4, 0xc2, 0xe6, 0xff, 0x9f, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1e8ec000080f40170001039080198001
	/* C4 */
	.octa 0x1007101f000103908018e002
	/* C6 */
	.octa 0x48000000600000020000000000001420
	/* C17 */
	.octa 0x800000000080000000000000
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x120040000000000000080
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1e8ec000080f40170001039080198001
	/* C4 */
	.octa 0x1007101f000103908018e002
	/* C6 */
	.octa 0x48000000600000020000000000001420
	/* C17 */
	.octa 0x800000000080000000000000
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x120040000000000000080
	/* C29 */
	.octa 0x1200400000000519fc000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000480208040000000000001c10
initial_SP_EL1_value:
	.octa 0x40000000500100010000000000001000
initial_VBAR_EL1_value:
	.octa 0x20008000400000150000000040400001
final_SP_EL0_value:
	.octa 0xc0000000480208040000000000001c10
final_SP_EL1_value:
	.octa 0x40000000500100010000000000001000
final_PCC_value:
	.octa 0x20008000400000150000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000f00070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_SP_EL0_value
	.dword initial_SP_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001700
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001710
	.dword 0x0000000000001ab0
	.dword 0x0000000000001ac0
	.dword 0x0000000000001c10
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
