.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xc0, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x84, 0x0f, 0x04, 0x62, 0x00, 0x00, 0x00, 0x80
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x9f, 0xaa, 0x8a, 0xb0, 0x3f, 0x00, 0x1e, 0xba, 0x9f, 0x57, 0x13, 0xa8, 0xa6, 0xb0, 0xc0, 0xc2
	.byte 0x40, 0x03, 0x1f, 0xd6
.data
check_data4:
	.byte 0xfe, 0xbf, 0x20, 0xea, 0x42, 0x7c, 0xc1, 0x9b, 0xc0, 0x9b, 0x0f, 0xa2, 0xec, 0xb1, 0xfc, 0xc2
	.byte 0x16, 0x1c, 0x15, 0xe2, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000062040f8400000000000010c0
	/* C5 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x447108
	/* C28 */
	.octa 0x1648
final_cap_values:
	/* C0 */
	.octa 0x8000000062040f8400000000000010c0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0xe500000000000000
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x447108
	/* C28 */
	.octa 0x1648
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4c00000001c6000f0000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb08aaa9f // ADRP-C.I-C Rd:31 immhi:000101010101010100 P:1 10000:10000 immlo:01 op:1
	.inst 0xba1e003f // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:1 000000:000000 Rm:30 11010000:11010000 S:1 op:0 sf:1
	.inst 0xa813579f // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:31 Rn:28 Rt2:10101 imm7:0100110 L:0 1010000:1010000 opc:10
	.inst 0xc2c0b0a6 // GCSEAL-R.C-C Rd:6 Cn:5 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xd61f0340 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:26 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 291060
	.inst 0xea20bffe // bics:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:31 imm6:101111 Rm:0 N:1 shift:00 01010:01010 opc:11 sf:1
	.inst 0x9bc17c42 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:2 Rn:2 Ra:11111 0:0 Rm:1 10:10 U:1 10011011:10011011
	.inst 0xa20f9bc0 // STTR-C.RIB-C Ct:0 Rn:30 10:10 imm9:011111001 0:0 opc:00 10100010:10100010
	.inst 0xc2fcb1ec // EORFLGS-C.CI-C Cd:12 Cn:15 0:0 10:10 imm8:11100101 11000010111:11000010111
	.inst 0xe2151c16 // ALDURSB-R.RI-32 Rt:22 Rn:0 op2:11 imm9:101010001 V:0 op1:00 11100010:11100010
	.inst 0xc2c211c0
	.zero 757472
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400765 // ldr c5, [x27, #1]
	.inst 0xc2400b6f // ldr c15, [x27, #2]
	.inst 0xc2400f75 // ldr c21, [x27, #3]
	.inst 0xc240137a // ldr c26, [x27, #4]
	.inst 0xc240177c // ldr c28, [x27, #5]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031db // ldr c27, [c14, #3]
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	.inst 0x826011db // ldr c27, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x14, #0xf
	and x27, x27, x14
	cmp x27, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240036e // ldr c14, [x27, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240076e // ldr c14, [x27, #1]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc2400b6e // ldr c14, [x27, #2]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc2400f6e // ldr c14, [x27, #3]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc240136e // ldr c14, [x27, #4]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc240176e // ldr c14, [x27, #5]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc2401b6e // ldr c14, [x27, #6]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc2401f6e // ldr c14, [x27, #7]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc240236e // ldr c14, [x27, #8]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc240276e // ldr c14, [x27, #9]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001011
	ldr x1, =check_data0
	ldr x2, =0x00001012
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001790
	ldr x1, =check_data1
	ldr x2, =0x000017a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f78
	ldr x1, =check_data2
	ldr x2, =0x00001f88
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
	ldr x0, =0x00447108
	ldr x1, =check_data4
	ldr x2, =0x00447120
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
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
