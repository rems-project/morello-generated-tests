.section text0, #alloc, #execinstr
test_start:
	.inst 0x089ffc19 // stlrb:aarch64/instrs/memory/ordered Rt:25 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xa247b000 // LDUR-C.RI-C Ct:0 Rn:0 00:00 imm9:001111011 0:0 opc:01 10100010:10100010
	.inst 0x1a000161 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:11 000000:000000 Rm:0 11010000:11010000 S:0 op:0 sf:0
	.inst 0x089f7cc6 // stllrb:aarch64/instrs/memory/ordered Rt:6 Rn:6 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x380cf60b // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:11 Rn:16 01:01 imm9:011001111 0:0 opc:00 111000:111000 size:00
	.zero 12
	.inst 0xc2c1102e // GCLIM-R.C-C Rd:14 Cn:1 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xd4000001
	.zero 984
	.inst 0x3818419e // 0x3818419e
	.inst 0xc2c2ba1d // 0xc2c2ba1d
	.inst 0xc2d650a0 // BR-CI-C 0:0 0000:0000 Cn:5 100:100 imm7:0110010 110000101101:110000101101
	.zero 64500
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e5 // ldr c5, [x15, #1]
	.inst 0xc24009e6 // ldr c6, [x15, #2]
	.inst 0xc2400dec // ldr c12, [x15, #3]
	.inst 0xc24011f0 // ldr c16, [x15, #4]
	.inst 0xc24015f9 // ldr c25, [x15, #5]
	.inst 0xc24019fe // ldr c30, [x15, #6]
	/* Set up flags and system registers */
	ldr x15, =0x0
	msr SPSR_EL3, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x0
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260106f // ldr c15, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc28e402f // msr CELR_EL3, c15
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e3 // ldr c3, [x15, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005e3 // ldr c3, [x15, #1]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc24009e3 // ldr c3, [x15, #2]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc2400de3 // ldr c3, [x15, #3]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc24011e3 // ldr c3, [x15, #4]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc24015e3 // ldr c3, [x15, #5]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc24019e3 // ldr c3, [x15, #6]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc2401de3 // ldr c3, [x15, #7]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc24021e3 // ldr c3, [x15, #8]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x15, 0x83
	orr x3, x3, x15
	ldr x15, =0x920000eb
	cmp x15, x3
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
	ldr x0, =0x00001005
	ldr x1, =check_data1
	ldr x2, =0x00001006
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001090
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001320
	ldr x1, =check_data3
	ldr x2, =0x00001330
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff4
	ldr x1, =check_data4
	ldr x2, =0x00001ff5
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400020
	ldr x1, =check_data6
	ldr x2, =0x40400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x4040040c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x08, 0x00, 0x00
	.zero 656
	.byte 0x20, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 3280
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x08, 0x00, 0x00
.data
check_data3:
	.byte 0x20, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x19, 0xfc, 0x9f, 0x08, 0x00, 0xb0, 0x47, 0xa2, 0x61, 0x01, 0x00, 0x1a, 0xc6, 0x7c, 0x9f, 0x08
	.byte 0x0b, 0xf6, 0x0c, 0x38
.data
check_data6:
	.byte 0x2e, 0x10, 0xc1, 0xc2, 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.byte 0x9e, 0x41, 0x18, 0x38, 0x1d, 0xba, 0xc2, 0xc2, 0xa0, 0x50, 0xd6, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1005
	/* C5 */
	.octa 0x9000000052fb13200000000000001000
	/* C6 */
	.octa 0x1000
	/* C12 */
	.octa 0x40000000000100050000000000002070
	/* C16 */
	.octa 0x200000030007e77ffffffffff800
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800800000000000000000000000
	/* C5 */
	.octa 0x9000000052fb13200000000000001000
	/* C6 */
	.octa 0x1000
	/* C12 */
	.octa 0x40000000000100050000000000002070
	/* C14 */
	.octa 0xffffffffffffffff
	/* C16 */
	.octa 0x200000030007e77ffffffffff800
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x20007805f800e77ffffffffff800
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd00000000003000300fe000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000400000090000000040400001
final_PCC_value:
	.octa 0x20008000008000000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword 0x0000000000001320
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword initial_DDC_EL0_value
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x82600c6f // ldr x15, [c3, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400c6f // str x15, [c3, #0]
	ldr x15, =0x40400028
	mrs x3, ELR_EL1
	sub x15, x15, x3
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e3 // cvtp c3, x15
	.inst 0xc2cf4063 // scvalue c3, c3, x15
	.inst 0x8260006f // ldr c15, [c3, #0]
	.inst 0x021e01ef // add c15, c15, #1920
	.inst 0xc2c211e0 // br c15

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
