.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xe2, 0x03, 0x0d, 0x78, 0x06, 0x90, 0xc0, 0xc2, 0xc1, 0x3c, 0x6b, 0x82, 0xda, 0xff, 0x4a, 0x7c
	.byte 0xe1, 0xd3, 0xc0, 0xc2, 0xc0, 0x8f, 0xc2, 0xc2, 0xe0, 0x73, 0xc2, 0xc2, 0xf0, 0x26, 0x8e, 0x1a
	.byte 0x63, 0xf9, 0x66, 0x69, 0xce, 0xe3, 0xb5, 0xd2, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0x1000
	/* C30 */
	.octa 0x800000003ffc0005000000000000104d
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x10000
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x1000
	/* C14 */
	.octa 0xaf1e0000
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x40000000000700070000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000420000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005e240a70000000000041e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x780d03e2 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:31 00:00 imm9:011010000 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c09006 // GCTAG-R.C-C Rd:6 Cn:0 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x826b3cc1 // ALDR-R.RI-64 Rt:1 Rn:6 op:11 imm9:010110011 L:1 1000001001:1000001001
	.inst 0x7c4affda // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:26 Rn:30 11:11 imm9:010101111 0:0 opc:01 111100:111100 size:01
	.inst 0xc2c0d3e1 // GCPERM-R.C-C Rd:1 Cn:31 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2c28fc0 // CSEL-C.CI-C Cd:0 Cn:30 11:11 cond:1000 Cm:2 11000010110:11000010110
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x1a8e26f0 // csinc:aarch64/instrs/integer/conditional/select Rd:16 Rn:23 o2:1 0:0 cond:0010 Rm:14 011010100:011010100 op:0 sf:0
	.inst 0x6966f963 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:3 Rn:11 Rt2:11110 imm7:1001101 L:1 1010010:1010010 opc:01
	.inst 0xd2b5e3ce // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:14 imm16:1010111100011110 hw:01 100101:100101 opc:10 sf:1
	.inst 0xc2c212c0
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
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400742 // ldr c2, [x26, #1]
	.inst 0xc2400b4b // ldr c11, [x26, #2]
	.inst 0xc2400f5e // ldr c30, [x26, #3]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_csp_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850038
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032da // ldr c26, [c22, #3]
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	.inst 0x826012da // ldr c26, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x22, #0x2
	and x26, x26, x22
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400356 // ldr c22, [x26, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400756 // ldr c22, [x26, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400b56 // ldr c22, [x26, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400f56 // ldr c22, [x26, #3]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc2401356 // ldr c22, [x26, #4]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401756 // ldr c22, [x26, #5]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc2401b56 // ldr c22, [x26, #6]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2401f56 // ldr c22, [x26, #7]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x22, v26.d[0]
	cmp x26, x22
	b.ne comparison_fail
	ldr x26, =0x0
	mov x22, v26.d[1]
	cmp x26, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010d0
	ldr x1, =check_data0
	ldr x2, =0x000010d2
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010fc
	ldr x1, =check_data1
	ldr x2, =0x000010fe
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
	ldr x0, =0x00421008
	ldr x1, =check_data3
	ldr x2, =0x00421010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004219a4
	ldr x1, =check_data4
	ldr x2, =0x004219ac
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
