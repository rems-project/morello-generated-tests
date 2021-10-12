.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x81, 0x10, 0xc2, 0xc2, 0xe1, 0x02, 0x1b, 0xfa, 0x5f, 0x39, 0x03, 0xd5, 0xa3, 0xa6, 0xba, 0x54
	.byte 0x1e, 0xf0, 0x7d, 0x69, 0xc1, 0x85, 0xcd, 0xc2, 0x01, 0x30, 0xc2, 0xc2, 0x4b, 0x10, 0x55, 0x38
	.byte 0x7f, 0x32, 0xc5, 0xc2, 0x95, 0x81, 0xaf, 0x9b, 0x00, 0x11, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000400024
	/* C2 */
	.octa 0x800000000007800f00000000004ea000
	/* C4 */
	.octa 0x3fff800000000000000000000000
	/* C13 */
	.octa 0xc0000000000000000001
	/* C14 */
	.octa 0x40000000000000000
	/* C19 */
	.octa 0x1
	/* C23 */
	.octa 0x8000000000000000
	/* C27 */
	.octa 0x7fffffffffffffff
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000400024
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x800000000007800f00000000004ea000
	/* C4 */
	.octa 0x3fff800000000000000000000000
	/* C11 */
	.octa 0xc2
	/* C13 */
	.octa 0xc0000000000000000001
	/* C14 */
	.octa 0x40000000000000000
	/* C19 */
	.octa 0x1
	/* C23 */
	.octa 0x8000000000000000
	/* C27 */
	.octa 0x7fffffffffffffff
	/* C28 */
	.octa 0xffffffffc2cd85c1
	/* C30 */
	.octa 0x697df01e
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100610070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c21081 // CHKSLD-C-C 00001:00001 Cn:4 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xfa1b02e1 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:23 000000:000000 Rm:27 11010000:11010000 S:1 op:1 sf:1
	.inst 0xd503395f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1001 11010101000000110011:11010101000000110011
	.inst 0x54baa6a3 // b_cond:aarch64/instrs/branch/conditional/cond cond:0011 0:0 imm19:1011101010100110101 01010100:01010100
	.inst 0x697df01e // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:30 Rn:0 Rt2:11100 imm7:1111011 L:1 1010010:1010010 opc:01
	.inst 0xc2cd85c1 // CHKSS-_.CC-C 00001:00001 Cn:14 001:001 opc:00 1:1 Cm:13 11000010110:11000010110
	.inst 0xc2c23001 // CHKTGD-C-C 00001:00001 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x3855104b // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:11 Rn:2 00:00 imm9:101010001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c5327f // CVTP-R.C-C Rd:31 Cn:19 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x9baf8195 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:21 Rn:12 Ra:0 o0:1 Rm:15 01:01 U:1 10011011:10011011
	.inst 0xc2c21100
	.zero 958244
	.inst 0x0000c200
	.zero 90284
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
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400742 // ldr c2, [x26, #1]
	.inst 0xc2400b44 // ldr c4, [x26, #2]
	.inst 0xc2400f4d // ldr c13, [x26, #3]
	.inst 0xc240134e // ldr c14, [x26, #4]
	.inst 0xc2401753 // ldr c19, [x26, #5]
	.inst 0xc2401b57 // ldr c23, [x26, #6]
	.inst 0xc2401f5b // ldr c27, [x26, #7]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850032
	msr SCTLR_EL3, x26
	ldr x26, =0x0
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260111a // ldr c26, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	mov x8, #0xf
	and x26, x26, x8
	cmp x26, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400348 // ldr c8, [x26, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400748 // ldr c8, [x26, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400b48 // ldr c8, [x26, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400f48 // ldr c8, [x26, #3]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc2401348 // ldr c8, [x26, #4]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc2401748 // ldr c8, [x26, #5]
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc2401b48 // ldr c8, [x26, #6]
	.inst 0xc2c8a5c1 // chkeq c14, c8
	b.ne comparison_fail
	.inst 0xc2401f48 // ldr c8, [x26, #7]
	.inst 0xc2c8a661 // chkeq c19, c8
	b.ne comparison_fail
	.inst 0xc2402348 // ldr c8, [x26, #8]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2402748 // ldr c8, [x26, #9]
	.inst 0xc2c8a761 // chkeq c27, c8
	b.ne comparison_fail
	.inst 0xc2402b48 // ldr c8, [x26, #10]
	.inst 0xc2c8a781 // chkeq c28, c8
	b.ne comparison_fail
	.inst 0xc2402f48 // ldr c8, [x26, #11]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040002c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x004e9f51
	ldr x1, =check_data1
	ldr x2, =0x004e9f52
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
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
