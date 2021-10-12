.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xa0, 0x85, 0xd9, 0xc2
.data
check_data3:
	.byte 0xe2, 0x26, 0xcf, 0x1a, 0xb0, 0xcf, 0x0f, 0xf8, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.byte 0x80, 0x0f, 0x00, 0x00
.data
check_data5:
	.byte 0x41, 0x20, 0x8a, 0x38, 0xc9, 0xaa, 0x18, 0x78, 0x81, 0xfd, 0x7f, 0x42, 0x1e, 0x54, 0x06, 0xa2
	.byte 0x2d, 0x54, 0x90, 0x29, 0x20, 0x00, 0x01, 0x5a, 0x82, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C2 */
	.octa 0x1010
	/* C4 */
	.octa 0x20008000000100070000000000400400
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x80000000000730070000000000403ffc
	/* C13 */
	.octa 0x204080026000e7f80000000000440000
	/* C16 */
	.octa 0xc2000000
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x1076
	/* C25 */
	.octa 0x400002000000000000000000000f04
	/* C30 */
	.octa 0x200000000
final_cap_values:
	/* C1 */
	.octa 0x1000
	/* C4 */
	.octa 0x20008000000100070000000000400400
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x80000000000730070000000000403ffc
	/* C13 */
	.octa 0x204080026000e7f80000000000440000
	/* C16 */
	.octa 0xc2000000
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x1076
	/* C25 */
	.octa 0x400002000000000000000000000f04
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x200000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000000100050000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 144
	.dword initial_cap_values + 160
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d985a0 // BRS-C.C-C 00000:00000 Cn:13 001:001 opc:00 1:1 Cm:25 11000010110:11000010110
	.zero 1020
	.inst 0x1acf26e2 // lsrv:aarch64/instrs/integer/shift/variable Rd:2 Rn:23 op2:01 0010:0010 Rm:15 0011010110:0011010110 sf:0
	.inst 0xf80fcfb0 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:16 Rn:29 11:11 imm9:011111100 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c210e0
	.zero 15344
	.inst 0x00000f80
	.zero 245760
	.inst 0x388a2041 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:2 00:00 imm9:010100010 0:0 opc:10 111000:111000 size:00
	.inst 0x7818aac9 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:22 10:10 imm9:110001010 0:0 opc:00 111000:111000 size:01
	.inst 0x427ffd81 // ALDAR-R.R-32 Rt:1 Rn:12 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xa206541e // STR-C.RIAW-C Ct:30 Rn:0 01:01 imm9:001100101 0:0 opc:00 10100010:10100010
	.inst 0x2990542d // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:13 Rn:1 Rt2:10101 imm7:0100000 L:0 1010011:1010011 opc:00
	.inst 0x5a010020 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:1 000000:000000 Rm:1 11010000:11010000 S:0 op:1 sf:0
	.inst 0xc2c21082 // BRS-C-C 00010:00010 Cn:4 100:100 opc:00 11000010110000100:11000010110000100
	.zero 786404
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2400c69 // ldr c9, [x3, #3]
	.inst 0xc240106c // ldr c12, [x3, #4]
	.inst 0xc240146d // ldr c13, [x3, #5]
	.inst 0xc2401870 // ldr c16, [x3, #6]
	.inst 0xc2401c75 // ldr c21, [x3, #7]
	.inst 0xc2402076 // ldr c22, [x3, #8]
	.inst 0xc2402479 // ldr c25, [x3, #9]
	.inst 0xc240287e // ldr c30, [x3, #10]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e3 // ldr c3, [c7, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x826010e3 // ldr c3, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400067 // ldr c7, [x3, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400467 // ldr c7, [x3, #1]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400867 // ldr c7, [x3, #2]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2400c67 // ldr c7, [x3, #3]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401067 // ldr c7, [x3, #4]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401467 // ldr c7, [x3, #5]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc2401867 // ldr c7, [x3, #6]
	.inst 0xc2c7a6a1 // chkeq c21, c7
	b.ne comparison_fail
	.inst 0xc2401c67 // ldr c7, [x3, #7]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2402067 // ldr c7, [x3, #8]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2402467 // ldr c7, [x3, #9]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402867 // ldr c7, [x3, #10]
	.inst 0xc2c7a7c1 // chkeq c30, c7
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
	ldr x0, =0x000010b2
	ldr x1, =check_data1
	ldr x2, =0x000010b3
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400400
	ldr x1, =check_data3
	ldr x2, =0x0040040c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00403ffc
	ldr x1, =check_data4
	ldr x2, =0x00404000
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00440000
	ldr x1, =check_data5
	ldr x2, =0x0044001c
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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
