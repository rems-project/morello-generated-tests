.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x87, 0x20, 0xc0, 0xc2, 0xed, 0x7f, 0x40, 0x9b, 0xe1, 0x7f, 0x26, 0xe2, 0x20, 0x84, 0x05, 0x9b
	.byte 0x1e, 0x00, 0x19, 0xda, 0x66, 0x96, 0x0c, 0x38, 0x8c, 0xff, 0x7f, 0x42, 0xe1, 0xd3, 0xc0, 0xc2
	.byte 0x84, 0xb7, 0x86, 0xda, 0xa1, 0xea, 0x69, 0x02, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x10400000000000000000000000
	/* C6 */
	.octa 0x0
	/* C19 */
	.octa 0x400000000300e2200000000000001ffe
	/* C21 */
	.octa 0x120030000000000000000
	/* C28 */
	.octa 0x1803
final_cap_values:
	/* C1 */
	.octa 0x120030000000000a7a000
	/* C4 */
	.octa 0x1803
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C19 */
	.octa 0x400000000300e22000000000000020c7
	/* C21 */
	.octa 0x120030000000000000000
	/* C28 */
	.octa 0x1803
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004001000900ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c02087 // SCBNDSE-C.CR-C Cd:7 Cn:4 000:000 opc:01 0:0 Rm:0 11000010110:11000010110
	.inst 0x9b407fed // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:13 Rn:31 Ra:11111 0:0 Rm:0 10:10 U:0 10011011:10011011
	.inst 0xe2267fe1 // ALDUR-V.RI-Q Rt:1 Rn:31 op2:11 imm9:001100111 V:1 op1:00 11100010:11100010
	.inst 0x9b058420 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:0 Rn:1 Ra:1 o0:1 Rm:5 0011011000:0011011000 sf:1
	.inst 0xda19001e // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:0 000000:000000 Rm:25 11010000:11010000 S:0 op:1 sf:1
	.inst 0x380c9666 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:6 Rn:19 01:01 imm9:011001001 0:0 opc:00 111000:111000 size:00
	.inst 0x427fff8c // ALDAR-R.R-32 Rt:12 Rn:28 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c0d3e1 // GCPERM-R.C-C Rd:1 Cn:31 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xda86b784 // csneg:aarch64/instrs/integer/conditional/select Rd:4 Rn:28 o2:1 0:0 cond:1011 Rm:6 011010100:011010100 op:1 sf:1
	.inst 0x0269eaa1 // ADD-C.CIS-C Cd:1 Cn:21 imm12:101001111010 sh:1 A:0 00000010:00000010
	.inst 0xc2c21120
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
	.inst 0xc2400746 // ldr c6, [x26, #1]
	.inst 0xc2400b53 // ldr c19, [x26, #2]
	.inst 0xc2400f55 // ldr c21, [x26, #3]
	.inst 0xc240135c // ldr c28, [x26, #4]
	/* Set up flags and system registers */
	mov x26, #0x80000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x3085003a
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260313a // ldr c26, [c9, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260113a // ldr c26, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
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
	mov x9, #0x9
	and x26, x26, x9
	cmp x26, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400349 // ldr c9, [x26, #0]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400749 // ldr c9, [x26, #1]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2400b49 // ldr c9, [x26, #2]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2400f49 // ldr c9, [x26, #3]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401349 // ldr c9, [x26, #4]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc2401749 // ldr c9, [x26, #5]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2401b49 // ldr c9, [x26, #6]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2401f49 // ldr c9, [x26, #7]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x9, v1.d[0]
	cmp x26, x9
	b.ne comparison_fail
	ldr x26, =0x0
	mov x9, v1.d[1]
	cmp x26, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001070
	ldr x1, =check_data0
	ldr x2, =0x00001080
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000180c
	ldr x1, =check_data1
	ldr x2, =0x00001810
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
