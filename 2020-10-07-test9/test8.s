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
	.byte 0x94, 0x3b, 0x75, 0x39, 0xc3, 0x43, 0x28, 0xfd, 0xe0, 0x73, 0xc2, 0xc2, 0xe0, 0xff, 0xdf, 0x08
	.byte 0xcd, 0x0f, 0xc0, 0xda, 0xc2, 0xfb, 0xbe, 0x9b, 0x8a, 0x48, 0x92, 0x78, 0x41, 0x80, 0xde, 0xc2
	.byte 0x5c, 0xf8, 0x17, 0x9b, 0x83, 0x85, 0x93, 0x9a, 0x60, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x800000000007000f00000000000010e0
	/* C28 */
	.octa 0x12ab
	/* C30 */
	.octa 0xffffffffffffbf80
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80ffefbf7f80
	/* C2 */
	.octa 0x80ffefbf7f80
	/* C4 */
	.octa 0x800000000007000f00000000000010e0
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x80bfffffffffffff
	/* C20 */
	.octa 0x0
	/* C30 */
	.octa 0xffffffffffffbf80
initial_SP_EL3_value:
	.octa 0x800000006111c004000000000040c100
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000114f020f0000000000008001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x39753b94 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:20 Rn:28 imm12:110101001110 opc:01 111001:111001 size:00
	.inst 0xfd2843c3 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:3 Rn:30 imm12:101000010000 opc:00 111101:111101 size:11
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x08dfffe0 // ldarb:aarch64/instrs/memory/ordered Rt:0 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xdac00fcd // rev:aarch64/instrs/integer/arithmetic/rev Rd:13 Rn:30 opc:11 1011010110000000000:1011010110000000000 sf:1
	.inst 0x9bbefbc2 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:30 Ra:30 o0:1 Rm:30 01:01 U:1 10011011:10011011
	.inst 0x7892488a // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:10 Rn:4 10:10 imm9:100100100 0:0 opc:10 111000:111000 size:01
	.inst 0xc2de8041 // SCTAG-C.CR-C Cd:1 Cn:2 000:000 0:0 10:10 Rm:30 11000010110:11000010110
	.inst 0x9b17f85c // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:28 Rn:2 Ra:30 o0:1 Rm:23 0011011000:0011011000 sf:1
	.inst 0x9a938583 // csinc:aarch64/instrs/integer/conditional/select Rd:3 Rn:12 o2:1 0:0 cond:1000 Rm:19 011010100:011010100 op:0 sf:1
	.inst 0xc2c21160
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
	ldr x26, =initial_cap_values
	.inst 0xc2400344 // ldr c4, [x26, #0]
	.inst 0xc240075c // ldr c28, [x26, #1]
	.inst 0xc2400b5e // ldr c30, [x26, #2]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q3, =0x0
	/* Set up flags and system registers */
	mov x26, #0x20000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	ldr x26, =0x0
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260317a // ldr c26, [c11, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260117a // ldr c26, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x11, #0x6
	and x26, x26, x11
	cmp x26, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034b // ldr c11, [x26, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240074b // ldr c11, [x26, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400b4b // ldr c11, [x26, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400f4b // ldr c11, [x26, #3]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc240134b // ldr c11, [x26, #4]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc240174b // ldr c11, [x26, #5]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc2401b4b // ldr c11, [x26, #6]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc2401f4b // ldr c11, [x26, #7]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x11, v3.d[0]
	cmp x26, x11
	b.ne comparison_fail
	ldr x26, =0x0
	mov x11, v3.d[1]
	cmp x26, x11
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
	ldr x0, =0x00001ff9
	ldr x1, =check_data1
	ldr x2, =0x00001ffa
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040c100
	ldr x1, =check_data3
	ldr x2, =0x0040c101
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
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
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
