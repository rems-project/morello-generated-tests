.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2bf7d80 // CAS-C.R-C Ct:0 Rn:12 11111:11111 R:0 Cs:31 1:1 L:0 1:1 10100010:10100010
	.inst 0x48dffdc1 // ldarh:aarch64/instrs/memory/ordered Rt:1 Rn:14 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xd3773bde // ubfm:aarch64/instrs/integer/bitfield Rd:30 Rn:30 imms:001110 immr:110111 N:1 100110:100110 opc:10 sf:1
	.inst 0xb8604a60 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:0 Rn:19 10:10 S:0 option:010 Rm:0 1:1 opc:01 111000:111000 size:10
	.inst 0xc2bdacff // ADD-C.CRI-C Cd:31 Cn:7 imm3:011 option:101 Rm:29 11000010101:11000010101
	.inst 0xc2d127c1 // CPYTYPE-C.C-C Cd:1 Cn:30 001:001 opc:01 0:0 Cm:17 11000010110:11000010110
	.inst 0x7a5b6b26 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0110 0:0 Rn:25 10:10 cond:0110 imm5:11011 111010010:111010010 op:1 sf:0
	.inst 0xc2c5b25f // CVTP-C.R-C Cd:31 Rn:18 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x78a13000 // ldseth:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:0 00:00 opc:011 0:0 Rs:1 1:1 R:0 A:1 111000:111000 size:01
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400547 // ldr c7, [x10, #1]
	.inst 0xc240094c // ldr c12, [x10, #2]
	.inst 0xc2400d4e // ldr c14, [x10, #3]
	.inst 0xc2401151 // ldr c17, [x10, #4]
	.inst 0xc2401552 // ldr c18, [x10, #5]
	.inst 0xc2401953 // ldr c19, [x10, #6]
	.inst 0xc2401d5d // ldr c29, [x10, #7]
	/* Set up flags and system registers */
	ldr x10, =0x0
	msr SPSR_EL3, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0xc0000
	msr CPACR_EL1, x10
	ldr x10, =0x0
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x8
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012ea // ldr c10, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e402a // msr CELR_EL3, c10
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x23, #0xf
	and x10, x10, x23
	cmp x10, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400157 // ldr c23, [x10, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400557 // ldr c23, [x10, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400957 // ldr c23, [x10, #2]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2400d57 // ldr c23, [x10, #3]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401157 // ldr c23, [x10, #4]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2401557 // ldr c23, [x10, #5]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401957 // ldr c23, [x10, #6]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2401d57 // ldr c23, [x10, #7]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc2402157 // ldr c23, [x10, #8]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a541 // chkeq c10, c23
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
	ldr x0, =0x00001014
	ldr x1, =check_data1
	ldr x2, =0x00001016
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c20
	ldr x1, =check_data2
	ldr x2, =0x00001c24
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
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
	.zero 3104
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 976
.data
check_data0:
	.byte 0x20, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data3:
	.byte 0x80, 0x7d, 0xbf, 0xa2, 0xc1, 0xfd, 0xdf, 0x48, 0xde, 0x3b, 0x77, 0xd3, 0x60, 0x4a, 0x60, 0xb8
	.byte 0xff, 0xac, 0xbd, 0xc2, 0xc1, 0x27, 0xd1, 0xc2, 0x26, 0x6b, 0x5b, 0x7a, 0x5f, 0xb2, 0xc5, 0xc2
	.byte 0x00, 0x30, 0xa1, 0x78, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C7 */
	.octa 0x20040006000007ffffffffe3800
	/* C12 */
	.octa 0x1000
	/* C14 */
	.octa 0x1014
	/* C17 */
	.octa 0x810000000000000000000000000
	/* C18 */
	.octa 0x4000000000
	/* C19 */
	.octa 0x1c20
	/* C29 */
	.octa 0x4000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1020
	/* C7 */
	.octa 0x20040006000007ffffffffe3800
	/* C12 */
	.octa 0x1000
	/* C14 */
	.octa 0x1014
	/* C17 */
	.octa 0x810000000000000000000000000
	/* C18 */
	.octa 0x4000000000
	/* C19 */
	.octa 0x1c20
	/* C29 */
	.octa 0x4000
initial_DDC_EL0_value:
	.octa 0xd0000000000100070080000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x200400060000080000000003800
final_PCC_value:
	.octa 0x20008000100100070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x82600eea // ldr x10, [c23, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eea // str x10, [c23, #0]
	ldr x10, =0x40400028
	mrs x23, ELR_EL1
	sub x10, x10, x23
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b157 // cvtp c23, x10
	.inst 0xc2ca42f7 // scvalue c23, c23, x10
	.inst 0x826002ea // ldr c10, [c23, #0]
	.inst 0x021e014a // add c10, c10, #1920
	.inst 0xc2c21140 // br c10

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
