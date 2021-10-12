.section data0, #alloc, #write
	.zero 1776
	.byte 0x20, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 2304
.data
check_data0:
	.byte 0x20, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xe2, 0x6b, 0x59, 0x39, 0xe3, 0x03, 0xc0, 0xc2, 0xee, 0xbb, 0x04, 0xe2, 0x23, 0x50, 0xc2, 0xc2
.data
check_data4:
	.byte 0xf2, 0x43, 0x6d, 0xa8, 0x17, 0xbb, 0x08, 0xe2, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 1
.data
check_data8:
	.byte 0xde, 0x7b, 0x4f, 0xb8, 0x00, 0xe4, 0x10, 0x02, 0x3e, 0xba, 0xcd, 0x92, 0x00, 0xf3, 0xdd, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8006400100fffffffffffc00
	/* C1 */
	.octa 0x20000000a0050003000000000047c019
	/* C24 */
	.octa 0x90100000000100050000000000001800
	/* C30 */
	.octa 0x80000000000100050000000000001f01
final_cap_values:
	/* C0 */
	.octa 0x800640010100000000000039
	/* C1 */
	.octa 0x20000000a0050003000000000047c019
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x80000000000a00050000000000402000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x90100000000100050000000000001800
	/* C30 */
	.octa 0xffff922effffffff
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000402000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000016f0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x39596be2 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:31 imm12:011001011010 opc:01 111001:111001 size:00
	.inst 0xc2c003e3 // SCBNDS-C.CR-C Cd:3 Cn:31 000:000 opc:00 0:0 Rm:0 11000010110:11000010110
	.inst 0xe204bbee // ALDURSB-R.RI-64 Rt:14 Rn:31 op2:10 imm9:001001011 V:0 op1:00 11100010:11100010
	.inst 0xc2c25023 // RETR-C-C 00011:00011 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.zero 16
	.inst 0xa86d43f2 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:18 Rn:31 Rt2:10000 imm7:1011010 L:1 1010000:1010000 opc:10
	.inst 0xe208bb17 // ALDURSB-R.RI-64 Rt:23 Rn:24 op2:10 imm9:010001011 V:0 op1:00 11100010:11100010
	.inst 0xc2c212a0
	.zero 507884
	.inst 0xb84f7bde // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:30 10:10 imm9:011110111 0:0 opc:01 111000:111000 size:10
	.inst 0x0210e400 // ADD-C.CIS-C Cd:0 Cn:0 imm12:010000111001 sh:0 A:0 00000010:00000010
	.inst 0x92cdba3e // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:30 imm16:0110110111010001 hw:10 100101:100101 opc:00 sf:1
	.inst 0xc2ddf300 // BR-CI-C 0:0 0000:0000 Cn:24 100:100 imm7:1101111 110000101101:110000101101
	.zero 540632
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008f8 // ldr c24, [x7, #2]
	.inst 0xc2400cfe // ldr c30, [x7, #3]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850038
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032a7 // ldr c7, [c21, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x826012a7 // ldr c7, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f5 // ldr c21, [x7, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24004f5 // ldr c21, [x7, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24008f5 // ldr c21, [x7, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400cf5 // ldr c21, [x7, #3]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc24010f5 // ldr c21, [x7, #4]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc24014f5 // ldr c21, [x7, #5]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc24018f5 // ldr c21, [x7, #6]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc2401cf5 // ldr c21, [x7, #7]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc24020f5 // ldr c21, [x7, #8]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc24024f5 // ldr c21, [x7, #9]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000016f0
	ldr x1, =check_data0
	ldr x2, =0x00001700
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000188b
	ldr x1, =check_data1
	ldr x2, =0x0000188c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff8
	ldr x1, =check_data2
	ldr x2, =0x00001ffc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400020
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00401ed0
	ldr x1, =check_data5
	ldr x2, =0x00401ee0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040204b
	ldr x1, =check_data6
	ldr x2, =0x0040204c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0040265a
	ldr x1, =check_data7
	ldr x2, =0x0040265b
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x0047c018
	ldr x1, =check_data8
	ldr x2, =0x0047c028
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
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
