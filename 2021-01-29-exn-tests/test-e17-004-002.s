.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac00049 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:9 Rn:2 101101011000000000000:101101011000000000000 sf:1
	.inst 0xa2bf7c3e // CAS-C.R-C Ct:30 Rn:1 11111:11111 R:0 Cs:31 1:1 L:0 1:1 10100010:10100010
	.inst 0xd503395f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1001 11010101000000110011:11010101000000110011
	.inst 0xc2c21000 // BR-C-C 00000:00000 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xa2fd835f // 0xa2fd835f
	.inst 0x292295e1 // 0x292295e1
	.inst 0x9a8140d5 // 0x9a8140d5
	.inst 0x398663a0 // 0x398663a0
	.inst 0xd4000001
	.zero 16364
	.inst 0xc2c213a0 // BR-C-C 00000:00000 Cn:29 100:100 opc:00 11000010110000100:11000010110000100
	.zero 49132
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
	.inst 0xc2400b05 // ldr c5, [x24, #2]
	.inst 0xc2400f0f // ldr c15, [x24, #3]
	.inst 0xc240131a // ldr c26, [x24, #4]
	.inst 0xc240171d // ldr c29, [x24, #5]
	.inst 0xc2401b1e // ldr c30, [x24, #6]
	/* Set up flags and system registers */
	ldr x24, =0x84000000
	msr SPSR_EL3, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0xc0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601338 // ldr c24, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	mov x25, #0x8
	and x24, x24, x25
	cmp x24, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400319 // ldr c25, [x24, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400719 // ldr c25, [x24, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400b19 // ldr c25, [x24, #2]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2400f19 // ldr c25, [x24, #3]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2401319 // ldr c25, [x24, #4]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc2401719 // ldr c25, [x24, #5]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2401b19 // ldr c25, [x24, #6]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a701 // chkeq c24, c25
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
	ldr x0, =0x00001810
	ldr x1, =check_data1
	ldr x2, =0x00001820
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f14
	ldr x1, =check_data2
	ldr x2, =0x00001f1c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x404001a9
	ldr x1, =check_data4
	ldr x2, =0x404001aa
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40404010
	ldr x1, =check_data5
	ldr x2, =0x40404014
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
	.zero 2064
	.byte 0x80, 0x40, 0x08, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x02, 0x01, 0x04, 0x04, 0x01, 0x80, 0x20
	.zero 2016
.data
check_data0:
	.byte 0x11, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0xcf, 0x91, 0x07, 0x10, 0x00, 0x80, 0x00, 0xa0
.data
check_data1:
	.byte 0x80, 0x40, 0x08, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x02, 0x01, 0x04, 0x04, 0x01, 0x80, 0x20
.data
check_data2:
	.byte 0x10, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x49, 0x00, 0xc0, 0xda, 0x3e, 0x7c, 0xbf, 0xa2, 0x5f, 0x39, 0x03, 0xd5, 0x00, 0x10, 0xc2, 0xc2
	.byte 0x5f, 0x83, 0xfd, 0xa2, 0xe1, 0x95, 0x22, 0x29, 0xd5, 0x40, 0x81, 0x9a, 0xa0, 0x63, 0x86, 0x39
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xa0, 0x13, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000e00040040000000040404010
	/* C1 */
	.octa 0xd8000000600000010000000000001810
	/* C5 */
	.octa 0x0
	/* C15 */
	.octa 0x40000000000300070000000000002000
	/* C26 */
	.octa 0xdc100000508000040000000000001000
	/* C29 */
	.octa 0xa0008000100791cf0000000040400011
	/* C30 */
	.octa 0x4000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xd8000000600000010000000000001810
	/* C5 */
	.octa 0x0
	/* C15 */
	.octa 0x40000000000300070000000000002000
	/* C26 */
	.octa 0xdc100000508000040000000000001000
	/* C29 */
	.octa 0xa0008000100791cf0000000040400011
	/* C30 */
	.octa 0x4000000000000000000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0xa0008000100791cf0000000040400024
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
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
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600f38 // ldr x24, [c25, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f38 // str x24, [c25, #0]
	ldr x24, =0x40400024
	mrs x25, ELR_EL1
	sub x24, x24, x25
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b319 // cvtp c25, x24
	.inst 0xc2d84339 // scvalue c25, c25, x24
	.inst 0x82600338 // ldr c24, [c25, #0]
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
