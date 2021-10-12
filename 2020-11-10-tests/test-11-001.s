.section data0, #alloc, #write
	.zero 80
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3968
.data
check_data0:
	.byte 0x6c, 0x00
.data
check_data1:
	.byte 0x36
.data
check_data2:
	.byte 0x0c, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xc0, 0x23, 0x61, 0x78, 0xa1, 0xab, 0x84, 0x38, 0x43, 0x30, 0xc2, 0xc2
.data
check_data6:
	.byte 0x2c, 0x53, 0xc8, 0x35, 0x3f, 0xfc, 0x41, 0x78, 0x87, 0xb0, 0x5a, 0xe2, 0xe4, 0xbf, 0x50, 0x5c
	.byte 0x22, 0x40, 0xff, 0x38, 0x41, 0x88, 0xdf, 0xc2, 0x3e, 0x9c, 0x0a, 0xf8, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data7:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xa0000000800640070000000000407ff0
	/* C4 */
	.octa 0x40000000600000010000000000002001
	/* C7 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C29 */
	.octa 0x102b
	/* C30 */
	.octa 0x1a07
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x115
	/* C2 */
	.octa 0x6c
	/* C4 */
	.octa 0x40000000600000010000000000002001
	/* C7 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C29 */
	.octa 0x102b
	/* C30 */
	.octa 0x2000800000010007000000000040000c
initial_RDDC_EL0_value:
	.octa 0xc0000000400410030000000000000001
initial_RSP_EL0_value:
	.octa 0x400100020000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000600200010000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword initial_RDDC_EL0_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x786123c0 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:30 00:00 opc:010 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x3884aba1 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:29 10:10 imm9:001001010 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c23043 // BLRR-C-C 00011:00011 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.zero 32740
	.inst 0x35c8532c // cbnz:aarch64/instrs/branch/conditional/compare Rt:12 imm19:1100100001010011001 op:1 011010:011010 sf:0
	.inst 0x7841fc3f // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:1 11:11 imm9:000011111 0:0 opc:01 111000:111000 size:01
	.inst 0xe25ab087 // ASTURH-R.RI-32 Rt:7 Rn:4 op2:00 imm9:110101011 V:0 op1:01 11100010:11100010
	.inst 0x5c50bfe4 // ldr_lit_fpsimd:aarch64/instrs/memory/literal/simdfp Rt:4 imm19:0101000010111111111 011100:011100 opc:01
	.inst 0x38ff4022 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:1 00:00 opc:100 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xc2df8841 // CHKSSU-C.CC-C Cd:1 Cn:2 0010:0010 opc:10 Cm:31 11000010110:11000010110
	.inst 0xf80a9c3e // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:1 11:11 imm9:010101001 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c211c0
	.zero 1015792
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2400c67 // ldr c7, [x3, #3]
	.inst 0xc240106c // ldr c12, [x3, #4]
	.inst 0xc240147d // ldr c29, [x3, #5]
	.inst 0xc240187e // ldr c30, [x3, #6]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851037
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	ldr x3, =initial_RDDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28b4323 // msr RDDC_EL0, c3
	ldr x3, =initial_RSP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28f4163 // msr RSP_EL0, c3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c3 // ldr c3, [c14, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x826011c3 // ldr c3, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x14, #0xf
	and x3, x3, x14
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006e // ldr c14, [x3, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240046e // ldr c14, [x3, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240086e // ldr c14, [x3, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400c6e // ldr c14, [x3, #3]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc240106e // ldr c14, [x3, #4]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc240146e // ldr c14, [x3, #5]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc240186e // ldr c14, [x3, #6]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc2401c6e // ldr c14, [x3, #7]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x14, v4.d[0]
	cmp x3, x14
	b.ne comparison_fail
	ldr x3, =0x0
	mov x14, v4.d[1]
	cmp x3, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001058
	ldr x1, =check_data0
	ldr x2, =0x0000105a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001076
	ldr x1, =check_data1
	ldr x2, =0x00001077
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001118
	ldr x1, =check_data2
	ldr x2, =0x00001120
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a08
	ldr x1, =check_data3
	ldr x2, =0x00001a0a
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fac
	ldr x1, =check_data4
	ldr x2, =0x00001fae
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040000c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00407ff0
	ldr x1, =check_data6
	ldr x2, =0x00408010
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004a97f8
	ldr x1, =check_data7
	ldr x2, =0x004a9800
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
