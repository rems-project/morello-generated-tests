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
	.byte 0xc1, 0x84, 0xc1, 0xc2, 0xc8, 0xff, 0x08, 0x38, 0x80, 0x02, 0x5f, 0xd6
.data
check_data3:
	.byte 0xe1, 0x07, 0xc0, 0x5a, 0x61, 0x64, 0x00, 0x9c, 0x7f, 0x08, 0xc0, 0xda, 0x42, 0x08, 0x47, 0x38
	.byte 0x80, 0x55, 0xb8, 0x92, 0x5e, 0xe7, 0xf0, 0x68, 0xe2, 0x6b, 0x52, 0xcb, 0x40, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x3e7980060080000000000000
	/* C2 */
	.octa 0x80000000000100050000000000403f8e
	/* C6 */
	.octa 0x100030000000000000000
	/* C8 */
	.octa 0x0
	/* C20 */
	.octa 0x402ff0
	/* C26 */
	.octa 0x8000000000010005000000000000106c
	/* C30 */
	.octa 0x4000000058000802000000000000106f
final_cap_values:
	/* C0 */
	.octa 0xffffffff3d53ffff
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x100030000000000000000
	/* C8 */
	.octa 0x0
	/* C20 */
	.octa 0x402ff0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x80000000000100050000000000000ff0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa00080007e4200000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 96
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c184c1 // CHKSS-_.CC-C 00001:00001 Cn:6 001:001 opc:00 1:1 Cm:1 11000010110:11000010110
	.inst 0x3808ffc8 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:8 Rn:30 11:11 imm9:010001111 0:0 opc:00 111000:111000 size:00
	.inst 0xd65f0280 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:20 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 12260
	.inst 0x5ac007e1 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:31 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0x9c006461 // ldr_lit_fpsimd:aarch64/instrs/memory/literal/simdfp Rt:1 imm19:0000000001100100011 011100:011100 opc:10
	.inst 0xdac0087f // rev:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:3 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x38470842 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:2 10:10 imm9:001110000 0:0 opc:01 111000:111000 size:00
	.inst 0x92b85580 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1100001010101100 hw:01 100101:100101 opc:00 sf:1
	.inst 0x68f0e75e // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:30 Rn:26 Rt2:11001 imm7:1100001 L:1 1010001:1010001 opc:01
	.inst 0xcb526be2 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:2 Rn:31 imm6:011010 Rm:18 0:0 shift:01 01011:01011 S:0 op:1 sf:1
	.inst 0xc2c21140
	.zero 1036272
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
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc2400886 // ldr c6, [x4, #2]
	.inst 0xc2400c88 // ldr c8, [x4, #3]
	.inst 0xc2401094 // ldr c20, [x4, #4]
	.inst 0xc240149a // ldr c26, [x4, #5]
	.inst 0xc240189e // ldr c30, [x4, #6]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850032
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601144 // ldr c4, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	mov x10, #0xf
	and x4, x4, x10
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008a // ldr c10, [x4, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240048a // ldr c10, [x4, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240088a // ldr c10, [x4, #2]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc2400c8a // ldr c10, [x4, #3]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc240108a // ldr c10, [x4, #4]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc240148a // ldr c10, [x4, #5]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc240188a // ldr c10, [x4, #6]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2401c8a // ldr c10, [x4, #7]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x10, v1.d[0]
	cmp x4, x10
	b.ne comparison_fail
	ldr x4, =0x0
	mov x10, v1.d[1]
	cmp x4, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000106c
	ldr x1, =check_data0
	ldr x2, =0x00001074
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010fe
	ldr x1, =check_data1
	ldr x2, =0x000010ff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00402ff0
	ldr x1, =check_data3
	ldr x2, =0x00403010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00403c80
	ldr x1, =check_data4
	ldr x2, =0x00403c90
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00403ffe
	ldr x1, =check_data5
	ldr x2, =0x00403fff
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
