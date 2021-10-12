.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c653e0 // CLRPERM-C.CI-C Cd:0 Cn:31 100:100 perm:010 1100001011000110:1100001011000110
	.inst 0xc87fc401 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:0 Rt2:10001 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0x387e63fd // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:31 00:00 opc:110 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x28430cbf // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:31 Rn:5 Rt2:00011 imm7:0000110 L:1 1010000:1010000 opc:00
	.inst 0xc2ef0834 // ORRFLGS-C.CI-C Cd:20 Cn:1 0:0 01:01 imm8:01111000 11000010111:11000010111
	.inst 0xa25061ff // LDUR-C.RI-C Ct:31 Rn:15 00:00 imm9:100000110 0:0 opc:01 10100010:10100010
	.inst 0x386000ff // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:7 00:00 opc:000 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x62efcd83 // LDP-C.RIBW-C Ct:3 Rn:12 Ct2:10011 imm7:1011111 L:1 011000101:011000101
	.inst 0xb96d20b8 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:24 Rn:5 imm12:101101001000 opc:01 111001:111001 size:10
	.inst 0xd4000001
	.zero 65496
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c5 // ldr c5, [x6, #0]
	.inst 0xc24004c7 // ldr c7, [x6, #1]
	.inst 0xc24008cc // ldr c12, [x6, #2]
	.inst 0xc2400ccf // ldr c15, [x6, #3]
	.inst 0xc24010de // ldr c30, [x6, #4]
	/* Set up flags and system registers */
	ldr x6, =0x0
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884106 // msr CSP_EL0, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x0
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601326 // ldr c6, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d9 // ldr c25, [x6, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24004d9 // ldr c25, [x6, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24008d9 // ldr c25, [x6, #2]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2400cd9 // ldr c25, [x6, #3]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc24010d9 // ldr c25, [x6, #4]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc24014d9 // ldr c25, [x6, #5]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc24018d9 // ldr c25, [x6, #6]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2401cd9 // ldr c25, [x6, #7]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc24020d9 // ldr c25, [x6, #8]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc24024d9 // ldr c25, [x6, #9]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc24028d9 // ldr c25, [x6, #10]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc2402cd9 // ldr c25, [x6, #11]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc24030d9 // ldr c25, [x6, #12]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984119 // mrs c25, CSP_EL0
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001050
	ldr x1, =check_data1
	ldr x2, =0x00001060
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a50
	ldr x1, =check_data2
	ldr x2, =0x00001a70
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040024c
	ldr x1, =check_data4
	ldr x2, =0x40400254
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40402f54
	ldr x1, =check_data5
	ldr x2, =0x40402f58
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2544
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 1424
.data
check_data0:
	.byte 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data3:
	.byte 0xe0, 0x53, 0xc6, 0xc2, 0x01, 0xc4, 0x7f, 0xc8, 0xfd, 0x63, 0x7e, 0x38, 0xbf, 0x0c, 0x43, 0x28
	.byte 0x34, 0x08, 0xef, 0xc2, 0xff, 0x61, 0x50, 0xa2, 0xff, 0x00, 0x60, 0x38, 0x83, 0xcd, 0xef, 0x62
	.byte 0xb8, 0x20, 0x6d, 0xb9, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x40400234
	/* C7 */
	.octa 0x1000
	/* C12 */
	.octa 0x1c60
	/* C15 */
	.octa 0x10fa
	/* C30 */
	.octa 0x80
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800000000000000000001050
	/* C1 */
	.octa 0x1
	/* C3 */
	.octa 0x101800000000000000000000000
	/* C5 */
	.octa 0x40400234
	/* C7 */
	.octa 0x1000
	/* C12 */
	.octa 0x1a50
	/* C15 */
	.octa 0x10fa
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x101800000000000000000000000
	/* C20 */
	.octa 0x7800000000000001
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x80
initial_SP_EL0_value:
	.octa 0x800000000000000000001050
initial_DDC_EL0_value:
	.octa 0xd00000000002000600c0000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x800000000000000000001050
final_PCC_value:
	.octa 0x20008000000080080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001a50
	.dword 0x0000000000001a60
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600f26 // ldr x6, [c25, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f26 // str x6, [c25, #0]
	ldr x6, =0x40400028
	mrs x25, ELR_EL1
	sub x6, x6, x25
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d9 // cvtp c25, x6
	.inst 0xc2c64339 // scvalue c25, c25, x6
	.inst 0x82600326 // ldr c6, [c25, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
