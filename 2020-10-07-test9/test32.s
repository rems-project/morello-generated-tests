.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0xe2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x1a
.data
check_data5:
	.byte 0x3f, 0xe8, 0x14, 0x38, 0x7f, 0x4b, 0x8f, 0xe2, 0x02, 0x30, 0xc3, 0xc2, 0xa0, 0x78, 0x89, 0x02
	.byte 0x21, 0xb3, 0x16, 0x78, 0xa0, 0x76, 0x0e, 0x78, 0x3e, 0x84, 0x4f, 0xd2, 0x0e, 0x7c, 0x81, 0x82
	.byte 0x82, 0x09, 0xc0, 0xda, 0x55, 0x20, 0xbf, 0xc2, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C1 */
	.octa 0x40000000000300070000000000001a00
	/* C5 */
	.octa 0x12003ffffffffffffe45e
	/* C14 */
	.octa 0x0
	/* C21 */
	.octa 0x40000000000100050000000000001000
	/* C25 */
	.octa 0x40000000000100050000000000002059
	/* C27 */
	.octa 0x17ec
final_cap_values:
	/* C0 */
	.octa 0x12003ffffffffffffe200
	/* C1 */
	.octa 0x40000000000300070000000000001a00
	/* C5 */
	.octa 0x12003ffffffffffffe45e
	/* C14 */
	.octa 0x0
	/* C25 */
	.octa 0x40000000000100050000000000002059
	/* C27 */
	.octa 0x17ec
	/* C30 */
	.octa 0xfffe00000007e5ff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3814e83f // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:1 10:10 imm9:101001110 0:0 opc:00 111000:111000 size:00
	.inst 0xe28f4b7f // ALDURSW-R.RI-64 Rt:31 Rn:27 op2:10 imm9:011110100 V:0 op1:10 11100010:11100010
	.inst 0xc2c33002 // SEAL-C.CI-C Cd:2 Cn:0 100:100 form:01 11000010110000110:11000010110000110
	.inst 0x028978a0 // SUB-C.CIS-C Cd:0 Cn:5 imm12:001001011110 sh:0 A:1 00000010:00000010
	.inst 0x7816b321 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:25 00:00 imm9:101101011 0:0 opc:00 111000:111000 size:01
	.inst 0x780e76a0 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:21 01:01 imm9:011100111 0:0 opc:00 111000:111000 size:01
	.inst 0xd24f843e // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:1 imms:100001 immr:001111 N:1 100100:100100 opc:10 sf:1
	.inst 0x82817c0e // ASTRH-R.RRB-32 Rt:14 Rn:0 opc:11 S:1 option:011 Rm:1 0:0 L:0 100000101:100000101
	.inst 0xdac00982 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:2 Rn:12 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2bf2055 // ADD-C.CRI-C Cd:21 Cn:2 imm3:000 option:001 Rm:31 11000010101:11000010101
	.inst 0xc2c21160
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba5 // ldr c5, [x29, #2]
	.inst 0xc2400fae // ldr c14, [x29, #3]
	.inst 0xc24013b5 // ldr c21, [x29, #4]
	.inst 0xc24017b9 // ldr c25, [x29, #5]
	.inst 0xc2401bbb // ldr c27, [x29, #6]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260317d // ldr c29, [c11, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260117d // ldr c29, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003ab // ldr c11, [x29, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24007ab // ldr c11, [x29, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400bab // ldr c11, [x29, #2]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc2400fab // ldr c11, [x29, #3]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc24013ab // ldr c11, [x29, #4]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	.inst 0xc24017ab // ldr c11, [x29, #5]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc2401bab // ldr c11, [x29, #6]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001600
	ldr x1, =check_data1
	ldr x2, =0x00001602
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000018e0
	ldr x1, =check_data2
	ldr x2, =0x000018e4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000194e
	ldr x1, =check_data3
	ldr x2, =0x0000194f
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc4
	ldr x1, =check_data4
	ldr x2, =0x00001fc6
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
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
