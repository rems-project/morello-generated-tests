.section text0, #alloc, #execinstr
test_start:
	.inst 0xd61f0020 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 32740
	.inst 0x79500bcb // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:11 Rn:30 imm12:010000000010 opc:01 111001:111001 size:01
	.inst 0x3a1e03df // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:30 000000:000000 Rm:30 11010000:11010000 S:1 op:0 sf:0
	.inst 0x485f7f20 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:0 Rn:25 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xf8846026 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:6 Rn:1 00:00 imm9:001000110 0:0 opc:10 111000:111000 size:11
	.inst 0xe2bd30d8 // ASTUR-V.RI-S Rt:24 Rn:6 op2:00 imm9:111010011 V:1 op1:10 11100010:11100010
	.inst 0xc2c19001 // CLRTAG-C.C-C Cd:1 Cn:0 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x78bfc37f // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:31 Rn:27 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0xc2f743f2 // BICFLGS-C.CI-C Cd:18 Cn:31 0:0 00:00 imm8:10111010 11000010111:11000010111
	.inst 0xd4000001
	.zero 32756
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
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400546 // ldr c6, [x10, #1]
	.inst 0xc2400959 // ldr c25, [x10, #2]
	.inst 0xc2400d5b // ldr c27, [x10, #3]
	.inst 0xc240115e // ldr c30, [x10, #4]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q24, =0x0
	/* Set up flags and system registers */
	ldr x10, =0x4000000
	msr SPSR_EL3, x10
	ldr x10, =initial_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288410a // msr CSP_EL0, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0x3c0000
	msr CPACR_EL1, x10
	ldr x10, =0x0
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x4
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260110a // ldr c10, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	mov x8, #0xf
	and x10, x10, x8
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400148 // ldr c8, [x10, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400548 // ldr c8, [x10, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400948 // ldr c8, [x10, #2]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc2400d48 // ldr c8, [x10, #3]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc2401148 // ldr c8, [x10, #4]
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	.inst 0xc2401548 // ldr c8, [x10, #5]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc2401948 // ldr c8, [x10, #6]
	.inst 0xc2c8a761 // chkeq c27, c8
	b.ne comparison_fail
	.inst 0xc2401d48 // ldr c8, [x10, #7]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x8, v24.d[0]
	cmp x10, x8
	b.ne comparison_fail
	ldr x10, =0x0
	mov x8, v24.d[1]
	cmp x10, x8
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984108 // mrs c8, CSP_EL0
	.inst 0xc2c8a541 // chkeq c10, c8
	b.ne comparison_fail
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a541 // chkeq c10, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000017d4
	ldr x1, =check_data0
	ldr x2, =0x000017d8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001df4
	ldr x1, =check_data1
	ldr x2, =0x00001df6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40407fe8
	ldr x1, =check_data4
	ldr x2, =0x4040800c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040fffc
	ldr x1, =check_data5
	ldr x2, =0x4040fffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x20, 0x00, 0x1f, 0xd6
.data
check_data4:
	.byte 0xcb, 0x0b, 0x50, 0x79, 0xdf, 0x03, 0x1e, 0x3a, 0x20, 0x7f, 0x5f, 0x48, 0x26, 0x60, 0x84, 0xf8
	.byte 0xd8, 0x30, 0xbd, 0xe2, 0x01, 0x90, 0xc1, 0xc2, 0x7f, 0xc3, 0xbf, 0x78, 0xf2, 0x43, 0xf7, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40407fe8
	/* C6 */
	.octa 0x1801
	/* C25 */
	.octa 0x80000000000300070000000000001ffc
	/* C27 */
	.octa 0x8000000000010005000000004040fffc
	/* C30 */
	.octa 0x800000000001000500000000000015f0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x1801
	/* C11 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C25 */
	.octa 0x80000000000300070000000000001ffc
	/* C27 */
	.octa 0x8000000000010005000000004040fffc
	/* C30 */
	.octa 0x800000000001000500000000000015f0
initial_SP_EL0_value:
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x40000000000002000000000007f80001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x0
final_PCC_value:
	.octa 0x2000800000010005000000004040800c
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
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword final_cap_values + 96
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x82600d0a // ldr x10, [c8, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d0a // str x10, [c8, #0]
	ldr x10, =0x4040800c
	mrs x8, ELR_EL1
	sub x10, x10, x8
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b148 // cvtp c8, x10
	.inst 0xc2ca4108 // scvalue c8, c8, x10
	.inst 0x8260010a // ldr c10, [c8, #0]
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
