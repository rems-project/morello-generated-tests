.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x41, 0x74, 0xdf, 0x78, 0x3e, 0x98, 0x5e, 0x02, 0x32, 0xa0, 0xfe, 0xc2, 0x19, 0x28, 0xdf, 0x1a
	.byte 0x1e, 0xfe, 0xdf, 0x88, 0x02, 0x2c, 0x33, 0x12, 0xa2, 0xca, 0x18, 0x38, 0x29, 0xd8, 0x5c, 0xba
	.byte 0xe0, 0x7f, 0x9f, 0x48, 0xc2, 0x73, 0x00, 0x1b, 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x1004
	/* C16 */
	.octa 0x100c
	/* C21 */
	.octa 0x1802
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C16 */
	.octa 0x100c
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x1802
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1006
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000060000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000007001000400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78df7441 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:2 01:01 imm9:111110111 0:0 opc:11 111000:111000 size:01
	.inst 0x025e983e // ADD-C.CIS-C Cd:30 Cn:1 imm12:011110100110 sh:1 A:0 00000010:00000010
	.inst 0xc2fea032 // BICFLGS-C.CI-C Cd:18 Cn:1 0:0 00:00 imm8:11110101 11000010111:11000010111
	.inst 0x1adf2819 // asrv:aarch64/instrs/integer/shift/variable Rd:25 Rn:0 op2:10 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0x88dffe1e // ldar:aarch64/instrs/memory/ordered Rt:30 Rn:16 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x12332c02 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:0 imms:001011 immr:110011 N:0 100100:100100 opc:00 sf:0
	.inst 0x3818caa2 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:21 10:10 imm9:110001100 0:0 opc:00 111000:111000 size:00
	.inst 0xba5cd829 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1001 0:0 Rn:1 10:10 cond:1101 imm5:11100 111010010:111010010 op:0 sf:1
	.inst 0x489f7fe0 // stllrh:aarch64/instrs/memory/ordered Rt:0 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x1b0073c2 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:2 Rn:30 Ra:28 o0:0 Rm:0 0011011000:0011011000 sf:0
	.inst 0xc2c21100
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc24008b0 // ldr c16, [x5, #2]
	.inst 0xc2400cb5 // ldr c21, [x5, #3]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850032
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603105 // ldr c5, [c8, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601105 // ldr c5, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x8, #0xf
	and x5, x5, x8
	cmp x5, #0x9
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a8 // ldr c8, [x5, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24004a8 // ldr c8, [x5, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc24008a8 // ldr c8, [x5, #2]
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	.inst 0xc2400ca8 // ldr c8, [x5, #3]
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	.inst 0xc24010a8 // ldr c8, [x5, #4]
	.inst 0xc2c8a6a1 // chkeq c21, c8
	b.ne comparison_fail
	.inst 0xc24014a8 // ldr c8, [x5, #5]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc24018a8 // ldr c8, [x5, #6]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001792
	ldr x1, =check_data2
	ldr x2, =0x00001793
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
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
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
