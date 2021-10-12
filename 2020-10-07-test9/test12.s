.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0xf5, 0x58, 0x14, 0x78, 0x36, 0x90, 0x4d, 0x78, 0xa1, 0xa6, 0xc3, 0xc2
	.byte 0x00, 0x78, 0xa5, 0xf8, 0x62, 0x16, 0xe9, 0xe2, 0x43, 0x40, 0xda, 0x78, 0x2a, 0xc0, 0x92, 0xcb
	.byte 0x1f, 0xf4, 0x71, 0x82, 0xb8, 0x7c, 0x20, 0x9b, 0x00, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001edf
	/* C1 */
	.octa 0x1e03
	/* C2 */
	.octa 0x480018
	/* C3 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C7 */
	.octa 0x10c7
	/* C19 */
	.octa 0x80000000000100050000000000403f47
	/* C21 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001edf
	/* C1 */
	.octa 0x1e03
	/* C2 */
	.octa 0x480018
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x10c7
	/* C19 */
	.octa 0x80000000000100050000000000403f47
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000d00030000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x781458f5 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:21 Rn:7 10:10 imm9:101000101 0:0 opc:00 111000:111000 size:01
	.inst 0x784d9036 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:22 Rn:1 00:00 imm9:011011001 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c3a6a1 // CHKEQ-_.CC-C 00001:00001 Cn:21 001:001 opc:01 1:1 Cm:3 11000010110:11000010110
	.inst 0xf8a57800 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:0 10:10 S:1 option:011 Rm:5 1:1 opc:10 111000:111000 size:11
	.inst 0xe2e91662 // ALDUR-V.RI-D Rt:2 Rn:19 op2:01 imm9:010010001 V:1 op1:11 11100010:11100010
	.inst 0x78da4043 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:3 Rn:2 00:00 imm9:110100100 0:0 opc:11 111000:111000 size:01
	.inst 0xcb92c02a // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:10 Rn:1 imm6:110000 Rm:18 0:0 shift:10 01011:01011 S:0 op:1 sf:1
	.inst 0x8271f41f // ALDRB-R.RI-B Rt:31 Rn:0 op:01 imm9:100011111 L:1 1000001001:1000001001
	.inst 0x9b207cb8 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:24 Rn:5 Ra:31 o0:0 Rm:0 01:01 U:0 10011011:10011011
	.inst 0xc2c21100
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400922 // ldr c2, [x9, #2]
	.inst 0xc2400d23 // ldr c3, [x9, #3]
	.inst 0xc2401127 // ldr c7, [x9, #4]
	.inst 0xc2401533 // ldr c19, [x9, #5]
	.inst 0xc2401935 // ldr c21, [x9, #6]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603109 // ldr c9, [c8, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601109 // ldr c9, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x8, #0xf
	and x9, x9, x8
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400128 // ldr c8, [x9, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400528 // ldr c8, [x9, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400928 // ldr c8, [x9, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400d28 // ldr c8, [x9, #3]
	.inst 0xc2c8a461 // chkeq c3, c8
	b.ne comparison_fail
	.inst 0xc2401128 // ldr c8, [x9, #4]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2401528 // ldr c8, [x9, #5]
	.inst 0xc2c8a661 // chkeq c19, c8
	b.ne comparison_fail
	.inst 0xc2401928 // ldr c8, [x9, #6]
	.inst 0xc2c8a6a1 // chkeq c21, c8
	b.ne comparison_fail
	.inst 0xc2401d28 // ldr c8, [x9, #7]
	.inst 0xc2c8a6c1 // chkeq c22, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x8, v2.d[0]
	cmp x9, x8
	b.ne comparison_fail
	ldr x9, =0x0
	mov x8, v2.d[1]
	cmp x9, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100c
	ldr x1, =check_data0
	ldr x2, =0x0000100e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001edc
	ldr x1, =check_data1
	ldr x2, =0x00001ede
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x00403fd8
	ldr x1, =check_data4
	ldr x2, =0x00403fe0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0047ffbc
	ldr x1, =check_data5
	ldr x2, =0x0047ffbe
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
