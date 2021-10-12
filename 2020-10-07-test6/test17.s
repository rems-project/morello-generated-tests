.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x20, 0x00, 0x00
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0x3f, 0x58, 0x6b, 0x62, 0xa9, 0x59, 0x41, 0x3a, 0x27, 0x10, 0x45, 0x7a, 0xe1, 0xa3, 0x06, 0xb8
	.byte 0x00, 0xa4, 0xc9, 0xc2
.data
check_data4:
	.byte 0x90, 0x78, 0xda, 0xc2, 0x8d, 0xeb, 0xcf, 0xc2, 0x42, 0x30, 0xc2, 0xc2
.data
check_data5:
	.byte 0x5f, 0x7b, 0x81, 0x4a, 0x61, 0x2e, 0x3f, 0x62, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x204080020007c00f0000000000400201
	/* C1 */
	.octa 0x4000000000000000000000002000
	/* C2 */
	.octa 0x20008000900400070000000000402005
	/* C4 */
	.octa 0x2400000000000000000000000
	/* C9 */
	.octa 0x400002000000000000000000000000
	/* C11 */
	.octa 0x4000000000000000000000000000
	/* C13 */
	.octa 0xffffffff
	/* C19 */
	.octa 0x480000004007000f0000000000001020
final_cap_values:
	/* C0 */
	.octa 0x204080020007c00f0000000000400201
	/* C1 */
	.octa 0x4000000000000000000000002000
	/* C2 */
	.octa 0x20008000900400070000000000402005
	/* C4 */
	.octa 0x2400000000000000000000000
	/* C9 */
	.octa 0x400002000000000000000000000000
	/* C11 */
	.octa 0x4000000000000000000000000000
	/* C16 */
	.octa 0x2434000000000000000000000
	/* C19 */
	.octa 0x480000004007000f0000000000001020
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x204080000007c00f000000000040020d
initial_SP_EL3_value:
	.octa 0x100e
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100180060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000180060080000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001d60
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x626b583f // LDNP-C.RIB-C Ct:31 Rn:1 Ct2:10110 imm7:1010110 L:1 011000100:011000100
	.inst 0x3a4159a9 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1001 0:0 Rn:13 10:10 cond:0101 imm5:00001 111010010:111010010 op:0 sf:0
	.inst 0x7a451027 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0111 0:0 Rn:1 00:00 cond:0001 Rm:5 111010010:111010010 op:1 sf:0
	.inst 0xb806a3e1 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:31 00:00 imm9:001101010 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c9a400 // BLRS-C.C-C 00000:00000 Cn:0 001:001 opc:01 1:1 Cm:9 11000010110:11000010110
	.zero 492
	.inst 0xc2da7890 // SCBNDS-C.CI-S Cd:16 Cn:4 1110:1110 S:1 imm6:110100 11000010110:11000010110
	.inst 0xc2cfeb8d // CTHI-C.CR-C Cd:13 Cn:28 1010:1010 opc:11 Rm:15 11000010110:11000010110
	.inst 0xc2c23042 // BLRS-C-C 00010:00010 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.zero 7672
	.inst 0x4a817b5f // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:26 imm6:011110 Rm:1 N:0 shift:10 01010:01010 opc:10 sf:0
	.inst 0x623f2e61 // STNP-C.RIB-C Ct:1 Rn:19 Ct2:01011 imm7:1111110 L:0 011000100:011000100
	.inst 0xc2c21060
	.zero 1040368
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	.inst 0xc24009c2 // ldr c2, [x14, #2]
	.inst 0xc2400dc4 // ldr c4, [x14, #3]
	.inst 0xc24011c9 // ldr c9, [x14, #4]
	.inst 0xc24015cb // ldr c11, [x14, #5]
	.inst 0xc24019cd // ldr c13, [x14, #6]
	.inst 0xc2401dd3 // ldr c19, [x14, #7]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306e // ldr c14, [c3, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260106e // ldr c14, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x3, #0xf
	and x14, x14, x3
	cmp x14, #0x7
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
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400dc3 // ldr c3, [x14, #3]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc24011c3 // ldr c3, [x14, #4]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc24015c3 // ldr c3, [x14, #5]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc24019c3 // ldr c3, [x14, #6]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2401dc3 // ldr c3, [x14, #7]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc24021c3 // ldr c3, [x14, #8]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc24025c3 // ldr c3, [x14, #9]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc24029c3 // ldr c3, [x14, #10]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001078
	ldr x1, =check_data1
	ldr x2, =0x0000107c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001d60
	ldr x1, =check_data2
	ldr x2, =0x00001d80
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400200
	ldr x1, =check_data4
	ldr x2, =0x0040020c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00402004
	ldr x1, =check_data5
	ldr x2, =0x00402010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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

	.balign 128
vector_table:
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
