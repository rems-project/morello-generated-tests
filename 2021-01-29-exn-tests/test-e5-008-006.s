.section text0, #alloc, #execinstr
test_start:
	.inst 0x7821731f // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:24 00:00 opc:111 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x620cc1f0 // STNP-C.RIB-C Ct:16 Rn:15 Ct2:10000 imm7:0011001 L:0 011000100:011000100
	.inst 0x9b014c3f // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:1 Ra:19 o0:0 Rm:1 0011011000:0011011000 sf:1
	.inst 0xe24047aa // ALDURH-R.RI-32 Rt:10 Rn:29 op2:01 imm9:000000100 V:0 op1:01 11100010:11100010
	.inst 0xc2c4b160 // LDCT-R.R-_ Rt:0 Rn:11 100:100 opc:01 11000010110001001:11000010110001001
	.zero 1004
	.inst 0x917c303f // 0x917c303f
	.inst 0xc2c9a81d // 0xc2c9a81d
	.inst 0x786503bd // 0x786503bd
	.inst 0x39208ebe // 0x39208ebe
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c5 // ldr c5, [x14, #2]
	.inst 0xc2400dc9 // ldr c9, [x14, #3]
	.inst 0xc24011cb // ldr c11, [x14, #4]
	.inst 0xc24015cf // ldr c15, [x14, #5]
	.inst 0xc24019d0 // ldr c16, [x14, #6]
	.inst 0xc2401dd5 // ldr c21, [x14, #7]
	.inst 0xc24021d8 // ldr c24, [x14, #8]
	.inst 0xc24025dd // ldr c29, [x14, #9]
	.inst 0xc24029de // ldr c30, [x14, #10]
	/* Set up flags and system registers */
	ldr x14, =0x0
	msr SPSR_EL3, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0xc0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x0
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =initial_DDC_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc28c412e // msr DDC_EL1, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260136e // ldr c14, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001db // ldr c27, [x14, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24005db // ldr c27, [x14, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc24009db // ldr c27, [x14, #2]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc2400ddb // ldr c27, [x14, #3]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc24011db // ldr c27, [x14, #4]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc24015db // ldr c27, [x14, #5]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc24019db // ldr c27, [x14, #6]
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	.inst 0xc2401ddb // ldr c27, [x14, #7]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc24021db // ldr c27, [x14, #8]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc24025db // ldr c27, [x14, #9]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc24029db // ldr c27, [x14, #10]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc2402ddb // ldr c27, [x14, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_SP_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc29c411b // mrs c27, CSP_EL1
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x14, 0x83
	orr x27, x27, x14
	ldr x14, =0x920000a3
	cmp x14, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001d88
	ldr x1, =check_data1
	ldr x2, =0x00001d8a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fbb
	ldr x1, =check_data2
	ldr x2, =0x00001fbc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fd0
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
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
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.byte 0x1f, 0x73, 0x21, 0x78, 0xf0, 0xc1, 0x0c, 0x62, 0x3f, 0x4c, 0x01, 0x9b, 0xaa, 0x47, 0x40, 0xe2
	.byte 0x60, 0xb1, 0xc4, 0xc2
.data
check_data5:
	.byte 0x3f, 0x30, 0x7c, 0x91, 0x1d, 0xa8, 0xc9, 0xc2, 0xbd, 0x03, 0x65, 0x78, 0xbe, 0x8e, 0x20, 0x39
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000000000001000
	/* C1 */
	.octa 0xa000
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x1883
	/* C15 */
	.octa 0x1e40
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C21 */
	.octa 0x1798
	/* C24 */
	.octa 0x1000
	/* C29 */
	.octa 0x80000000000100050000000000001d84
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800000000000000000001000
	/* C1 */
	.octa 0xa000
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x1883
	/* C15 */
	.octa 0x1e40
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C21 */
	.octa 0x1798
	/* C24 */
	.octa 0x1000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc800000060020f3400ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400000
final_SP_EL1_value:
	.octa 0xf16000
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000047a0070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x82600f6e // ldr x14, [c27, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400f6e // str x14, [c27, #0]
	ldr x14, =0x40400414
	mrs x27, ELR_EL1
	sub x14, x14, x27
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1db // cvtp c27, x14
	.inst 0xc2ce437b // scvalue c27, c27, x14
	.inst 0x8260036e // ldr c14, [c27, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
