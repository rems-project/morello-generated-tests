.section data0, #alloc, #write
	.byte 0x20, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 32
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x00, 0x80, 0x20, 0xb8, 0x01, 0x86, 0xdf, 0xc2, 0x19, 0xd4, 0x65, 0x62, 0xe2, 0xb4, 0x03, 0xb9
	.byte 0xbf, 0x20, 0x7f, 0xf8, 0x13, 0xe4, 0x55, 0xb1, 0xc1, 0x5b, 0x4e, 0x62, 0xfe, 0xff, 0x01, 0x88
	.byte 0xdc, 0x13, 0x00, 0xe2, 0x41, 0x1a, 0xf7, 0x8a, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x1940
	/* C7 */
	.octa 0x101c
	/* C16 */
	.octa 0x60c320000000000000000000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000502200020000000000001010
final_cap_values:
	/* C0 */
	.octa 0x1820
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x1940
	/* C7 */
	.octa 0x101c
	/* C16 */
	.octa 0x60c320000000000000000000
	/* C19 */
	.octa 0x57a820
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000502200020000000000001010
initial_SP_EL3_value:
	.octa 0x50000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000092100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000600100000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000011d0
	.dword 0x00000000000011e0
	.dword 0x00000000000014d0
	.dword 0x00000000000014e0
	.dword initial_cap_values + 96
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb8208000 // swp:aarch64/instrs/memory/atomicops/swp Rt:0 Rn:0 100000:100000 Rs:0 1:1 R:0 A:0 111000:111000 size:10
	.inst 0xc2df8601 // CHKSS-_.CC-C 00001:00001 Cn:16 001:001 opc:00 1:1 Cm:31 11000010110:11000010110
	.inst 0x6265d419 // LDNP-C.RIB-C Ct:25 Rn:0 Ct2:10101 imm7:1001011 L:1 011000100:011000100
	.inst 0xb903b4e2 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:7 imm12:000011101101 opc:00 111001:111001 size:10
	.inst 0xf87f20bf // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:5 00:00 opc:010 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xb155e413 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:19 Rn:0 imm12:010101111001 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x624e5bc1 // LDNP-C.RIB-C Ct:1 Rn:30 Ct2:10110 imm7:0011100 L:1 011000100:011000100
	.inst 0x8801fffe // stlxr:aarch64/instrs/memory/exclusive/single Rt:30 Rn:31 Rt2:11111 o0:1 Rs:1 0:0 L:0 0010000:0010000 size:10
	.inst 0xe20013dc // ASTURB-R.RI-32 Rt:28 Rn:30 op2:00 imm9:000000001 V:0 op1:00 11100010:11100010
	.inst 0x8af71a41 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:18 imm6:000110 Rm:23 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0xc2c210c0
	.zero 1048532
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
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a2 // ldr c2, [x29, #1]
	.inst 0xc2400ba5 // ldr c5, [x29, #2]
	.inst 0xc2400fa7 // ldr c7, [x29, #3]
	.inst 0xc24013b0 // ldr c16, [x29, #4]
	.inst 0xc24017bc // ldr c28, [x29, #5]
	.inst 0xc2401bbe // ldr c30, [x29, #6]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x3085103f
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030dd // ldr c29, [c6, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x826010dd // ldr c29, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x6, #0xf
	and x29, x29, x6
	cmp x29, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003a6 // ldr c6, [x29, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24007a6 // ldr c6, [x29, #1]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400ba6 // ldr c6, [x29, #2]
	.inst 0xc2c6a4a1 // chkeq c5, c6
	b.ne comparison_fail
	.inst 0xc2400fa6 // ldr c6, [x29, #3]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc24013a6 // ldr c6, [x29, #4]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc24017a6 // ldr c6, [x29, #5]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2401ba6 // ldr c6, [x29, #6]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc2401fa6 // ldr c6, [x29, #7]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc24023a6 // ldr c6, [x29, #8]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc24027a6 // ldr c6, [x29, #9]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc2402ba6 // ldr c6, [x29, #10]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001011
	ldr x1, =check_data1
	ldr x2, =0x00001012
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011d0
	ldr x1, =check_data2
	ldr x2, =0x000011f0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013d0
	ldr x1, =check_data3
	ldr x2, =0x000013d4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000014d0
	ldr x1, =check_data4
	ldr x2, =0x000014f0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001940
	ldr x1, =check_data5
	ldr x2, =0x00001948
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
