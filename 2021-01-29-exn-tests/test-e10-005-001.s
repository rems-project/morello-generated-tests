.section text0, #alloc, #execinstr
test_start:
	.inst 0xb840afcb // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:11 Rn:30 11:11 imm9:000001010 0:0 opc:01 111000:111000 size:10
	.inst 0xa20f943f // STR-C.RIAW-C Ct:31 Rn:1 01:01 imm9:011111001 0:0 opc:00 10100010:10100010
	.inst 0x42ea9e81 // LDP-C.RIB-C Ct:1 Rn:20 Ct2:00111 imm7:1010101 L:1 010000101:010000101
	.inst 0xa24d341e // LDR-C.RIAW-C Ct:30 Rn:0 01:01 imm9:011010011 0:0 opc:01 10100010:10100010
	.inst 0xc2c1102a // GCLIM-R.C-C Rd:10 Cn:1 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xdac00000 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:0 Rn:0 101101011000000000000:101101011000000000000 sf:1
	.inst 0x7926fbae // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:14 Rn:29 imm12:100110111110 opc:00 111001:111001 size:01
	.inst 0x78e072f3 // lduminh:aarch64/instrs/memory/atomicops/ld Rt:19 Rn:23 00:00 opc:111 0:0 Rs:0 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x622db749 // STNP-C.RIB-C Ct:9 Rn:26 Ct2:01101 imm7:1011011 L:0 011000100:011000100
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400989 // ldr c9, [x12, #2]
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc240118e // ldr c14, [x12, #4]
	.inst 0xc2401594 // ldr c20, [x12, #5]
	.inst 0xc2401997 // ldr c23, [x12, #6]
	.inst 0xc2401d9a // ldr c26, [x12, #7]
	.inst 0xc240219d // ldr c29, [x12, #8]
	.inst 0xc240259e // ldr c30, [x12, #9]
	/* Set up flags and system registers */
	ldr x12, =0x4000000
	msr SPSR_EL3, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30d5d99f
	msr SCTLR_EL1, x12
	ldr x12, =0xc0000
	msr CPACR_EL1, x12
	ldr x12, =0x0
	msr S3_0_C1_C2_2, x12 // CCTLR_EL1
	ldr x12, =0x80000000
	msr HCR_EL2, x12
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010ac // ldr c12, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc28e402c // msr CELR_EL3, c12
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400185 // ldr c5, [x12, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400585 // ldr c5, [x12, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400985 // ldr c5, [x12, #2]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2400d85 // ldr c5, [x12, #3]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc2401185 // ldr c5, [x12, #4]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2401585 // ldr c5, [x12, #5]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2401985 // ldr c5, [x12, #6]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2401d85 // ldr c5, [x12, #7]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2402185 // ldr c5, [x12, #8]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2402585 // ldr c5, [x12, #9]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc2402985 // ldr c5, [x12, #10]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2402d85 // ldr c5, [x12, #11]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2403185 // ldr c5, [x12, #12]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2403585 // ldr c5, [x12, #13]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check system registers */
	ldr x12, =final_PCC_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100c
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001080
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013c0
	ldr x1, =check_data2
	ldr x2, =0x000013e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017c0
	ldr x1, =check_data3
	ldr x2, =0x000017d0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001810
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
	.zero 96
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3984
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x40, 0x40, 0x10, 0x04, 0x08, 0x08, 0x00, 0x80, 0x80, 0x08, 0x04, 0x00, 0x40
	.byte 0x02, 0x02, 0x08, 0x04, 0x08, 0x00, 0x00, 0x00, 0x80, 0x20, 0x08, 0x80, 0x40, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xcb, 0xaf, 0x40, 0xb8, 0x3f, 0x94, 0x0f, 0xa2, 0x81, 0x9e, 0xea, 0x42, 0x1e, 0x34, 0x4d, 0xa2
	.byte 0x2a, 0x10, 0xc1, 0xc2, 0x00, 0x00, 0xc0, 0xda, 0xae, 0xfb, 0x26, 0x79, 0xf3, 0x72, 0xe0, 0x78
	.byte 0x49, 0xb7, 0x2d, 0x62, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x901000000007081700000000000017c0
	/* C1 */
	.octa 0x4000000000b100070000000000001800
	/* C9 */
	.octa 0x40000408808000080804104040000000
	/* C13 */
	.octa 0x4040800820800000000804080202
	/* C14 */
	.octa 0x102
	/* C20 */
	.octa 0x800000004004002a0000000000001310
	/* C23 */
	.octa 0xc000000059001731000000000000180c
	/* C26 */
	.octa 0x48000000020700140000000000001610
	/* C29 */
	.octa 0x40000000000100070000000000000490
	/* C30 */
	.octa 0x80000000102701070000000000001002
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xf24000000000000
	/* C1 */
	.octa 0x100000000000000000000
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x40000408808000080804104040000000
	/* C10 */
	.octa 0xffffffffffffffff
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x4040800820800000000804080202
	/* C14 */
	.octa 0x102
	/* C19 */
	.octa 0x102
	/* C20 */
	.octa 0x800000004004002a0000000000001310
	/* C23 */
	.octa 0xc000000059001731000000000000180c
	/* C26 */
	.octa 0x48000000020700140000000000001610
	/* C29 */
	.octa 0x40000000000100070000000000000490
	/* C30 */
	.octa 0x0
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000200100060000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200100060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001060
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword final_cap_values + 192
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
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x0200018c // add c12, c12, #0
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x0202018c // add c12, c12, #128
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x0204018c // add c12, c12, #256
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x0206018c // add c12, c12, #384
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x0208018c // add c12, c12, #512
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x020a018c // add c12, c12, #640
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x020c018c // add c12, c12, #768
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x020e018c // add c12, c12, #896
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x0210018c // add c12, c12, #1024
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x0212018c // add c12, c12, #1152
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x0214018c // add c12, c12, #1280
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x0216018c // add c12, c12, #1408
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x0218018c // add c12, c12, #1536
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x021a018c // add c12, c12, #1664
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x021c018c // add c12, c12, #1792
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x82600cac // ldr x12, [c5, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cac // str x12, [c5, #0]
	ldr x12, =0x40400028
	mrs x5, ELR_EL1
	sub x12, x12, x5
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b185 // cvtp c5, x12
	.inst 0xc2cc40a5 // scvalue c5, c5, x12
	.inst 0x826000ac // ldr c12, [c5, #0]
	.inst 0x021e018c // add c12, c12, #1920
	.inst 0xc2c21180 // br c12

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
