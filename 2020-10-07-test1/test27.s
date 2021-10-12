.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x08, 0x0c, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x22
.data
check_data4:
	.byte 0x21, 0x28, 0x9f, 0xb8, 0x19, 0xe0, 0x86, 0xe2, 0x00, 0xa8, 0x9b, 0x02, 0x40, 0x7c, 0x9f, 0x88
	.byte 0xa2, 0x07, 0x54, 0x38, 0xe1, 0xff, 0xdf, 0x48, 0x01, 0xd2, 0xc1, 0xc2, 0xc2, 0x27, 0xc0, 0xc2
	.byte 0x30, 0x64, 0x82, 0xe2, 0xa0, 0x1d, 0x3e, 0xb0, 0x40, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1a00700000000000012f2
	/* C1 */
	.octa 0x800000005001c002000000000044d00a
	/* C2 */
	.octa 0x400000004001000200000000000010c0
	/* C16 */
	.octa 0x1012
	/* C25 */
	.octa 0x22000000
	/* C29 */
	.octa 0x800000002007e007000000000040fffe
	/* C30 */
	.octa 0x480020000000000000000
final_cap_values:
	/* C0 */
	.octa 0xc000000010270001000000007c4b5000
	/* C1 */
	.octa 0x1012
	/* C2 */
	.octa 0x48002ffffffffffffffff
	/* C16 */
	.octa 0x0
	/* C25 */
	.octa 0x22000000
	/* C29 */
	.octa 0x800000002007e007000000000040ff3e
	/* C30 */
	.octa 0x480020000000000000000
initial_SP_EL3_value:
	.octa 0x80000000600000040000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000102700010000000000100004
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb89f2821 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:1 10:10 imm9:111110010 0:0 opc:10 111000:111000 size:10
	.inst 0xe286e019 // ASTUR-R.RI-32 Rt:25 Rn:0 op2:00 imm9:001101110 V:0 op1:10 11100010:11100010
	.inst 0x029ba800 // SUB-C.CIS-C Cd:0 Cn:0 imm12:011011101010 sh:0 A:1 00000010:00000010
	.inst 0x889f7c40 // stllr:aarch64/instrs/memory/ordered Rt:0 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x385407a2 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:29 01:01 imm9:101000000 0:0 opc:01 111000:111000 size:00
	.inst 0x48dfffe1 // ldarh:aarch64/instrs/memory/ordered Rt:1 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c1d201 // CPY-C.C-C Cd:1 Cn:16 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xc2c027c2 // CPYTYPE-C.C-C Cd:2 Cn:30 001:001 opc:01 0:0 Cm:0 11000010110:11000010110
	.inst 0xe2826430 // ALDUR-R.RI-32 Rt:16 Rn:1 op2:01 imm9:000100110 V:0 op1:10 11100010:11100010
	.inst 0xb03e1da0 // ADRDP-C.ID-C Rd:0 immhi:011111000011101101 P:0 10000:10000 immlo:01 op:1
	.inst 0xc2c21140
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
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a2 // ldr c2, [x5, #2]
	.inst 0xc2400cb0 // ldr c16, [x5, #3]
	.inst 0xc24010b9 // ldr c25, [x5, #4]
	.inst 0xc24014bd // ldr c29, [x5, #5]
	.inst 0xc24018be // ldr c30, [x5, #6]
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
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603145 // ldr c5, [c10, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601145 // ldr c5, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000aa // ldr c10, [x5, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24004aa // ldr c10, [x5, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24008aa // ldr c10, [x5, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400caa // ldr c10, [x5, #3]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc24010aa // ldr c10, [x5, #4]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc24014aa // ldr c10, [x5, #5]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc24018aa // ldr c10, [x5, #6]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001038
	ldr x1, =check_data1
	ldr x2, =0x0000103c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010c4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001360
	ldr x1, =check_data3
	ldr x2, =0x00001364
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
	ldr x0, =0x0040fffe
	ldr x1, =check_data5
	ldr x2, =0x0040ffff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0044cffc
	ldr x1, =check_data6
	ldr x2, =0x0044d000
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
