.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x08
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xbf, 0x67, 0xc3, 0x68, 0xbc, 0x2e, 0xc9, 0x69, 0x95, 0x44, 0x4a, 0x82, 0x20, 0xb4, 0x71, 0x82
	.byte 0xf0, 0x4b, 0xde, 0xc2, 0xd3, 0x4b, 0xc0, 0xc2, 0x00, 0x21, 0xc2, 0xc2, 0x32, 0x90, 0x27, 0x39
	.byte 0xe2, 0x7f, 0x5f, 0x9b, 0xc7, 0x98, 0x20, 0x9b, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000000100050000000000000640
	/* C4 */
	.octa 0x698
	/* C8 */
	.octa 0x800700060000000000000000
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x800000000007000600000000000017c0
	/* C29 */
	.octa 0x800000000001000600000000000017fc
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x40000000000100050000000000000640
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x698
	/* C8 */
	.octa 0x800700060000000000000000
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x80000000000700060000000000001808
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000100060000000000001814
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000580209010000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x68c367bf // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:31 Rn:29 Rt2:11001 imm7:0000110 L:1 1010001:1010001 opc:01
	.inst 0x69c92ebc // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:28 Rn:21 Rt2:01011 imm7:0010010 L:1 1010011:1010011 opc:01
	.inst 0x824a4495 // ASTRB-R.RI-B Rt:21 Rn:4 op:01 imm9:010100100 L:0 1000001001:1000001001
	.inst 0x8271b420 // ALDRB-R.RI-B Rt:0 Rn:1 op:01 imm9:100011011 L:1 1000001001:1000001001
	.inst 0xc2de4bf0 // UNSEAL-C.CC-C Cd:16 Cn:31 0010:0010 opc:01 Cm:30 11000010110:11000010110
	.inst 0xc2c04bd3 // UNSEAL-C.CC-C Cd:19 Cn:30 0010:0010 opc:01 Cm:0 11000010110:11000010110
	.inst 0xc2c22100 // SCBNDSE-C.CR-C Cd:0 Cn:8 000:000 opc:01 0:0 Rm:2 11000010110:11000010110
	.inst 0x39279032 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:18 Rn:1 imm12:100111100100 opc:00 111001:111001 size:00
	.inst 0x9b5f7fe2 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:2 Rn:31 Ra:11111 0:0 Rm:31 10:10 U:0 10011011:10011011
	.inst 0x9b2098c7 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:7 Rn:6 Ra:6 o0:1 Rm:0 01:01 U:0 10011011:10011011
	.inst 0xc2c21300
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400341 // ldr c1, [x26, #0]
	.inst 0xc2400744 // ldr c4, [x26, #1]
	.inst 0xc2400b48 // ldr c8, [x26, #2]
	.inst 0xc2400f52 // ldr c18, [x26, #3]
	.inst 0xc2401355 // ldr c21, [x26, #4]
	.inst 0xc240175d // ldr c29, [x26, #5]
	.inst 0xc2401b5e // ldr c30, [x26, #6]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850032
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260331a // ldr c26, [c24, #3]
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	.inst 0x8260131a // ldr c26, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400358 // ldr c24, [x26, #0]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400758 // ldr c24, [x26, #1]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400b58 // ldr c24, [x26, #2]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2400f58 // ldr c24, [x26, #3]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc2401358 // ldr c24, [x26, #4]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc2401758 // ldr c24, [x26, #5]
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	.inst 0xc2401b58 // ldr c24, [x26, #6]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2401f58 // ldr c24, [x26, #7]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc2402358 // ldr c24, [x26, #8]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc2402758 // ldr c24, [x26, #9]
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	.inst 0xc2402b58 // ldr c24, [x26, #10]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2402f58 // ldr c24, [x26, #11]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2403358 // ldr c24, [x26, #12]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001024
	ldr x1, =check_data0
	ldr x2, =0x00001025
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000103d
	ldr x1, =check_data1
	ldr x2, =0x0000103e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000105c
	ldr x1, =check_data2
	ldr x2, =0x0000105d
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017fc
	ldr x1, =check_data3
	ldr x2, =0x00001804
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001808
	ldr x1, =check_data4
	ldr x2, =0x00001810
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
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
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
