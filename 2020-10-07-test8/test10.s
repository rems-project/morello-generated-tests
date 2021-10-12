.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x10
.data
check_data4:
	.byte 0xbf, 0x77, 0xbb, 0xe2, 0x51, 0x25, 0x0a, 0x82, 0x60, 0xc7, 0x0c, 0x38, 0xb4, 0xb5, 0x00, 0x1b
	.byte 0xfe, 0x67, 0x40, 0x0a, 0xee, 0x13, 0xc7, 0xc2, 0xe3, 0x6f, 0xc0, 0xc2, 0xff, 0xf7, 0xed, 0x82
	.byte 0x01, 0x40, 0x5b, 0x78, 0x9e, 0x5a, 0x7f, 0xb1, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000500011d20000000000001410
	/* C13 */
	.octa 0x17fcafc000000030
	/* C27 */
	.octa 0x40000000200140050000000000001ffe
	/* C29 */
	.octa 0x2001
final_cap_values:
	/* C0 */
	.octa 0x80000000500011d20000000000001410
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x80000000500011d20000000000001410
	/* C13 */
	.octa 0x17fcafc000000030
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0xfffc3d30
	/* C27 */
	.octa 0x400000002001400500000000000020ca
	/* C29 */
	.octa 0x2001
	/* C30 */
	.octa 0x100f99d30
initial_SP_EL3_value:
	.octa 0x401a820000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005ff900380000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2bb77bf // ALDUR-V.RI-S Rt:31 Rn:29 op2:01 imm9:110110111 V:1 op1:10 11100010:11100010
	.inst 0x820a2551 // LDR-C.I-C Ct:17 imm17:00101000100101010 1000001000:1000001000
	.inst 0x380cc760 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:27 01:01 imm9:011001100 0:0 opc:00 111000:111000 size:00
	.inst 0x1b00b5b4 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:20 Rn:13 Ra:13 o0:1 Rm:0 0011011000:0011011000 sf:0
	.inst 0x0a4067fe // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:31 imm6:011001 Rm:0 N:0 shift:01 01010:01010 opc:00 sf:0
	.inst 0xc2c713ee // RRLEN-R.R-C Rd:14 Rn:31 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xc2c06fe3 // CSEL-C.CI-C Cd:3 Cn:31 11:11 cond:0110 Cm:0 11000010110:11000010110
	.inst 0x82edf7ff // ALDR-R.RRB-64 Rt:31 Rn:31 opc:01 S:1 option:111 Rm:13 1:1 L:1 100000101:100000101
	.inst 0x785b4001 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:0 00:00 imm9:110110100 0:0 opc:01 111000:111000 size:01
	.inst 0xb17f5a9e // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:20 imm12:111111010110 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2c211e0
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
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004ed // ldr c13, [x7, #1]
	.inst 0xc24008fb // ldr c27, [x7, #2]
	.inst 0xc2400cfd // ldr c29, [x7, #3]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x3085003a
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031e7 // ldr c7, [c15, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x826011e7 // ldr c7, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
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
	mov x15, #0xf
	and x7, x7, x15
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000ef // ldr c15, [x7, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24004ef // ldr c15, [x7, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24008ef // ldr c15, [x7, #2]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc2400cef // ldr c15, [x7, #3]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc24010ef // ldr c15, [x7, #4]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc24014ef // ldr c15, [x7, #5]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc24018ef // ldr c15, [x7, #6]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc2401cef // ldr c15, [x7, #7]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc24020ef // ldr c15, [x7, #8]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc24024ef // ldr c15, [x7, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x15, v31.d[0]
	cmp x7, x15
	b.ne comparison_fail
	ldr x7, =0x0
	mov x15, v31.d[1]
	cmp x7, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011b8
	ldr x1, =check_data0
	ldr x2, =0x000011c0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013c4
	ldr x1, =check_data1
	ldr x2, =0x000013c6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004512a0
	ldr x1, =check_data5
	ldr x2, =0x004512b0
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
