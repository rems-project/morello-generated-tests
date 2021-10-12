.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x01
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xf4, 0x7f
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xfb, 0x7e, 0x3f, 0x42, 0xe6, 0xa0, 0x2a, 0x32, 0xca, 0xff, 0xdf, 0x08, 0x26, 0x7d, 0x9f, 0x48
	.byte 0xe1, 0x34, 0x19, 0x02, 0xe1, 0xa7, 0xc1, 0xc2, 0x18, 0x38, 0x5d, 0x78, 0xb9, 0xd7, 0x6f, 0x82
	.byte 0x01, 0xfc, 0x9f, 0x08, 0x08, 0xd8, 0x2e, 0xf1, 0x40, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x104d
	/* C7 */
	.octa 0x740050000000000007cb4
	/* C9 */
	.octa 0x13a0
	/* C23 */
	.octa 0x40000000400002210000000000001220
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000100050000000000001f01
	/* C30 */
	.octa 0x4febfc
final_cap_values:
	/* C0 */
	.octa 0x104d
	/* C1 */
	.octa 0x740050000000000008301
	/* C6 */
	.octa 0x7fc07ff4
	/* C7 */
	.octa 0x740050000000000007cb4
	/* C8 */
	.octa 0x497
	/* C9 */
	.octa 0x13a0
	/* C10 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000400002210000000000001220
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000100050000000000001f01
	/* C30 */
	.octa 0x4febfc
initial_csp_value:
	.octa 0xfffffffffff8bffaffffffffffff7cfe
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000602070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000300070000000000c90001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 176
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x423f7efb // ASTLRB-R.R-B Rt:27 Rn:23 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x322aa0e6 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:6 Rn:7 imms:101000 immr:101010 N:0 100100:100100 opc:01 sf:0
	.inst 0x08dfffca // ldarb:aarch64/instrs/memory/ordered Rt:10 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x489f7d26 // stllrh:aarch64/instrs/memory/ordered Rt:6 Rn:9 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x021934e1 // ADD-C.CIS-C Cd:1 Cn:7 imm12:011001001101 sh:0 A:0 00000010:00000010
	.inst 0xc2c1a7e1 // CHKEQ-_.CC-C 00001:00001 Cn:31 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0x785d3818 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:24 Rn:0 10:10 imm9:111010011 0:0 opc:01 111000:111000 size:01
	.inst 0x826fd7b9 // ALDRB-R.RI-B Rt:25 Rn:29 op:01 imm9:011111101 L:1 1000001001:1000001001
	.inst 0x089ffc01 // stlrb:aarch64/instrs/memory/ordered Rt:1 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xf12ed808 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:8 Rn:0 imm12:101110110110 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0xc2c21340
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a7 // ldr c7, [x21, #1]
	.inst 0xc2400aa9 // ldr c9, [x21, #2]
	.inst 0xc2400eb7 // ldr c23, [x21, #3]
	.inst 0xc24012bb // ldr c27, [x21, #4]
	.inst 0xc24016bd // ldr c29, [x21, #5]
	.inst 0xc2401abe // ldr c30, [x21, #6]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_csp_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850032
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603355 // ldr c21, [c26, #3]
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	.inst 0x82601355 // ldr c21, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x26, #0xf
	and x21, x21, x26
	cmp x21, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002ba // ldr c26, [x21, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24006ba // ldr c26, [x21, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400aba // ldr c26, [x21, #2]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc2400eba // ldr c26, [x21, #3]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc24012ba // ldr c26, [x21, #4]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc24016ba // ldr c26, [x21, #5]
	.inst 0xc2daa521 // chkeq c9, c26
	b.ne comparison_fail
	.inst 0xc2401aba // ldr c26, [x21, #6]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc2401eba // ldr c26, [x21, #7]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc24022ba // ldr c26, [x21, #8]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc24026ba // ldr c26, [x21, #9]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc2402aba // ldr c26, [x21, #10]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	.inst 0xc2402eba // ldr c26, [x21, #11]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc24032ba // ldr c26, [x21, #12]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001022
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000104d
	ldr x1, =check_data1
	ldr x2, =0x0000104e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001220
	ldr x1, =check_data2
	ldr x2, =0x00001221
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013a0
	ldr x1, =check_data3
	ldr x2, =0x000013a2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
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
	ldr x0, =0x004febfc
	ldr x1, =check_data6
	ldr x2, =0x004febfd
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
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
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
