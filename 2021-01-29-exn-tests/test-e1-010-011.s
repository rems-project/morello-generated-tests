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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c4 // ldr c4, [x14, #2]
	.inst 0xc2400dc9 // ldr c9, [x14, #3]
	.inst 0xc24011d8 // ldr c24, [x14, #4]
	.inst 0xc24015dc // ldr c28, [x14, #5]
	.inst 0xc24019dd // ldr c29, [x14, #6]
	.inst 0xc2401dde // ldr c30, [x14, #7]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x14, =0x4000000
	msr SPSR_EL3, x14
	ldr x14, =initial_SP_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc28c410e // msr CSP_EL1, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0x3c0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x0
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260106e // ldr c14, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
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
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x3, #0xf
	and x14, x14, x3
	cmp x14, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c3 // ldr c3, [x14, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005c3 // ldr c3, [x14, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24009c3 // ldr c3, [x14, #2]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2400dc3 // ldr c3, [x14, #3]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc24011c3 // ldr c3, [x14, #4]
	.inst 0xc2c3a5a1 // chkeq c13, c3
	b.ne comparison_fail
	.inst 0xc24015c3 // ldr c3, [x14, #5]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc24019c3 // ldr c3, [x14, #6]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc2401dc3 // ldr c3, [x14, #7]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc24021c3 // ldr c3, [x14, #8]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc24025c3 // ldr c3, [x14, #9]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x3, v29.d[0]
	cmp x14, x3
	b.ne comparison_fail
	ldr x14, =0x0
	mov x3, v29.d[1]
	cmp x14, x3
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_SP_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc29c4103 // mrs c3, CSP_EL1
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x14, 0x83
	orr x3, x3, x14
	ldr x14, =0x920000a3
	cmp x14, x3
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
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x000010e2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffd
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
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x9d, 0x03, 0x0c, 0x7c, 0x1b, 0x43, 0xd8, 0xc2, 0x14, 0xe0, 0xc1, 0x82, 0xcd, 0x27, 0xde, 0xc2
	.byte 0x80, 0xa4, 0xc9, 0x78
.data
check_data4:
	.byte 0xbd, 0xc3, 0xdb, 0xc2, 0xe0, 0x0f, 0x12, 0xa2, 0x21, 0x11, 0xc2, 0xc2, 0xbb, 0x17, 0x57, 0x4b
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1ffd
	/* C4 */
	.octa 0x800000000001a00fc008000000000001
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0x300070000e00028008000
	/* C28 */
	.octa 0x40000000000500030000000000001020
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x30000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1ffd
	/* C4 */
	.octa 0x800000000001a00fc008000000000001
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C13 */
	.octa 0x3ffffffffffffffff
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x300070000e00028008000
	/* C28 */
	.octa 0x40000000000500030000000000001020
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x30000000000000000
initial_SP_EL1_value:
	.octa 0x400000004003000a0000000000001e00
initial_DDC_EL0_value:
	.octa 0x800000000002000700f1800000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000f01e0000000040400001
final_SP_EL1_value:
	.octa 0x400000004003000a0000000000001000
final_PCC_value:
	.octa 0x200080005000f01e0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x82600c6e // ldr x14, [c3, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c6e // str x14, [c3, #0]
	ldr x14, =0x40400414
	mrs x3, ELR_EL1
	sub x14, x14, x3
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c3 // cvtp c3, x14
	.inst 0xc2ce4063 // scvalue c3, c3, x14
	.inst 0x8260006e // ldr c14, [c3, #0]
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
