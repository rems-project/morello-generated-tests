.section data0, #alloc, #write
	.zero 3760
	.byte 0xf1, 0xff, 0x43, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x03, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 320
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x03, 0x00
.data
check_data4:
	.zero 16
	.byte 0xf1, 0xff, 0x43, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x03, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data5:
	.byte 0x0d, 0x7c, 0x5f, 0x42, 0x01, 0xea, 0x20, 0x39, 0x4e, 0xfc, 0x9f, 0x48, 0xff, 0x33, 0xc4, 0xc2
.data
check_data6:
	.byte 0xe6, 0x7f, 0x15, 0xa2, 0xde, 0x23, 0xc1, 0x9a, 0x42, 0xe0, 0xc2, 0xc2, 0x22, 0xf6, 0xa8, 0xd0
	.byte 0x02, 0xf0, 0x81, 0x82, 0x02, 0xf0, 0xc5, 0xc2, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4000000040040cb80000000000001ab0
	/* C6 */
	.octa 0x2
	/* C14 */
	.octa 0x3
	/* C16 */
	.octa 0x40000000000100070000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x2
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x3
	/* C16 */
	.octa 0x40000000000100070000000000001000
	/* C30 */
	.octa 0x400011
initial_csp_value:
	.octa 0xd0000000200140050000000000001ea0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000001007100700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001eb0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x425f7c0d // ALDAR-C.R-C Ct:13 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x3920ea01 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:16 imm12:100000111010 opc:00 111001:111001 size:00
	.inst 0x489ffc4e // stlrh:aarch64/instrs/memory/ordered Rt:14 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c433ff // LDPBLR-C.C-C Ct:31 Cn:31 100:100 opc:01 11000010110001000:11000010110001000
	.zero 262112
	.inst 0xa2157fe6 // STR-C.RIBW-C Ct:6 Rn:31 11:11 imm9:101010111 0:0 opc:00 10100010:10100010
	.inst 0x9ac123de // lslv:aarch64/instrs/integer/shift/variable Rd:30 Rn:30 op2:00 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0xc2c2e042 // SCFLGS-C.CR-C Cd:2 Cn:2 111000:111000 Rm:2 11000010110:11000010110
	.inst 0xd0a8f622 // ADRP-C.IP-C Rd:2 immhi:010100011110110001 P:1 10000:10000 immlo:10 op:1
	.inst 0x8281f002 // ASTRB-R.RRB-B Rt:2 Rn:0 opc:00 S:1 option:111 Rm:1 0:0 L:0 100000101:100000101
	.inst 0xc2c5f002 // CVTPZ-C.R-C Cd:2 Rn:0 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xc2c21080
	.zero 786420
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400962 // ldr c2, [x11, #2]
	.inst 0xc2400d66 // ldr c6, [x11, #3]
	.inst 0xc240116e // ldr c14, [x11, #4]
	.inst 0xc2401570 // ldr c16, [x11, #5]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_csp_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850038
	msr SCTLR_EL3, x11
	ldr x11, =0x84
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260308b // ldr c11, [c4, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x8260108b // ldr c11, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400164 // ldr c4, [x11, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400564 // ldr c4, [x11, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400964 // ldr c4, [x11, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400d64 // ldr c4, [x11, #3]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2401164 // ldr c4, [x11, #4]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc2401564 // ldr c4, [x11, #5]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc2401964 // ldr c4, [x11, #6]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2401d64 // ldr c4, [x11, #7]
	.inst 0xc2c4a7c1 // chkeq c30, c4
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
	ldr x0, =0x00001410
	ldr x1, =check_data1
	ldr x2, =0x00001420
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000183a
	ldr x1, =check_data2
	ldr x2, =0x0000183b
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ab0
	ldr x1, =check_data3
	ldr x2, =0x00001ab2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ea0
	ldr x1, =check_data4
	ldr x2, =0x00001ec0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0043fff0
	ldr x1, =check_data6
	ldr x2, =0x0044000c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
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
