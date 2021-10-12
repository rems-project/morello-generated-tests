.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x14, 0xfc, 0x7f, 0x42, 0x02, 0x51, 0xc2, 0xc2, 0x3f, 0xcc, 0x51, 0xb8, 0x8e, 0x0b, 0xea, 0xc2
	.byte 0xff, 0xfb, 0x17, 0x1b, 0x22, 0x08, 0x93, 0x78, 0xe1, 0xa7, 0xdf, 0xc2, 0x2a, 0xe8, 0x0b, 0xa2
	.byte 0x7b, 0xfd, 0x9f, 0x08, 0x20, 0xf8, 0xa5, 0x9b, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0xc800000040140d110000000000001204
	/* C8 */
	.octa 0x20008000800180060000000000400009
	/* C10 */
	.octa 0x4000000000000000000000000000
	/* C11 */
	.octa 0x40000000000100050000000000001fd4
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0xc800000040140d110000000000001120
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x20008000800180060000000000400009
	/* C10 */
	.octa 0x4000000000000000000000000000
	/* C11 */
	.octa 0x40000000000100050000000000001fd4
	/* C14 */
	.octa 0x5000000000000000
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xffffffffffffffffffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300030000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000004000600ffffc000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x427ffc14 // ALDAR-R.R-32 Rt:20 Rn:0 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c25102 // RETS-C-C 00010:00010 Cn:8 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0xb851cc3f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:1 11:11 imm9:100011100 0:0 opc:01 111000:111000 size:10
	.inst 0xc2ea0b8e // ORRFLGS-C.CI-C Cd:14 Cn:28 0:0 01:01 imm8:01010000 11000010111:11000010111
	.inst 0x1b17fbff // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:31 Ra:30 o0:1 Rm:23 0011011000:0011011000 sf:0
	.inst 0x78930822 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:1 10:10 imm9:100110000 0:0 opc:10 111000:111000 size:01
	.inst 0xc2dfa7e1 // CHKEQ-_.CC-C 00001:00001 Cn:31 001:001 opc:01 1:1 Cm:31 11000010110:11000010110
	.inst 0xa20be82a // STTR-C.RIB-C Ct:10 Rn:1 10:10 imm9:010111110 0:0 opc:00 10100010:10100010
	.inst 0x089ffd7b // stlrb:aarch64/instrs/memory/ordered Rt:27 Rn:11 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x9ba5f820 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:1 Ra:30 o0:1 Rm:5 01:01 U:1 10011011:10011011
	.inst 0xc2c210c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400888 // ldr c8, [x4, #2]
	.inst 0xc2400c8a // ldr c10, [x4, #3]
	.inst 0xc240108b // ldr c11, [x4, #4]
	.inst 0xc240149b // ldr c27, [x4, #5]
	.inst 0xc240189c // ldr c28, [x4, #6]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030c4 // ldr c4, [c6, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826010c4 // ldr c4, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x6, #0xf
	and x4, x4, x6
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400086 // ldr c6, [x4, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400486 // ldr c6, [x4, #1]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400886 // ldr c6, [x4, #2]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2400c86 // ldr c6, [x4, #3]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401086 // ldr c6, [x4, #4]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2401486 // ldr c6, [x4, #5]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2401886 // ldr c6, [x4, #6]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2401c86 // ldr c6, [x4, #7]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2402086 // ldr c6, [x4, #8]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001050
	ldr x1, =check_data1
	ldr x2, =0x00001052
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001120
	ldr x1, =check_data2
	ldr x2, =0x00001124
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d00
	ldr x1, =check_data3
	ldr x2, =0x00001d10
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fd4
	ldr x1, =check_data4
	ldr x2, =0x00001fd5
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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
