.section data0, #alloc, #write
	.zero 16
	.byte 0xbd, 0x27, 0x46, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x80, 0x20
	.zero 4064
.data
check_data0:
	.zero 16
	.byte 0xbd, 0x27, 0x46, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x80, 0x20
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x24, 0x11, 0xc4, 0xc2, 0x1f, 0x7c, 0xdf, 0x08, 0xff, 0x9b, 0x95, 0x78, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xdf, 0x82, 0xc1, 0xc2, 0xc1, 0xa3, 0xfb, 0xc2, 0x49, 0x90, 0xc0, 0xc2, 0xbb, 0xa5, 0x79, 0xf9
	.byte 0xd5, 0x6f, 0x51, 0xa2, 0x36, 0x10, 0xc7, 0xc2, 0x9f, 0xc1, 0xce, 0x34
.data
check_data5:
	.zero 3
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004ffffe
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x90000000000100060000000000001000
	/* C13 */
	.octa 0x80000000000700060000000000400100
	/* C22 */
	.octa 0x800000000001000500000000005000a3
	/* C30 */
	.octa 0x80100000500110020000000000002000
final_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004ffffe
	/* C1 */
	.octa 0x80100000500110020000000000002000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C9 */
	.octa 0x1
	/* C13 */
	.octa 0x80000000000700060000000000400100
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x2000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x80100000500110020000000000001160
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c41124 // LDPBR-C.C-C Ct:4 Cn:9 100:100 opc:00 11000010110001000:11000010110001000
	.inst 0x08df7c1f // ldlarb:aarch64/instrs/memory/ordered Rt:31 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x78959bff // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:31 10:10 imm9:101011001 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c210e0
	.zero 403372
	.inst 0xc2c182df // SCTAG-C.CR-C Cd:31 Cn:22 000:000 0:0 10:10 Rm:1 11000010110:11000010110
	.inst 0xc2fba3c1 // BICFLGS-C.CI-C Cd:1 Cn:30 0:0 00:00 imm8:11011101 11000010111:11000010111
	.inst 0xc2c09049 // GCTAG-R.C-C Rd:9 Cn:2 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xf979a5bb // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:27 Rn:13 imm12:111001101001 opc:01 111001:111001 size:11
	.inst 0xa2516fd5 // LDR-C.RIBW-C Ct:21 Rn:30 11:11 imm9:100010110 0:0 opc:01 10100010:10100010
	.inst 0xc2c71036 // RRLEN-R.R-C Rd:22 Rn:1 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x34cec19f // cbz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:1100111011000001100 op:0 011010:011010 sf:0
	.zero 645160
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a62 // ldr c2, [x19, #2]
	.inst 0xc2400e69 // ldr c9, [x19, #3]
	.inst 0xc240126d // ldr c13, [x19, #4]
	.inst 0xc2401676 // ldr c22, [x19, #5]
	.inst 0xc2401a7e // ldr c30, [x19, #6]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010f3 // ldr c19, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400267 // ldr c7, [x19, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400667 // ldr c7, [x19, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400a67 // ldr c7, [x19, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400e67 // ldr c7, [x19, #3]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2401267 // ldr c7, [x19, #4]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401667 // ldr c7, [x19, #5]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401a67 // ldr c7, [x19, #6]
	.inst 0xc2c7a6a1 // chkeq c21, c7
	b.ne comparison_fail
	.inst 0xc2401e67 // ldr c7, [x19, #7]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2402267 // ldr c7, [x19, #8]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402667 // ldr c7, [x19, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
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
	ldr x0, =0x00001160
	ldr x1, =check_data1
	ldr x2, =0x00001170
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00407448
	ldr x1, =check_data3
	ldr x2, =0x00407450
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004627bc
	ldr x1, =check_data4
	ldr x2, =0x004627d8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffc
	ldr x1, =check_data5
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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
