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
	.byte 0xb3, 0x00, 0x1b, 0x3a, 0x60, 0x97, 0xd8, 0x93, 0xab, 0x70, 0xc6, 0xc2, 0xea, 0x5d, 0x08, 0x54
.data
check_data3:
	.byte 0x1f, 0x64, 0x31, 0xe2, 0x82, 0x09, 0xde, 0xc2, 0xa2, 0x0a, 0xd7, 0x1a, 0xf8, 0x1b, 0xe1, 0xc2
	.byte 0xff, 0xf4, 0xbf, 0x82, 0x42, 0xd6, 0x81, 0x1a, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc000
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x1ff0
	/* C12 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x41d0000000000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x2000000000000040000000000000000
final_cap_values:
	/* C0 */
	.octa 0x20e8
	/* C1 */
	.octa 0xc000
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x1ff0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0xc001e004000000000000c000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x2000000000000040000000000000000
initial_csp_value:
	.octa 0xc001e004000000000001c001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000700060000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 80
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3a1b00b3 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:19 Rn:5 000000:000000 Rm:27 11010000:11010000 S:1 op:0 sf:0
	.inst 0x93d89760 // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:0 Rn:27 imms:100101 Rm:24 0:0 N:1 00100111:00100111 sf:1
	.inst 0xc2c670ab // CLRPERM-C.CI-C Cd:11 Cn:5 100:100 perm:011 1100001011000110:1100001011000110
	.inst 0x54085dea // b_cond:aarch64/instrs/branch/conditional/cond cond:1010 0:0 imm19:0000100001011101111 01010100:01010100
	.zero 68536
	.inst 0xe231641f // ALDUR-V.RI-B Rt:31 Rn:0 op2:01 imm9:100010110 V:1 op1:00 11100010:11100010
	.inst 0xc2de0982 // SEAL-C.CC-C Cd:2 Cn:12 0010:0010 opc:00 Cm:30 11000010110:11000010110
	.inst 0x1ad70aa2 // udiv:aarch64/instrs/integer/arithmetic/div Rd:2 Rn:21 o1:0 00001:00001 Rm:23 0011010110:0011010110 sf:0
	.inst 0xc2e11bf8 // CVT-C.CR-C Cd:24 Cn:31 0110:0110 0:0 0:0 Rm:1 11000010111:11000010111
	.inst 0x82bff4ff // ASTR-R.RRB-64 Rt:31 Rn:7 opc:01 S:1 option:111 Rm:31 1:1 L:0 100000101:100000101
	.inst 0x1a81d642 // csinc:aarch64/instrs/integer/conditional/select Rd:2 Rn:18 o2:1 0:0 cond:1101 Rm:1 011010100:011010100 op:0 sf:0
	.inst 0xc2c21380
	.zero 979996
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a1 // ldr c1, [x13, #0]
	.inst 0xc24005a5 // ldr c5, [x13, #1]
	.inst 0xc24009a7 // ldr c7, [x13, #2]
	.inst 0xc2400dac // ldr c12, [x13, #3]
	.inst 0xc24011b7 // ldr c23, [x13, #4]
	.inst 0xc24015b8 // ldr c24, [x13, #5]
	.inst 0xc24019bb // ldr c27, [x13, #6]
	.inst 0xc2401dbe // ldr c30, [x13, #7]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_csp_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260338d // ldr c13, [c28, #3]
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	.inst 0x8260138d // ldr c13, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x28, #0xf
	and x13, x13, x28
	cmp x13, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001bc // ldr c28, [x13, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24005bc // ldr c28, [x13, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc24009bc // ldr c28, [x13, #2]
	.inst 0xc2dca4a1 // chkeq c5, c28
	b.ne comparison_fail
	.inst 0xc2400dbc // ldr c28, [x13, #3]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc24011bc // ldr c28, [x13, #4]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc24015bc // ldr c28, [x13, #5]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc24019bc // ldr c28, [x13, #6]
	.inst 0xc2dca661 // chkeq c19, c28
	b.ne comparison_fail
	.inst 0xc2401dbc // ldr c28, [x13, #7]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc24021bc // ldr c28, [x13, #8]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc24025bc // ldr c28, [x13, #9]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc24029bc // ldr c28, [x13, #10]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x28, v31.d[0]
	cmp x13, x28
	b.ne comparison_fail
	ldr x13, =0x0
	mov x28, v31.d[1]
	cmp x13, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff0
	ldr x1, =check_data0
	ldr x2, =0x00001ff8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00410bc8
	ldr x1, =check_data3
	ldr x2, =0x00410be4
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
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
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
