.section text0, #alloc, #execinstr
test_start:
	.inst 0x7c0c039d // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:29 Rn:28 00:00 imm9:011000000 0:0 opc:00 111100:111100 size:01
	.inst 0xc2d8431b // SCVALUE-C.CR-C Cd:27 Cn:24 000:000 opc:10 0:0 Rm:24 11000010110:11000010110
	.inst 0x82c1e014 // ALDRB-R.RRB-B Rt:20 Rn:0 opc:00 S:0 option:111 Rm:1 0:0 L:1 100000101:100000101
	.inst 0xc2de27cd // CPYTYPE-C.C-C Cd:13 Cn:30 001:001 opc:01 0:0 Cm:30 11000010110:11000010110
	.inst 0x78c9a480 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:4 01:01 imm9:010011010 0:0 opc:11 111000:111000 size:01
	.zero 1004
	.inst 0xc2dbc3bd // 0xc2dbc3bd
	.inst 0xa2120fe0 // 0xa2120fe0
	.inst 0xc2c21121 // 0xc2c21121
	.inst 0x4b5717bb // 0x4b5717bb
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e4 // ldr c4, [x15, #2]
	.inst 0xc2400de9 // ldr c9, [x15, #3]
	.inst 0xc24011f8 // ldr c24, [x15, #4]
	.inst 0xc24015fc // ldr c28, [x15, #5]
	.inst 0xc24019fd // ldr c29, [x15, #6]
	.inst 0xc2401dfe // ldr c30, [x15, #7]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x15, =0x4000000
	msr SPSR_EL3, x15
	ldr x15, =initial_SP_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c410f // msr CSP_EL1, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0x3c0000
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
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012cf // ldr c15, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x22, #0xf
	and x15, x15, x22
	cmp x15, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f6 // ldr c22, [x15, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24005f6 // ldr c22, [x15, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24009f6 // ldr c22, [x15, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400df6 // ldr c22, [x15, #3]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc24011f6 // ldr c22, [x15, #4]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc24015f6 // ldr c22, [x15, #5]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc24019f6 // ldr c22, [x15, #6]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2401df6 // ldr c22, [x15, #7]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc24021f6 // ldr c22, [x15, #8]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc24025f6 // ldr c22, [x15, #9]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x22, v29.d[0]
	cmp x15, x22
	b.ne comparison_fail
	ldr x15, =0x0
	mov x22, v29.d[1]
	cmp x15, x22
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc29c4116 // mrs c22, CSP_EL1
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	ldr x22, =esr_el1_dump_address
	ldr x22, [x22]
	mov x15, 0x83
	orr x22, x22, x15
	ldr x15, =0x920000a3
	cmp x15, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001114
	ldr x1, =check_data1
	ldr x2, =0x00001116
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040fffe
	ldr x1, =check_data4
	ldr x2, =0x4040ffff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x9d, 0x03, 0x0c, 0x7c, 0x1b, 0x43, 0xd8, 0xc2, 0x14, 0xe0, 0xc1, 0x82, 0xcd, 0x27, 0xde, 0xc2
	.byte 0x80, 0xa4, 0xc9, 0x78
.data
check_data3:
	.byte 0xbd, 0xc3, 0xdb, 0xc2, 0xe0, 0x0f, 0x12, 0xa2, 0x21, 0x11, 0xc2, 0xc2, 0xbb, 0x17, 0x57, 0x4b
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000000000000000000000
	/* C1 */
	.octa 0x4040fffe
	/* C4 */
	.octa 0x80000000000780070000000000009685
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0x420040040000000000002001
	/* C28 */
	.octa 0x40000000000600050000000000001054
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x40000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x4000000000000000000000000000
	/* C1 */
	.octa 0x4040fffe
	/* C4 */
	.octa 0x80000000000780070000000000009685
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C13 */
	.octa 0x4ffffffffffffffff
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x420040040000000000002001
	/* C28 */
	.octa 0x40000000000600050000000000001054
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x40000000000000000
initial_SP_EL1_value:
	.octa 0x48000000020140050000000000001e10
initial_DDC_EL0_value:
	.octa 0x80000000000400070000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400001
final_SP_EL1_value:
	.octa 0x48000000020140050000000000001010
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600100000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
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
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x82600ecf // ldr x15, [c22, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400ecf // str x15, [c22, #0]
	ldr x15, =0x40400414
	mrs x22, ELR_EL1
	sub x15, x15, x22
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f6 // cvtp c22, x15
	.inst 0xc2cf42d6 // scvalue c22, c22, x15
	.inst 0x826002cf // ldr c15, [c22, #0]
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
