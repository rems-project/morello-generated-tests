.section data0, #alloc, #write
	.zero 1824
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x10, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2256
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x07, 0x10, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x1a, 0x18, 0x00, 0x00
.data
check_data5:
	.byte 0x57, 0xe8, 0xde, 0xc2, 0x41, 0xfc, 0x9f, 0x88, 0x60, 0x82, 0x1e, 0x38, 0x42, 0xf0, 0x58, 0x38
	.byte 0xfa, 0x03, 0x46, 0x78, 0xdd, 0xaf, 0x8d, 0x38, 0x3e, 0xec, 0x50, 0xf8, 0xc0, 0x5f, 0x20, 0x51
	.byte 0x00, 0x00, 0x1f, 0xd6
.data
check_data6:
	.byte 0x1f, 0x51, 0xc1, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data7:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x8000000057821652000000000000181a
	/* C2 */
	.octa 0xc000000040040fd60000000000001800
	/* C19 */
	.octa 0x400000005fec00000000000000001040
	/* C30 */
	.octa 0x80000000000500030000000000001000
final_cap_values:
	/* C0 */
	.octa 0x4007f0
	/* C1 */
	.octa 0x80000000578216520000000000001728
	/* C2 */
	.octa 0x0
	/* C19 */
	.octa 0x400000005fec00000000000000001040
	/* C23 */
	.octa 0x10000000000000001800
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x401007
initial_csp_value:
	.octa 0x80000000000300070000000000420bc0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004810dffa0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword initial_csp_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dee857 // CTHI-C.CR-C Cd:23 Cn:2 1010:1010 opc:11 Rm:30 11000010110:11000010110
	.inst 0x889ffc41 // stlr:aarch64/instrs/memory/ordered Rt:1 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x381e8260 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:19 00:00 imm9:111101000 0:0 opc:00 111000:111000 size:00
	.inst 0x3858f042 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:2 00:00 imm9:110001111 0:0 opc:01 111000:111000 size:00
	.inst 0x784603fa // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:26 Rn:31 00:00 imm9:001100000 0:0 opc:01 111000:111000 size:01
	.inst 0x388dafdd // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:29 Rn:30 11:11 imm9:011011010 0:0 opc:10 111000:111000 size:00
	.inst 0xf850ec3e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:1 11:11 imm9:100001110 0:0 opc:01 111000:111000 size:11
	.inst 0x51205fc0 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:30 imm12:100000010111 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xd61f0000 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 1996
	.inst 0xc2c1511f // CFHI-R.C-C Rd:31 Cn:8 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c210e0
	.zero 1046536
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c2 // ldr c2, [x14, #2]
	.inst 0xc2400dd3 // ldr c19, [x14, #3]
	.inst 0xc24011de // ldr c30, [x14, #4]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_csp_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850038
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010ee // ldr c14, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c7 // ldr c7, [x14, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24005c7 // ldr c7, [x14, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24009c7 // ldr c7, [x14, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400dc7 // ldr c7, [x14, #3]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc24011c7 // ldr c7, [x14, #4]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc24015c7 // ldr c7, [x14, #5]
	.inst 0xc2c7a741 // chkeq c26, c7
	b.ne comparison_fail
	.inst 0xc24019c7 // ldr c7, [x14, #6]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2401dc7 // ldr c7, [x14, #7]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001028
	ldr x1, =check_data0
	ldr x2, =0x00001029
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010da
	ldr x1, =check_data1
	ldr x2, =0x000010db
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001728
	ldr x1, =check_data2
	ldr x2, =0x00001730
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000178f
	ldr x1, =check_data3
	ldr x2, =0x00001790
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001804
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400024
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004007f0
	ldr x1, =check_data6
	ldr x2, =0x004007f8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00420c20
	ldr x1, =check_data7
	ldr x2, =0x00420c22
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
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
