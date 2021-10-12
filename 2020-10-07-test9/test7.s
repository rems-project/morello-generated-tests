.section data0, #alloc, #write
	.zero 2032
	.byte 0x00, 0x00, 0x04, 0x80, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x01, 0xf0, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xc4, 0x00, 0x78, 0x00, 0x80, 0x00, 0x20
	.zero 2032
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x00, 0x04, 0x80, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x01, 0xf0, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xc4, 0x00, 0x78, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x17, 0x59, 0x5b, 0x78, 0xc2, 0x33, 0xc4, 0xc2
.data
check_data6:
	.byte 0xf4, 0x63, 0xde, 0xc2, 0xd4, 0x30, 0xc0, 0xc2, 0xe2, 0xc3, 0x15, 0xe2, 0x4b, 0x03, 0x08, 0xe2
	.byte 0xc3, 0x41, 0xdb, 0xc2, 0xe5, 0x53, 0x83, 0xe2, 0x41, 0xb0, 0xc5, 0xc2, 0x7f, 0xf3, 0xc0, 0xc2
	.byte 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x180060080000000000001
	/* C8 */
	.octa 0x1044
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x22086204f0000000000400000
	/* C26 */
	.octa 0x13f8
	/* C27 */
	.octa 0x1
	/* C30 */
	.octa 0x901000000003000700000000000017f0
final_cap_values:
	/* C1 */
	.octa 0x200080007800c401000000048044c401
	/* C2 */
	.octa 0x480040000
	/* C3 */
	.octa 0x22086204f0000000000000001
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x180060080000000000001
	/* C8 */
	.octa 0x1044
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x22086204f0000000000400000
	/* C20 */
	.octa 0xffffffffffffffff
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x13f8
	/* C27 */
	.octa 0x1
	/* C30 */
	.octa 0x200080000000a0080000000000400008
initial_SP_EL3_value:
	.octa 0x8002200d0000000000001044
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004102044700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000017f0
	.dword 0x0000000000001800
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x785b5917 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:23 Rn:8 10:10 imm9:110110101 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c433c2 // LDPBLR-C.C-C Ct:2 Cn:30 100:100 opc:01 11000010110001000:11000010110001000
	.zero 61432
	.inst 0xc2de63f4 // SCOFF-C.CR-C Cd:20 Cn:31 000:000 opc:11 0:0 Rm:30 11000010110:11000010110
	.inst 0xc2c030d4 // GCLEN-R.C-C Rd:20 Cn:6 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xe215c3e2 // ASTURB-R.RI-32 Rt:2 Rn:31 op2:00 imm9:101011100 V:0 op1:00 11100010:11100010
	.inst 0xe208034b // ASTURB-R.RI-32 Rt:11 Rn:26 op2:00 imm9:010000000 V:0 op1:00 11100010:11100010
	.inst 0xc2db41c3 // SCVALUE-C.CR-C Cd:3 Cn:14 000:000 opc:10 0:0 Rm:27 11000010110:11000010110
	.inst 0xe28353e5 // ASTUR-R.RI-32 Rt:5 Rn:31 op2:00 imm9:000110101 V:0 op1:10 11100010:11100010
	.inst 0xc2c5b041 // CVTP-C.R-C Cd:1 Rn:2 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c0f37f // GCTYPE-R.C-C Rd:31 Cn:27 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc2c210e0
	.zero 987100
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400185 // ldr c5, [x12, #0]
	.inst 0xc2400586 // ldr c6, [x12, #1]
	.inst 0xc2400988 // ldr c8, [x12, #2]
	.inst 0xc2400d8b // ldr c11, [x12, #3]
	.inst 0xc240118e // ldr c14, [x12, #4]
	.inst 0xc240159a // ldr c26, [x12, #5]
	.inst 0xc240199b // ldr c27, [x12, #6]
	.inst 0xc2401d9e // ldr c30, [x12, #7]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	ldr x12, =0xc
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030ec // ldr c12, [c7, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826010ec // ldr c12, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400187 // ldr c7, [x12, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400587 // ldr c7, [x12, #1]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400987 // ldr c7, [x12, #2]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400d87 // ldr c7, [x12, #3]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc2401187 // ldr c7, [x12, #4]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc2401587 // ldr c7, [x12, #5]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc2401987 // ldr c7, [x12, #6]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401d87 // ldr c7, [x12, #7]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2402187 // ldr c7, [x12, #8]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2402587 // ldr c7, [x12, #9]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2402987 // ldr c7, [x12, #10]
	.inst 0xc2c7a741 // chkeq c26, c7
	b.ne comparison_fail
	.inst 0xc2402d87 // ldr c7, [x12, #11]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2403187 // ldr c7, [x12, #12]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000013e7
	ldr x1, =check_data0
	ldr x2, =0x000013e8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001440
	ldr x1, =check_data1
	ldr x2, =0x00001442
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014c0
	ldr x1, =check_data2
	ldr x2, =0x000014c4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017f0
	ldr x1, =check_data3
	ldr x2, =0x00001810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000018bf
	ldr x1, =check_data4
	ldr x2, =0x000018c0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400008
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040f000
	ldr x1, =check_data6
	ldr x2, =0x0040f024
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
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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
