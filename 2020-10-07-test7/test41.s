.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.byte 0xd9, 0x78, 0x22, 0x9b, 0x00, 0x0e, 0xcd, 0x9a, 0x02, 0x53, 0xc2, 0xc2, 0x26, 0x9c, 0x0a, 0xa2
	.byte 0xd4, 0x03, 0xc1, 0xe2, 0xe8, 0xe7, 0x9f, 0x38, 0x2a, 0x1b, 0xd8, 0xc2, 0xde, 0x23, 0xa2, 0xc2
	.byte 0xc1, 0x47, 0xce, 0xc2, 0xf3, 0xac, 0xd4, 0xd8, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1200
	/* C2 */
	.octa 0xe000
	/* C6 */
	.octa 0x4000000000000000000000100000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0xffffffffffffffff
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x200080008007000f000000000040000c
	/* C30 */
	.octa 0x40000000580108020000000000000ff0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4000000058010802000000000000eff0
	/* C2 */
	.octa 0xe000
	/* C6 */
	.octa 0x4000000000000000000000100000
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0xffffffffffffffff
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x200080008007000f000000000040000c
	/* C25 */
	.octa 0xe00000ff0
	/* C30 */
	.octa 0x4000000058010802000000000000eff0
initial_SP_EL3_value:
	.octa 0x1022
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001ffb00070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000005ca2000000fffffffffff801
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 48
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b2278d9 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:25 Rn:6 Ra:30 o0:0 Rm:2 01:01 U:0 10011011:10011011
	.inst 0x9acd0e00 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:0 Rn:16 o1:1 00001:00001 Rm:13 0011010110:0011010110 sf:1
	.inst 0xc2c25302 // RETS-C-C 00010:00010 Cn:24 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0xa20a9c26 // STR-C.RIBW-C Ct:6 Rn:1 11:11 imm9:010101001 0:0 opc:00 10100010:10100010
	.inst 0xe2c103d4 // ASTUR-R.RI-64 Rt:20 Rn:30 op2:00 imm9:000010000 V:0 op1:11 11100010:11100010
	.inst 0x389fe7e8 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:8 Rn:31 01:01 imm9:111111110 0:0 opc:10 111000:111000 size:00
	.inst 0xc2d81b2a // ALIGND-C.CI-C Cd:10 Cn:25 0110:0110 U:0 imm6:110000 11000010110:11000010110
	.inst 0xc2a223de // ADD-C.CRI-C Cd:30 Cn:30 imm3:000 option:001 Rm:2 11000010101:11000010101
	.inst 0xc2ce47c1 // CSEAL-C.C-C Cd:1 Cn:30 001:001 opc:10 0:0 Cm:14 11000010110:11000010110
	.inst 0xd8d4acf3 // prfm_lit:aarch64/instrs/memory/literal/general Rt:19 imm19:1101010010101100111 011000:011000 opc:11
	.inst 0xc2c212a0
	.zero 1048532
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
	.inst 0xc24000e1 // ldr c1, [x7, #0]
	.inst 0xc24004e2 // ldr c2, [x7, #1]
	.inst 0xc24008e6 // ldr c6, [x7, #2]
	.inst 0xc2400ced // ldr c13, [x7, #3]
	.inst 0xc24010ee // ldr c14, [x7, #4]
	.inst 0xc24014f4 // ldr c20, [x7, #5]
	.inst 0xc24018f8 // ldr c24, [x7, #6]
	.inst 0xc2401cfe // ldr c30, [x7, #7]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850030
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
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x21, #0xf
	and x7, x7, x21
	cmp x7, #0x1
	b.ne comparison_fail
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
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc24010f5 // ldr c21, [x7, #4]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc24014f5 // ldr c21, [x7, #5]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc24018f5 // ldr c21, [x7, #6]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2401cf5 // ldr c21, [x7, #7]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc24020f5 // ldr c21, [x7, #8]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc24024f5 // ldr c21, [x7, #9]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc24028f5 // ldr c21, [x7, #10]
	.inst 0xc2d5a721 // chkeq c25, c21
	b.ne comparison_fail
	.inst 0xc2402cf5 // ldr c21, [x7, #11]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001022
	ldr x1, =check_data1
	ldr x2, =0x00001023
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c90
	ldr x1, =check_data2
	ldr x2, =0x00001ca0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
