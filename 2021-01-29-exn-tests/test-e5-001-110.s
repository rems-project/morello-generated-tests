.section text0, #alloc, #execinstr
test_start:
	.inst 0x7821323f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x0820ffa2 // casp:aarch64/instrs/memory/atomicops/cas/pair Rt:2 Rn:29 Rt2:11111 o0:1 Rs:0 1:1 L:0 0010000:0010000 sz:0 0:0
	.inst 0x38ff0196 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:12 00:00 opc:000 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x8276b7bd // ALDRB-R.RI-B Rt:29 Rn:29 op:01 imm9:101101011 L:1 1000001001:1000001001
	.inst 0x223ad1c8 // STLXP-R.CR-C Ct:8 Rn:14 Ct2:10100 1:1 Rs:26 1:1 L:0 001000100:001000100
	.zero 1004
	.inst 0xc2c611bf // 0xc2c611bf
	.inst 0xb8e46140 // 0xb8e46140
	.inst 0xa86d643d // 0xa86d643d
	.inst 0x485f7fbe // 0x485f7fbe
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b82 // ldr c2, [x28, #2]
	.inst 0xc2400f83 // ldr c3, [x28, #3]
	.inst 0xc2401384 // ldr c4, [x28, #4]
	.inst 0xc2401788 // ldr c8, [x28, #5]
	.inst 0xc2401b8a // ldr c10, [x28, #6]
	.inst 0xc2401f8c // ldr c12, [x28, #7]
	.inst 0xc240238d // ldr c13, [x28, #8]
	.inst 0xc240278e // ldr c14, [x28, #9]
	.inst 0xc2402b91 // ldr c17, [x28, #10]
	.inst 0xc2402f94 // ldr c20, [x28, #11]
	.inst 0xc240339d // ldr c29, [x28, #12]
	/* Set up flags and system registers */
	ldr x28, =0x4000000
	msr SPSR_EL3, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0xc0000
	msr CPACR_EL1, x28
	ldr x28, =0x4
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x4
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
	ldr x28, =initial_DDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288413c // msr DDC_EL0, c28
	ldr x28, =initial_DDC_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28c413c // msr DDC_EL1, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260121c // ldr c28, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc28e403c // msr CELR_EL3, c28
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400390 // ldr c16, [x28, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400790 // ldr c16, [x28, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400b90 // ldr c16, [x28, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400f90 // ldr c16, [x28, #3]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2401390 // ldr c16, [x28, #4]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2401790 // ldr c16, [x28, #5]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc2401b90 // ldr c16, [x28, #6]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc2401f90 // ldr c16, [x28, #7]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc2402390 // ldr c16, [x28, #8]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc2402790 // ldr c16, [x28, #9]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2402b90 // ldr c16, [x28, #10]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc2402f90 // ldr c16, [x28, #11]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc2403390 // ldr c16, [x28, #12]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2403790 // ldr c16, [x28, #13]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2403b90 // ldr c16, [x28, #14]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2403f90 // ldr c16, [x28, #15]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_SP_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc29c4110 // mrs c16, CSP_EL1
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x28, 0x83
	orr x16, x16, x28
	ldr x28, =0x920000eb
	cmp x28, x16
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
	ldr x0, =0x0000109c
	ldr x1, =check_data1
	ldr x2, =0x000010a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001102
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000116b
	ldr x1, =check_data3
	ldr x2, =0x0000116c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001802
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ed0
	ldr x1, =check_data5
	ldr x2, =0x00001ee0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x40400414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
	.byte 0x0c, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1728
	.byte 0x00, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 288
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x01
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x0c, 0x20
.data
check_data5:
	.byte 0x00, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0x3f, 0x32, 0x21, 0x78, 0xa2, 0xff, 0x20, 0x08, 0x96, 0x01, 0xff, 0x38, 0xbd, 0xb7, 0x76, 0x82
	.byte 0xc8, 0xd1, 0x3a, 0x22
.data
check_data7:
	.byte 0xbf, 0x11, 0xc6, 0xc2, 0x40, 0x61, 0xe4, 0xb8, 0x3d, 0x64, 0x6d, 0xa8, 0xbe, 0x7f, 0x5f, 0x48
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2000
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1000000
	/* C8 */
	.octa 0x4000000000000000000000000000
	/* C10 */
	.octa 0x109c
	/* C12 */
	.octa 0xc0000000200700060000000000001000
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x80000000000000
	/* C17 */
	.octa 0xc0000000000700070000000000001800
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0xc00000004001000c0000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2000
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1000000
	/* C8 */
	.octa 0x4000000000000000000000000000
	/* C10 */
	.octa 0x109c
	/* C12 */
	.octa 0xc0000000200700060000000000001000
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x80000000000000
	/* C17 */
	.octa 0xc0000000000700070000000000001800
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x1100
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000100140050080000000000001
initial_DDC_EL1_value:
	.octa 0xc00000000006000200fffffffc000001
initial_VBAR_EL1_value:
	.octa 0x200080004800001d0000000040400000
final_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x200080004800001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000410000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword initial_cap_values + 160
	.dword initial_cap_values + 192
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 160
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x82600e1c // ldr x28, [c16, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e1c // str x28, [c16, #0]
	ldr x28, =0x40400414
	mrs x16, ELR_EL1
	sub x28, x28, x16
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b390 // cvtp c16, x28
	.inst 0xc2dc4210 // scvalue c16, c16, x28
	.inst 0x8260021c // ldr c28, [c16, #0]
	.inst 0x021e039c // add c28, c28, #1920
	.inst 0xc2c21380 // br c28

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
