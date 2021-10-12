.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2adfdeb // CASL-C.R-C Ct:11 Rn:15 11111:11111 R:1 Cs:13 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c1d24a // CPY-C.C-C Cd:10 Cn:18 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x783f53df // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:101 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25020 // RET-C-C 00000:00000 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.zero 112
	.inst 0xd82b2e3f // prfm_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:0010101100101110001 011000:011000 opc:11
	.inst 0xc2c21021 // 0xc2c21021
	.inst 0xc2ea701d // 0xc2ea701d
	.inst 0x359704f3 // cbnz:aarch64/instrs/branch/conditional/compare Rt:19 imm19:1001011100000100111 op:1 011010:011010 sf:0
	.inst 0xa20c0495 // STR-C.RIAW-C Ct:21 Rn:4 01:01 imm9:011000000 0:0 opc:00 10100010:10100010
	.inst 0xd4000001
	.zero 65384
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
	.inst 0xc2400844 // ldr c4, [x2, #2]
	.inst 0xc2400c4b // ldr c11, [x2, #3]
	.inst 0xc240104d // ldr c13, [x2, #4]
	.inst 0xc240144f // ldr c15, [x2, #5]
	.inst 0xc2401853 // ldr c19, [x2, #6]
	.inst 0xc2401c55 // ldr c21, [x2, #7]
	.inst 0xc240205e // ldr c30, [x2, #8]
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
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012e2 // ldr c2, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x23, #0xf
	and x2, x2, x23
	cmp x2, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400057 // ldr c23, [x2, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400457 // ldr c23, [x2, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400857 // ldr c23, [x2, #2]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2400c57 // ldr c23, [x2, #3]
	.inst 0xc2d7a561 // chkeq c11, c23
	b.ne comparison_fail
	.inst 0xc2401057 // ldr c23, [x2, #4]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc2401457 // ldr c23, [x2, #5]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc2401857 // ldr c23, [x2, #6]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc2401c57 // ldr c23, [x2, #7]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc2402057 // ldr c23, [x2, #8]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2402457 // ldr c23, [x2, #9]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a441 // chkeq c2, c23
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
	ldr x0, =0x00001808
	ldr x1, =check_data1
	ldr x2, =0x0000180a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400080
	ldr x1, =check_data3
	ldr x2, =0x40400098
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
	.byte 0x00, 0x00, 0x20, 0x00, 0x20, 0x02, 0x02, 0x40, 0x08, 0x00, 0x40, 0x04, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xeb, 0xfd, 0xad, 0xa2, 0x4a, 0xd2, 0xc1, 0xc2, 0xdf, 0x53, 0x3f, 0x78, 0x20, 0x50, 0xc2, 0xc2
.data
check_data3:
	.byte 0x3f, 0x2e, 0x2b, 0xd8, 0x21, 0x10, 0xc2, 0xc2, 0x1d, 0x70, 0xea, 0xc2, 0xf3, 0x04, 0x97, 0x35
	.byte 0x95, 0x04, 0x0c, 0xa2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x20008000880140050000000040400081
	/* C4 */
	.octa 0x4c000000000100060000000000001000
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x44000084002022000200000
	/* C30 */
	.octa 0x1808
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x20008000880140050000000040400081
	/* C4 */
	.octa 0x4c000000000100060000000000001c00
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x44000084002022000200000
	/* C29 */
	.octa 0x5300000000000000
	/* C30 */
	.octa 0x1808
initial_DDC_EL0_value:
	.octa 0xdc000000000700070000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000080140050000000040400098
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000408000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
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
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x82600ee2 // ldr x2, [c23, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ee2 // str x2, [c23, #0]
	ldr x2, =0x40400098
	mrs x23, ELR_EL1
	sub x2, x2, x23
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b057 // cvtp c23, x2
	.inst 0xc2c242f7 // scvalue c23, c23, x2
	.inst 0x826002e2 // ldr c2, [c23, #0]
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
